#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import signal
# import gflags
import psutil
import time

from absl import flags
from absl import app

import sys
import logging
import argparse
from treelib import Tree, Node

def show_all():
    print("----------------------------- show all processes info --------------------------------")
    # show processes info
    pids = psutil.pids()
    psutil.pid()
    for pid in pids:
        p = psutil.Process(pid)
        # get process name according to pid
        process_name = p.name()

        print("Process name is: %s, pid is: %s" % (process_name, pid))

    print("----------------------------- kill specific process --------------------------------")
    pids = psutil.pids()
    for pid in pids:
        p = psutil.Process(pid)
        # get process name according to pid
        process_name = p.name()
        # kill process "sleep_test1"
        if 'sleep_test1' == process_name:
            print("kill specific process: name(%s)-pid(%s)" % (process_name, pid))
            os.kill(pid, signal.SIGKILL)


def find_all_parent(pid):
    p = psutil.Process(pid=16948)

    # 进程名称
    print(p.name())  # WeChat.exe

    # 进程的exe路径
    print(p.exe())  # D:\WeChat\WeChat.exe

    # 进程的工作目录
    print(p.cwd())  # D:\WeChat

    # 进程启动的命令行
    print(p.cmdline())  # ['D:\\WeChat\\WeChat.exe']

    # 当前进程id
    print(p.pid)  # 16948

    # 父进程id
    print(p.ppid())  # 11700

    # 父进程
    print(p.parent())  # psutil.Process(pid=11700, name='explorer.exe', started='09:19:06')

    # 子进程列表
    pprint(p.children())

    # 进程状态
    print(p.status())  # running

    # 进程用户名
    print(p.username())  # LAPTOP-264ORES3\satori

    # 进程创建时间,返回时间戳
    print(p.create_time())  # 1561775539.0

    # 进程终端
    # 在windows上无法使用
    try:
        print(p.terminal())
    except Exception as e:
        print(e)  # 'Process' object has no attribute 'terminal'

    # 进程使用的cpu时间
    print(p.cpu_times())  # pcputimes(user=133.3125, system=188.203125, children_user=0.0, children_system=0.0)

    # 进程所使用的的内存
    print(p.memory_info())

    # 进程打开的文件
    pprint(p.open_files())

    # 进程相关的网络连接
    pprint(p.connections())

    # 进程内的线程数量，这个进程开启了多少个线程
    print(p.num_threads())  # 66

    # 这个进程内的所有线程信息
    pprint(p.threads())
    # 进程的环境变量
    pprint(p.environ())
    # 结束进程, 返回 None, 执行之后微信就会被强制关闭, 当然这里就不试了
    # print(p.terminal())  # None

    exit(0)


FLAGS = flags.FLAGS
flags.DEFINE_integer('pid', 0, 'process id')
flags.DEFINE_boolean('debug', False, 'whether debug')
flags.DEFINE_string('name', 'func_test', 'test function name')


def get_ppid(pid, ppidlist):
    p = psutil.Process(pid=int(pid))
    ppidlist.append(p)
    if pid == 1:
        return 1
    ppid = p.ppid()
    #print(f'ppid={ppid}   cmd={p.cmdline()}')
    get_ppid(ppid, ppidlist)
    #time.sleep(1)
    return ppid

def ps_find_parent(args):
    #print('ps_find_all')
    # for i in args.cmdargs:
    #     print(f'arg: {i}')
    id = args.cmdargs[0]
    #print(f'pid: {id}')
    p = psutil.Process(pid=int(id))
    # print(p.cmdline())
    # print(f'ppid={p.ppid()}')
    result=[]
    tree = Tree()
    get_ppid(id, result)
    result.reverse()
    last_ppid = ''
    print(f'{" List ":=^80s}')
    for obj in result:
        print(f'{obj.pid:6d} --- {obj.cmdline()}')
        #print(f'last_ppid {last_ppid}')
        if obj.pid == 1:
            tree.create_node(tag=f'{obj.pid}  {obj.cmdline()}', identifier=f'{obj.pid}', data=f'{obj.cmdline()}')
        else:
            tree.create_node(tag=f'{obj.pid}  {obj.cmdline()}', identifier=f'{obj.pid}', parent=f'{last_ppid}', data=f'{obj.cmdline()}')
        last_ppid = obj.pid

    AA=" Tree "
    #print(f'{AA:=^80s}{" ":=<40s}')
    print(f'{" Tree ":=^80s}')
    tree.show()

def ps_find_child(args):
    print('ps_find_child')
    for i in args.cmdargs:
        print(f'arg: {i}')

def ps_find_all(args):
    print('ps_find_all')
    for i in args.cmdargs:
        print(f'arg: {i}')

def case2():
    print('case2')


def default():
    print('default')


switch = {'show_parent': {'func': ps_find_parent, 'help': '<PID> : show all parent process'},
          'show_child':  {'func': ps_find_child,  'help': '<PID> : show all child process'},
          'show_all':    {'func': ps_find_all,    'help': '<PID> : show all parent and child process'}
         }

def main(argv):
    # ret = FLAGS(argv)
    # logging.basicConfig(level=logging.DEBUG,
    #                     format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
    #                     datefmt='%a, %d %b %Y %H:%M:%S',
    #                     filename='test.log',
    #                     filemode='w')
    # logging.debug(FLAGS.name)
    # logging.info(FLAGS.pid)
    # logging.warning(FLAGS.debug)
    # print(f'{Flags.FlagDict()}')
    parser = argparse.ArgumentParser(description='Process manage tools by python', prog='ps.py', formatter_class=argparse.RawTextHelpFormatter)
    #parser.add_argument('cmd', type=str, metavar='CMD', choices=['aaa', 'bbb'], help='command name')
    LR='\n'
    help2=''
    for key in switch.keys():
        help2 += '  ' + f'{key: <16s}' + " " + switch.get(key, "None").get("help", "a") + LR
    #parser.add_argument('cmd', type=str, metavar='CMD', choices=switch.keys(), help=f'command {[key for key in switch.keys()]} {LR} { [ key + "---" + switch.get(key, "None").get("help", "a")+LR for key in switch.keys() ]}')
    parser.add_argument('cmd', type=str, metavar='CMD', choices=switch.keys(), help=f'supported command {[key for key in switch.keys()]} {LR}{help2}')
    parser.add_argument('cmdargs', metavar='arg', type=str, nargs='*',
                        help='command argument, can be multiple')
    parser.add_argument('--sum', required=False, dest='accumulate', action='store_const',
                        const=sum, default=max,
                        help='sum the integers (default: find the max)')
    parser.add_argument('--tree', required=False, dest='tree', action='store_const',
                        const=None, default=0,
                        help='show result in tree mode (default: no-tree)')
    args = parser.parse_args()
    print(f'argv[]={argv} ret={parser} tree={args.tree}')
    for i in args.cmdargs:
        print(f'arg: {i}')
    #print(f'{args.accumulate(args.cmdargs)}')
    print(f'CMD={args.cmd}')
    switch.get(args.cmd, default).get('func', 'None')(args)


def main_test():
    import getopt
    import sys

    # opts, args = getopt.getopt(sys.argv[1:], "i:ho:", ["help", "input=", "output="])
    # print(opts)
    # print(args)
    #
    # for opts, arg in opts:
    #     print(opts)
    #     if opts == "-h" or opts == "--help":
    #         print("我只是一个说明文档")
    #     elif opts == "-i" or opts == "--input":
    #         print("我只是输入，输入内容如下：")
    #         print(arg)
    #     elif opts == "-o" or opts == "--output":
    #         print("我只是输出，输出内容如下：")
    #         print(arg)

    find_all_parent(pid=1000)


if __name__ == "__main__":
    main(sys.argv)
    # app.run(main)
