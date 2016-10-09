#!/usr/bin/ansible-playbook -i 'localhost,' -c local -e vars_file=$WORKSPACE/vars_file.yml
- hosts: localhost
  vars_files:
    - "{{ vars_file }}"
  vars:
    run_shell: ./output.sh
  tasks:
    - name: "Prepare {{ run_shell }}"
      copy: content='#!/bin/bash' dest="{{ run_shell }}"
      become: yes
      become_user: jenkins

    - name: "Create {{ run_shell }}"
      blockinfile:
        dest: "{{ run_shell }}"
        marker: '# {mark}'
        insertafter: "^#!/bin/bash"
        block: |
          echo "# $(basename $0)"
          tempdir=$(mktemp -d -p "$HOME" -t deploy.XXXXXXXXXX)
          trap "rm -rf $tempdir" EXIT TERM KILL
          cd $tempdir
          echo "machine $(echo {{ url }} |cut -d'/' -f3) username {{ url_username |default('') }} password {{ url_password |default('') }}" > netrc
          curl -k -sL --netrc-file netrc -o $tempdir/{{ dest }}.zip {{ url }}
          unzip -q {{ dest }}.zip -d $tempdir
          {% for cmd in post_cmd %}
          {{ cmd }}
          {% endfor %}
      become: yes
      become_user: jenkins
