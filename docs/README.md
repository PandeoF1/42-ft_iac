# 42-ft_iac

Welcome to the 42-ft_iac documentation!

## Overview

This project works with differents technologies, and please install the following tools:
- [Terraform](https://developer.hashicorp.com/terraform)
- [Packer](https://developer.hashicorp.com/packer)
- [Ansible](https://docs.ansible.com/)
- [Docker](https://docs.docker.com/desktop/)

We are compatible with those cloud providers:
- [Google Cloud](https://cloud.google.com/)

We are also using [Cloudflare](https://www.cloudflare.com/) for the DNS management.
- [Cloudflare API](https://api.cloudflare.com/)

## Setup

### Prerequisites

#### Google Cloud

For this project, you need to create a service account in your Google Cloud project. For this follow the documentation [here](./gcp/README.md).

#### Packer


Packer is used to create the base image for the project.
The first step will be to create the packer configuration file.
Copy the packer/example.pkvars.hcl file to packer/gcp.pkvars.hcl and fill in the variables with your own values.
```hcl
# packer/gcp.pkvars.hcl
credentials_file 				= "../gcp.json" # Do not change this
zone 							= "europe-west1-b"
project_id 						= "xxxxxxxxxxxxxxxxx" # The project id of your project, can be found in the URL of your project (ex: if the URL is 'https://console.cloud.google.com/home/dashboard?project=something-123', the project id is 'something-123')>')
network 						= "xxxxxxxxx" # The default network of your project (ex: if project_id is 'test-<rand_id>', network is 'test')
subnetwork 						= "xxxxxxxxx"
```
To build the image, run the following command:

```bash
packer build -var-file=packer/gcp.pkvars.hcl packer/gcp.pkr.hcl
```

#### Cloudflare

Cloudflare is used to manage the DNS records for the project.
You will need to create a Cloudflare account and add your domain to it.
After that, you will need to create an API token (Profile > API Tokens) with the following permissions:
- Zone: DNS: Edit

#### Terraform

Terraform is used to create the infrastructure for the project.
The first step will be to create the terraform configuration file.
Copy the terraform/terraform.tfvars.example file to terraform/gcp.tfvars.hcl and fill in the variables with your own values.
```hcl
# terraform/gcp.tfvars.hcl
name                      = "ft-iac"
region                    = "EU"
size                      = "medium"
replicas                  = 2
project_id                = "xxxxxxxxxxxxxxxxxx" # The project id of your project, can be found in the URL of your project (ex: if the URL is 'https://console.cloud.google.com/home/dashboard?project=something-123', the project id is 'something-123')
deletion_protection       = false
domain                    = "xxxx.xxxxx.xx"
cloudflare_zone_id        = "xxxxxxxxxxxxxxxx"
backups                   = true
availability_type         = "REGIONAL"
notification_channels_url = "projects/<project_id>/notificationChannels/<channel_id>"
session_under_redis       = true
database_replicas         = false
```

For more information about the variables, please refer to the [terraform documentation](./terraform/README.md).

To create the infrastructure, run the following command:

```bash
cd terraform
terraform init
terraform plan -var-file=gcp.tfvars.hcl -var cloudflare_api_token=<your_cloudflare_api_token>
terraform apply -var-file=gcp.tfvars.hcl -var cloudflare_api_token=<your_cloudflare_api_token>
```
