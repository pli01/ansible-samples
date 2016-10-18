#!/bin/bash
[ -z ${name} ] && name=ctx1
[ -z ${DOCKER_USER} ] && DOCKER_USER=root
[ -z ${IMAGE_NAME} ] && IMAGE_NAME=debian-ssh

trap 'echo "# Cleanup"; docker rm -f -v ${name} || true ' KILL TERM EXIT;

echo "# Run container in detached state."
docker run --detach --name ${name} -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" --volume="$PWD/..":/project:ro ${run_opts} $IMAGE_NAME ; \
docker ps -f name=${name} ; \

echo "# Generate inventory"
ip=$(docker inspect --format='{{.NetworkSettings.IPAddress}}' ${name})
echo "$name ansible_ssh_host=$ip ansible_ssh_user=${DOCKER_USER} ansible_ssh_pass=''" > inventory

echo "# ssh check access" ; \
ssh ${DOCKER_USER}@$ip -tt -o "StrictHostKeyChecking=no" env TERM=xterm ls -alsrt /project/tests ; \

echo "# Basic role syntax check" ; \
ansible-playbook tests-install.yml -i inventory --syntax-check ; \
#docker exec -t "${name}" bash -c "cd /project/tests && ansible-playbook tests-install.yml -i inventory --syntax-check" ; \
#ssh ${DOCKER_USER}@$ip -tt -o "StrictHostKeyChecking=no" 'cd /project/tests && ansible-playbook tests-install.yml -i inventory -c local --syntax-check'

echo "# Run the role/playbook." ; \
ansible-playbook tests-install.yml -i inventory --diff -v ; \
#docker exec -t "${name}" bash -c "cd /project/tests && ansible-playbook tests-install.yml -i inventory --connection=local --diff" ; \

echo "# Run the role/playbook again, checking to make sure it's idempotent."
#docker exec -t "${name}" bash -c "cd /project/tests && ansible-playbook tests-install.yml -i inventory --connection=local" \
ansible-playbook tests-install.yml -i inventory -v \
  | tee /dev/tty  \
  | grep -q 'changed=0.*failed=0'  \
  && (echo 'Idempotence test: pass' && exit 0)  \
  || (echo 'Idempotence test: fail' && exit 1)
