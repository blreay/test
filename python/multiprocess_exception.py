import multiprocessing, traceback, time

class Process(multiprocessing.Process):

    def __init__(self, *args, **kwargs):
        multiprocessing.Process.__init__(self, *args, **kwargs)
        self._pconn, self._cconn = multiprocessing.Pipe()
        self._exception = None

    def run(self):
        try:
            multiprocessing.Process.run(self)
            self._cconn.send(None)
        except Exception as e:
            tb = traceback.format_exc()
            self._cconn.send((e, tb))
            #raise e  # You can still rise this exception if you need to

    @property
    def exception(self):
        if self._pconn.poll():
            self._exception = self._pconn.recv()
        return self._exception


# this function will be executed in a child process asynchronously
def failFunction():
   raise RuntimeError('trust fall, catch me!')

# execute the helloWorld() function in a child process in the background
process = Process(
 target = failFunction,
)
process.start()

# <this is where async stuff would happen>
time.sleep(1)

# catch the child process' exception
try:
    process.join()
    if process.exception:
        raise process.exception
except Exception as e:
    print( "Exception caught!" )
