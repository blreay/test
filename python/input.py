#encoding: utf-8
 
import threading
from pykeyboard import *
 
def thread_entry(userInput:str, waitSec:int=3):
    userInput['input'] = input(f'请在 {waitSec} 秒内完成信息输入并回车\n :) ')
 
def run():
    userInput = {'input': None} # 默认为空
    waitSec = 10
    t = threading.Thread(target=thread_entry, args=(userInput, waitSec))
    t.start()
    t.join(waitSec)
 
    if userInput['input'] is None or 0 == len(userInput['input']):
        k = PyKeyboard()
        k.tap_key(k.enter_key)
        print("超时。使用默认值。")
    else:
        print(f"你的输入为“{userInput['input']}”")
 
if __name__=="__main__":
    run()
