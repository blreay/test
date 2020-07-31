#!/bin/bash

set -e
set -vx

ETCD_VER=v3.4.10

MYTEMP=$(pwd)/tmp
mkdir -p ${MYTEMP}

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f ${MYTEMP}/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf ${MYTEMP}/etcd-download-test && mkdir -p ${MYTEMP}/etcd-download-test

while true; do
  curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o ${MYTEMP}/etcd-${ETCD_VER}-linux-amd64.tar.gz
  [[ $? -eq 0 ]] && break || continue
done

tar xzvf ${MYTEMP}/etcd-${ETCD_VER}-linux-amd64.tar.gz -C ${MYTEMP}/etcd-download-test --strip-components=1
#rm -f ${MYTEMP}/etcd-${ETCD_VER}-linux-amd64.tar.gz

${MYTEMP}/etcd-download-test/etcd --version
${MYTEMP}/etcd-download-test/etcdctl version
# start a local etcd server
${MYTEMP}/etcd-download-test/etcd &

# write,read to etcd
${MYTEMP}/etcd-download-test/etcdctl --endpoints=localhost:2379 put foo bar
${MYTEMP}/etcd-download-test/etcdctl --endpoints=localhost:2379 get foo
