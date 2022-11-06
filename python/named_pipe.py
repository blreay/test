import multiprocessing
import os
import traceback
import time
import json
import sys
import fcntl
 
class Pipe:
    def __init__(self, pipe_name):
        file_path = "/tmp/"
        try:
            self.fifo_path = "{}{}.pipe".format(file_path, pipe_name)
            os.mkfifo(self.fifo_path)
        except Exception:
            print(traceback.format_exc())
        self.block_file = "/tmp/block_{}.file".format(pipe_name)
        if not os.path.exists(self.block_file):
            f = open(self.block_file, "w")
            f.close()
        self.fp_block = open(self.block_file, "w")
 
    def __lock(self, flag=fcntl.LOCK_EX | fcntl.LOCK_NB):
        fcntl.flock(self.fp_block.fileno(), flag)
 
    def __unlock(self):
        fcntl.flock(self.fp_block.fileno(), fcntl.LOCK_UN)
 
    def send(self, msg):
        try:
            self.__lock()
            f = os.open(self.fifo_path, os.O_RDWR | os.O_NONBLOCK)
            os.write(f, "{};".format(json.dumps(msg)).encode("utf-8"))
        except Exception:
            print(traceback.format_exc())
            return False
        finally:
            self.__unlock()
        return True
 
    def receive(self):
        msg_str = ""
        try:
            self.__lock()
            f = os.open(self.fifo_path, os.O_RDWR | os.O_NONBLOCK)
            while True:
                s = os.read(f, 1).decode("utf-8")
                if s != ";":
                    msg_str += s
                else:
                    break
        except Exception:
            print(traceback.format_exc())
            return ""
        finally:
            self.__unlock()
        return msg_str
 
 
if __name__ == '__main__':
    pipe_name = "test.pipe"
    pid = os.fork()
    if pid:
        pipe = Pipe(pipe_name)
        pipe.send({"code": "A00000", "data": "xxx"})
        pipe.send({"code": "A00000", "data": "yyy"})
        time.sleep(5)
        print("send end")
    else:
        pipe = Pipe(pipe_name)
        time.sleep(1)
        s = pipe.receive()
        print("receive1 = {}".format(s))
        s = pipe.receive()
        print("receive2 = {}".format(s))
        pass
    sys.exit(0)
