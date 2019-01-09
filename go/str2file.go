package main

import (
    "encoding/base64"
    "fmt"
    "log"
	"io/ioutil"
"path/filepath"
)

func main() {
    input := []byte("hello golang base64 快乐编程http://www.01happy.com +~")
	toppath := "/tmp"
	filename :="jobrunner.sh"

    // 演示base64编码
    encodeString := base64.StdEncoding.EncodeToString(input)
    fmt.Println(encodeString)

    // 对上面的编码结果进行base64解码
    decodeBytes, err := base64.StdEncoding.DecodeString(encodeString)
    if err != nil {
        log.Fatalln(err)
    }
    fmt.Println(string(decodeBytes))

    // zzy
    fmt.Println("zzy: test Decode copied string")
	encodeString = "MTIzCg=="
    decodeBytes, err = base64.StdEncoding.DecodeString(encodeString)
    if err != nil {
        log.Fatalln(err)
    }
    fmt.Println(string(decodeBytes))

	encodeString = "IyEvYmluL2Jhc2gKSlJfRU5EUE9JTlQ9JHtKUl9FTkRQT0lOVC0xMC4xODIuNzQuNjI6NzAwMH0KZXhwb3J0IEpSX0VORFBPSU5UCmV4cG9ydCBXQUlUVElNRT0xMAppZiBbIC16ICIkT1JBX0FQUF9OQU1FIiBdO3RoZW4KICBlY2hvICJlbnYgdmFyIE9SQV9BUFBfTkFNRSBpcyB1bmRlZmluZWQsIGV4aXQuIgogIGV4aXQgMQpmaQoKZWNobyAiVkVSU0lPTiAyMDE3MDgwMS0xMDUwIgplY2hvCgphcHBuYW1lPWBlY2hvICRPUkFfQVBQX05BTUV8c2VkICdzLy1hY2MvLydgCmV4cG9ydCBhcHBuYW1lCmVjaG8gIlNlcnZlciBpcyBhdCAkSlJfRU5EUE9JTlQsIGFwcG5hbWUgaXMgJGFwcG5hbWUiCmVjaG8gIkpvYnJ1bm5lciBpcyBhdCBodHRwOi8vJEpSX0VORFBPSU5UL2pvYnJ1bm5lci8kYXBwbmFtZSIKCmV4cG9ydCBsb2dmaWxlPS90bXAvY21kZXhlYy5sb2cKCnVybHZhbGlkKCkgewogIHVybD0iJCoiCiAgaWYgbm9fcHJveHk9JyonIGh0dHBfcHJveHk9JycgY3VybCAtLWNvbm5lY3QtdGltZW91dCA1IC0tbWF4LXRpbWUgNSAtLXJldHJ5LW1heC10aW1lIDEgLS1vdXRwdXQgL2Rldi9udWxsIC0tc2lsZW50IC0taGVhZCAtLWZhaWwgLUggIkNhY2hlLUNvbnRyb2w6IG5vLWNhY2hlIiAiJHVybCI7IHRoZW4KICAgIGVjaG8geQogIGVsc2UKICAgIGVjaG8gbgogIGZpCn0KCmpvYmNsZWFyKCkgewogIGN1cmwgLXMgIC1IICJDb250ZW50LXR5cGU6IHRleHQvcGxhaW4iIC1YIFBVVCBodHRwOi8vJEpSX0VORFBPSU5UL2pvYmNsZWFyP2FwcG5hbWU9JGFwcG5hbWUKfQoKd2hpbGUgWyAxIF07IGRvCiAgaWYgWyAiYHVybHZhbGlkICRKUl9FTkRQT0lOVGAiID0gbiBdO3RoZW4KICAgIGVjaG8gJyMnCiAgICBzbGVlcCAkV0FJVFRJTUUKICAgIGNvbnRpbnVlCiAgZmkKCiAgY21kPWBjdXJsIC1zIGh0dHA6Ly8kSlJfRU5EUE9JTlQvam9iP2FwcG5hbWU9JGFwcG5hbWVgCgogIGlmIFsgLXogIiRjbWQiIF07dGhlbgogICAgZWNobyAuCiAgICBzbGVlcCAkV0FJVFRJTUUKICAgIGNvbnRpbnVlCiAgZmkKCiAgZWNobyAiLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0iCiAgZWNobyAiJGNtZCIKICBlY2hvICItLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSIKCiAgam9iY2xlYXIKICBybSAtZiAkbG9nZmlsZQoKICBjYXNlICIkY21kIiBpbgogICAgX3VwZGF0ZV9qb2JydW5uZXIpCiAgICAgIGNkICRBUFBfSE9NRQogICAgICBjdXJsIC1zIGh0dHA6Ly8kSlJfRU5EUE9JTlQvc2NyaXB0cy91cGRhdGVyLnNoIC1vIHVwZGF0ZXIuc2ggPiAkbG9nZmlsZSAyPiYxCiAgICAgIGN1cmwgLXMgaHR0cDovLyRKUl9FTkRQT0lOVC9zY3JpcHRzL2pvYnJ1bm5lci5zaCAtbyBqb2JydW5uZXIuc2ggPj4gJGxvZ2ZpbGUgMj4mMQogICAgICBjaG1vZCAreCB1cGRhdGVyLnNoIGpvYnJ1bm5lci5zaAogICAgICBub2h1cCAuL3VwZGF0ZXIuc2ggPj4gJGxvZ2ZpbGUgMj4mMSAmCiAgICAgIGV4aXQgMAogICAgICA7OwogICAgX3BhdGNoX2FuZF9ydW5fc2NyaXB0X2xvY2FsKQogICAgICBpZiBbICEgLWQgcGF0Y2ggXTt0aGVuIG1rZGlyIHBhdGNoOyBmaQogICAgICBlY2hvICdleHRyYWN0aW5nIHBhdGNoIHBhY2thZ2UgLi4uICcgPiAkbG9nZmlsZSAyPiYxCiAgICAgIGNkIHBhdGNoICYmIFwKICAgICAgICBybSAtcmYgKiAmJiBcCiAgICAgICAgY3VybCAtcyBodHRwOi8vJEpSX0VORFBPSU5UL3BhdGNoL3BhdGNoLnRneiB8IHRhciB4ZnogLSA+PiAkbG9nZmlsZSAyPiYxCiAgICAgIGVjaG8gPj4gJGxvZ2ZpbGUgMj4mMQogICAgICBscyAtbHRyICA+PiAkbG9nZmlsZSAyPiYxCiAgICAgIGVjaG8gPj4gJGxvZ2ZpbGUgMj4mMQogICAgICBlY2hvICdwYXRjaCBzY3JpcHQgY29udGVudDonID4+ICRsb2dmaWxlIDI+JjEKICAgICAgY2F0IHBhdGNoLnNoID4+ICRsb2dmaWxlIDI+JjEKICAgICAgZWNobyA+PiAkbG9nZmlsZSAyPiYxCiAgICAgIGNobW9kICt4IHBhdGNoLnNoCiAgICAgIC4vcGF0Y2guc2ggPj4gJGxvZ2ZpbGUgMj4mMQogICAgICBlY2hvICdkb25lJyA+PiAkbG9nZmlsZSAyPiYxCiAgICAgIGNkICRBUFBfSE9NRQogICAgICA7OwogICAgX3NldF93YWl0X3RpbWVfKikKICAgICAgZWNobyAiLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0iID4gJGxvZ2ZpbGUKICAgICAgZWNobyAiJGNtZCIgPj4gJGxvZ2ZpbGUgMj4mMQogICAgICBlY2hvICItLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSIgPj4gJGxvZ2ZpbGUKICAgICAgbmV3dGltZT1gZWNobyAkY21kfHNlZCAncy9fc2V0X3dhaXRfdGltZV8vLydgCiAgICAgIGlmIFsgIiRuZXd0aW1lIiAtZ2UgMiBdO3RoZW4KICAgICAgICBlY2hvICJTZXQgd2FpdCB0aW1lIHRvICRuZXd0aW1lIHNlY29uZHMuIiA+PiAkbG9nZmlsZQogICAgICAgIGV4cG9ydCBXQUlUVElNRT0kbmV3dGltZQogICAgICBlbHNlCiAgICAgICAgZWNobyAiV2FpdCB0aW1lIHRvbyBzaG9ydCwgcGxlYXNlIHNwZWNpZnkgYSBsb25nZXIgdmFsdWUuIiA+PiAkbG9nZmlsZQogICAgICBmaQogICAgICA7OwogICAgX3NjcmlwdF9ydW4pCiAgICAgIGN1cmwgLXMgaHR0cDovLyRKUl9FTkRQT0lOVC9zY3JpcHRzL2pvYi5zaCAtbyBqb2Iuc2gKICAgICAgY2htb2QgK3ggam9iLnNoCiAgICAgIC4vam9iLnNoID4gJGxvZ2ZpbGUgMj4mMQogICAgICA7OwogICAgKikKICAgICAgdG1wZmlsZT1gbWt0ZW1wYAogICAgICBlY2hvICIkY21kIiA+ICR0bXBmaWxlCiAgICAgIGJhc2ggJHRtcGZpbGUgPiAkbG9nZmlsZSAyPiYxCgogICAgICBybSAtZiAkdG1wZmlsZQogICAgICA7OwogIGVzYWMKCiAgY3VybCAtcyAgLUggIkNvbnRlbnQtdHlwZTogdGV4dC9wbGFpbiIgLVggUE9TVCAtLWRhdGEtYmluYXJ5IEAkbG9nZmlsZSBodHRwOi8vJEpSX0VORFBPSU5UL2pvYnJlc3VsdD9hcHBuYW1lPSRhcHBuYW1lCmRvbmUK"
    decodeBytes, err = base64.StdEncoding.DecodeString(encodeString)
    if err != nil {
        log.Fatalln(err)
    }
    //fmt.Println(string(decodeBytes))

    fmt.Println()

	//err = ioutil.WriteFile(filepath.Join(toppath, "jobrunner.sh"), []byte(encode)), 0755)
	err = ioutil.WriteFile(filepath.Join(toppath, filename), decodeBytes, 0755)
	if err != nil {
			log.Fatalln("%s Error creating cmd.sh in %s: %s", "main", toppath, err)
			return
	}
    fmt.Println("contents has been written to file: %s", filepath.Join(toppath, filename)) 


    // 如果要用在url中，需要使用URLEncoding
    uEnc := base64.URLEncoding.EncodeToString([]byte(input))
    fmt.Println(uEnc)

    uDec, err := base64.URLEncoding.DecodeString(uEnc)
    if err != nil {
        log.Fatalln(err)
    }
    fmt.Println(string(uDec))
}
