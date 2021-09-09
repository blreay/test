#include <iostream>
#include <memory>
#include <fstream>
#include <sstream>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <iterator>
#include <regex>
#include "json/json.h"

#define LOG_DEBUG printf
#define LOG_ERROR printf
using JsonObject = Json::Value;

static std::string itoa_self(int i) {
  std::stringstream ss;
  ss << i;
  return ss.str();
}

uint32_t parse_config_file(std::string path, JsonObject& json) {
  try {
    LOG_DEBUG("parse configuration file: %s", path.c_str());
    std::ifstream s(path);
    if (!s) {
      // file not exist, or access denied
      LOG_ERROR("configuration file not exist or access denied: %s", path.c_str());
      return 1;
    }
    s >> json;
  } catch (std::exception e) {
    // file format wrong, syntax error
    LOG_ERROR("json syntax error. exception occured: %s file=%s", e.what(), path.c_str());
    return 2;
  }
  return 0;
}

int main(int argc, char** argv) {
  int iValue = 0;
  std::string strValue;
  std::string filepath = "test.json";
  if (argc > 1) {
    filepath = argv[1];
  }
  std::cout << "configuration file: " << filepath << std::endl;

  JsonObject json;
  uint32_t ret = parse_config_file(filepath, json);
  if (ret != 0) {
    std::cout << "parse configuration file failed" << std::endl;
    // return 1;
  }
  try {
    // read int value
    if (json["storage_cluster"].isMember("cluster_size")) {
      int shard_count = json["storage_cluster"].get("cluster_size", 0).asInt();
      std::cout << "shard_count: " << shard_count << std::endl;
    } else {
      std::cout << "Failed: shard_count" << std::endl;
    }
    std::cout << "cluser size: " << json["storage_cluster"]["cluster"].size() << std::endl;
    // read string value
    if (json["storage_cluster"]["cluster"][0].isMember("ip")) {
      std::string ip = json["storage_cluster"]["cluster"][0].get("ip","").asString();
      std::cout << "ip: " << ip << std::endl;
    } else {
      std::cout << "Failed: ip" << std::endl;
    }
    // read string value
    if (json["storage_cluster"]["cluster"][0].isMember("ipXXX")) {
      std::string ip = json["storage_cluster"]["cluster"][0].get("ipXXX","").asString();
      std::cout << "ip: " << ip << std::endl;
    } else {
      std::cout << "ipXXX not exist" << std::endl;
    }
    // read child-tree and convert to string
    auto obj2 = json.get("storage_server", "");
    std::cout << "storage_server: " << obj2.toStyledString() << std::endl;
  } catch (std::exception& e) {
    std::cout << "exception occured:" << e.what() << "  file=" << filepath << std::endl;
  }

  // construct json object
  JsonObject json01;
  json01["AAA"] = "aaa";
  json01["BBB"] = "bbb";
  json01["map1"]["strkey1"] = "v1";
  json01["map1"]["intkey1"] = 123;

  JsonObject json02;
  json02["CCC"] = "ccc";
  json02["DDD"] = "ddd";
  json02["obj"] = json01;
  json02["EEE"] = "eee";
  std::cout << "new obj: " << json01.toStyledString() << std::endl;
  std::cout << "new obj2: " << json02.toStyledString() << std::endl;

  std::map<std::string, std::string> maps;
  Json::Value::Members members = json02.getMemberNames();
  uint32_t count = 0;
  for (Json::Value::Members::iterator it = members.begin(); it != members.end(); it++) {
    count++;
    Json::ValueType vt = json02[*it].type();
    switch (vt)
    {
      case Json::stringValue:
        {
          maps.insert(std::pair<std::string, std::string>(*it, json02[*it].asString()));
          break;
        }
      case Json::intValue:
        {
          int intTmp = json02[*it].asInt();
          maps.insert(std::pair<std::string, std::string>(*it, itoa_self(intTmp)));
          break;
        }
      case Json::arrayValue:
        {
          std::string strid;
          for (unsigned int i = 0; i < json02[*it].size(); i++)
          {
            strid +=json02[*it][i].asString();
            strid +=",";
          }
          if(!strid.empty())
          {
            strid = strid.substr(0,strid.size()-1);
          }
          maps.insert(std::pair<std::string, std::string>(*it, strid));
          break;
        }
      default:
        {
          maps.insert(std::pair<std::string, std::string>("OTHER_KEY", "OTHER_VALUE"));
          break;
        }
    }
  }
  std::cout << "count=" << count << std::endl;
  std::cout << "===== map ======" << std::endl;
  for(auto it: maps) {
    std::cout << it.first << "---->" << it.second << std::endl;
  }
  return 0;
}
