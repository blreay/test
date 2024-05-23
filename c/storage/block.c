#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>

/*
 根据块号(block number)来直接读取一个块设备上的数据。块号指的是设备上的逻辑块的序号，
 这些块是设备存储的基本单位。通常块大小是512字节或者更大。
 在UNIX-like系统上，你可以通过lseek函数来寻址到特定块号所在的位置，并使用read函数来读取数据。
 以下是一个根据块号读取块设备的C语言示例：
 */

// 假设我们的块大小为 512 字节
#define BLOCK_SIZE 512

int main(int argc, char *argv[]) {
    // 检查命令行参数
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <device> <block number>\n", argv[0]);
        return 1;
    }

    const char *device = argv[1]; // 块设备文件路径
    long block_number = strtol(argv[2], NULL, 10); // 要读取的块号
    unsigned char buffer[BLOCK_SIZE]; // 数据读取缓冲区

    // 打开块设备文件
    int fd = open(device, O_RDONLY);
    if (fd == -1) {
        fprintf(stderr, "Error opening device %s: %s\n", device, strerror(errno));
        return 1;
    }

    // 移动文件读写位置到指定的块号
    off_t offset = lseek(fd, block_number * BLOCK_SIZE, SEEK_SET);
    if (offset == (off_t)-1) {
        fprintf(stderr, "Error seeking device %s: %s\n", device, strerror(errno));
        close(fd);
        return 1;
    }

    // 读取数据块
    ssize_t bytes_read = read(fd, buffer, sizeof(buffer));
    if (bytes_read == -1) {
        fprintf(stderr, "Error reading from device %s: %s\n", device, strerror(errno));
        close(fd);
        return 1;
    }

    // 打印读取的数据
    for(int i = 0; i < bytes_read; ++i) {
        printf("%02x ", buffer[i]);
        if ((i + 1) % 16 == 0) {
            printf("\n");
        }
    }
    printf("\n");

    // 关闭设备文件描述符
    close(fd);
    return 0;
}

