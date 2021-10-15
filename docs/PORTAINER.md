# GigaDB Portainer service

### What is portainer?
Portainer is an open-source management UI for Docker, including Docker Swarm environment. Portainer makes it easier for you to manage your Docker containers, it allows you to manage containers, images, networks, and volumes from the web-based Portainer dashboard.

### Pre-requisites
1. The staging server and live server are up and running. [Here]((https://gist.github.com/rija/343128de50e68d28f3537af7619a14bd)) and [here](https://github.com/gigascience/gigadb-website/blob/develop/docs/SETUP_CI_CD_PIPELINE.md) are the details of how to provision and configure an EC2 server using Ansible and Terraform.
2. The Let's Encrypt certificate fallout has been fixed by getting the latest code from this [PR #198](https://github.com/rija/gigadb-website/pull/198).
3. Have Docker Hub account, and store `DOCKER_HUB_USERNAME` and `DOCKER_HUB_PASSWORD` which is the access token in gitlab CI/CD variables.
4. 

### Steps to configure the portainer
1. Changes to the DNS record
Create an `A` record for access portainer on staging and on live as following:

| Record name | Type | IP |  
| --- | --- | --- |
| portainer.$staging_url | A | staging server IP |
| portainer.$live_url | A | live server IP |

2. Changes to the gitlab variables
Create a new variable as following:
   
|  Key | Value | Environment |
| --- | --- | --- |
| PORTAINER_PASSWORD | "Self assign" |  All(default) |

Variable `PORTAINER_BCRYPT`  (if any) could be deleted.

3. Changes to the `nginx` configuration  
Add server blocks to route all request from `portainer.$staging/live_url` to `http://portainer:9000`.

4. Access the portainer UI  
On staging server: https://portainer.ec2-staging.gigadb.link/  
On live server: https://portainer.ec2-live.gigadb.link/
### Reference
1. [Official protainer doc](https://docs.portainer.io/v/ce-2.9/start/intro)
2. 