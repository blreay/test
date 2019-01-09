package main
import "fmt"

func main() {
    fmt.Printf("begin to generate crash\n")
	var a=0
	var b=1
	b=b/a
	var p *int 
	  *p = 0 
    fmt.Printf("should have crashed\n")
}

