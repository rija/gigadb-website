#!/usr/bin/env bash

set -ex

source ../../../../.env

if [ -f .init_env_vars ];then
  source .init_env_vars
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
    --project)
        has_project=true
        gitlab_project=$2
        shift
        ;;
    --ssh-key)
        has_ssh_key=true
        aws_ssh_key=$2
        shift
        ;;
    --env)
        has_env=true
        target_environment=$2
        shift
        ;;
    *)
        echo "Invalid option: $1"
        exit 1  ## Could be optional.
        ;;
    esac
    shift
done

# Ensure variables are not empty
if [ -z $gitlab_project ];then
  read -p "You need to specify a fully qualified Gitlab project (e.g: gigascience/upstream/gigadb-website): " gitlab_project
fi

if [ -z $aws_ssh_key ];then
  read -p "You need to specify the path to the ssh private key to use to connect to the EC2 instance: " aws_ssh_key
fi

if [ -z $target_environment ];then
  read -p "You need to specify a target environment (staging or live): " target_environment
fi

if [ -z $GITLAB_USERNAME ];then
  read -p "You need to specify your GitLab username: " GITLAB_USERNAME
fi

if [ -z $GITLAB_PRIVATE_TOKEN ];then
  read -p "You need to specify your GitLab username: " GITLAB_PRIVATE_TOKEN
fi

if [ -z $AWS_REGION ];then
  read -p "You need to specify an AWS region: " AWS_REGION
fi

# url encode gitlab project
encoded_gitlab_project=$(echo $gitlab_project | sed -e 's/\//%2F/g')


# Ensure we are in the environment-specific directory
if [ "envs/$target_environment" != `pwd | rev | cut -d"/" -f 1,2 | rev` ];then
  echo "You are not in the correct directory given the specified parameters. you should be in 'envs/$target_environment'"
  exit 1
fi

#####
# Terraform preparation part
#####

# copy the terraform and playbook files to the environment specific directory

cp ../../terraform.tf .
cp ../../getIAMUserNameToJSON.sh .

# Infer the name the EC2 key pair from the file name without extension from teh $aws_ssh_key variable
key_name=$(echo $aws_ssh_key | rev | cut -d"/" -f 1 | rev | cut -d"." -f 1)

# create the terraform variables file (must be named terraform.tfvars for terraform to recognise it automatically)
echo "deployment_target = \"$target_environment\"" > terraform.tfvars
echo "key_name = \"$key_name\"" >> terraform.tfvars
echo "aws_region = \"$AWS_REGION\"" >> terraform.tfvars
# create an environment variable file for this script and for ansible_init.sh
echo "gitlab_project=$gitlab_project" > .init_env_vars
echo "GITLAB_USERNAME=$GITLAB_USERNAME" >> .init_env_vars
echo "GITLAB_PRIVATE_TOKEN=$GITLAB_PRIVATE_TOKEN" >> .init_env_vars
echo "aws_ssh_key=$aws_ssh_key" >> .init_env_vars
echo "deployment_target=$target_environment" >> .init_env_vars


# Initialise a remote terraform state on GitLab

terraform init \
          -backend-config="address=https://gitlab.com/api/v4/projects/$encoded_gitlab_project/terraform/state/${target_environment}_infra" \
          -backend-config="lock_address=https://gitlab.com/api/v4/projects/$encoded_gitlab_project/terraform/state/${target_environment}_infra/lock" \
          -backend-config="unlock_address=https://gitlab.com/api/v4/projects/$encoded_gitlab_project/terraform/state/${target_environment}_infra/lock" \
          -backend-config="username=$GITLAB_USERNAME" \
          -backend-config="password=$GITLAB_PRIVATE_TOKEN" \
          -backend-config="lock_method=POST" \
          -backend-config="unlock_method=DELETE" \
          -backend-config="retry_wait_min=5"

#####
# Ansible preparation part
#####

source .init_env_vars

# copy Ansible files into the environment specific directory
cp ../../playbook.yml .



# Update properties file with values from GitLab so Ansible can configure the services
gigadb_db_host=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" "$PROJECT_VARIABLES_URL/gigadb_db_host?filter%5benvironment_scope%5d=$target_environment" | jq -r .value)
gigadb_db_user=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" "$PROJECT_VARIABLES_URL/gigadb_db_user?filter%5benvironment_scope%5d=$target_environment" | jq -r .value)
gigadb_db_password=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" "$PROJECT_VARIABLES_URL/gigadb_db_password?filter%5benvironment_scope%5d=$target_environment" | jq -r .value)
gigadb_db_database=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" "$PROJECT_VARIABLES_URL/gigadb_db_database?filter%5benvironment_scope%5d=$target_environment" | jq -r .value)

echo "gigadb_db_host = $gigadb_db_host" > ansible.properties
echo "gigadb_db_user = $gigadb_db_user" >> ansible.properties
echo "gigadb_db_password = $gigadb_db_password" >> ansible.properties
echo "gigadb_db_database = $gigadb_db_database" >> ansible.properties

fuw_db_host=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" "$PROJECT_VARIABLES_URL/fuw_db_host?filter%5benvironment_scope%5d=$target_environment" | jq -r .value)
fuw_db_user=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" "$PROJECT_VARIABLES_URL/fuw_db_user?filter%5benvironment_scope%5d=$target_environment" | jq -r .value)
fuw_db_password=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" "$PROJECT_VARIABLES_URL/fuw_db_password?filter%5benvironment_scope%5d=$target_environment" | jq -r .value)
fuw_db_database=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" "$PROJECT_VARIABLES_URL/fuw_db_database?filter%5benvironment_scope%5d=$target_environment" | jq -r .value)

echo "fuw_db_host = $fuw_db_host" >> ansible.properties
echo "fuw_db_user = $fuw_db_user" >> ansible.properties
echo "fuw_db_password = $fuw_db_password" >> ansible.properties
echo "fuw_db_database = $fuw_db_database" >> ansible.properties

echo "deployment_target = $deployment_target" >> ansible.properties
echo "gitlab_project = $gitlab_project" >> ansible.properties
echo "ssh_private_key_file = $aws_ssh_key" >> ansible.properties
echo "gitlab_private_token= $GITLAB_PRIVATE_TOKEN" >> ansible.properties



