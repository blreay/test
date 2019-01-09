// Copyright 2016 go-dockerclient authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

//##############################################
// build here: /home/zhaozhan/go/src/github.com/hyperledger

package main
//package server

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"strings"
	"time"

	"archive/tar"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	mathrand "math/rand"
	"net"
	"net/http"
	libpath "path"
	"regexp"
	"strconv"
	"sync" 
	"github.com/docker/docker/api/types/swarm"
	"github.com/docker/docker/pkg/stdcopy"
	"github.com/fsouza/go-dockerclient"
	"github.com/gorilla/mux"
)

var nameRegexp = regexp.MustCompile(`^[a-zA-Z0-9][a-zA-Z0-9_.-]+$`)

// DockerServer represents a programmable, concurrent (not much), HTTP server
// implementing a fake version of the Docker remote API.
//
// It can used in standalone mode, listening for connections or as an arbitrary
// HTTP handler.
//
// For more details on the remote API, check http://goo.gl/G3plxW.
type DockerServer struct {
	containers     map[string]*docker.Container
	contNameToID   map[string]string
	uploadedFiles  map[string]string
	execs          []*docker.ExecInspect
	execMut        sync.RWMutex
	cMut           sync.RWMutex
	images         map[string]docker.Image
	iMut           sync.RWMutex
	imgIDs         map[string]string
	networks       []*docker.Network
	netMut         sync.RWMutex
	listener       net.Listener
	mux            *mux.Router
	hook           func(*http.Request)
	failures       map[string]string
	multiFailures  []map[string]string
	execCallbacks  map[string]func()
	statsCallbacks map[string]func(string) docker.Stats
	customHandlers map[string]http.Handler
	handlerMutex   sync.RWMutex
	cChan          chan<- *docker.Container
	volStore       map[string]*volumeCounter
	volMut         sync.RWMutex
	swarmMut       sync.RWMutex
	swarm          *swarm.Swarm
	swarmServer    *swarmServer
	nodes          []swarm.Node
	nodeID         string
	tasks          []*swarm.Task
	services       []*swarm.Service
	nodeRR         int
	servicePorts   int
}

type volumeCounter struct {
	volume docker.Volume
	count  int
}

func baseDockerServer() DockerServer {
	return DockerServer{
		containers:     make(map[string]*docker.Container),
		contNameToID:   make(map[string]string),
		imgIDs:         make(map[string]string),
		images:         make(map[string]docker.Image),
		failures:       make(map[string]string),
		execCallbacks:  make(map[string]func()),
		statsCallbacks: make(map[string]func(string) docker.Stats),
		customHandlers: make(map[string]http.Handler),
		uploadedFiles:  make(map[string]string),
	}
}

func buildDockerServer(listener net.Listener, containerChan chan<- *docker.Container, hook func(*http.Request)) *DockerServer {
	server := baseDockerServer()
	server.listener = listener
	server.hook = hook
	server.cChan = containerChan
	server.buildMuxer()
	return &server
}

// NewServer returns a new instance of the fake server, in standalone mode. Use
// the method URL to get the URL of the server.
//
// It receives the bind address (use 127.0.0.1:0 for getting an available port
// on the host), a channel of containers and a hook function, that will be
// called on every request.
//
// The fake server will send containers in the channel whenever the container
// changes its state, via the HTTP API (i.e.: create, start and stop). This
// channel may be nil, which means that the server won't notify on state
// changes.
func NewServer(bind string, containerChan chan<- *docker.Container, hook func(*http.Request)) (*DockerServer, error) {
	listener, err := net.Listen("tcp", bind)
	if err != nil {
		return nil, err
	}
	server := buildDockerServer(listener, containerChan, hook)
	go http.Serve(listener, server)
	return server, nil
}

// TLSConfig is the set of options to start the TLS-enabled testing server.
type TLSConfig struct {
	CertPath    string
	CertKeyPath string
	RootCAPath  string
}

// NewTLSServer creates and starts a TLS-enabled testing server.
func NewTLSServer(bind string, containerChan chan<- *docker.Container, hook func(*http.Request), tlsConfig TLSConfig) (*DockerServer, error) {
	listener, err := net.Listen("tcp", bind)
	if err != nil {
		return nil, err
	}
	defaultCertificate, err := tls.LoadX509KeyPair(tlsConfig.CertPath, tlsConfig.CertKeyPath)
	if err != nil {
		return nil, err
	}
	tlsServerConfig := new(tls.Config)
	tlsServerConfig.Certificates = []tls.Certificate{defaultCertificate}
	if tlsConfig.RootCAPath != "" {
		rootCertPEM, err := ioutil.ReadFile(tlsConfig.RootCAPath)
		if err != nil {
			return nil, err
		}
		certsPool := x509.NewCertPool()
		certsPool.AppendCertsFromPEM(rootCertPEM)
		tlsServerConfig.RootCAs = certsPool
	}
	tlsListener := tls.NewListener(listener, tlsServerConfig)
	server := buildDockerServer(tlsListener, containerChan, hook)
	go http.Serve(tlsListener, server)
	return server, nil
}

func (s *DockerServer) notify(container *docker.Container) {
	if s.cChan != nil {
		s.cChan <- container
	}
}

func (s *DockerServer) buildMuxer() {
	s.mux = mux.NewRouter()
	s.mux.Path("/commit").Methods("POST").HandlerFunc(s.handlerWrapper(s.commitContainer))
	s.mux.Path("/containers/json").Methods("GET").HandlerFunc(s.handlerWrapper(s.listContainers))
	s.mux.Path("/containers/create").Methods("POST").HandlerFunc(s.handlerWrapper(s.createContainer))
	s.mux.Path("/containers/{id:.*}/json").Methods("GET").HandlerFunc(s.handlerWrapper(s.inspectContainer))
	s.mux.Path("/containers/{id:.*}/rename").Methods("POST").HandlerFunc(s.handlerWrapper(s.renameContainer))
	s.mux.Path("/containers/{id:.*}/top").Methods("GET").HandlerFunc(s.handlerWrapper(s.topContainer))
	s.mux.Path("/containers/{id:.*}/start").Methods("POST").HandlerFunc(s.handlerWrapper(s.startContainer))
	s.mux.Path("/containers/{id:.*}/kill").Methods("POST").HandlerFunc(s.handlerWrapper(s.stopContainer))
	s.mux.Path("/containers/{id:.*}/stop").Methods("POST").HandlerFunc(s.handlerWrapper(s.stopContainer))
	s.mux.Path("/containers/{id:.*}/pause").Methods("POST").HandlerFunc(s.handlerWrapper(s.pauseContainer))
	s.mux.Path("/containers/{id:.*}/unpause").Methods("POST").HandlerFunc(s.handlerWrapper(s.unpauseContainer))
	s.mux.Path("/containers/{id:.*}/wait").Methods("POST").HandlerFunc(s.handlerWrapper(s.waitContainer))
	s.mux.Path("/containers/{id:.*}/attach").Methods("POST").HandlerFunc(s.handlerWrapper(s.attachContainer))
	s.mux.Path("/containers/{id:.*}").Methods("DELETE").HandlerFunc(s.handlerWrapper(s.removeContainer))
	s.mux.Path("/containers/{id:.*}/exec").Methods("POST").HandlerFunc(s.handlerWrapper(s.createExecContainer))
	s.mux.Path("/containers/{id:.*}/stats").Methods("GET").HandlerFunc(s.handlerWrapper(s.statsContainer))
	s.mux.Path("/containers/{id:.*}/archive").Methods("PUT").HandlerFunc(s.handlerWrapper(s.uploadToContainer))
	s.mux.Path("/containers/{id:.*}/archive").Methods("GET").HandlerFunc(s.handlerWrapper(s.downloadFromContainer))
	s.mux.Path("/containers/{id:.*}/logs").Methods("GET").HandlerFunc(s.handlerWrapper(s.logContainer))
	s.mux.Path("/exec/{id:.*}/resize").Methods("POST").HandlerFunc(s.handlerWrapper(s.resizeExecContainer))
	s.mux.Path("/exec/{id:.*}/start").Methods("POST").HandlerFunc(s.handlerWrapper(s.startExecContainer))
	s.mux.Path("/exec/{id:.*}/json").Methods("GET").HandlerFunc(s.handlerWrapper(s.inspectExecContainer))
	s.mux.Path("/images/create").Methods("POST").HandlerFunc(s.handlerWrapper(s.pullImage))
	s.mux.Path("/build").Methods("POST").HandlerFunc(s.handlerWrapper(s.buildImage))
	s.mux.Path("/images/json").Methods("GET").HandlerFunc(s.handlerWrapper(s.listImages))
	s.mux.Path("/images/{id:.*}").Methods("DELETE").HandlerFunc(s.handlerWrapper(s.removeImage))
	s.mux.Path("/images/{name:.*}/json").Methods("GET").HandlerFunc(s.handlerWrapper(s.inspectImage))
	s.mux.Path("/images/{name:.*}/push").Methods("POST").HandlerFunc(s.handlerWrapper(s.pushImage))
	s.mux.Path("/images/{name:.*}/tag").Methods("POST").HandlerFunc(s.handlerWrapper(s.tagImage))
	s.mux.Path("/events").Methods("GET").HandlerFunc(s.listEvents)
	s.mux.Path("/_ping").Methods("GET").HandlerFunc(s.handlerWrapper(s.pingDocker))
	s.mux.Path("/images/load").Methods("POST").HandlerFunc(s.handlerWrapper(s.loadImage))
	s.mux.Path("/images/{id:.*}/get").Methods("GET").HandlerFunc(s.handlerWrapper(s.getImage))
	s.mux.Path("/networks").Methods("GET").HandlerFunc(s.handlerWrapper(s.listNetworks))
	s.mux.Path("/networks/{id:.*}").Methods("GET").HandlerFunc(s.handlerWrapper(s.networkInfo))
	s.mux.Path("/networks/{id:.*}").Methods("DELETE").HandlerFunc(s.handlerWrapper(s.removeNetwork))
	s.mux.Path("/networks/create").Methods("POST").HandlerFunc(s.handlerWrapper(s.createNetwork))
	s.mux.Path("/networks/{id:.*}/connect").Methods("POST").HandlerFunc(s.handlerWrapper(s.networksConnect))
	s.mux.Path("/volumes").Methods("GET").HandlerFunc(s.handlerWrapper(s.listVolumes))
	s.mux.Path("/volumes/create").Methods("POST").HandlerFunc(s.handlerWrapper(s.createVolume))
	s.mux.Path("/volumes/{name:.*}").Methods("GET").HandlerFunc(s.handlerWrapper(s.inspectVolume))
	s.mux.Path("/volumes/{name:.*}").Methods("DELETE").HandlerFunc(s.handlerWrapper(s.removeVolume))
	s.mux.Path("/info").Methods("GET").HandlerFunc(s.handlerWrapper(s.infoDocker))
	s.mux.Path("/version").Methods("GET").HandlerFunc(s.handlerWrapper(s.versionDocker))
	s.mux.Path("/swarm/init").Methods("POST").HandlerFunc(s.handlerWrapper(s.swarmInit))
	s.mux.Path("/swarm").Methods("GET").HandlerFunc(s.handlerWrapper(s.swarmInspect))
	s.mux.Path("/swarm/join").Methods("POST").HandlerFunc(s.handlerWrapper(s.swarmJoin))
	s.mux.Path("/swarm/leave").Methods("POST").HandlerFunc(s.handlerWrapper(s.swarmLeave))
	s.mux.Path("/nodes/{id:.+}/update").Methods("POST").HandlerFunc(s.handlerWrapper(s.nodeUpdate))
	s.mux.Path("/nodes/{id:.+}").Methods("GET").HandlerFunc(s.handlerWrapper(s.nodeInspect))
	s.mux.Path("/nodes/{id:.+}").Methods("DELETE").HandlerFunc(s.handlerWrapper(s.nodeDelete))
	s.mux.Path("/nodes").Methods("GET").HandlerFunc(s.handlerWrapper(s.nodeList))
	s.mux.Path("/services/create").Methods("POST").HandlerFunc(s.handlerWrapper(s.serviceCreate))
	s.mux.Path("/services/{id:.+}").Methods("GET").HandlerFunc(s.handlerWrapper(s.serviceInspect))
	s.mux.Path("/services").Methods("GET").HandlerFunc(s.handlerWrapper(s.serviceList))
	s.mux.Path("/services/{id:.+}").Methods("DELETE").HandlerFunc(s.handlerWrapper(s.serviceDelete))
	s.mux.Path("/services/{id:.+}/update").Methods("POST").HandlerFunc(s.handlerWrapper(s.serviceUpdate))
	s.mux.Path("/tasks").Methods("GET").HandlerFunc(s.handlerWrapper(s.taskList))
	s.mux.Path("/tasks/{id:.+}").Methods("GET").HandlerFunc(s.handlerWrapper(s.taskInspect))
}

// SetHook changes the hook function used by the server.
//
// The hook function is a function called on every request.
func (s *DockerServer) SetHook(hook func(*http.Request)) {
	s.hook = hook
}

// PrepareExec adds a callback to a container exec in the fake server.
//
// This function will be called whenever the given exec id is started, and the
// given exec id will remain in the "Running" start while the function is
// running, so it's useful for emulating an exec that runs for two seconds, for
// example:
//
//    opts := docker.CreateExecOptions{
//        AttachStdin:  true,
//        AttachStdout: true,
//        AttachStderr: true,
//        Tty:          true,
//        Cmd:          []string{"/bin/bash", "-l"},
//    }
//    // Client points to a fake server.
//    exec, err := client.CreateExec(opts)
//    // handle error
//    server.PrepareExec(exec.ID, func() {time.Sleep(2 * time.Second)})
//    err = client.StartExec(exec.ID, docker.StartExecOptions{Tty: true}) // will block for 2 seconds
//    // handle error
func (s *DockerServer) PrepareExec(id string, callback func()) {
	s.execCallbacks[id] = callback
}

// PrepareStats adds a callback that will be called for each container stats
// call.
//
// This callback function will be called multiple times if stream is set to
// true when stats is called.
func (s *DockerServer) PrepareStats(id string, callback func(string) docker.Stats) {
	s.statsCallbacks[id] = callback
}

// PrepareFailure adds a new expected failure based on a URL regexp it receives
// an id for the failure.
func (s *DockerServer) PrepareFailure(id string, urlRegexp string) {
	s.failures[id] = urlRegexp
}

// PrepareMultiFailures enqueues a new expected failure based on a URL regexp
// it receives an id for the failure.
func (s *DockerServer) PrepareMultiFailures(id string, urlRegexp string) {
	s.multiFailures = append(s.multiFailures, map[string]string{"error": id, "url": urlRegexp})
}

// ResetFailure removes an expected failure identified by the given id.
func (s *DockerServer) ResetFailure(id string) {
	delete(s.failures, id)
}

// ResetMultiFailures removes all enqueued failures.
func (s *DockerServer) ResetMultiFailures() {
	s.multiFailures = []map[string]string{}
}

// CustomHandler registers a custom handler for a specific path.
//
// For example:
//
//     server.CustomHandler("/containers/json", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
//         http.Error(w, "Something wrong is not right", http.StatusInternalServerError)
//     }))
func (s *DockerServer) CustomHandler(path string, handler http.Handler) {
	s.handlerMutex.Lock()
	s.customHandlers[path] = handler
	s.handlerMutex.Unlock()
}

// MutateContainer changes the state of a container, returning an error if the
// given id does not match to any container "running" in the server.
func (s *DockerServer) MutateContainer(id string, state docker.State) error {
	s.cMut.Lock()
	defer s.cMut.Unlock()
	if container, ok := s.containers[id]; ok {
		container.State = state
		return nil
	}
	return errors.New("container not found")
}

// Stop stops the server.
func (s *DockerServer) Stop() {
	if s.listener != nil {
		s.listener.Close()
	}
	if s.swarmServer != nil {
		s.swarmServer.listener.Close()
	}
}

// URL returns the HTTP URL of the server.
func (s *DockerServer) URL() string {
	if s.listener == nil {
		return ""
	}
	return "http://" + s.listener.Addr().String() + "/"
}

// ServeHTTP handles HTTP requests sent to the server.
func (s *DockerServer) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handlerMutex.RLock()
	defer s.handlerMutex.RUnlock()
	for re, handler := range s.customHandlers {
		if m, _ := regexp.MatchString(re, r.URL.Path); m {
			handler.ServeHTTP(w, r)
			return
		}
	}
	s.mux.ServeHTTP(w, r)
	if s.hook != nil {
		s.hook(r)
	}
}

// DefaultHandler returns default http.Handler mux, it allows customHandlers to
// call the default behavior if wanted.
func (s *DockerServer) DefaultHandler() http.Handler {
	return s.mux
}

func (s *DockerServer) handlerWrapper(f http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		for errorID, urlRegexp := range s.failures {
			matched, err := regexp.MatchString(urlRegexp, r.URL.Path)
			if err != nil {
				http.Error(w, err.Error(), http.StatusBadRequest)
				return
			}
			if !matched {
				continue
			}
			http.Error(w, errorID, http.StatusBadRequest)
			return
		}
		for i, failure := range s.multiFailures {
			matched, err := regexp.MatchString(failure["url"], r.URL.Path)
			if err != nil {
				http.Error(w, err.Error(), http.StatusBadRequest)
				return
			}
			if !matched {
				continue
			}
			http.Error(w, failure["error"], http.StatusBadRequest)
			s.multiFailures = append(s.multiFailures[:i], s.multiFailures[i+1:]...)
			return
		}
		f(w, r)
	}
}

func (s *DockerServer) listContainers(w http.ResponseWriter, r *http.Request) {
	all := r.URL.Query().Get("all")
	filtersRaw := r.FormValue("filters")
	filters := make(map[string][]string)
	json.Unmarshal([]byte(filtersRaw), &filters)
	labelFilters := make(map[string]*string)
	for _, f := range filters["label"] {
		parts := strings.Split(f, "=")
		if len(parts) == 2 {
			labelFilters[parts[0]] = &parts[1]
			continue
		}
		labelFilters[parts[0]] = nil
	}
	s.cMut.RLock()
	result := make([]docker.APIContainers, 0, len(s.containers))
loop:
	for _, container := range s.containers {
		if all == "1" || container.State.Running {
			var ports []docker.APIPort
			if container.NetworkSettings != nil {
				ports = container.NetworkSettings.PortMappingAPI()
			}
			for l, fv := range labelFilters {
				lv, ok := container.Config.Labels[l]
				if !ok {
					continue loop
				}
				if fv != nil && lv != *fv {
					continue loop
				}
			}
			result = append(result, docker.APIContainers{
				ID:      container.ID,
				Image:   container.Image,
				Command: fmt.Sprintf("%s %s", container.Path, strings.Join(container.Args, " ")),
				Created: container.Created.Unix(),
				Status:  container.State.String(),
				State:   container.State.StateString(),
				Ports:   ports,
				Names:   []string{fmt.Sprintf("/%s", container.Name)},
			})
		}
	}
	s.cMut.RUnlock()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(result)
}

func (s *DockerServer) listImages(w http.ResponseWriter, r *http.Request) {
	s.cMut.RLock()
	result := make([]docker.APIImages, len(s.images))
	i := 0
	for _, image := range s.images {
		result[i] = docker.APIImages{
			ID:      image.ID,
			Created: image.Created.Unix(),
		}
		for tag, id := range s.imgIDs {
			if id == image.ID {
				result[i].RepoTags = append(result[i].RepoTags, tag)
			}
		}
		i++
	}
	s.cMut.RUnlock()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(result)
}

func (s *DockerServer) findImage(id string) (string, error) {
	s.iMut.RLock()
	defer s.iMut.RUnlock()
	image, ok := s.imgIDs[id]
	if ok {
		return image, nil
	}
	if _, ok := s.images[id]; ok {
		return id, nil
	}
	return "", errors.New("No such image")
}

func (s *DockerServer) createContainer(w http.ResponseWriter, r *http.Request) {
	var config struct {
		*docker.Config
		HostConfig *docker.HostConfig
	}
	defer r.Body.Close()
	err := json.NewDecoder(r.Body).Decode(&config)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	name := r.URL.Query().Get("name")
	if name != "" && !nameRegexp.MatchString(name) {
		http.Error(w, "Invalid container name", http.StatusInternalServerError)
		return
	}
	imageID, err := s.findImage(config.Image)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	ports := map[docker.Port][]docker.PortBinding{}
	for port := range config.ExposedPorts {
		ports[port] = []docker.PortBinding{{
			HostIP:   "0.0.0.0",
			HostPort: strconv.Itoa(mathrand.Int() % 0xffff),
		}}
	}

	//the container may not have cmd when using a Dockerfile
	var path string
	var args []string
	if len(config.Cmd) == 1 {
		path = config.Cmd[0]
	} else if len(config.Cmd) > 1 {
		path = config.Cmd[0]
		args = config.Cmd[1:]
	}

	generatedID := s.generateID()
	config.Config.Hostname = generatedID[:12]
	container := docker.Container{
		Name:       name,
		ID:         generatedID,
		Created:    time.Now(),
		Path:       path,
		Args:       args,
		Config:     config.Config,
		HostConfig: config.HostConfig,
		State: docker.State{
			Running:  false,
			Pid:      mathrand.Int() % 50000,
			ExitCode: 0,
		},
		Image: config.Image,
		NetworkSettings: &docker.NetworkSettings{
			IPAddress:   fmt.Sprintf("172.16.42.%d", mathrand.Int()%250+2),
			IPPrefixLen: 24,
			Gateway:     "172.16.42.1",
			Bridge:      "docker0",
			Ports:       ports,
		},
	}
	s.cMut.Lock()
	if val, ok := s.uploadedFiles[imageID]; ok {
		s.uploadedFiles[container.ID] = val
	}
	if container.Name != "" {
		_, err = s.findContainerWithLock(container.Name, false)
		if err == nil {
			defer s.cMut.Unlock()
			http.Error(w, "there's already a container with this name", http.StatusConflict)
			return
		}
	}
	s.addContainer(&container)
	s.cMut.Unlock()
	w.WriteHeader(http.StatusCreated)
	s.notify(&container)

	json.NewEncoder(w).Encode(container)
}

func (s *DockerServer) addContainer(container *docker.Container) {
	s.containers[container.ID] = container
	if container.Name != "" {
		s.contNameToID[container.Name] = container.ID
	}
}

func (s *DockerServer) generateID() string {
	var buf [16]byte
	rand.Read(buf[:])
	return fmt.Sprintf("%x", buf)
}

func (s *DockerServer) renameContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	s.cMut.Lock()
	defer s.cMut.Unlock()
	container, err := s.findContainerWithLock(id, false)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	delete(s.contNameToID, container.Name)
	container.Name = r.URL.Query().Get("name")
	s.contNameToID[container.Name] = container.ID
	w.WriteHeader(http.StatusNoContent)
}

func (s *DockerServer) inspectContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	container, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	s.cMut.RLock()
	defer s.cMut.RUnlock()
	json.NewEncoder(w).Encode(container)
}

func (s *DockerServer) statsContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	_, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	stream, _ := strconv.ParseBool(r.URL.Query().Get("stream"))
	callback := s.statsCallbacks[id]
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	encoder := json.NewEncoder(w)
	for {
		var stats docker.Stats
		if callback != nil {
			stats = callback(id)
		}
		encoder.Encode(stats)
		if !stream {
			break
		}
	}
}

func (s *DockerServer) uploadToContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	_, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	path := r.URL.Query().Get("path")
	if r.Body != nil {
		tr := tar.NewReader(r.Body)
		if hdr, _ := tr.Next(); hdr != nil {
			path = libpath.Join(path, hdr.Name)
		}
	}
	s.cMut.Lock()
	s.uploadedFiles[id] = path
	s.cMut.Unlock()
	w.WriteHeader(http.StatusOK)
}

func (s *DockerServer) downloadFromContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	_, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	path := r.URL.Query().Get("path")
	s.cMut.RLock()
	val, ok := s.uploadedFiles[id]
	s.cMut.RUnlock()
	if !ok || val != path {
		w.WriteHeader(http.StatusNotFound)
		fmt.Fprintf(w, "Path %s not found", path)
		return
	}
	w.Header().Set("Content-Type", "application/x-tar")
	w.WriteHeader(http.StatusOK)
}

func (s *DockerServer) topContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	container, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	s.cMut.RLock()
	defer s.cMut.RUnlock()
	if !container.State.Running {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, "Container %s is not running", id)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	result := docker.TopResult{
		Titles: []string{"UID", "PID", "PPID", "C", "STIME", "TTY", "TIME", "CMD"},
		Processes: [][]string{
			{"root", "7535", "7516", "0", "03:20", "?", "00:00:00", container.Path + " " + strings.Join(container.Args, " ")},
		},
	}
	json.NewEncoder(w).Encode(result)
}

func (s *DockerServer) startContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	container, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	s.cMut.Lock()
	defer s.cMut.Unlock()
	defer r.Body.Close()
	if container.State.Running {
		http.Error(w, "", http.StatusNotModified)
		return
	}
	var hostConfig *docker.HostConfig
	err = json.NewDecoder(r.Body).Decode(&hostConfig)
	if err != nil && err != io.EOF {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if hostConfig == nil {
		hostConfig = container.HostConfig
	} else {
		container.HostConfig = hostConfig
	}
	if hostConfig != nil && len(hostConfig.PortBindings) > 0 {
		ports := map[docker.Port][]docker.PortBinding{}
		for key, items := range hostConfig.PortBindings {
			bindings := make([]docker.PortBinding, len(items))
			for i := range items {
				binding := docker.PortBinding{
					HostIP:   items[i].HostIP,
					HostPort: items[i].HostPort,
				}
				if binding.HostIP == "" {
					binding.HostIP = "0.0.0.0"
				}
				if binding.HostPort == "" {
					binding.HostPort = strconv.Itoa(mathrand.Int() % 0xffff)
				}
				bindings[i] = binding
			}
			ports[key] = bindings
		}
		container.NetworkSettings.Ports = ports
	}
	container.State.Running = true
	container.State.StartedAt = time.Now()
	s.notify(container)
}

func (s *DockerServer) stopContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	container, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	s.cMut.Lock()
	defer s.cMut.Unlock()
	if !container.State.Running {
		http.Error(w, "Container not running", http.StatusBadRequest)
		return
	}
	w.WriteHeader(http.StatusNoContent)
	container.State.Running = false
	s.notify(container)
}

func (s *DockerServer) pauseContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	container, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	s.cMut.Lock()
	defer s.cMut.Unlock()
	if container.State.Paused {
		http.Error(w, "Container already paused", http.StatusBadRequest)
		return
	}
	w.WriteHeader(http.StatusNoContent)
	container.State.Paused = true
}

func (s *DockerServer) unpauseContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	container, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	s.cMut.Lock()
	defer s.cMut.Unlock()
	if !container.State.Paused {
		http.Error(w, "Container not paused", http.StatusBadRequest)
		return
	}
	w.WriteHeader(http.StatusNoContent)
	container.State.Paused = false
}

func (s *DockerServer) attachContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	container, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	hijacker, ok := w.(http.Hijacker)
	if !ok {
		http.Error(w, "cannot hijack connection", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/vnd.docker.raw-stream")
	w.WriteHeader(http.StatusOK)
	conn, _, err := hijacker.Hijack()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	wg := sync.WaitGroup{}
	if r.URL.Query().Get("stdin") == "1" {
		wg.Add(1)
		go func() {
			ioutil.ReadAll(conn)
			wg.Done()
		}()
	}
	outStream := stdcopy.NewStdWriter(conn, stdcopy.Stdout)
	s.cMut.RLock()
	if container.State.Running {
		fmt.Fprintf(outStream, "Container is running\n")
	} else {
		fmt.Fprintf(outStream, "Container is not running\n")
	}
	s.cMut.RUnlock()
	fmt.Fprintln(outStream, "What happened?")
	fmt.Fprintln(outStream, "Something happened")
	wg.Wait()
	if r.URL.Query().Get("stream") == "1" {
		for {
			time.Sleep(1e6)
			s.cMut.RLock()
			if !container.State.StartedAt.IsZero() && !container.State.Running {
				s.cMut.RUnlock()
				break
			}
			s.cMut.RUnlock()
		}
	}
	conn.Close()
}

func (s *DockerServer) waitContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	container, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	var exitCode int
	for {
		time.Sleep(1e6)
		s.cMut.RLock()
		if !container.State.Running {
			exitCode = container.State.ExitCode
			s.cMut.RUnlock()
			break
		}
		s.cMut.RUnlock()
	}
	result := map[string]int{"StatusCode": exitCode}
	json.NewEncoder(w).Encode(result)
}

func (s *DockerServer) removeContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	force := r.URL.Query().Get("force")
	s.cMut.Lock()
	defer s.cMut.Unlock()
	container, err := s.findContainerWithLock(id, false)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	if container.State.Running && force != "1" {
		msg := "Error: API error (406): Impossible to remove a running container, please stop it first"
		http.Error(w, msg, http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusNoContent)
	delete(s.containers, container.ID)
	delete(s.contNameToID, container.Name)
}

func (s *DockerServer) commitContainer(w http.ResponseWriter, r *http.Request) {
	id := r.URL.Query().Get("container")
	container, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	config := new(docker.Config)
	runConfig := r.URL.Query().Get("run")
	if runConfig != "" {
		err = json.Unmarshal([]byte(runConfig), config)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
	}
	w.WriteHeader(http.StatusOK)
	image := docker.Image{
		ID:        "img-" + container.ID,
		Parent:    container.Image,
		Container: container.ID,
		Comment:   r.URL.Query().Get("m"),
		Author:    r.URL.Query().Get("author"),
		Config:    config,
	}
	repository := r.URL.Query().Get("repo")
	tag := r.URL.Query().Get("tag")
	s.iMut.Lock()
	s.images[image.ID] = image
	if repository != "" {
		if tag != "" {
			repository += ":" + tag
		}
		s.imgIDs[repository] = image.ID
	}
	s.iMut.Unlock()
	s.cMut.Lock()
	if val, ok := s.uploadedFiles[container.ID]; ok {
		s.uploadedFiles[image.ID] = val
	}
	s.cMut.Unlock()
	fmt.Fprintf(w, `{"ID":%q}`, image.ID)
}

func (s *DockerServer) findContainer(idOrName string) (*docker.Container, error) {
	return s.findContainerWithLock(idOrName, true)
}

func (s *DockerServer) findContainerWithLock(idOrName string, shouldLock bool) (*docker.Container, error) {
	if shouldLock {
		s.cMut.RLock()
		defer s.cMut.RUnlock()
	}
	if contID, ok := s.contNameToID[idOrName]; ok {
		idOrName = contID
	}
	if cont, ok := s.containers[idOrName]; ok {
		return cont, nil
	}
	return nil, errors.New("No such container")
}

func (s *DockerServer) logContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	container, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "application/vnd.docker.raw-stream")
	w.WriteHeader(http.StatusOK)
	s.cMut.RLock()
	if container.State.Running {
		fmt.Fprintf(w, "Container is running\n")
	} else {
		fmt.Fprintf(w, "Container is not running\n")
	}
	s.cMut.RUnlock()
	fmt.Fprintln(w, "What happened?")
	fmt.Fprintln(w, "Something happened")
	if r.URL.Query().Get("follow") == "1" {
		for {
			time.Sleep(1e6)
			s.cMut.RLock()
			if !container.State.StartedAt.IsZero() && !container.State.Running {
				s.cMut.RUnlock()
				break
			}
			s.cMut.RUnlock()
		}
	}
}

func (s *DockerServer) buildImage(w http.ResponseWriter, r *http.Request) {
	if ct := r.Header.Get("Content-Type"); ct == "application/tar" {
		gotDockerFile := false
		tr := tar.NewReader(r.Body)
		for {
			header, err := tr.Next()
			if err != nil {
				break
			}
			if header.Name == "Dockerfile" {
				gotDockerFile = true
			}
		}
		if !gotDockerFile {
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte("miss Dockerfile"))
			return
		}
	}
	//we did not use that Dockerfile to build image cause we are a fake Docker daemon
	image := docker.Image{
		ID:      s.generateID(),
		Created: time.Now(),
	}

	query := r.URL.Query()
	repository := image.ID
	if t := query.Get("t"); t != "" {
		repository = t
	}
	s.iMut.Lock()
	s.images[image.ID] = image
	s.imgIDs[repository] = image.ID
	s.iMut.Unlock()
	w.Write([]byte(fmt.Sprintf("Successfully built %s", image.ID)))
}

func (s *DockerServer) pullImage(w http.ResponseWriter, r *http.Request) {
	fromImageName := r.URL.Query().Get("fromImage")
	tag := r.URL.Query().Get("tag")
	if fromImageName != "" {
		if tag != "" {
			separator := ":"
			if strings.HasPrefix(tag, "sha256") {
				separator = "@"
			}
			fromImageName = fmt.Sprintf("%s%s%s", fromImageName, separator, tag)
		}
	}
	image := docker.Image{
		ID:     s.generateID(),
		Config: &docker.Config{},
	}
	s.iMut.Lock()
	if _, exists := s.imgIDs[fromImageName]; fromImageName == "" || !exists {
		s.images[image.ID] = image
		if fromImageName != "" {
			s.imgIDs[fromImageName] = image.ID
		}
	}
	s.iMut.Unlock()
}

func (s *DockerServer) pushImage(w http.ResponseWriter, r *http.Request) {
	name := mux.Vars(r)["name"]
	tag := r.URL.Query().Get("tag")
	if tag != "" {
		name += ":" + tag
	}
	s.iMut.RLock()
	if _, ok := s.imgIDs[name]; !ok {
		s.iMut.RUnlock()
		http.Error(w, "No such image", http.StatusNotFound)
		return
	}
	s.iMut.RUnlock()
	fmt.Fprintln(w, "Pushing...")
	fmt.Fprintln(w, "Pushed")
}

func (s *DockerServer) tagImage(w http.ResponseWriter, r *http.Request) {
	name := mux.Vars(r)["name"]
	id, err := s.findImage(name)
	if err != nil {
		http.Error(w, "No such image", http.StatusNotFound)
		return
	}
	s.iMut.Lock()
	defer s.iMut.Unlock()
	newRepo := r.URL.Query().Get("repo")
	newTag := r.URL.Query().Get("tag")
	if newTag != "" {
		newRepo += ":" + newTag
	}
	s.imgIDs[newRepo] = id
	w.WriteHeader(http.StatusCreated)
}

func (s *DockerServer) removeImage(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	s.iMut.Lock()
	defer s.iMut.Unlock()
	var tag string
	if img, ok := s.imgIDs[id]; ok {
		id, tag = img, id
	}
	var tags []string
	for tag, taggedID := range s.imgIDs {
		if taggedID == id {
			tags = append(tags, tag)
		}
	}
	_, ok := s.images[id]
	if !ok {
		http.Error(w, "No such image", http.StatusNotFound)
		return
	}
	if tag == "" && len(tags) > 1 {
		http.Error(w, "image is referenced in multiple repositories", http.StatusConflict)
		return
	}
	w.WriteHeader(http.StatusNoContent)
	if tag == "" {
		// delete called with image ID
		for _, t := range tags {
			delete(s.imgIDs, t)
		}
		delete(s.images, id)
	} else {
		// delete called with image repository name
		delete(s.imgIDs, tag)
		if len(tags) == 1 {
			delete(s.images, id)
		}
	}
}

func (s *DockerServer) inspectImage(w http.ResponseWriter, r *http.Request) {
	name := mux.Vars(r)["name"]
	s.iMut.RLock()
	defer s.iMut.RUnlock()
	if id, ok := s.imgIDs[name]; ok {
		name = id
	}
	img, ok := s.images[name]
	if !ok {
		http.Error(w, "not found", http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(img)
}

func (s *DockerServer) listEvents(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	var events [][]byte
	count := mathrand.Intn(20)
	for i := 0; i < count; i++ {
		data, err := json.Marshal(s.generateEvent())
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		events = append(events, data)
	}
	w.WriteHeader(http.StatusOK)
	for _, d := range events {
		fmt.Fprintln(w, d)
		time.Sleep(time.Duration(mathrand.Intn(200)) * time.Millisecond)
	}
}

func (s *DockerServer) pingDocker(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func (s *DockerServer) generateEvent() *docker.APIEvents {
	var eventType string
	switch mathrand.Intn(4) {
	case 0:
		eventType = "create"
	case 1:
		eventType = "start"
	case 2:
		eventType = "stop"
	case 3:
		eventType = "destroy"
	}
	return &docker.APIEvents{
		ID:     s.generateID(),
		Status: eventType,
		From:   "mybase:latest",
		Time:   time.Now().Unix(),
	}
}

func (s *DockerServer) loadImage(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func (s *DockerServer) getImage(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Header().Set("Content-Type", "application/tar")
}

func (s *DockerServer) createExecContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	container, err := s.findContainer(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}

	execID := s.generateID()
	s.cMut.Lock()
	container.ExecIDs = append(container.ExecIDs, execID)
	s.cMut.Unlock()

	exec := docker.ExecInspect{
		ID:          execID,
		ContainerID: container.ID,
	}

	var params docker.CreateExecOptions
	err = json.NewDecoder(r.Body).Decode(&params)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if len(params.Cmd) > 0 {
		exec.ProcessConfig.EntryPoint = params.Cmd[0]
		if len(params.Cmd) > 1 {
			exec.ProcessConfig.Arguments = params.Cmd[1:]
		}
	}

	exec.ProcessConfig.User = params.User
	exec.ProcessConfig.Tty = params.Tty

	s.execMut.Lock()
	s.execs = append(s.execs, &exec)
	s.execMut.Unlock()
	w.WriteHeader(http.StatusOK)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"Id": exec.ID})
}

func (s *DockerServer) startExecContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	if exec, err := s.getExec(id, false); err == nil {
		s.execMut.Lock()
		exec.Running = true
		s.execMut.Unlock()
		if callback, ok := s.execCallbacks[id]; ok {
			callback()
			delete(s.execCallbacks, id)
		} else if callback, ok := s.execCallbacks["*"]; ok {
			callback()
			delete(s.execCallbacks, "*")
		}
		s.execMut.Lock()
		exec.Running = false
		s.execMut.Unlock()
		w.WriteHeader(http.StatusOK)
		return
	}
	w.WriteHeader(http.StatusNotFound)
}

func (s *DockerServer) resizeExecContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	if _, err := s.getExec(id, false); err == nil {
		w.WriteHeader(http.StatusOK)
		return
	}
	w.WriteHeader(http.StatusNotFound)
}

func (s *DockerServer) inspectExecContainer(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	if exec, err := s.getExec(id, true); err == nil {
		w.WriteHeader(http.StatusOK)
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(exec)
		return
	}
	w.WriteHeader(http.StatusNotFound)
}

func (s *DockerServer) getExec(id string, copy bool) (*docker.ExecInspect, error) {
	s.execMut.RLock()
	defer s.execMut.RUnlock()
	for _, exec := range s.execs {
		if exec.ID == id {
			if copy {
				cp := *exec
				exec = &cp
			}
			return exec, nil
		}
	}
	return nil, errors.New("exec not found")
}

func (s *DockerServer) findNetwork(idOrName string) (*docker.Network, int, error) {
	s.netMut.RLock()
	defer s.netMut.RUnlock()
	for i, network := range s.networks {
		if network.ID == idOrName || network.Name == idOrName {
			return network, i, nil
		}
	}
	return nil, -1, errors.New("No such network")
}

func (s *DockerServer) listNetworks(w http.ResponseWriter, r *http.Request) {
	s.netMut.RLock()
	result := make([]docker.Network, 0, len(s.networks))
	for _, network := range s.networks {
		result = append(result, *network)
	}
	s.netMut.RUnlock()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(result)
}

func (s *DockerServer) networkInfo(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	network, _, err := s.findNetwork(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(network)
}

// isValidName validates configuration objects supported by libnetwork
func isValidName(name string) bool {
	if name == "" || strings.Contains(name, ".") {
		return false
	}
	return true
}

func (s *DockerServer) createNetwork(w http.ResponseWriter, r *http.Request) {
	var config *docker.CreateNetworkOptions
	defer r.Body.Close()
	err := json.NewDecoder(r.Body).Decode(&config)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	if !isValidName(config.Name) {
		http.Error(w, "Invalid network name", http.StatusBadRequest)
		return
	}
	if n, _, _ := s.findNetwork(config.Name); n != nil {
		http.Error(w, "network already exists", http.StatusForbidden)
		return
	}

	generatedID := s.generateID()
	network := docker.Network{
		Name:       config.Name,
		ID:         generatedID,
		Driver:     config.Driver,
		Containers: map[string]docker.Endpoint{},
	}
	s.netMut.Lock()
	s.networks = append(s.networks, &network)
	s.netMut.Unlock()
	w.WriteHeader(http.StatusCreated)
	var c = struct{ ID string }{ID: network.ID}
	json.NewEncoder(w).Encode(c)
}

func (s *DockerServer) removeNetwork(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	_, index, err := s.findNetwork(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	s.netMut.Lock()
	defer s.netMut.Unlock()
	s.networks[index] = s.networks[len(s.networks)-1]
	s.networks = s.networks[:len(s.networks)-1]
	w.WriteHeader(http.StatusNoContent)
}

func (s *DockerServer) networksConnect(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	var config *docker.NetworkConnectionOptions
	defer r.Body.Close()
	err := json.NewDecoder(r.Body).Decode(&config)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	network, index, _ := s.findNetwork(id)
	container, _ := s.findContainer(config.Container)
	if network == nil || container == nil {
		http.Error(w, "network or container not found", http.StatusNotFound)
		return
	}

	if _, found := network.Containers[container.ID]; found == true {
		http.Error(w, "endpoint already exists in network", http.StatusBadRequest)
		return
	}

	s.netMut.Lock()
	s.networks[index].Containers[config.Container] = docker.Endpoint{}
	s.netMut.Unlock()

	w.WriteHeader(http.StatusOK)
}

func (s *DockerServer) listVolumes(w http.ResponseWriter, r *http.Request) {
	s.volMut.RLock()
	result := make([]docker.Volume, 0, len(s.volStore))
	for _, volumeCounter := range s.volStore {
		result = append(result, volumeCounter.volume)
	}
	s.volMut.RUnlock()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string][]docker.Volume{"Volumes": result})
}

func (s *DockerServer) createVolume(w http.ResponseWriter, r *http.Request) {
	var data struct {
		*docker.CreateVolumeOptions
	}
	defer r.Body.Close()
	err := json.NewDecoder(r.Body).Decode(&data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	volume := &docker.Volume{
		Name:   data.CreateVolumeOptions.Name,
		Driver: data.CreateVolumeOptions.Driver,
	}
	// If the name is not specified, generate one.  Just using generateID for now
	if len(volume.Name) == 0 {
		volume.Name = s.generateID()
	}
	// If driver is not specified, use local
	if len(volume.Driver) == 0 {
		volume.Driver = "local"
	}
	// Mount point is a default one with name
	volume.Mountpoint = "/var/lib/docker/volumes/" + volume.Name

	// If the volume already exists, don't re-add it.
	exists := false
	s.volMut.Lock()
	if s.volStore != nil {
		_, exists = s.volStore[volume.Name]
	} else {
		// No volumes, create volStore
		s.volStore = make(map[string]*volumeCounter)
	}
	if !exists {
		s.volStore[volume.Name] = &volumeCounter{
			volume: *volume,
			count:  0,
		}
	}
	s.volMut.Unlock()
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(volume)
}

func (s *DockerServer) inspectVolume(w http.ResponseWriter, r *http.Request) {
	s.volMut.RLock()
	defer s.volMut.RUnlock()
	name := mux.Vars(r)["name"]
	vol, err := s.findVolume(name)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(vol.volume)
}

func (s *DockerServer) findVolume(name string) (*volumeCounter, error) {
	vol, ok := s.volStore[name]
	if !ok {
		return nil, errors.New("no such volume")
	}
	return vol, nil
}

func (s *DockerServer) removeVolume(w http.ResponseWriter, r *http.Request) {
	s.volMut.Lock()
	defer s.volMut.Unlock()
	name := mux.Vars(r)["name"]
	vol, err := s.findVolume(name)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	if vol.count != 0 {
		http.Error(w, "volume in use and cannot be removed", http.StatusConflict)
		return
	}
	delete(s.volStore, vol.volume.Name)
	w.WriteHeader(http.StatusNoContent)
}

func (s *DockerServer) infoDocker(w http.ResponseWriter, r *http.Request) {
	s.cMut.RLock()
	defer s.cMut.RUnlock()
	s.iMut.RLock()
	defer s.iMut.RUnlock()
	var running, stopped, paused int
	for _, c := range s.containers {
		if c.State.Running {
			running++
		} else {
			stopped++
		}
		if c.State.Paused {
			paused++
		}
	}
	var swarmInfo *swarm.Info
	if s.swarm != nil {
		swarmInfo = &swarm.Info{
			NodeID: s.nodeID,
		}
		for _, n := range s.nodes {
			swarmInfo.RemoteManagers = append(swarmInfo.RemoteManagers, swarm.Peer{
				NodeID: n.ID,
				Addr:   n.ManagerStatus.Addr,
			})
		}
	}
	envs := map[string]interface{}{
		"ID":                "AAAA:XXXX:0000:BBBB:AAAA:XXXX:0000:BBBB:AAAA:XXXX:0000:BBBB",
		"Containers":        len(s.containers),
		"ContainersRunning": running,
		"ContainersPaused":  paused,
		"ContainersStopped": stopped,
		"Images":            len(s.images),
		"Driver":            "aufs",
		"DriverStatus":      [][]string{},
		"SystemStatus":      nil,
		"Plugins": map[string]interface{}{
			"Volume": []string{
				"local",
			},
			"Network": []string{
				"bridge",
				"null",
				"host",
			},
			"Authorization": nil,
		},
		"MemoryLimit":        true,
		"SwapLimit":          false,
		"CpuCfsPeriod":       true,
		"CpuCfsQuota":        true,
		"CPUShares":          true,
		"CPUSet":             true,
		"IPv4Forwarding":     true,
		"BridgeNfIptables":   true,
		"BridgeNfIp6tables":  true,
		"Debug":              false,
		"NFd":                79,
		"OomKillDisable":     true,
		"NGoroutines":        101,
		"SystemTime":         "2016-02-25T18:13:10.25870078Z",
		"ExecutionDriver":    "native-0.2",
		"LoggingDriver":      "json-file",
		"NEventsListener":    0,
		"KernelVersion":      "3.13.0-77-generic",
		"OperatingSystem":    "Ubuntu 14.04.3 LTS",
		"OSType":             "linux",
		"Architecture":       "x86_64",
		"IndexServerAddress": "https://index.docker.io/v1/",
		"RegistryConfig": map[string]interface{}{
			"InsecureRegistryCIDRs": []string{},
			"IndexConfigs":          map[string]interface{}{},
			"Mirrors":               nil,
		},
		"InitSha1":          "e2042dbb0fcf49bb9da199186d9a5063cda92a01",
		"InitPath":          "/usr/lib/docker/dockerinit",
		"NCPU":              1,
		"MemTotal":          2099204096,
		"DockerRootDir":     "/var/lib/docker",
		"HttpProxy":         "",
		"HttpsProxy":        "",
		"NoProxy":           "",
		"Name":              "vagrant-ubuntu-trusty-64",
		"Labels":            nil,
		"ExperimentalBuild": false,
		"ServerVersion":     "1.10.1",
		"ClusterStore":      "",
		"ClusterAdvertise":  "",
		"Swarm":             swarmInfo,
	}
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(envs)
}

func (s *DockerServer) versionDocker(w http.ResponseWriter, r *http.Request) {
	envs := map[string]interface{}{
		"Version":       "1.10.1",
		"Os":            "linux",
		"KernelVersion": "3.13.0-77-generic",
		"GoVersion":     "go1.4.2",
		"GitCommit":     "9e83765",
		"Arch":          "amd64",
		"ApiVersion":    "1.22",
		"BuildTime":     "2015-12-01T07:09:13.444803460+00:00",
		"Experimental":  false,
	}
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(envs)
}

// SwarmAddress returns the address if there's a fake swarm server enabled.
func (s *DockerServer) SwarmAddress() string {
	if s.swarmServer == nil {
		return ""
	}
	return s.swarmServer.listener.Addr().String()
}

func (s *DockerServer) initSwarmNode(listenAddr, advertiseAddr string) (swarm.Node, error) {
	_, portPart, _ := net.SplitHostPort(listenAddr)
	if portPart == "" {
		portPart = "0"
	}
	var err error
	s.swarmServer, err = newSwarmServer(s, fmt.Sprintf("127.0.0.1:%s", portPart))
	if err != nil {
		return swarm.Node{}, err
	}
	if advertiseAddr == "" {
		advertiseAddr = s.SwarmAddress()
	}
	hostPart, portPart, err := net.SplitHostPort(advertiseAddr)
	if err != nil {
		hostPart = advertiseAddr
	}
	if portPart == "" || portPart == "0" {
		_, portPart, _ = net.SplitHostPort(s.SwarmAddress())
	}
	s.nodeID = s.generateID()
	return swarm.Node{
		ID: s.nodeID,
		Status: swarm.NodeStatus{
			Addr:  hostPart,
			State: swarm.NodeStateReady,
		},
		ManagerStatus: &swarm.ManagerStatus{
			Addr: fmt.Sprintf("%s:%s", hostPart, portPart),
		},
	}, nil
}

type swarmServer struct {
	srv      *DockerServer
	mux      *mux.Router
	listener net.Listener
}

func newSwarmServer(srv *DockerServer, bind string) (*swarmServer, error) {
	listener, err := net.Listen("tcp", bind)
	if err != nil {
		return nil, err
	}
	router := mux.NewRouter()
	router.Path("/internal/updatenodes").Methods("POST").HandlerFunc(srv.handlerWrapper(srv.internalUpdateNodes))
	server := &swarmServer{
		listener: listener,
		mux:      router,
		srv:      srv,
	}
	go http.Serve(listener, router)
	return server, nil
}

func (s *swarmServer) URL() string {
	if s.listener == nil {
		return ""
	}
	return "http://" + s.listener.Addr().String() + "/"
}

// MutateTask changes a task, returning an error if the given id does not match
// to any task in the server.
func (s *DockerServer) MutateTask(id string, newTask swarm.Task) error {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	for i, task := range s.tasks {
		if task.ID == id {
			s.tasks[i] = &newTask
			return nil
		}
	}
	return errors.New("task not found")
}

func (s *DockerServer) swarmInit(w http.ResponseWriter, r *http.Request) {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	if s.swarm != nil {
		w.WriteHeader(http.StatusNotAcceptable)
		return
	}
	var req swarm.InitRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil && err != io.EOF {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	node, err := s.initSwarmNode(req.ListenAddr, req.AdvertiseAddr)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	node.ManagerStatus.Leader = true
	err = s.runNodeOperation(s.swarmServer.URL(), nodeOperation{
		Op:   "add",
		Node: node,
	})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	s.swarm = &swarm.Swarm{
		JoinTokens: swarm.JoinTokens{
			Manager: s.generateID(),
			Worker:  s.generateID(),
		},
	}
	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(s.nodeID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func (s *DockerServer) swarmInspect(w http.ResponseWriter, r *http.Request) {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	if s.swarm == nil {
		w.WriteHeader(http.StatusNotAcceptable)
	} else {
		w.WriteHeader(http.StatusOK)
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(s.swarm)
	}
}

func (s *DockerServer) swarmJoin(w http.ResponseWriter, r *http.Request) {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	if s.swarm != nil {
		w.WriteHeader(http.StatusNotAcceptable)
		return
	}
	var req swarm.JoinRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if len(req.RemoteAddrs) == 0 {
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	node, err := s.initSwarmNode(req.ListenAddr, req.AdvertiseAddr)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	s.swarm = &swarm.Swarm{
		JoinTokens: swarm.JoinTokens{
			Manager: s.generateID(),
			Worker:  s.generateID(),
		},
	}
	s.swarmMut.Unlock()
	err = s.runNodeOperation(fmt.Sprintf("http://%s", req.RemoteAddrs[0]), nodeOperation{
		Op:        "add",
		Node:      node,
		forceLock: true,
	})
	s.swarmMut.Lock()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusOK)
}

func (s *DockerServer) swarmLeave(w http.ResponseWriter, r *http.Request) {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	if s.swarm == nil {
		w.WriteHeader(http.StatusNotAcceptable)
	} else {
		s.swarmServer.listener.Close()
		s.swarm = nil
		s.nodes = nil
		s.swarmServer = nil
		s.nodeID = ""
		w.WriteHeader(http.StatusOK)
	}
}

func (s *DockerServer) containerForService(srv *swarm.Service, name string) *docker.Container {
	hostConfig := docker.HostConfig{}
	dockerConfig := docker.Config{
		Entrypoint: srv.Spec.TaskTemplate.ContainerSpec.Command,
		Cmd:        srv.Spec.TaskTemplate.ContainerSpec.Args,
		Env:        srv.Spec.TaskTemplate.ContainerSpec.Env,
	}
	return &docker.Container{
		ID:         s.generateID(),
		Name:       name,
		Image:      srv.Spec.TaskTemplate.ContainerSpec.Image,
		Created:    time.Now(),
		Config:     &dockerConfig,
		HostConfig: &hostConfig,
		State: docker.State{
			Running:   true,
			StartedAt: time.Now(),
			Pid:       mathrand.Int() % 50000,
			ExitCode:  0,
		},
	}
}

func (s *DockerServer) serviceCreate(w http.ResponseWriter, r *http.Request) {
	var config swarm.ServiceSpec
	defer r.Body.Close()
	err := json.NewDecoder(r.Body).Decode(&config)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	s.cMut.Lock()
	defer s.cMut.Unlock()
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	if len(s.nodes) == 0 || s.swarm == nil {
		http.Error(w, "no swarm nodes available", http.StatusNotAcceptable)
		return
	}
	if config.Name == "" {
		config.Name = s.generateID()
	}
	for _, s := range s.services {
		if s.Spec.Name == config.Name {
			http.Error(w, "there's already a service with this name", http.StatusConflict)
			return
		}
	}
	service := swarm.Service{
		ID:   s.generateID(),
		Spec: config,
	}
	s.setServiceEndpoint(&service)
	s.addTasks(&service, false)
	s.services = append(s.services, &service)
	err = s.runNodeOperation(s.swarmServer.URL(), nodeOperation{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(service)
}

func (s *DockerServer) setServiceEndpoint(service *swarm.Service) {
	if service.Spec.EndpointSpec == nil {
		return
	}
	service.Endpoint = swarm.Endpoint{
		Spec: *service.Spec.EndpointSpec,
	}
	for _, port := range service.Spec.EndpointSpec.Ports {
		if port.PublishedPort == 0 {
			port.PublishedPort = uint32(30000 + s.servicePorts)
			s.servicePorts++
		}
		service.Endpoint.Ports = append(service.Endpoint.Ports, port)
	}
}

func (s *DockerServer) addTasks(service *swarm.Service, update bool) {
	if service.Spec.TaskTemplate.ContainerSpec == nil {
		return
	}
	containerCount := 1
	if service.Spec.Mode.Global != nil {
		containerCount = len(s.nodes)
	} else if repl := service.Spec.Mode.Replicated; repl != nil {
		if repl.Replicas != nil {
			containerCount = int(*repl.Replicas)
		}
	}
	for i := 0; i < containerCount; i++ {
		name := fmt.Sprintf("%s-%d", service.Spec.Name, i)
		if update {
			name = fmt.Sprintf("%s-%d-updated", service.Spec.Name, i)
		}
		container := s.containerForService(service, name)
		chosenNode := s.nodes[s.nodeRR]
		s.nodeRR = (s.nodeRR + 1) % len(s.nodes)
		task := swarm.Task{
			ID:        s.generateID(),
			ServiceID: service.ID,
			NodeID:    chosenNode.ID,
			Status: swarm.TaskStatus{
				State: swarm.TaskStateReady,
				ContainerStatus: &swarm.ContainerStatus{
					ContainerID: container.ID,
				},
			},
			DesiredState: swarm.TaskStateReady,
			Spec:         service.Spec.TaskTemplate,
		}
		s.tasks = append(s.tasks, &task)
		s.addContainer(container)
		s.notify(container)
	}
}

func (s *DockerServer) serviceInspect(w http.ResponseWriter, r *http.Request) {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	if s.swarm == nil {
		w.WriteHeader(http.StatusNotAcceptable)
		return
	}
	id := mux.Vars(r)["id"]
	for _, srv := range s.services {
		if srv.ID == id || srv.Spec.Name == id {
			json.NewEncoder(w).Encode(srv)
			return
		}
	}
	http.Error(w, "service not found", http.StatusNotFound)
}

func (s *DockerServer) taskInspect(w http.ResponseWriter, r *http.Request) {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	if s.swarm == nil {
		w.WriteHeader(http.StatusNotAcceptable)
		return
	}
	id := mux.Vars(r)["id"]
	for _, task := range s.tasks {
		if task.ID == id {
			json.NewEncoder(w).Encode(task)
			return
		}
	}
	http.Error(w, "task not found", http.StatusNotFound)
}

func (s *DockerServer) serviceList(w http.ResponseWriter, r *http.Request) {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	if s.swarm == nil {
		w.WriteHeader(http.StatusNotAcceptable)
		return
	}
	filtersRaw := r.FormValue("filters")
	var filters map[string][]string
	json.Unmarshal([]byte(filtersRaw), &filters)
	if filters == nil {
		json.NewEncoder(w).Encode(s.services)
		return
	}
	var ret []*swarm.Service
	for i, srv := range s.services {
		if inFilter(filters["id"], srv.ID) &&
			inFilter(filters["name"], srv.Spec.Name) {
			ret = append(ret, s.services[i])
		}
	}
	json.NewEncoder(w).Encode(ret)
}

func (s *DockerServer) taskList(w http.ResponseWriter, r *http.Request) {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	if s.swarm == nil {
		w.WriteHeader(http.StatusNotAcceptable)
		return
	}
	filtersRaw := r.FormValue("filters")
	var filters map[string][]string
	json.Unmarshal([]byte(filtersRaw), &filters)
	if filters == nil {
		json.NewEncoder(w).Encode(s.tasks)
		return
	}
	var ret []*swarm.Task
	for i, task := range s.tasks {
		var srv *swarm.Service
		for _, srv = range s.services {
			if task.ServiceID == srv.ID {
				break
			}
		}
		if srv == nil {
			http.Error(w, "service not found", http.StatusNotFound)
			return
		}
		if inFilter(filters["id"], task.ID) &&
			(inFilter(filters["service"], task.ServiceID) ||
				inFilter(filters["service"], srv.Spec.Annotations.Name)) &&
			inFilter(filters["node"], task.NodeID) &&
			inFilter(filters["desired-state"], string(task.DesiredState)) &&
			inLabelFilter(filters["label"], srv.Spec.Annotations.Labels) {
			ret = append(ret, s.tasks[i])
		}
	}
	json.NewEncoder(w).Encode(ret)
}

func inLabelFilter(list []string, labels map[string]string) bool {
	if len(list) == 0 {
		return true
	}
	for _, item := range list {
		parts := strings.Split(item, "=")
		key := parts[0]
		if val, ok := labels[key]; ok {
			if len(parts) > 1 && val != parts[1] {
				continue
			}
			return true
		}
	}
	return false
}

func inFilter(list []string, wanted string) bool {
	if len(list) == 0 {
		return true
	}
	for _, item := range list {
		if item == wanted {
			return true
		}
	}
	return false
}

func (s *DockerServer) serviceDelete(w http.ResponseWriter, r *http.Request) {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	s.cMut.Lock()
	defer s.cMut.Unlock()
	if s.swarm == nil {
		w.WriteHeader(http.StatusNotAcceptable)
		return
	}
	id := mux.Vars(r)["id"]
	var i int
	var toDelete *swarm.Service
	for i = range s.services {
		if s.services[i].ID == id || s.services[i].Spec.Name == id {
			toDelete = s.services[i]
			break
		}
	}
	if toDelete == nil {
		http.Error(w, "service not found", http.StatusNotFound)
		return
	}
	s.services[i] = s.services[len(s.services)-1]
	s.services = s.services[:len(s.services)-1]
	for i := 0; i < len(s.tasks); i++ {
		if s.tasks[i].ServiceID == toDelete.ID {
			cont, _ := s.findContainerWithLock(s.tasks[i].Status.ContainerStatus.ContainerID, false)
			if cont != nil {
				delete(s.containers, cont.ID)
				delete(s.contNameToID, cont.Name)
			}
			s.tasks = append(s.tasks[:i], s.tasks[i+1:]...)
			i--
		}
	}
	err := s.runNodeOperation(s.swarmServer.URL(), nodeOperation{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func (s *DockerServer) serviceUpdate(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	s.cMut.Lock()
	defer s.cMut.Unlock()
	if s.swarm == nil {
		w.WriteHeader(http.StatusNotAcceptable)
		return
	}
	id := mux.Vars(r)["id"]
	var toUpdate *swarm.Service
	for i := range s.services {
		if s.services[i].ID == id || s.services[i].Spec.Name == id {
			toUpdate = s.services[i]
			break
		}
	}
	if toUpdate == nil {
		http.Error(w, "service not found", http.StatusNotFound)
		return
	}
	var newSpec swarm.ServiceSpec
	err := json.NewDecoder(r.Body).Decode(&newSpec)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	toUpdate.Spec = newSpec
	end := time.Now()
	toUpdate.UpdateStatus = &swarm.UpdateStatus{
		State:       swarm.UpdateStateCompleted,
		CompletedAt: &end,
		StartedAt:   &start,
	}
	s.setServiceEndpoint(toUpdate)
	for i := 0; i < len(s.tasks); i++ {
		if s.tasks[i].ServiceID != toUpdate.ID {
			continue
		}
		cont, _ := s.findContainerWithLock(s.tasks[i].Status.ContainerStatus.ContainerID, false)
		if cont != nil {
			delete(s.containers, cont.ID)
			delete(s.contNameToID, cont.Name)
		}
		s.tasks = append(s.tasks[:i], s.tasks[i+1:]...)
		i--
	}
	s.addTasks(toUpdate, true)
	err = s.runNodeOperation(s.swarmServer.URL(), nodeOperation{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func (s *DockerServer) nodeUpdate(w http.ResponseWriter, r *http.Request) {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	if s.swarm == nil {
		w.WriteHeader(http.StatusNotAcceptable)
		return
	}
	id := mux.Vars(r)["id"]
	var n *swarm.Node
	for i := range s.nodes {
		if s.nodes[i].ID == id {
			n = &s.nodes[i]
			break
		}
	}
	if n == nil {
		w.WriteHeader(http.StatusNotFound)
		return
	}
	var spec swarm.NodeSpec
	err := json.NewDecoder(r.Body).Decode(&spec)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	n.Spec = spec
	err = s.runNodeOperation(s.swarmServer.URL(), nodeOperation{
		Op:   "update",
		Node: *n,
	})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func (s *DockerServer) nodeDelete(w http.ResponseWriter, r *http.Request) {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	if s.swarm == nil {
		w.WriteHeader(http.StatusNotAcceptable)
		return
	}
	id := mux.Vars(r)["id"]
	err := s.runNodeOperation(s.swarmServer.URL(), nodeOperation{
		Op: "delete",
		Node: swarm.Node{
			ID: id,
		},
	})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func (s *DockerServer) nodeInspect(w http.ResponseWriter, r *http.Request) {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	if s.swarm == nil {
		w.WriteHeader(http.StatusNotAcceptable)
		return
	}
	id := mux.Vars(r)["id"]
	for _, n := range s.nodes {
		if n.ID == id {
			err := json.NewEncoder(w).Encode(n)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}
			return
		}
	}
	w.WriteHeader(http.StatusNotFound)
}

func (s *DockerServer) nodeList(w http.ResponseWriter, r *http.Request) {
	s.swarmMut.Lock()
	defer s.swarmMut.Unlock()
	if s.swarm == nil {
		w.WriteHeader(http.StatusNotAcceptable)
		return
	}
	err := json.NewEncoder(w).Encode(s.nodes)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

type nodeOperation struct {
	Op        string
	Node      swarm.Node
	Tasks     []*swarm.Task
	Services  []*swarm.Service
	forceLock bool
}

func (s *DockerServer) runNodeOperation(dst string, nodeOp nodeOperation) error {
	data, err := json.Marshal(nodeOp)
	if err != nil {
		return err
	}
	url := fmt.Sprintf("%s/internal/updatenodes", strings.TrimRight(dst, "/"))
	if nodeOp.forceLock {
		url += "?forcelock=1"
	}
	rsp, err := http.Post(url, "application/json", bytes.NewReader(data))
	if err != nil {
		return err
	}
	if rsp.StatusCode != http.StatusOK {
		return fmt.Errorf("unexpected status code in updatenodes: %d", rsp.StatusCode)
	}
	return json.NewDecoder(rsp.Body).Decode(&s.nodes)
}

func (s *DockerServer) internalUpdateNodes(w http.ResponseWriter, r *http.Request) {
	propagate := r.URL.Query().Get("propagate") != "0"
	if !propagate || r.URL.Query().Get("forcelock") != "" {
		s.swarmMut.Lock()
		defer s.swarmMut.Unlock()
	}
	data, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	var nodeOp nodeOperation
	err = json.Unmarshal(data, &nodeOp)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	switch nodeOp.Op {
	case "add":
		s.nodes = append(s.nodes, nodeOp.Node)
	case "update":
		for i, n := range s.nodes {
			if n.ID == nodeOp.Node.ID {
				s.nodes[i] = nodeOp.Node
				break
			}
		}
	case "delete":
		for i, n := range s.nodes {
			if n.ID == nodeOp.Node.ID {
				s.nodes = append(s.nodes[:i], s.nodes[i+1:]...)
				break
			}
		}
	}
	if propagate {
		nodeOp.Services = s.services
		nodeOp.Tasks = s.tasks
		data, _ = json.Marshal(nodeOp)
		for _, node := range s.nodes {
			if s.nodeID == node.ID {
				continue
			}
			url := fmt.Sprintf("http://%s/internal/updatenodes?propagate=0", node.ManagerStatus.Addr)
			_, err = http.Post(url, "application/json", bytes.NewReader(data))
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
		}
	}
	if nodeOp.Services != nil {
		s.services = nodeOp.Services
	}
	if nodeOp.Tasks != nil {
		s.tasks = nodeOp.Tasks
	}
	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(s.nodes)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func main() {
	fmt.Println("test");
	//DockerServer s;
	//error e:
	s,e := NewServer("127.0.0.1:3002", nil, nil);
	fmt.Println("s:%x", s);
	fmt.Println("s:%x", e);
	s1,e1:=newSwarmServer(s, "127.0.0.1:3003");
	fmt.Println("s:%x", s1);
	fmt.Println("s:%x", e1);

	endpoint := "unix:///var/run/docker.sock"
	client, err := docker.NewClient(endpoint)
	if err != nil {
		panic(err)
	}
	imgs, err := client.ListImages(docker.ListImagesOptions{All: false})
	if err != nil {
		panic(err)
	}
	for _, img := range imgs {
		fmt.Println("ID: ", img.ID)
		fmt.Println("RepoTags: ", img.RepoTags)
		fmt.Println("Created: ", img.Created)
		fmt.Println("Size: ", img.Size)
		fmt.Println("VirtualSize: ", img.VirtualSize)
		fmt.Println("ParentId: ", img.ParentID)
	}
	fmt.Println("======================================================");
	opts := docker.CreateServiceOptions{
		Auth: docker.AuthConfiguration{},
		ServiceSpec: swarm.ServiceSpec {
			TaskTemplate: swarm.TaskSpec {
				ContainerSpec: &swarm.ContainerSpec{
					Image: "oraclelinux",
					Command: []string{"bash", "-c", "sleep 999998"},
					},
				Networks: []swarm.NetworkAttachmentConfig{swarm.NetworkAttachmentConfig{Target: "test0_net1"}},
		},
	}}
	service, err := client.CreateService(opts)
	if err != nil {
		panic(err)
	}
	fmt.Println("service:%x", service);
	fmt.Println("ID: ", service.ID)
	fmt.Println("Spec: ", service.Spec)

	svcs, err := client.ListServices(docker.ListServicesOptions{})
	if err != nil {
		panic(err)
	}
/*
type Service struct {
    ID  string
    Meta
    Spec         ServiceSpec   `json:",omitempty"`
    PreviousSpec *ServiceSpec  `json:",omitempty"`
    Endpoint     Endpoint      `json:",omitempty"`
    UpdateStatus *UpdateStatus `json:",omitempty"`
}
*/
	for _, svc := range svcs {
		fmt.Println("ID: ", svc.ID)
		fmt.Println("Spec: ", svc.Spec)
		for _, net:=range svc.Spec.TaskTemplate.Networks {
			fmt.Println("network: ", net)
		}
	}
	
}
