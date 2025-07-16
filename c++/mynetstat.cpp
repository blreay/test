#include <iostream>
#include <fstream>
#include <sstream>
#include <dirent.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <cstring>
#include <unordered_set>
#include <map>

// 将 TCP 状态码转换为字符串
std::string tcp_state_to_string(unsigned int state) {
    static const std::map<unsigned int, std::string> state_map = {
        {0x01, "ESTABLISHED"},
        {0x02, "SYN_SENT"},
        {0x03, "SYN_RECV"},
        {0x04, "FIN_WAIT1"},
        {0x05, "FIN_WAIT2"},
        {0x06, "TIME_WAIT"},
        {0x07, "CLOSE"},
        {0x08, "CLOSE_WAIT"},
        {0x09, "LAST_ACK"},
        {0x0a, "LISTEN"},
        {0x0b, "CLOSING"},
        {0x0c, "NEW_SYN_RECV"},
        {0x0d, "UNKNOWN"}
    };
    auto it = state_map.find(state);
    return it != state_map.end() ? it->second : "UNKNOWN";
}

// 获取当前进程的所有 socket inode
std::unordered_set<std::string> get_process_sockets() {
    std::unordered_set<std::string> sockets;
    DIR* dir = opendir("/proc/self/fd");
    if (!dir) return sockets;

    struct dirent* entry;
    while ((entry = readdir(dir))) {
        if (entry->d_type == DT_LNK) {
            char path[256];
            snprintf(path, sizeof(path), "/proc/self/fd/%s", entry->d_name);
            char link[256];
            ssize_t len = readlink(path, link, sizeof(link) - 1);
            if (len != -1) {
                link[len] = '\0';
                if (strncmp(link, "socket:[", 8) == 0) {
                    std::string inode = std::string(link + 8, strchr(link + 8, ']') - (link + 8));
                    sockets.insert(inode);
                    std::cout << "insert one inode: " << inode << std::endl;
                }
            }
        }
    }
    closedir(dir);
    return sockets;
}

// 解析 /proc/net/tcp 或 tcp6 文件
void parse_tcp_file(const std::string& filename, const std::unordered_set<std::string>& sockets) {
  /*
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode
   0: 00000000:0016 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 2469851810 1 0000000000000000 100 0 0 10 0
   1: 0100007F:B0C3 00000000:0000 0A 00000000:00000000 00:00000000 00000000 1968091        0 1218736865 1 0000000000000000 100 0 0 10 0
   2: 0100007F:1131 00000000:0000 0A 00000000:00000000 00:00000000 00000000   500        0 4075351290 1 0000000000000000 100 0 0 10 0
   3: 0100007F:9CB1 00000000:0000 0A 00000000:00000000 00:00000000 00000000 1968091        0 1150253288 1 0000000000000000 100 0 0 10 0
   4: 0100007F:8DFB 00000000:0000 0A 00000000:00000000 00:00000000 00000000 1968091        0 3862182591 1 0000000000000000 100 0 0 10 0
   5: 0100007F:D62E 0100007F:8DFB 08 00000000:00000001 00:00000000 00000000 1968091        0 1226609056 1 0000000000000000 20 4 30 10 9
   6: 0100007F:E3B6 0100007F:2773 06 00000000:00000000 03:00000107 00000000     0        0 0 3 0000000000000000
   7: 0100007F:C8C6 0100007F:2328 06 00000000:00000000 03:000000DF 00000000     0        0 0 3 0000000000000000
   8: 0100007F:CB84 0100007F:9CB1 01 00000000:00000000 00:00000000 00000000 1968091        0 1150245178 1 0000000000000000 20 4 30 10 9
   9: 0100007F:A934 0100007F:271B 06 00000000:00000000 03:00000060 00000000     0        0 0 3 0000000000000000
  10: 0100007F:BD08 0100007F:8DFB 08 00000000:00000001 00:00000000 00000000 1968091        0 3862283345 1 0000000000000000 20 4 22 10 9
  11: 57720006:DA34 6A164C6E:01BB 01 00000000:00000000 02:00000037 00000000   500        0 1234347205 2 0000000000000000 20 4 28 10 7
  12: 0100007F:BC1A 0100007F:283B 01 00000000:00000000 00:00000000 00000000   500        0 2469884219 1 0000000000000000 21 4 1 10 9
  13: 0100007F:D258 0100007F:271A 06 00000000:00000000 03:000000DF 00000000     0        0 0 3 0000000000000000
   */
    std::ifstream file(filename);
    if (!file.is_open()) {
        std::cerr << "Failed to open " << filename << std::endl;
        return;
    }

    std::string line;
    std::getline(file, line); // 跳过表头
    while (std::getline(file, line)) {
        // std::cout << "oneline: " << line << std::endl;
        std::istringstream iss(line);
        std::string id, local, remote, state_str, inode_str, tmp;
        iss >> id >> local >> remote >> state_str >> tmp >> tmp >> tmp >> tmp >> tmp >> inode_str;
        // std::cout << "inode_str: " << inode_str << " state: " << state_str << std::endl;

        if (sockets.find(inode_str) != sockets.end()) {
            unsigned int state = std::stoul(state_str, nullptr, 16);
            std::cout << "Socket inode: " << inode_str << ", State: " << tcp_state_to_string(state) << std::endl;
        }
    }
}

//////////////////////////////////////////////////////////////////
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <unordered_map>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>

pid_t pid = getpid(); // 获取当前进程 PID

// TCP 状态码映射表
const std::unordered_map<std::string, std::string> tcp_states = {
    {"00", "UNKNOWN"}, {"01", "ESTABLISHED"}, {"02", "SYN_SENT"},
    {"03", "SYN_RECV"}, {"04", "FIN_WAIT1"},  {"05", "FIN_WAIT2"},
    {"06", "TIME_WAIT"}, {"07", "CLOSE"},     {"08", "CLOSE_WAIT"},
    {"09", "LAST_ACK"}, {"0A", "LISTEN"},     {"0B", "CLOSING"}
};

// 十六进制 IP:Port 转可读格式
std::string hex_to_ip_port(const std::string& hex) {
    // std::cout << "hex: " << hex << " size=" << hex.size() << std::endl;
    if (hex.size() != 13) return "0.0.0.0:0"; // IPv4 格式校验

    // 解析 IP 地址 (小端序)
    std::string ip_part = hex.substr(6, 2) + ":" + hex.substr(4, 2) + ":" +
                          hex.substr(2, 2) + ":" + hex.substr(0, 2);
    uint32_t ip_num = std::stoul(ip_part, nullptr, 16);

    struct in_addr addr;
    addr.s_addr = htonl(ip_num);
    std::string ip = inet_ntoa(addr);

    // 解析端口 (小端序)
    uint16_t port = std::stoul(hex.substr(9, 4), nullptr, 16);
    return ip + ":" + std::to_string(port);
}

// // 将十六进制字符串转换为十进制（处理可能的冒号分隔）
unsigned long hexstr_to_dec(const std::string& hexstr) {
    size_t colon_pos = hexstr.find(':');
    if (colon_pos != std::string::npos) {
        return stol(hexstr.substr(0, colon_pos), nullptr, 16);
    }
    return stol(hexstr, nullptr, 16);
}

// 统计 TCP 连接
void analyze_tcp_connections(pid_t pid) {
    std::string proc_path = "/proc/" + std::to_string(pid) + "/net/tcp";
    std::ifstream file(proc_path);
    std::string line;

    int total_connections = 0;
    int total_tx_size = 0;
    int total_rx_size = 0;
    int total_retrnsmt = 0;
    std::unordered_map<std::string, int> state_counts;

    // 跳过标题行
    std::getline(file, line);

    while (std::getline(file, line)) {
        std::istringstream iss(line);
        std::string token;
        std::vector<std::string> tokens;

        // 按空格分割行内容
        while (iss >> token) tokens.push_back(token);
        if (tokens.size() < 4) continue;

        // 提取本地地址、远程地址和状态
        std::string local_addr = hex_to_ip_port(tokens[1]);
        std::string remote_addr = hex_to_ip_port(tokens[2]);
        std::string state = tcp_states.count(tokens[3]) ? tcp_states.at(tokens[3]) : "UNKNOWN";

        // 统计信息
        total_connections++;
        state_counts[state]++;

        if (tokens.size() < 8) continue;

        unsigned long tx_queue = hexstr_to_dec(tokens[4]);
        unsigned long rx_queue = hexstr_to_dec(tokens[5]);
        unsigned long tr = hexstr_to_dec(tokens[6]);
        unsigned long tm_when = hexstr_to_dec(tokens[7]);
        unsigned long retrnsmt = hexstr_to_dec(tokens[8]);

        total_tx_size  += tx_queue;
        total_rx_size  += rx_queue;
        total_retrnsmt += retrnsmt;


        // 输出连接详情 (调试用)
        std::cout << "Local: " << local_addr
                  << " | Remote: " << remote_addr
                  << " | State: " << state
                  << " | retrnsmt: " << retrnsmt
                  << " | tx_queue: " << tx_queue
                  << " | rx_queue: " << rx_queue
                  << " | tr: " << tr
                  << std::endl;
    }

    // 输出汇总信息
    std::cout << "\nTotal TCP connections: " << total_connections << std::endl;
    for (const auto& [state, count] : state_counts) {
        std::cout << state << ": " << count << std::endl;
    }
    std::cout << "\nTotal tx_queue size: " << total_tx_size << std::endl;
    std::cout << "Total rx_queue size: " << total_rx_size << std::endl;
    std::cout << "Total retrnsmt size: " << total_retrnsmt << std::endl;
}

#include <iostream>
#include <thread>
#include <vector>
#include <memory>
#include <cstring>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

// 服务器监听的端口
const int PORT = 8080;

// 处理客户端连接的函数
void handle_client(int client_socket) {
    std::cout << "New client connected: " << client_socket << std::endl;
    std::this_thread::sleep_for(std::chrono::seconds(500));
    // 简单处理：关闭连接
    close(client_socket);
}

// 启动 TCP 服务器
void start_server() {
    int server_fd, new_socket;
    struct sockaddr_in address;
    int addrlen = sizeof(address);

    // 创建 socket
    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd == -1) {
        std::cerr << "Socket creation failed!" << std::endl;
        return;
    }

    // 设置地址复用（避免端口占用）
    int opt = 1;
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt)) < 0) {
        std::cerr << "Setsockopt failed!" << std::endl;
        close(server_fd);
        return;
    }

    // 绑定地址
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        std::cerr << "Bind failed!" << std::endl;
        close(server_fd);
        return;
    }

    // 监听
    if (listen(server_fd, 3) < 0) {
        std::cerr << "Listen failed!" << std::endl;
        close(server_fd);
        return;
    }

    std::cout << "Server is listening on port " << PORT << "..." << std::endl;

    // 接受 3 个连接
    std::vector<std::thread> clients;
    for (int i = 0; i < 3; ++i) {
        new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen);
        if (new_socket < 0) {
            std::cerr << "Accept failed!" << std::endl;
            continue;
        }
        clients.emplace_back(handle_client, new_socket);
    }

    // 等待所有客户端线程完成
    for (auto& t : clients) {
        if (t.joinable()) {
            t.join();
        }
    }

    close(server_fd);
    std::cout << "Server closed." << std::endl;
}

// 客户端连接函数
void connect_to_server() {
    int sock = 0;
    struct sockaddr_in serv_addr;

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        std::cerr << "Socket creation error" << std::endl;
        return;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);

    // 将 IPv4 地址从字符串转换为网络格式
    if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0) {
        std::cerr << "Invalid address/ Address not supported" << std::endl;
        close(sock);
        return;
    }

    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        std::cerr << "Connection Failed" << std::endl;
        close(sock);
        return;
    }

    std::this_thread::sleep_for(std::chrono::seconds(500));
    std::cout << "Connected to server from client: " << sock << std::endl;
    close(sock);
}

int main_create_tcp() {
    // 启动服务器线程
    std::thread server_thread(start_server);
    std::this_thread::sleep_for(std::chrono::seconds(1)); // 等待服务器启动

    // 创建 3 个客户端连接
    std::vector<std::thread> client_threads;
    for (int i = 0; i < 3; ++i) {
        client_threads.emplace_back(connect_to_server);
    }

    // 等待客户端线程完成
    for (auto& t : client_threads) {
        if (t.joinable()) {
            t.join();
        }
    }

    // 等待服务器线程结束
    if (server_thread.joinable()) {
        server_thread.join();
    }

    return 0;
}

int main() {
    std::thread server_thread(main_create_tcp);

    std::this_thread::sleep_for(std::chrono::seconds(3));
    system("netstat -anlp|grep mynetstat");
    auto sockets = get_process_sockets();
    if (sockets.empty()) {
        std::cout << "No TCP sockets found in current process." << std::endl;
        return 0;
    }

    std::cout << "TCP connections in current process:" << std::endl;
    parse_tcp_file("/proc/net/tcp", sockets);
    // parse_tcp_file("/proc/net/tcp6", sockets);
    std::cout << "==================================" << std::endl;
    pid_t pid = getpid();
    analyze_tcp_connections(pid);

    return 0;
}
