#!/bin/bash -e
STDOUT=output.stdout
STDERR=output.stderr

if [ -f $STDERR ] ;then
 echo "########### STDERR ###########"
 cat $STDERR
 echo ""
fi
if [ -f $STDOUT ] ;then
 echo "########### STDOUT ###########"
 cat $STDOUT
 echo ""
fi

echo ""

cat $STDOUT \
  | grep -q "unreachable=0.*failed=0"  \
  && (echo 'Success' && exit 0) \
  || (echo 'Failed' && exit 1)
