#!/bin/bash -ex
cat > vars_file.yml <<EOF
---
user: jenkins
url: https://github.com/pli01/ansible-samples/archive/master.zip
dest: ansible-samples-master
pre_cmd: []
post_cmd: ["( export PYTHONUNBUFFERED=1 ; cd ansible-samples-master && ansible-playbook -i hosts -c local site.yml -e toto='titi' )"]
EOF

