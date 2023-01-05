#!/bin/env python3

#ps：下面看下python中过滤器filter用法

#第一个参数是一个返回bool值的一般函数或lambda函数，第二个参数是一个可迭代对象
#最后返回一个可迭代对象，可以通过list获得
def is_positive(item):
  return item>0
values = [1,-2,3,-4]
print(filter(is_positive,values))
a = list(filter(is_positive,values))
print(a)
print(values)
#output
#  <filter object at 0x000002398A1AB4A8>
#  [1, 3]
#  [1, -2, 3, -4]
b = list(filter(lambda item:item>0,values))
print(b)
 #output
#  [1,3]
