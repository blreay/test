#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import os
import signal
import psutil
import time
import threading
import sys
import logging
import argparse
from treelib import Tree, Node
# from absl import flags, app

# import my light python framework
import myapp

## Global variables
###########################################################
g_appinfo = {"prog": "ps.py", "description": "Process management tools"}
g_logger = myapp.getlogger()
g_switch = {
    'show_parent': {'func': "ps_find_parent", 'help': '<PID> : show all parent process'},
    'show_child':  {'func': "ps_find_child", 'help': '<PID> : show all child process'},
    'show_all':    {'func': "ps_find_all", 'help': '<PID> : show all parent and child process'},
    'kill_all':    {'func': "ps_kill_all", 'help': '<PID> : kill all child and grandchild process'}
}
############################################################

def get_ppid(pid, ppidlist):
    if pid == 0:
        return 1
    try:
        p = psutil.Process(pid=int(pid))
    except psutil.NoSuchProcess as e:
        print(f'process not exist: {pid}')
        return
    ppidlist.append(p)
    try:
        ppid = p.ppid()
    except Exception as e:
        pass
    else:
        get_ppid(ppid, ppidlist)
    return ppid


def gen_parent_tree(pid, tree):
    result = []
    get_ppid(pid, result)
    result.reverse()
    last_ppid = ''
    # print(f'{" List ":=^80s}')
    for obj in result:
        # print(f'{obj.pid:6d} --- {obj.cmdline()}')
        if obj.pid == 1:
            tree.create_node(tag=f'{obj.pid}  {obj.cmdline()}', identifier=f'{obj.pid}', data=f'{obj.cmdline()}')
        else:
            tree.create_node(tag=f'{obj.pid}  {obj.cmdline()}', identifier=f'{obj.pid}', parent=f'{last_ppid}',
                             data=f'{obj.cmdline()}')
        last_ppid = obj.pid


def ps_find_parent(args):
    # print('ps_find_all')
    # for i in args.cmdargs:
    #     print(f'arg: {i}')
    # id = args.cmdargs[0]
    id = args.pid
    # p = psutil.Process(pid=int(id))
    try:
        p = psutil.Process(pid=int(id))
    except psutil.NoSuchProcess as e:
        print(f'process not exist: {id}')
        return
    # print(p.cmdline())
    tree = Tree()
    gen_parent_tree(id, tree)

    g_logger.debug(f"just for test id={id}")

    print(f'{" Tree ":=^80s}')
    tree.show()


def gen_child_tree(pid, tree):
    for obj in psutil.Process(int(pid)).children():
        tree.create_node(tag=f'{obj.pid}  {obj.cmdline()}', identifier=f'{obj.pid}', parent=f'{pid}',
                         data=f'{obj.cmdline()}')
        gen_child_tree(obj.pid, tree)


def ps_find_child(args):
    # print('ps_find_child')
    #  for i in args.cmdargs:
    #  print(f'arg: {i}')
    id = args.pid
    # obj = psutil.Process(int(id))
    try:
        obj = psutil.Process(pid=int(id))
    except psutil.NoSuchProcess as e:
        print(f'process not exist: {id}')
        return
    tree = Tree()
    tree.create_node(tag=f'{obj.pid}  {obj.cmdline()}', identifier=f'{obj.pid}', data=f'{obj.cmdline()}')
    gen_child_tree(id, tree)
    print(f'{" Tree ":=^80s}')
    tree.show()


def ps_find_all(args):
    # print('ps_find_all')
    # id = args.cmdargs[0]
    id = args.pid
    try:
        obj = psutil.Process(pid=int(id))
    except psutil.NoSuchProcess as e:
        print(f'process not exist: {id}')
        return
    tree = Tree()
    gen_parent_tree(id, tree)
    gen_child_tree(id, tree)
    print(f'{" Tree ":=^80s}')
    tree.show()


def default():
    print('default')


def ps_kill_all(args):
    pid = args.cmdargs[0]

    parent = psutil.Process(pid)
    for child in parent.children(recursive=True):  # or parent.children() for recursive=False
        print(f'kill child: {child.pid}')
        child.kill()
    parent.kill()


# add individual argument for each sub-command
def ps_find_parent_parser(parser_obj, name):
    parser_obj.add_argument('pid', type=int, default='')
    parser_obj.add_argument('-m', type=int, default=1, required=False)


def ps_find_child_parser(parser_obj, name):
    parser_obj.add_argument('pid', type=int, default='')


def ps_find_all_parser(parser_obj, name):
    parser_obj.add_argument('pid', type=int, default='')


def ps_kill_all_parser(parser_obj, name):
    parser_obj.add_argument('pid', type=int, default='')

def main(parser):
    subparsers = parser.add_subparsers(help='supported', title='subcommand',
                                       required=True,
                                       dest='subcommand',
                                       description='all supported command')
    for key in g_switch.keys():
        func = g_switch.get(key, default).get('func', 'None')
        parser_func_name = f"{g_switch.get(key, default).get('func', 'None')}_parser"
        new_parser_obj = subparsers.add_parser(key, help=f"{g_switch.get(key, default).get('help', 'NONE')}")
        eval(parser_func_name)(new_parser_obj, key)
        new_parser_obj.set_defaults(func=func)

    arg = parser.parse_args()
    # arg = myapp.parse(parser)
    g_logger.debug(f'commandline parse result: [{arg}]')
    eval(arg.func)(arg)
    g_logger.debug(f'main end')


if __name__ == "__main__":
    g_logger.debug(f'python entry begin')
    myapp.run(main, g_appinfo)
    g_logger.debug(f'python entry end')
