#!/bin/env python3

import threading

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

def thread_id_filter(record):
    """Inject thread_id to log records"""
    record.thread_id = threading.get_native_id()
    return record

import logging

my_logger = logging.getLogger()
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter('%(asctime)s | %(levelname)s | [%(process)d/%(thread)d] ThreadID=%(thread_id)s | %(message)s'))
handler.addFilter(thread_id_filter)
my_logger.addHandler(handler)
my_logger.setLevel('INFO')
my_logger.info('test123')

