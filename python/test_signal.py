import sys
import os
import signal
import atexit
import time

def release():
    print ("Release resources...")

#def sigHandler():
def sigHandler(signo, frame):
    sys.exit(0)

import atexit
import os
import signal
import sys


if os.name != 'posix':
    raise ImportError("POSIX only")
_registered_exit_funs = set()
_executed_exit_funs = set()
_exit_signals = frozenset([signal.SIGTERM])


def register_exit_fun(fun, signals=_exit_signals):
    """Register a function which will be executed on "normal"
    interpreter exit or in case one of the `signals` is received
    by this process (differently from atexit.register()).

    Also, it makes sure to execute any previously registered
    via signal.signal().If any, it will be executed after `fun`.

    Functions which were already registered or executed via this
    function will be skipped.

    Exit function will not be executed on SIGKILL, SIGSTOP or
    os._exit(0).
    """
    def fun_wrapper():
        if fun not in _executed_exit_funs:
            try:
                fun()
            finally:
                _executed_exit_funs.add(fun)

    def signal_wrapper(signum=None, frame=None):
        if signum is not None:
            pass
            # smap = dict([(getattr(signal, x), x) for x in dir(signal)
            #              if x.startswith('SIG')])
            # print("signal {} received by process with PID {}".format(
            #     smap.get(signum, signum), os.getpid()))
        fun_wrapper()
        # Only return the original signal this process was hit with
        # in case fun returns with no errors, otherwise process will
        # return with sig 1.
        if signum is not None:
            if signum == signal.SIGINT:
                raise KeyboardInterrupt
            # XXX - should we do the same for SIGTERM / SystemExit?
            sys.exit(signum)

    if not callable(fun):
        raise TypeError("{!r} is not callable".format(fun))
    set([fun])  # raise exc if obj is not hash-able

    for sig in signals:
        # Register function for this signal and pop() the previously
        # registered one (if any). This can either be a callable,
        # SIG_IGN (ignore signal) or SIG_DFL (perform default action
        # for signal).
        old_handler = signal.signal(sig, signal_wrapper)
        if old_handler not in (signal.SIG_DFL, signal.SIG_IGN):
            # ...just for extra safety.
            if not callable(old_handler):
                continue
            # This is needed otherwise we'll get a KeyboardInterrupt
            # strace on interpreter exit, even if the process exited
            # with sig 0.
            if (sig == signal.SIGINT and
                    old_handler is signal.default_int_handler):
                continue
            # There was a function which was already registered for this
            # signal. Register it again so it will get executed (after our
            # new fun).
            if old_handler not in _registered_exit_funs:
                atexit.register(old_handler)
                _registered_exit_funs.add(old_handler)

    # This further registration will be executed in case of clean
    # interpreter exit (no signals received).
    if fun not in _registered_exit_funs or not signals:
        atexit.register(fun_wrapper)
        _registered_exit_funs.add(fun)

def cleanup():
    print("cleanup")


if __name__ == "__main__":
    #atexit.register(release)
    #signal.signal(signal.SIGTERM, sigHandler)
    # signal.signal(signal.SIGKILL, sigHandler)
    #signal.signal(signal.SIGINT, sigHandler)
    register_exit_fun(cleanup)

    print("aaa, pid=" + str(os.getpid()))
    time.sleep(1000)
    print("aaa")
    sys.exit(0)
    #while True:
    #    pass