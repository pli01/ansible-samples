#!/usr/bin/ansible-playbook -i 'localhost,' -c local -e vars_file=$WORKSPACE/vars_file.yml
#
# Usage
#  ./get_package.yml -e vars_file=vars.yml
#   with vars.yml
#     user: jenkins
#     url: https://github.com/pli01/docker-samples/archive/master.zip
#     dest: docker-samples-master
#     post_cmd: ["ansible -i localhost, -c local localhost -m setup"] 
#
#  ./get_package.yml -e user=jenkins -e url=https://github.com/pli01/docker-samples/archive/master.zip -e dest=docker-samples-master -e '{ post_cmd: ["make""] }' 
#
- hosts: localhost
  become: true
  become_user: "{{ user }}"
  vars_files:
   - "{{ vars_file }}"
  vars:
    user: ''
    url: ''
    url_username: ''
    url_password: ''
    force: 'yes'

    proxy: yes
    proxy_env:
      http_proxy: "{{http_proxy | default('')}}"
      https_proxy: "{{https_proxy | default('')}}"
      no_proxy: "localhost"

    pre_cmd:
      - "whoami"
    post_cmd:
      - "make -C {{ tempdir }}/{{ dest }} build DISTRIB='debian'"
  tasks:
    - block:
       - name: "Create temp dir"
         shell: mktemp -d -p "$HOME" -t deploy.XXXXXXXXXX
         register: mktemp

       - name: "Register {{ mktemp.stdout }}"
         set_fact:
           tempdir: "{{ mktemp.stdout }}"

       - name: "Run pre command"
         shell: "{{ item }}"
         with_items: "{{ pre_cmd }}"
         args:
           chdir: "{{ tempdir }}"
         when: pre_cmd
         changed_when: False
         ignore_errors: true

       - name: "Get package {{ url }}"
         get_url: {url: "{{ url }}", dest: "{{ tempdir }}", tmp_dest: "{{ tempdir }}", url_username: "{{ url_username }}", url_password: "{{ url_password }}", validate_certs: no, use_proxy: '{{ proxy }}', force: '{{ force }}' }
         environment: "{{ proxy_env }}"
         when: url
         register: destfile

       - name: "Uncompress package {{ destfile.dest }}"
         unarchive: { copy: no, src: "{{ destfile.dest }}", dest: "{{ tempdir }}" }
         when: destfile.dest

       - name: "Run post command"
         shell: "{{ item }}"
         with_items: "{{ post_cmd }}"
         args:
           chdir: "{{ tempdir }}"
#         creates: test.txt
#         changed_when: False
         when: post_cmd
         register: post_cmd_out

       - name: "Output debug post_cmd_out"
         debug: var=post_cmd_out.results[0].stdout_lines

      rescue:
       - name: "Error message post_cmd_out"
         debug: msg='{{ post_cmd_out }}'

      always: 
       - name: "Cleanup temp dir {{ tempdir }}"
         file: { name: "{{ tempdir }}", state: absent }
       - debug: var=post_cmd_out.results[0].stderr
         failed_when: post_cmd_out.results[0].rc > 0
         when: post_cmd_out.results[0].rc > 0

- hosts: localhost
  tasks:
    - shell: "echo '{{ post_cmd_out.results[0].stdout | to_nice_json }}' > output.log"
    - shell: "echo '{{ post_cmd_out | to_nice_json }}' > output.json"
