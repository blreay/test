import threading  
import time  
import random  
import faulthandler
import logging
import os
import time
from dataclasses import dataclass
from logging.handlers import QueueHandler
from pathlib import Path
from queue import Queue
from concurrent.futures import ThreadPoolExecutor, Future
from multiprocessing import get_context
from multiprocessing.managers import SyncManager
from typing import List
from patch import sync_manager
from patch.sync_manager import MySyncManager

import context.aterror

L = []   

class SubProcManager(MySyncManager):
    def __init__(self):
        from patch import trace
        # extra init trace log
        super(SubProcManager, self).__init__(preloads=[trace.__name__])

def test_reg():
    print(f'[{os.getpid()}]begin test_reg')

def test_clean():
    print(f'[{os.getpid()}]begin test_reg')

def act():
    time.sleep(1)
    from context.aterror import critical_error
    critical_error('zzy')

class runner:
    def wait_error(e):
        print(f'[{os.getpid()}]begin wait_error ')
        from context.aterror import wait_critical_error
        wait_critical_error()

SubProcManager.register('test', runner)
SubProcManager.register('clean_up', test_clean)
SubProcManager.register('doact', act)


def _sub_proc_init_func(working_dir, proc_title):
    # set proc title for usability
    from setproctitle import setproctitle
    setproctitle(proc_title)

    # signal handler
    import signal
    #signal.signal(signal.SIGTERM, _sigterm_handler)

    os.chdir(working_dir)



def wait_error2():
    from context.aterror import wait_critical_error
    wait_critical_error()

def on_error_callback(e):
    print(f'[{os.getpid()}]on_error_callback')


if __name__ == '__main__':   
    #_WAIT_ERROR_POOL = ThreadPoolExecutor(thread_name_prefix='WAIT_ERROR_POOL', max_workers=2)
    #_WAIT_ERROR_POOL.submit(wait_error).add_done_callback(on_error_callback)

    #_WAIT_ERROR_POOL2 = ThreadPoolExecutor(thread_name_prefix='WAIT_ERROR_POOL', max_workers=2)
    #_WAIT_ERROR_POOL2.submit(wait_error).add_done_callback(on_error_callback)

    working_dir="/tmp"
    manager = SubProcManager()
    manager.start(_sub_proc_init_func, (working_dir, "aaa"))
    print(f"[{os.getpid()}]launch subprocess [{manager._process.pid}]")

    manager2 = SubProcManager()
    manager2.start(_sub_proc_init_func, (working_dir, "bbb"))
    print(f"[{os.getpid()}]launch subprocess [{manager2._process.pid}]")
    #time.sleep(200)


    handler=manager.test()
    _WAIT_ERROR_POOL = ThreadPoolExecutor(thread_name_prefix='WAIT_ERROR_POOL', max_workers=2)
    _WAIT_ERROR_POOL.submit(handler.wait_error).add_done_callback(on_error_callback)

    handler2=manager2.test()
    _WAIT_ERROR_POOL2 = ThreadPoolExecutor(thread_name_prefix='WAIT_ERROR_POOL2', max_workers=2)
    _WAIT_ERROR_POOL2.submit(handler2.wait_error).add_done_callback(on_error_callback)

    time.sleep(1)

    ## NOTE: following code will activate the event in the first manager process
    handler3=manager.doact()
    print(f'first event has been set')
    time.sleep(2)

    ## NOTE: following code will activate the event in the second manager process
    handler4=manager2.doact()
    print(f'second event has been set')
    time.sleep(2)

    ## NOTE: following code cannot work, because act() is not running in manager process
    #R = threading.Thread(target = act)
    #R.start()   
    #R.join()   

    time.sleep(2)

