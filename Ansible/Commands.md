# install ansible on Linux

amazon-linux-extras install ansible2

# verify version
ansible --version

ansible <group name> --<command>
ansible webservers --lists hosts

 # ping group of hosts/all/or single node
ansible webservers -m ping

# get details of any ad-hoc commands

ansible-doc <module name>

ansible doc ping

# -o single line output
ansible all -m ping -o 

# ad-hoc execute scripts
ansible <server alias> options -m shell -a "<command>"

 ansible webservers -m shell -a "systemctl status sshd"

 # default ad hoc module is command

 # copy file with copy module
 ansible webservers -m copy -a "src=<source path on controller node> dest=<destination path on managed node>>"

 # use shell command to create a file
 ansible node1 -m shell -a "echo Hello Clarusway > /home/ec2-user/testfile2; cat testfile2"

 # to manage multiple manage hosts use :
 hosts: webservers:dbservers
 hosts: node1:node2

 # -b flag ignores confirmation

 ansible webservers -b -m shell -a "amazon-linux-extras install -y nginx1 ; systemctl start nginx ; systemctl enable nginx" 

 # to pass an inventory file on command line
ansible -i inventory -b -m yum -a "name=httpd state=present" node1 
ansible -i inventory -b -m yum -a "name=httpd state=absent" node1 

# secure copy

# run a playbook 
ansible-playbook playbook1.yml

# loop 

- name: play 5
  hosts: webservers
  tasks:
    - name: installing httpd and wget
      yum:
        pkg: "{{ item }}"
        state: present
      loop:
        - httpd
        - wget


# conditions

- name: Create users
  hosts: "*"
  tasks:
    - user:
        name: "{{ item }}"
        state: present
      loop:
        - joe
        - matt
        - james
        - oliver
      when: ansible_os_family == "RedHat"

# using facts, vars, secrets

# debug module returns facts about managed nodes

```yml
- name: show facts #name of yaml book
  hosts: all # run playbook against which managed nodes
  tasks:
    - name: print facts # name of task, will print on screen
      debug: # ansible module name
        var: ansible_facts # module parameters
```

# Working with sensitive data 

# create a secret file 

ansible-vault create secret.yml

answer what is prompt as following

New Vault password: xxxx
Confirm Nev Vault password: xxxx

# Update content of secret yaml

```yml
username: tyler
password: 99abcd
```

# how to use it? 

# Create a yml file 

```yml
- name: create a user
  hosts: all
  become: true
  vars_files:
    - secret.yml # name of secret file
  tasks:
    - name: creating user
      user:
        name: "{{ username }}" # variables
        password: "{{ password }}" # variables
```

# run playbook by asking secret yml password

 ansible-playbook --ask-vault-pass create-user.yml

 # verify if user was created 

 ansible all -b -m command -a "grep tyler /etc/shadow"

 # how to hash password with secret.yml

 ```bash
ansible-vault create secret-1.yml
```

New Vault password: xxxx
Confirm Nev Vault password: xxxx

```yml
username: Oliver
pwhash: 14abcd # hash password
```

# use hashed password
```yml
- name: create a user
  hosts: all
  become: true
  vars_files:
    - secret-1.yml
  tasks:
    - name: creating user
      user:
        name: "{{ username }}"
        password: "{{ pwhash | password_hash ('sha512') }}"     
``` 


# dynamic inventory

Create  a role with full ec2 instance "AmazonEC2FullAccess"

Attach IAM role to ansible control node

install boto3 and botocore on control node

# use below plugin

```yml
plugin: aws_ec2 # aws plugin
regions:
  - "us-east-1" # region
keyed_groups:
  - key: tags.Name # ec2 tags .Name property
compose:
  ansible_host: public_ip_address

```

# run playbook

```bash
$ ansible-inventory -i inventory_aws_ec2.yml --graph
```

# create a playbook to create a  user on each managed node to test dynamic inventory

# 
- name: create a user using a variable
  hosts: all
  become: true
  vars:
    user: lisa
    ansible_ssh_private_key_file: "/home/ec2-user/<pem file>"
  tasks:
    - name: create a user {{ user }}
      user:
        name: "{{ user }}"


# https://docs.ansible.com/ansible/latest/plugins/plugins.html



# ansible configuration 
# https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html

# A web server provisioning

# Contoller node prerequisites

- copy pem file to remote

- install python3
- install ansible

- inventory file for managed nodes

# Steps to configure db server

- Task 1 install mariadb and pymysql
        - start mariadb
        - enable mariadb
- create sql script to create a table and insert sample data in it
- copy file to db server with copy module
- create a root user with mysql_user module
- create a file .my.cnf on control node and copy it to db server
```conf
[client]
user=root
password=clarus1234

[mysqld]
wait_timeout=30000
interactive_timeout=30000
bind-address=0.0.0.0
```

-  create a remote user so application can use it
- create database schema with mysql_db module

- check if db has a table 
```yml
    - name: check if the database has the table
      shell: |
        echo "USE ecomdb; show tables like 'products'; " | mysql
      register: resultOfShowTables

    - name: DEBUG
      debug:
        var: resultOfShowTables
```

- if table not existed then execute sql script to create table and insert sample data
```yml
    - name: Import database table
      mysql_db:
        name: ecomdb   # This is the database schema name.
        state: import  # This module is not idempotent when the state property value is import.
        target: ~/db-load-script.sql # This script creates the products table.
      when: resultOfShowTables.stdout == "" # This line checks if the table is already imported. If so this task doesn't run.
```
- restart maria db

# Web server configuration

- install the latest version of Git, Apache, Php, Php-Mysqlnd
- start apache server
- clone repository to /var/www/html/ destination of web server
- for one time replace IP address with db server ip address
```yml
    - name: clone the repo of the website
      shell: |
        if [ -z "$(ls -al /var/www/html | grep .git)" ]; then
          git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/
          echo "ok"
        else
          echo "already cloned..."
        fi
      register: result

    - name: DEBUG
      debug:
        var: result

    - name: Replace a default entry with our own
      lineinfile:
        path: /var/www/html/index.php
        regexp: '172\.20\.1\.101'
        line: "$link = mysqli_connect('{{ hostvars['db_server'].ansible_host }}', 'remoteUser', 'clarus1234', 'ecomdb');"
      when: not result.stdout == "already cloned..."
```

- disable security enhanced linux 
- restart apache server 

DONE! 

# ansible roles

# update ansible config to add roles path

```conf
[defaults]
host_key_checking = False
inventory=inventory.txt
interpreter_python=auto_silent
roles_path = /home/ec2-user/ansible/roles/
```

# get ansible apache role

ansible-galaxy init /home/ec2-user/ansible/roles/apache

ansible-galaxy  list





















