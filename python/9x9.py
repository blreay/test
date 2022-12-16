#!/bin/env python

print("Hello, World")
for a in range(1,10):       #外层控制行
    for b in range(1, a+1):    #内层控制列
        #print('{0}x{1}={2}'.format(b,a,b*a),end='\t')
        print(f'{a}x{b}={a*b}',end='\t')
    print()
print(f"=========== 作者：Richie ============")
