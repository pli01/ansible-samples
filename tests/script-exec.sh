#!/bin/bash
[ -z ${container_id} ] && container_id=out
[ -z ${name} ] && name=ctx1

trap 'echo "# Cleanup"; cat ${container_id} | xargs docker rm -f -v || true ; \
  rm -rf ${container_id}; ' KILL TERM EXIT;
#  docker ps -f status=exited -a -q | xargs docker rm -f -v || true ; \

echo "# Run container in detached state."
#docker run --detach --name ${name} --volume="$PWD/..":/project:ro ${run_opts} $IMAGE_NAME "/sbin/init" > "${container_id}" ; \
docker run --detach --name ${name} -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" --volume="$PWD/..":/project:ro ${run_opts} $IMAGE_NAME  > "${container_id}" ; \
docker ps -f name=${name} ; \

echo "# Ansible syntax check." ; \
docker exec --tty "${name}" env TERM=xterm ls -alsrt /project ; \

echo "# Basic role syntax check" ; \
docker exec -t "${name}" bash -c "cd /project/tests && ansible-playbook tests-install.yml -i inventory --syntax-check" ; \

echo "# Run the role/playbook." ; \
docker exec -t "${name}" bash -c "cd /project/tests && ansible-playbook tests-install.yml -i inventory --connection=local --diff" ; \

echo "# Run the role/playbook again, checking to make sure it's idempotent."
docker exec -t "${name}" bash -c "cd /project/tests && ansible-playbook tests-install.yml -i inventory --connection=local" \
  | tee /dev/tty  \
  | grep -q 'changed=0.*failed=0'  \
  && (echo 'Idempotence test: pass' && exit 0)  \
  || (echo 'Idempotence test: fail' && exit 1)
