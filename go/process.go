package main

import "fmt"
import "strings"
import "path/filepath"
import "io/ioutil"
import "os/exec"
import "os"

func main() {
    //我们将从一个简单的命令开始，没有参数或者输入，仅打印一些信息到标准输出流。exec.Command 函数帮助我们创建一个表示这个外部进程的对象。
    dateCmd := exec.Command("date")
    //.Output 是另一个帮助我们处理运行一个命令的常见情况的函数，它等待命令运行完成，并收集命令的输出。如果没有出错，dateOut 将获取到日期信息的字节。
    dateOut, err := dateCmd.Output()
    if err != nil {
        panic(err)
    }
    fmt.Println("> date")
    fmt.Println(string(dateOut))
    //下面我们将看看一个稍复杂的例子，我们将从外部进程的stdin 输入数据并从 stdout 收集结果。
    grepCmd := exec.Command("grep", "hello")
    //这里我们明确的获取输入/输出管道，运行这个进程，写入一些输入信息，读取输出的结果，最后等待程序运行结束。
    grepIn, _ := grepCmd.StdinPipe()
    grepOut, _ := grepCmd.StdoutPipe()
    grepCmd.Start()
    grepIn.Write([]byte("hello grep\ngoodbye grep"))
    grepIn.Close()
    grepBytes, _ := ioutil.ReadAll(grepOut)
    grepCmd.Wait()
    //上面的例子中，我们忽略了错误检测，但是你可以使用if err != nil 的方式来进行错误检查，我们也只收集StdoutPipe 的结果，但是你可以使用相同的方法收集StderrPipe 的结果。
    fmt.Println("> grep hello")
    fmt.Println(string(grepBytes))
    //注意，当我们需要提供一个明确的命令和参数数组来生成命令，和能够只需要提供一行命令行字符串相比，你想使用通过一个字符串生成一个完整的命令，那么你可以使用 bash命令的 -c 选项：
    lsCmd := exec.Command("bash", "-c", "AAA=5; echo $AAA; ls -a -l -h")
    lsOut, err := lsCmd.Output()
    if err != nil {
        panic(err)
    }
    fmt.Println("> ls -a -l -h")
    fmt.Println(string(lsOut))

	// ***********************************************
	// use os.StartProcess 
	var procAttr os.ProcAttr
	//procAttr.Files = []*os.File{nil, os.Stdout, os.Stderr}
	procAttr.Files = []*os.File{os.Stdin, os.Stdout, os.Stderr}

    fmt.Println("===========")
    fmt.Println("os.Args[1]=" + os.Args[1])
    fmt.Println("os.Args[1:]=" + strings.Join(os.Args[1:], " "))
    fmt.Println("===========")
	process, err := os.StartProcess(os.Args[1], os.Args[1:], &procAttr)
	if err != nil {
		println("start process failed:" + err.Error())
		return
	}

	println("start process success: %d" , process.Pid)
	//_, err = process.Wait()

	toppath := "/tmp"
	filename := "jobrunner.sh"
process, err = os.StartProcess("/bin/bash", []string{"/bin/bash", "-c", "/bin/bash " + filepath.Join(toppath, filename) + " 999 >/tmp/jobrunner.log 2>&1" }, &procAttr) 
	if err != nil {
		println("start process failed:" + err.Error())
		return
	}

	if err != nil {
		println("Wait Error:" + err.Error())
	}
	// ***********************************************
}
