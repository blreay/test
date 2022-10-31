#task_master.py
import random,time,queue
from multiprocessing.managers import BaseManager

task_queue = queue.Queue()
result_queue = queue.Queue()

class QueueManager(BaseManager):
    pass

if __name__ == '__main__':
    print("master start.")
    QueueManager.register('get_task_queue',callable = lambda:task_queue)
    QueueManager.register('get_result_queue',callable = lambda:result_queue)
    manager = QueueManager(address = ('0.0.0.0',9833),authkey=b'abc')
    manager.start()
    task = manager.get_task_queue()
    result = manager.get_result_queue()

    for i in range(10):
        n = random.randint(0,1000)
        print('put task %d ...' % n)
        task.put(n)
    print('try get results...')

    for i in range(10):
        r = result.get(timeout = 100)
        print('Result:%s' % r)
    time.sleep(5)
    manager.shutdown()
    print('master exit.')

