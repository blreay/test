#!/bin/env python3

# -*- encoding:utf-8 -*-

import threading
import logging
import os
import threading
from logging import handlers
from concurrent.futures import ThreadPoolExecutor

#  is there a way to show the thread native_id:
#
#  native_id
#
#  The native integral thread ID of this thread. This is a non-negative integer, or None if the thread has not been started. See the get_native_id() function. This represents the Thread ID (TID) as assigned to the thread by the OS (kernel). Its value may be used to uniquely identify this particular thread system-wide (until the thread terminates, after which the value may be recycled by the OS).
#
#  in the python logs using the logging LogRecord attributes.
#
#  %(threadName)s and %(thread)s do not show the native_id.
#
#  I am using linux Ubuntu and RHEL.
#
#  Thanks


import sys
import logging

class NoParsingFilter(logging.Filter):
  def filter(self, record):
    print(f'record.name={record.name}  record.levelno={record.levelno}')
    print(f'{record.__dict__}')
    if record.name == 'tornado.access' and record.levelno == 20:
      return False
    if record.msg.__contains__("123"):
      return False
    return True

## simple filter to insert thread_id(new attribute)
def thread_id_filter(record):
    """Inject thread_id to log records"""
    record.thread_id = threading.get_native_id()
    return record


def test_basic2():
    my_logger = logging.getLogger()
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter('%(asctime)s | %(levelname)s | [%(process)d/%(thread)d] ThreadID=%(thread_id)s | %(message)s'))
    handler.addFilter(thread_id_filter)
    my_logger.addHandler(handler)
    my_logger.setLevel('INFO')
    my_logger.info('test123')

    logobj = logging.getLogger('server')
    handler.setFormatter(logging.Formatter('%(asctime)s | %(levelname)s | ThreadID=%(thread_id)s | %(message)s'))
    logobj.addFilter(NoParsingFilter())
    ## this log will not be output
    logobj.info('test123')
    ## this log will be output
    logobj.info('test223')

#  【python logging】自定义日志过滤器，通过参数控制日志记录
#  【需求要点】
#  当前程序已经实现日志记录到 log 文件。新增需求，需要把日志记录到文件的同时，通过 syslog 服务记录到系统日志中。
#  要求通过新增参数的方式实现日志记录扩展，不能影响原有日志记录。
#  如果在某一条日志记录处增加参数，则把该日志记录到日志文件和系统日志两个位置中。

class ContextFilter(logging.Filter):
    """
    这是一个控制日志记录的过滤器。
    """
    def filter(self, record):
        #print(f'record: {record.__dict__}')
        try:
            filter_key = record.TASK
        except AttributeError:
            return False

        if filter_key == "logToConsole":
            return True
        else:
            return False

def test_basic():
    # 创建日志对象
    print(f'{"#":#^64s}')
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)
    ## donot propagte to previous logger object
    logger.propagate = False

    # 创建日志处理器，记录日志到文件
    log_path = "./log.log"
    file_handler = logging.FileHandler(log_path)
    file_handler.setLevel(logging.INFO)
    file_fmt = "%(asctime)-15s %(levelname)s [%(filename)s %(lineno)d] %(message)s"
    file_formatter = logging.Formatter(file_fmt)
    file_handler.setFormatter(file_formatter)
    logger.addHandler(file_handler)

    # 添加日志处理器，输出日志到控制台
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.WARN)

    console_fmt = 'console %(asctime)-15s [%(TASK)s] %(message)s'
    console_formatter = logging.Formatter(console_fmt)
    console_handler.setFormatter(console_formatter)

    console_filter = ContextFilter()
    console_handler.addFilter(console_filter)

    logger.addHandler(console_handler)

    filter_dict = {'TASK': 'logToConsole'}

    # 记录日志
    logger.debug('debug message')
    logger.info('info message')
    logger.warning('warn message')
    logger.error('error message1', extra=filter_dict)
    logger.error('error message2')

def test_log_rotate():
    filename="fair-compute-ppc.log"
    os.system(f"/bin/rm {filename}*")
    a=input("input number")
    log = logging.getLogger('error.log')            # log保存位置
    # log时间戳格式
    format_str = logging.Formatter('%(asctime)s - %(thread)d\
        %(pathname)s[line:%(lineno)d] - %(levelname)s: %(message)s')
    log.setLevel(logging.DEBUG)                     # log日志等级（往下的内容不保存）
    sh = logging.StreamHandler()                    # 往屏幕上输出
    # filename:log文件名；maxBytes：超过最大尺寸，log会另存一个文件；
    # backupCount:最多保存多少个日志；encoding：保存编码格式
    #  th = handlers.RotatingFileHandler(filename='fair-compute-ppc.', maxBytes=4000, \
    #                                  backupCount=10, encoding='utf-8')
    th = handlers.RotatingFileHandler(filename=f'{filename}', maxBytes=4000, \
                                    backupCount=10)
    th.setFormatter(format_str)                     # 设置文件里写入的格式
    #log.addHandler(sh)
    log.addHandler(th)

    def writelog():
        for i in range(1000):
            log.info(f"{[i for i in range(10)]}")
    writelog()
    #with threading.
    with ThreadPoolExecutor(thread_name_prefix='workload', max_workers=100) as executor:
        for i in range(100):
            executor.submit(writelog)

if __name__ == '__main__':
    #test_basic2()
    #test_basic()
    test_log_rotate()
