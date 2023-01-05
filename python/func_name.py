#!/bin/env python3

'''
Test how to get current func name when writting log
'''

import inspect
import sys

def get_current_function_name():
    return inspect.stack()[1][3]
class MyClass:
    def function_one(self):
        print("%s.%s invoked"%(self.__class__.__name__, get_current_function_name()))

def get_current_func_name2():
    #return sys._getframe().f_code.co_name
    return sys._getframe().f_back.f_code.co_name

def test2():
    print(f"current_func is {get_current_func_name2()}")
    

if __name__ == "__main__":
    myclass = MyClass()
    myclass.function_one()

    def test():
        import sys
        funcName = sys._getframe().f_back.f_code.co_name #获取调用函数名
        lineNumber = sys._getframe().f_back.f_lineno     #获取行号

        print(sys._getframe().f_code.co_name) # 获取当前函数名

    test()
    test2()
