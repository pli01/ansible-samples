#!/bin/bash -e
STDOUT=output.stdout
STDERR=output.stderr

test -f $STDERR && cat $STDERR
test -f $STDOUT && cat $STDOUT

echo ""

cat $STDOUT \
  | grep -q "unreachable=0.*failed=0"  \
  && (echo 'Success' && exit 0) \
  || (echo 'Failed' && exit 1)

