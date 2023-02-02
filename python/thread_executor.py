#!/bin/env python3

import threading
from concurrent.futures import ThreadPoolExecutor
 
# a mock task that does nothing
def task(name):
    pass
 
# create a thread pool with a custom name prefix
executor =  ThreadPoolExecutor(thread_name_prefix='TaskPool', max_workers=3)
executor1 = ThreadPoolExecutor(thread_name_prefix='TaskPool0', max_workers=3)
# execute asks
executor.map(task, range(100))
executor1.map(task, range(100))
# report all thread names
for thread in threading.enumerate():
    print(thread.name)
# shutdown the thread pool
executor.shutdown()
