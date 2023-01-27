#!/usr/bin/env python3
# -*- coding: utf-8 -*-

## HOW to use this light framework
#########################################################
'''
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

##################
import myapp

g_appinfo = {"prog": "mytest.py", "description": "Process management tools"}
g_logger = myapp.getlogger()
g_switch = {
    'show_parent': {'func': "ps_find_parent", 'help': '<PID> : show all parent process'},
    'show_child':  {'func': "ps_find_child",  'help': '<PID> : show all child process'},
    'show_all':    {'func': "ps_find_all",    'help': '<PID> : show all parent and child process'},
    'kill_all':    {'func': "ps_kill_all",    'help': '<PID> : kill all child and grandchild process'}
}

# add individual argument for each sub-command
def ps_find_parent_parser(parser_obj, name):
    parser_obj.add_argument('pid', type=int, default='')
    parser_obj.add_argument('-m', type=int, default=1, required=False)
def ps_find_child_parser(parser_obj, name):
    parser_obj.add_argument('pid', type=int, default='')
def ps_find_all_parser(parser_obj, name):
    parser_obj.add_argument('pid', type=int, default=''
def ps_kill_all_parser(parser_obj, name):
    parser_obj.add_argument('pid', type=int, default='')

def main(parser):
    subparsers = parser.add_subparsers(help='supported', title='subcommand',
                                       required=True,
                                       dest='subcommand',
                                       description='all supported command')
    for key in g_switch.keys():
        parser_func_name = f"{g_switch.get(key, default).get('func', 'None')}_parser"
        new_parser_obj = subparsers.add_parser(key, help=f"{g_switch.get(key, default).get('help', 'NONE')}")
        eval(parser_func_name)(new_parser_obj, key)
        new_parser_obj.set_defaults(func=g_switch.get(key, default).get('func', 'None'))

    arg = parser.parse_args()
    eval(arg.func)(arg)

if __name__ == "__main__":
    myapp.run(main, g_appinfo)

'''
######################################################
import os
import signal
import psutil
import time
import threading
# import gflags
# from absl import flags, app

import sys
import logging
import argparse

my_logger = logging.getLogger(__name__)


## simple filter to insert thread_id(new attribute)
def thread_id_filter(record):
    """Inject thread_id to log records"""
    record.thread_id = threading.get_native_id()
    return record


def enable_console_stdout_log(arg):
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s [%(process)d/%(thread_id)d] %(message)s'))
    handler.addFilter(thread_id_filter)
    my_logger.propagate = False
    my_logger.addHandler(handler)
    # my_logger.setLevel(arg.myloglevel)
    my_logger.setLevel("INFO")
    # my_logger.info('test123')


def getlogger():
    return my_logger


class DbgAction(argparse.Action):
    def __init__(self, option_strings, dest, nargs=None, **kwargs):
        # if nargs is not None:
        #     raise ValueError("nargs not allowed")
        super().__init__(option_strings, dest, 0, **kwargs)

    def __call__(self, parser, namespace, values, option_string=None):
        print('%r %r 99=%r %s' % (namespace, values, option_string, self.dest))
        # setattr(namespace, self.dest, values)
        setattr(namespace, self.dest, "DEBUG")
        my_logger.setLevel("DEBUG")


# def parse(obj):
#     enable_console_stdout_log(None);
#     arg = obj.parse_args()
#     return arg


def run(func, appinfo):
    # global g_appinfo
    enable_console_stdout_log(None);

    # create the top-level parser
    parser = argparse.ArgumentParser(description=f'{appinfo["description"]}',
                                     prog=f'{appinfo["prog"]}', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-D', '--debug', action=DbgAction, dest='myloglevel',
                        nargs=0, default="INFO", required=False,
                        help='enable debug log')

    ### run user main function
    func(parser)
