#!//bin/bash -ex

test -f output.err && cat output.err
test -f output.log && cat output.log

cat output.log \
  | grep -q "unreachable=0.*failed=0"  \
  && (echo 'Success: pass' && exit 0) \
  || (echo 'Failed: fail' && exit 1)

