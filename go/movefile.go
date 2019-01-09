package main

import (
    "flag"
    "fmt"
    "log"
    "os"
    "regexp"
    "strings"
)

func main() {

    batch := flag.Int("batch", 0, "the amount of files to be processed")
    pattern := flag.String("pattern", "", "string pattern to be matched")
    dir := flag.Int("dir", 0, "key from strings.Split(pattern, '')")
    confirm := flag.String("move", "no", "flags if program should move files")

    flag.Parse()

    d, err := os.Open(".")
    if err != nil {
        log.Fatal("Could not open directory. ", err)
    }

    files, err := d.Readdir(*batch)
    if err != nil {
        log.Fatal("Could not read directory. ", err)
    }

    for _, file := range files {
        fname := file.Name()
        match, err := regexp.Match(*pattern, []byte(fname))
        if err != nil {
            log.Fatal(err)
        }
        if match == true {

            s := strings.Split(fname, "_")
            dest := s[*dir]

            switch *confirm {
            case "no":
                fmt.Printf(" %s  matches  %s\n Dir name =  %s\n -----------------------\n", fname, *pattern, dest)

            case "yes":
                //all directories are expected to be a number.
                //terminate execution if directory doesn't match regex
                if match, err := regexp.Match("[0-9]", []byte(dest)); match == false {
                    log.Fatalf("Expected directory name does not match prepared directory.\n Expected dir name must be a number (regex [0-9]) | Current dir name is: %s\n", dest)
                    if err != nil {
                        log.Fatal(err)
                    }
                }

                //check if direcotry exists. create it if it doesn't
                if _, err := os.Stat(dest); os.IsNotExist(err) {
                    err = os.Mkdir(dest, 0777)
                    if err != nil {
                        log.Fatal("Could not create directory. ", err)
                    }
                }
                err = os.Rename(fname, fmt.Sprintf("%s/%s", dest, fname))
                if err != nil {
                    log.Fatal("Could not move file. ", err)
                }
                fmt.Printf("Moved %s to %s\n", fname, dest)
            }
        }
    }
    fmt.Println("Exit")
}
