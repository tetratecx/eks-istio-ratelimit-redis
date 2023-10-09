# EKS Istio Rate Limit with Redis
This repository provides a comprehensive setup to implement rate limiting in an EKS (Elastic Kubernetes Service) environment using Istio and Redis.

## Overview
The repository contains configurations and scripts to set up an EKS cluster, deploy Istio, and implement rate limiting using both local and remote Redis instances.

## Features
- **EKS Setup:** Terraform scripts to provision an EKS cluster.
- **Istio Integration:** Configuration files to deploy Istio using helm.
- **Rate Limiting:** Implement rate limiting using Istio and Redis. Both local and remote (AWS ElastiCache) rate limiting configurations are provided.
- **Redis:** Configuration to deploy Redis locally within the EKS cluster and also to configure a remote Redis instance using AWS ElastiCache.
- **Sample Application:** Deployment of a sample httpbin application to demonstrate the rate limiting functionality.

## Directory Structure
- **kubernetes/:** Contains Kubernetes configuration files for deploying Istio, Redis, rate limit configurations, and the sample httpbin application.
- **terraform/:** Contains Terraform scripts for provisioning the EKS cluster, VPC, and other related AWS resources.
- **output/:** Contains Kubeconfig and Terraform output artifacts.

## Quick Start

The `makefile` provided takes you through all necessary steps and is self documenting.

```bash
$ make

help                           This help
terraform-up                   Bring up aws infra with terraform
terraform-down                 Bring down aws infra with terraform
refresh-k8s-token              Refresh eks kubectl kubeconfig token
istio-install                  Install istio with helm
deploy-redis-cli               Deploy redis-cli
deploy-ratelimit-local         Deploy local connected ratelimit service
undeploy-ratelimit-local       Undeploy local connected ratelimit service
deploy-ratelimit-remote        Deploy remote connected ratelimit service
undeploy-ratelimit-remote      Undeploy remote connected ratelimit service
deploy-httpbin                 Deploy test application httpbin
clean                          Clean up the environment
```

### Provision EKS Cluster:
Navigate to the terraform/ directory and run the Terraform scripts to provision the EKS cluster and related resources.

```bash
make terraform-up
```

### Deploy Istio:
Once the EKS cluster is up, deploy Istio using the provided configuration files.

```bash
make istio-install
```

### Deploy Redis CLI:
Deploy a redis-cli pod for debugging purposes.

```bash
make deploy-redis-cli
```

### Configure Rate Limiting:
Apply the rate limit configurations based on your choice of local or remote Redis.

```bash
make deploy-ratelimit-local
make deploy-ratelimit-remote
```

### Deploy Sample Application:
Deploy the httpbin application and test the rate limiting functionality.

```bash
make deploy-httpbin
```

### Cleanup:
To delete all the resources run:

```bash
make clean
```
This will destroy the terraform infra and remove output artifacts.

##   Conclusion
This repository provides a seamless way to integrate rate limiting in an EKS environment using Istio and Redis. It offers flexibility in choosing between local and remote rate limiting and provides a sample application to demonstrate the functionality.