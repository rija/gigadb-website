#!/usr/bin/env bash

# bail out if an unset variable is used
#set -u

# bail out as soon as there is an error
set -e

# Load environment variables
source "./.env"
source "./.secrets"

# Path to the certs
FULLCHAIN_PEM=/etc/letsencrypt/archive/$REMOTE_HOSTNAME/fullchain1.pem
PRIVATE_PEM=/etc/letsencrypt/archive/$REMOTE_HOSTNAME/privkey1.pem
CHAIN_PEM=/etc/letsencrypt/archive/$REMOTE_HOSTNAME/chain1.pem

# docker-compose executable
if [[ $GIGADB_ENV != "dev" && $GIGADB_ENV != "CI" ]];then
	DOCKER_COMPOSE="docker-compose --tlsverify -H=$REMOTE_DOCKER_HOST -f ops/deployment/docker-compose.production-envs.yml"
else
	DOCKER_COMPOSE="docker-compose"
fi

echo "Checking whether the certificate exists locally"
cert_files_local_exists=$($DOCKER_COMPOSE run --rm config /bin/bash -c "test -f $FULLCHAIN_PEM && test -f $PRIVATE_PEM && test -f $CHAIN_PEM && echo 'true' || echo 'false'")
echo "cert_files_local_exists: $cert_files_local_exists"
echo "To see if they could be found in gitlab"
if ! [ -z "$tls_fullchain_pem" ];then
  fullchain_pem_remote_exists="true"
else
  fullchain_pem_remote_exists="false"
fi

if ! [ -z "$tls_privkey_pem" ];then
  privkey_pem_remote_exists="true"
else
  privkey_pem_remote_exists="false"
fi

if ! [ -z "$tls_chain_pem" ];then
  chain_pem_remote_exists="true"
else
  chain_pem_remote_exists="false"
fi

echo "fullchain_pem_remote_exists: $fullchain_pem_remote_exists"
echo "privkey_pem_remote_exists: $privkey_pem_remote_exists"
echo "chain_pem_remote_exists: $chain_pem_remote_exists"

encoded_gitlab_project=$(echo $CI_PROJECT_PATH | sed -e 's/\//%2F/g')

if [[ $cert_files_local_exists == 'true' ]];then
  echo "Read content of files"
  fullchain=$($DOCKER_COMPOSE run --rm config cat $FULLCHAIN_PEM)
  privkey=$($DOCKER_COMPOSE run --rm config cat $PRIVATE_PEM)
  chain=$($DOCKER_COMPOSE run --rm config cat $CHAIN_PEM)

	echo "Renewing the certificate for $REMOTE_HOSTNAME"
	$DOCKER_COMPOSE run --rm certbot renew
	echo "Backup the fullchain cert to gitlab variable"
	if [ $fullchain_pem_remote_exists == "true" ];then
	  echo "/usr/bin/curl --show-error --silent --request PUT --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables/tls_fullchain_pem?filter%5benvironment_scope%5d=$GIGADB_ENV' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'value=\$fullchain'"
    $DOCKER_COMPOSE run --rm config bash -c "/usr/bin/curl --show-error --silent --request PUT --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables/tls_fullchain_pem?filter%5benvironment_scope%5d=$GIGADB_ENV' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'value=$fullchain'"
	else
	  echo "/usr/bin/curl --show-error --silent --request POST --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'key=tls_fullchain_pem' --form 'value=\$fullchain'"
    $DOCKER_COMPOSE run --rm config bash -c "/usr/bin/curl -L --show-error --silent --request POST --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'key=tls_fullchain_pem' --form 'value=$fullchain'"
	fi
  echo "Backup the private key to gitlab variable"
	if [ $privkey_pem_remote_exists == "true" ];then
	  echo "/usr/bin/curl --show-error --silent --request PUT --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables/tls_privkey_pem?filter%5benvironment_scope%5d=$GIGADB_ENV' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'value=\$privkey'"
    $DOCKER_COMPOSE run --rm config bash -c "/usr/bin/curl --show-error --silent --request PUT --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables/tls_privkey_pem?filter%5benvironment_scope%5d=$GIGADB_ENV' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'value=$privkey'"
	else
	  echo "/usr/bin/curl --show-error --silent --request POST --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'key=tls_privkey_pem' --form 'value=\$privkey'"
    $DOCKER_COMPOSE run --rm config bash -c "/usr/bin/curl -L --show-error --silent --request POST --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'key=tls_privkey_pem' --form 'value=$privkey'"
	fi
	echo "Backup the chain cert to gitlab variable"
	if [ $chain_pem_remote_exists == "true" ];then
	  echo "/usr/bin/curl --show-error --silent --request PUT --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables/tls_chain_pem?filter%5benvironment_scope%5d=$GIGADB_ENV' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'value=\$chain'"
    $DOCKER_COMPOSE run --rm config bash -c "/usr/bin/curl --show-error --silent --request PUT --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables/tls_chain_pem?filter%5benvironment_scope%5d=$GIGADB_ENV' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'value=$chain'"
	else
	  echo "/usr/bin/curl --show-error --silent --request POST --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'key=tls_chain_pem' --form 'value=\$chain'"
    $DOCKER_COMPOSE run --rm config bash -c "/usr/bin/curl -L --show-error --silent --request POST --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'key=tls_chain_pem' --form 'value=$chain'"
	fi

else
  echo "Certs do not exist in the filesystem"
  if [[ $fullchain_pem_remote_exists == "true" && $privkey_pem_remote_exists == "true" && $chain_pem_remote_exists == "true" ]];then
    echo "Certs fullchain, privkey and chain could be found in gitlab"
    echo "Get fullchain cert from gitlab"
    $DOCKER_COMPOSE run --rm config bash -c "/usr/bin/curl --show-error --silent \
      --request GET --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables/tls_fullchain_pem?filter%5benvironment_scope%5d=$GIGADB_ENV' \
      --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' | jq -r '.value' | tee $FULLCHAIN_PEM "

    echo "Get private cert from gitlab"
    $DOCKER_COMPOSE run --rm config bash -c "/usr/bin/curl --show-error --silent \
      --request GET --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables/tls_privkey_pem?filter%5benvironment_scope%5d=$GIGADB_ENV' \
      --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' | jq -r '.value' | tee $PRIVATE_PEM"
    echo "Get chain cert from gitlab"
    $DOCKER_COMPOSE run --rm config bash -c "/usr/bin/curl --show-error --silent \
      --request GET --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables/tls_chain_pem?filter%5benvironment_scope%5d=$GIGADB_ENV' \
      --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' | jq -r '.value' | tee $CHAIN_PEM"
  else
    echo "No certs on GitLab, certbot to create one"
    $DOCKER_COMPOSE run --rm certbot certonly -d $REMOTE_HOSTNAME --dry-run
    echo "Read content of files"
#    fullchain=$($DOCKER_COMPOSE run --rm config cat $FULLCHAIN_PEM)
#    privkey=$($DOCKER_COMPOSE run --rm config cat $PRIVATE_PEM)
#    chain=$($DOCKER_COMPOSE run --rm config cat $CHAIN_PEM)
    fullchain="hello"
    privkey="world"
    chain="bye"
    echo "And then backup the newly created cert to GitLab"
    $DOCKER_COMPOSE run --rm config bash -c "/usr/bin/curl --show-error --silent --request POST --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'key=tls_fullchain_pem' --form 'value=$fullchain'"
    $DOCKER_COMPOSE run --rm config bash -c "/usr/bin/curl --show-error --silent --request POST --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'key=tls_privkey_pem' --form 'value=$privkey'"
    $DOCKER_COMPOSE run --rm config bash -c "/usr/bin/curl --show-error --silent --request POST --url '$CI_API_V4_URL/projects/$encoded_gitlab_project/variables' --header 'PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN' --form 'environment_scope=$GIGADB_ENV' --form 'key=tls_chain_pem' --form 'value=$chain'"

  fi
fi