#!/bin/env python3

from multiprocessing import Manager, Process
import time


class A:
    def __init__(self):
        self.manager = Manager()

    def start(self):
        print("started")
        time.sleep(5)

if __name__ == "__main__":
    a = A()
    proc = Process(target=a.start)
    print(f'{proc.start()}')
    print(f'{proc.join()}')
    proc.join()
