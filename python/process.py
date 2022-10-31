from multiprocessing import Process, Manager
import time

def f(d, l):
    d[1] = "1"
    d["2"] = 2
    d[0.25] = None
    l.reverse()
    time.sleep(2)

if __name__ == '__main__':
    with Manager() as manager:
        d = manager.dict()
        l = manager.list(range(10))

        p = Process(target=f, args=(d,l))
        p.start()
        p.join()

        print(d)
        print(l)
