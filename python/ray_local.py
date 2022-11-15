#!/bin/env python

import ray
import os, threading, sys
import numpy
import time


import ctypes
libc = ctypes.cdll.LoadLibrary('libc.so.6')
# System dependent, see e.g. /usr/include/x86_64-linux-gnu/asm/unistd_64.h
SYS_gettid = 186
def getThreadId():
   """Returns OS thread id - Specific to Linux"""
   return libc.syscall(SYS_gettid)

@ray.remote
class MyTest:
    def __init__(self, data):
        self.__data = data

    def m(self, n):
        print(f'in m n={n}')
        time.sleep(n)
        return f"f({ray.util.get_node_ip_address()}) m {os.getpid()}/{threading.get_native_id()}"

    def f(self, n):
        print(f'in f n={n}')
        time.sleep(n)
        return f"f({ray.util.get_node_ip_address()}) f {os.getpid()}/{threading.get_native_id()}"

    def g(self, obj):
        return obj + "g"

    def h(self, obj):
        return obj + "h"


@ray.remote
def test(n):
    time.sleep(n)
    #print(f'{os.getpid()}/{getThreadId()}/{threading.get_native_id()} input[{n}]')
    print(f'{os.getpid()}/{threading.get_native_id()} input[{n}]')
    return n

@ray.remote
def test_thread(n):
    time.sleep(n)
    def call():
        print(f'in call')
    with ThreadPoolExecutor(thread_name_prefix='workload') as executor:
        executor.submit(lambda n: time.sleep(n), n).add_done_callback(call)
    #print(f'{os.getpid()}/{getThreadId()}/{threading.get_native_id()} input[{n}]')
    print(f'{os.getpid()}/{threading.get_native_id()} input[{n}]')
    return n

# 不使用注解的方式
#test_remote = ray.remote(test)

ray.init(num_cpus=10)

# test Actor
## test "default mode" of ray, run serial in one thread
#h1 = MyTest.remote('aaa')
## test "threaded actor" of ray, run concurrently in multithread mode
h1 = MyTest.options(max_concurrency=5).remote('aaa')
t1 = h1.f.remote(2)
time.sleep(2)
t2 = h1.m.remote(60)
t3 = h1.m.remote(3)

print(f'{os.getpid()}/{getThreadId()}/{threading.get_native_id()} t1[{t1}]')
print(f'{os.getpid()}/{getThreadId()}/{threading.get_native_id()} t2[{t2}]')
print(f'{os.getpid()}/{getThreadId()}/{threading.get_native_id()} t3[{t3}]')

check=[t1, t2, t3]
for i in range(30):
    print(f'{" "+str(i)+" ":=^80s}')
    ready_refs, remaining_refs = ray.wait(check, num_returns=3, timeout=1)
    for _ in ready_refs:
        print(f'OK: {_} [{ray.get(_)}]')
    for _ in remaining_refs:
        print(f'NG: {_}')

sys.exit(0)

# 函数test 加注解时使用方式
test_remote1 = test_thread.remote(1000)
time.sleep(2)
test_remote2 = test.remote(2)
test_remote3 = test.remote(3)
check=[test_remote1, test_remote2, test_remote3]
print(f'{os.getpid()}/{getThreadId()}/{threading.get_native_id()} test_remote1[{test_remote1}]')
print(f'{os.getpid()}/{getThreadId()}/{threading.get_native_id()} test_remote2[{test_remote2}]')
print(f'{os.getpid()}/{getThreadId()}/{threading.get_native_id()} test_remote3[{test_remote3}]')

for i in range(100):
    print(f'{" "+str(i)+" ":=^80s}')
    ready_refs, remaining_refs = ray.wait(check, num_returns=3, timeout=1)
    for _ in ready_refs:
        print(f'OK: {_}')
    for _ in remaining_refs:
        print(f'NG: {_}')

#ray.get(test_remote1)
print(f'{os.getpid()}/{getThreadId()}/{threading.get_native_id()} test_remote2[{ray.get(test_remote2)}]')
print(f'{os.getpid()}/{getThreadId()}/{threading.get_native_id()} test_remote3[{ray.get(test_remote3)}]')
#print(f'{os.getpid()}/{getThreadId()}/{threading.get_native_id()} test_remote1[{ray.get(test_remote1)}]')

start_time = time.time()

for i in range(10):
    pass
    #test(1)

print(time.time() - start_time)
