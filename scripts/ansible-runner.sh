#!/bin/sh
database_name=$1
server_fqdn=$2
administrator_user=$3
administrator_password=$4
database_user_password=$5

pip install pipenv
pipenv install

pipenv run ansible-playbook --extra-vars "{\"database_name\": $1, \"server_fqdn\": $2, \"administrator_user\": $3, \"administrator_password\": $4, \"database_user_password\": $5
}" --connection=local -i 127.0.0.1 ../playbook-ansible/main.yml
