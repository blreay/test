#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <chrono>
#include <mutex>
#include <thread>
#include <atomic>
#include <iomanip>

using namespace std;

// 你要求的字段，顺序和命名请参照最新的清单
const vector<string> g_fields = {
    "IpInReceives", "IpInDelivers", "IpOutRequests", "IpReasmReqds", "IpReasmOKs",
    "IcmpInMsgs", "IcmpInErrors", "IcmpInDestUnreachs", "IcmpInEchos",
    "IcmpInEchoReps", "IcmpOutMsgs", "IcmpOutDestUnreachs", "IcmpOutEchos",
    "IcmpOutEchoReps",
    "IcmpMsgInType0", "IcmpMsgInType3", "IcmpMsgInType8",
    "IcmpMsgOutType0", "IcmpMsgOutType3", "IcmpMsgOutType8",
    "TcpActiveOpens", "TcpPassiveOpens", "TcpAttemptFails", "TcpEstabResets",
    "TcpInSegs", "TcpOutSegs", "TcpRetransSegs", "TcpInErrs", "TcpOutRsts",
    "UdpInDatagrams", "UdpNoPorts", "UdpOutDatagrams",
    "TcpExtEmbryonicRsts", "TcpExtPruneCalled", "TcpExtOutOfWindowIcmps", "TcpExtTW",
    "TcpExtTWKilled", "TcpExtPAWSEstab", "TcpExtDelayedACKs", "TcpExtDelayedACKLocked",
    "TcpExtDelayedACKLost", "TcpExtListenOverflows", "TcpExtListenDrops",
    "TcpExtTCPPrequeued", "TcpExtTCPDirectCopyFromBacklog", "TcpExtTCPDirectCopyFromPrequeue",
    "TcpExtTCPPrequeueDropped", "TcpExtTCPHPHits", "TcpExtTCPHPHitsToUser", "TcpExtTCPPureAcks",
    "TcpExtTCPHPAcks", "TcpExtTCPSackRecovery", "TcpExtTCPSACKReorder",
    "TcpExtTCPTSReorder", "TcpExtTCPFullUndo", "TcpExtTCPPartialUndo", "TcpExtTCPDSACKUndo",
    "TcpExtTCPLossUndo", "TcpExtTCPSackFailures", "TcpExtTCPLossFailures", "TcpExtTCPFastRetrans",
    "TcpExtTCPForwardRetrans", "TcpExtTCPSlowStartRetrans", "TcpExtTCPTimeouts",
    "TcpExtTCPLossProbes", "TcpExtTCPLossProbeRecovery", "TcpExtTCPSackRecoveryFail",
    "TcpExtTCPRcvCollapsed", "TcpExtTCPDSACKOldSent", "TcpExtTCPDSACKOfoSent",
    "TcpExtTCPDSACKRecv", "TcpExtTCPDSACKOfoRecv", "TcpExtTCPAbortOnData", "TcpExtTCPAbortOnClose",
    "TcpExtTCPAbortOnTimeout", "TcpExtTCPDSACKIgnoredOld", "TcpExtTCPDSACKIgnoredNoUndo",
    "TcpExtTCPSpuriousRTOs", "TcpExtTCPSackShifted", "TcpExtTCPSackMerged",
    "TcpExtTCPSackShiftFallback", "TcpExtTCPRcvCoalesce", "TcpExtTCPOFOQueue",
    "TcpExtTCPOFOMerge", "TcpExtTCPChallengeACK", "TcpExtTCPSYNChallenge", "TcpExtTCPAutoCorking",
    "TcpExtTCPFromZeroWindowAdv", "TcpExtTCPToZeroWindowAdv", "TcpExtTCPWantZeroWindowAdv",
    "TcpExtTCPSynRetrans", "TcpExtTCPOrigDataSent", "TcpExtTCPHystartTrainDetect",
    "TcpExtTCPHystartTrainCwnd", "TcpExtTCPHystartDelayDetect", "TcpExtTCPHystartDelayCwnd",
    "TcpExtTCPACKSkippedPAWS", "TcpExtTCPACKSkippedSeq", "TcpExtTCPACKSkippedChallenge",
    "TcpExtTCPWinProbe", "TcpExtTCPKeepAlive",
    "IpExtInOctets", "IpExtOutOctets", "IpExtInNoECTPkts"
};

using StatMap = map<string, uint64_t>;

struct StatCache {
    StatMap last, curr;
    chrono::steady_clock::time_point last_time, curr_time;
};
StatCache g_cache;
mutex g_mtx;

// 字符串分割工具
vector<string> split(const string& s, char delim = ' ') {
    vector<string> elems;
    size_t p = 0, q;
    while (p < s.size()) {
        while (p < s.size() && s[p] == delim) ++p;
        q = p;
        while (q < s.size() && s[q] != delim) ++q;
        if (q > p) elems.push_back(s.substr(p, q - p));
        p = q + 1;
    }
    return elems;
}

void parse_proc_snmp(const string& filename, StatMap& stat_map) {
    ifstream in(filename);
    string line;
    vector<string> last_names;
    while (getline(in, line)) {
        if (line.empty()) continue;
        auto arr = split(line);
        if (arr.size() <= 1) continue;
        string section = arr[0];
        if (section.back() == ':') section.pop_back();
        // 特殊处理IcmpMsg
        if (section == "IcmpMsg") {
            auto keys = arr; keys[0] = ""; // 去除section
            if (!getline(in, line)) break;
            auto vals = split(line);
            if (vals.size() != arr.size()) continue;
            // InType0/3/8 OutType0/3/8，字段映射
            if (vals.size() > 6) {
                stat_map["IcmpMsgInType0"] = stoull(vals[1]);
                stat_map["IcmpMsgInType3"] = stoull(vals[2]);
                stat_map["IcmpMsgInType8"] = stoull(vals[3]);
                stat_map["IcmpMsgOutType0"] = stoull(vals[4]);
                stat_map["IcmpMsgOutType3"] = stoull(vals[5]);
                stat_map["IcmpMsgOutType8"] = stoull(vals[6]);
            }
        } else {
            last_names = arr;
            if (!getline(in, line)) break;
            auto vals = split(line);
            if (vals.size() != last_names.size()) continue;
            for (size_t i=1; i<last_names.size(); ++i) {
                string fname = section + last_names[i];
                stat_map[fname] = stoull(vals[i]);
            }
        }
    }
}

void parse_proc_netstat(const string& filename, StatMap& stat_map) {
    ifstream in(filename);
    string line;
    vector<string> last_names;
    while (getline(in, line)) {
        if (line.empty()) continue;
        auto arr = split(line);
        if (arr.size() <= 1) continue;
        string section = arr[0];
        if (section.back() == ':') section.pop_back();
        last_names = arr;
        if (!getline(in, line)) break;
        auto vals = split(line);
        if (vals.size() != last_names.size()) continue;
        for (size_t i=1; i<last_names.size(); ++i) {
            string fname = section + last_names[i];
            stat_map[fname] = stoull(vals[i]);
        }
    }
}

// 采集线程
atomic<bool> running(true);
void collector(int interval_seconds) {
    while (running) {
        StatMap stat;
        // 解析所有主流统计文件
        parse_proc_snmp("/proc/net/snmp", stat);
        parse_proc_snmp("/proc/net/snmp6", stat);        // IPv6
        parse_proc_netstat("/proc/net/netstat", stat);
        parse_proc_netstat("/proc/net/netstat6", stat);  // IPv6
        // 预留其它文件按需补充
        {
            lock_guard<mutex> lk(g_mtx);
            g_cache.last = g_cache.curr;
            g_cache.curr = stat;
            g_cache.last_time = g_cache.curr_time;
            g_cache.curr_time = chrono::steady_clock::now();
        }
        this_thread::sleep_for(chrono::seconds(interval_seconds));
    }
}

void print_table() {
    constexpr int w_name = 32;
    constexpr int w_value = 24;
    lock_guard<mutex> lk(g_mtx);
    cout << "#kernel" << endl;
    auto& curr = g_cache.curr;
    auto& last = g_cache.last;
    double interval = chrono::duration<double>(g_cache.curr_time - g_cache.last_time).count();
    for (auto& f : g_fields) {
        uint64_t cur = curr.count(f) ? curr.at(f) : 0;
        uint64_t lst = last.count(f) ? last.at(f) : cur;
        double rate = (interval > 0.0) ? ((double)cur - lst) / interval : 0.0;
        cout << left << setw(w_name) << f
            << right << setw(w_value) << cur
            << "    " << fixed << setprecision(1) << rate << endl;
    }
}

int main() {
    int interval = 1;
    {
        StatMap initstat;
        parse_proc_snmp("/proc/net/snmp", initstat);
        // parse_proc_snmp("/proc/net/snmp6", initstat);
        parse_proc_netstat("/proc/net/netstat", initstat);
        // parse_proc_netstat("/proc/net/netstat6", initstat);
        lock_guard<mutex> lk(g_mtx);
        g_cache.last = g_cache.curr = initstat;
        g_cache.last_time = g_cache.curr_time = chrono::steady_clock::now();
    }
    thread t(collector, interval);
    while (true) {
        this_thread::sleep_for(chrono::seconds(interval));
        print_table();
    }
    running = false;
    t.join();
    return 0;
}

