# GigaDB Portainer service

### What is portainer?
Portainer is an open-source management UI for Docker, including Docker Swarm environment. Portainer makes it easier for you to manage your Docker containers, it allows you to manage containers, images, networks, and volumes from the web-based Portainer dashboard.

### Pre-requisites
1. The staging server and live server are up and running. [Here]((https://gist.github.com/rija/343128de50e68d28f3537af7619a14bd)) and [here](https://github.com/gigascience/gigadb-website/blob/develop/docs/SETUP_CI_CD_PIPELINE.md) are the details of how to provision and configure an EC2 server using Ansible and Terraform.
2. The Let's Encrypt certificate fallout has been fixed by getting the latest code from this [PR #198](https://github.com/rija/gigadb-website/pull/198).
3. Have Docker Hub account, and store `DOCKER_HUB_USERNAME` and `DOCKER_HUB_PASSWORD`  which is the access token in gitlab CI/CD variables.

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
| PORTAINER_PASSWORD | "Password" |  All(default) |
| DOCKER_HUB_USERNAME | "User name" | All(default) |
| DOCKER_HUB_PASSWORD | "Access token" | All(default) |

Variable `PORTAINER_BCRYPT`  (if any) could be deleted.

3. Changes to the `nginx` configuration  
Add server blocks to route all request from `portainer.$staging/live_url` to `http://portainer:9000`.

#### How to know portainer is configured correctly
A. On `dev` environment
1. In terminal
```
% curl -I localhost:9009
HTTP/1.1 200 OK
Accept-Ranges: bytes
Cache-Control: max-age=31536000
Content-Length: 6176
Content-Type: text/html; charset=utf-8
Last-Modified: Sun, 10 Oct 2021 23:45:45 GMT
X-Content-Type-Options: nosniff
X-Xss-Protection: 1; mode=block
Date: Sun, 17 Oct 2021 03:25:38 GMT
```
2. And visit `http://localhost:9009/`

B. On staging or live servers
1. In terminal
```
$ curl -I localhost:9009
HTTP/1.1 200 OK
Accept-Ranges: bytes
Cache-Control: max-age=31536000
Content-Length: 6176
Content-Type: text/html; charset=utf-8
Last-Modified: Sun, 10 Oct 2021 23:45:45 GMT
X-Content-Type-Options: nosniff
X-Xss-Protection: 1; mode=block
Date: Sun, 17 Oct 2021 03:28:39 GMT
```
2. And visit [portainer on staging](https://portainer.ec2-staging.gigadb.link/) or [portainer on live](https://portainer.ec2-live.gigadb.link/)

### Reference
1. [Official protainer doc](https://docs.portainer.io/v/ce-2.9/start/intro)
2. [Unable to access portainer URL with custom context path apart](https://github.com/portainer/portainer/issues/4483)
3. [nginx and portainer on non-root URI](https://github.com/portainer/portainer/issues/3303)