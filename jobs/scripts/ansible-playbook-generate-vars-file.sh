#!/bin/bash -ex
cat > vars_file.yml <<EOF
---
user: a
url: https://github.com/pli01/ansible-samples/archive/master.zip
dest: ansible-samples-master
pre_cmd: []
post_cmd: ["( export PYTHONUNBUFFERED=$PYTHONUNBUFFERED ; cd ansible-samples-master && ansible-playbook -i hosts -c local site.yml -e myvar='' )"]
EOF
