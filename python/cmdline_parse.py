import argparse

# sub-command functions
def foo(args):
    print(args.x * args.y)

def bar(args):
    print('((%s))' % args.z)

# create the top-level parser
parser = argparse.ArgumentParser()
subparsers = parser.add_subparsers(help='supported', title='subcommand', description='all supported command')

# create the parser for the "foo" command
parser_foo = subparsers.add_parser('foo', help='aaaaa')
parser_foo.add_argument('-m', type=int, default=1)
parser_foo.add_argument('x', type=int, default=1)
parser_foo.add_argument('y', type=float)
parser_foo.set_defaults(func=foo)

# create the parser for the "bar" command
parser_bar = subparsers.add_parser('bar', help='bbbbb')
parser_bar.add_argument('z')
parser_bar.set_defaults(func=bar)

arg1 = parser.parse_args()
arg1.func(arg1)

#  parse the args and call whatever function was selected
#  args = parser.parse_args('foo 1 -x 2'.split())
#  args.func(args)
#
#
#  parse the args and call whatever function was selected
#  args = parser.parse_args('bar XYZYX'.split())
#  args.func(args)

