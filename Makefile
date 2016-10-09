syntax-check:
	ansible-playbook -i hosts -c local site.yml -e myvar='' --syntax-check
list-tasks:
	ansible-playbook -i hosts -c local site.yml -e myvar='' --list-tasks
list-hosts:
	ansible-playbook -i hosts -c local site.yml -e myvar='' --list-hosts
deploy: list-hosts list-tasks syntax-check
	ansible-playbook -i hosts -c local site.yml -e myvar='' -v
