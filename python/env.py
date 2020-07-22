#!/usr/bin/python
#coding=UTF-8

import os

env_dist = os.environ # environ是在os.py中定义的一个dict environ = {}

print env_dist.get('SH')
print env_dist['SH']

# 打印所有环境变量，遍历字典
for key in env_dist:
    print key + ' : ' + env_dist[key]

if os.environ.get('TEST') == 'ABC':
    print "OO"
else:
    print "KK"
