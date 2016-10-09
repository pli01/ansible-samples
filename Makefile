list-hosts:
	ansible-playbook -i hosts -c local site.yml -e myvar='' --list-hosts
list-tasks:
	ansible-playbook -i hosts -c local site.yml -e myvar='' --list-tasks
syntax-check:
	ansible-playbook -i hosts -c local site.yml -e myvar='' --syntax-check
deploy: list-hosts list-tasks syntax-check
	 export PYTHONUNBUFFERED=1 ; stdbuf -e0 -o0 ansible-playbook -i hosts -c local site.yml -e myvar='' -vv
