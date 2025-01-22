#include <iostream>
#include <regex>
#include <string>

bool isIPv4(const std::string &ip) {
    std::regex ipv4Pattern(
        R"((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(
           25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(
           25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(
           25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))"
        );  // Pattern for IPv4
    return std::regex_match(ip, ipv4Pattern);
}

bool isIPv6(const std::string &ip) {
    std::regex ipv6Pattern(
        R"((?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}| 
        (?:[0-9a-fA-F]{1,4}:){1,7}:| 
        (?:[0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}| 
        (?:[0-9a-fA-F]{1,4}:){1,5}(?::[0-9a-fA-F]{1,4}){1,2}| 
        (?:[0-9a-fA-F]{1,4}:){1,4}(?::[0-9a-fA-F]{1,4}){1,3}| 
        (?:[0-9a-fA-F]{1,4}:){1,3}(?::[0-9a-fA-F]{1,4}){1,4}| 
        (?:[0-9a-fA-F]{1,4}:){1,2}(?::[0-9a-fA-F]{1,4}){1,5}| 
        [0-9a-fA-F]{1,4}:(?::[0-9a-fA-F]{1,4}){1,6}| 
        :(?::[0-9a-fA-F]{1,4}){1,7}| 
        (?:[0-9a-fA-F]{1,4}:){1,6}:[0-9]{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}| 
        (?:[0-9a-fA-F]{1,4}:){1,5}:(?:ffff:(?:[0-9]{1,3}\.){3}[0-9]{1,3}| 
        (?:[0-9a-fA-F]{1,4}:){1,4}[0-9]{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}))"
    );  // Pattern for IPv6
    return std::regex_match(ip, ipv6Pattern);
}

bool isDomain(const std::string &domain) {
    // 更加稳健的正则，避免对特殊字符的不匹配而导致异常
    std::regex domainPattern(R"(^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$)");
    return std::regex_match(domain, domainPattern);
}

int main() {
    std::string input;

    std::cout << "请输入一个字符串: ";
    std::cin >> input;

    try {
        if (isIPv4(input)) {
            std::cout << input << " 是一个 IPv4 地址。" << std::endl;
        } else if (isIPv6(input)) {
            std::cout << input << " 是一个 IPv6 地址。" << std::endl;
        } else if (isDomain(input)) {
            std::cout << input << " 是一个域名。" << std::endl;
        } else {
            std::cout << input << " 不是有效的 IP 地址或域名。" << std::endl;
        }
    } catch (const std::regex_error& e) {
        std::cerr << "正则表达式匹配失败: " << e.what() << std::endl;
    }

    return 0;
}

