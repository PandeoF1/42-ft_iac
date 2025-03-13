# packer {
#   required_version = ">= 1.7.0"
#   # description			= "VM for FT-IaC
#   required_plugins {
#     googlecompute = {
#       version = " >= 1.1.8"
#       source  = "github.com/hashicorp/googlecompute"
#     }
#     ansible = {
#       version = " >= 1.1.2"
#       source  = "github.com/hashicorp/ansible"
#     }
#   }
# }


# source "googlecompute" "ft-iac-image-ubuntu" {
#   project_id          = var.project_id
#   ssh_username        = "packer"
#   ssh_password        = "packer"
#   source_image_family = var.source_image_family
#   # source_image = var.source_image
#   zone         = var.zone
#   machine_type = var.machine_type
#   disk_size    = 10
#   #   subnetwork   = "default"
#   communicator = "ssh"
# #   wait_to_add_ssh_keys = "20s"
#   enable_nested_virtualization = true
#   credentials_file = "./ft-iac-0e15f88277c2.json"
#   use_iap =  true
#   network = "ft-iac"
#   subnetwork = "ft-iac"
#   use_internal_ip = true
#   omit_external_ip = false
#   #   ssh_timeout  = "1m"
#   # network_project_id = "SHARED_VPC_ft-iac"
# }
# # fatal: [default]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: Warning: Permanently added '[127.0.0.1]:40553' (ECDSA) to the list of known hosts.\r\npacker@127.0.0.1: Permission denied (publickey).", "unreachable": true}
# build {
#   sources = ["sources.googlecompute.ft-iac-image-ubuntu"]
#   provisioner "ansible" {
# 	playbook_file = "./playbook/playbook-ft-iac-ubuntu.yml"
# 	extra_arguments = ["--extra-vars", "ansible_ssh_user=packer"]
#   }
# }





variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
  # default = "ft-iac"
}

variable "source_image_family" {
  type        = string
  description = "Source image family to use for the instance"
  # default = "debian-12"
}
variable "zone" {
  type        = string
  description = "Zone to deploy the instance"
  # default = "eu-west4-b"
}
variable "machine_type" {
  type        = string
  description = "Machine type to use for the instance"
  # default = "e2-micro"
}

variable "startup_script_file" {
  type        = string
  description = "Path to the startup script file"
  # default = "./script/startup.sh"
}

packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
    ansible = {
      version = " >= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "googlecompute" "ft-iac-template" {
#   source_image_family = var.source_image_family
  source_image = "ubuntu-2204-jammy-v20250305"
  credentials_file = "ft-iac-0e15f88277c2.json"
  disk_size = 10
#   machine_type = var.machine_type
  machine_type = "e2-medium"
  ssh_username = "ubuntu"
  zone = var.zone
#   project_id = var.project_id
  project_id = "ft-iac"
  preemptible = true # Low cost
  communicator = "ssh"
  omit_external_ip = false
  use_internal_ip = true
  use_iap = true

  network = "ft-iac"
  subnetwork = "ft-iac"
}

build {
  name = "ft-iac-template"
  sources = ["sources.googlecompute.ft-iac-template"]

  provisioner "ansible" {
    playbook_file = "playbook/playbook-ft-iac-ubuntu.yml"
	extra_arguments = ["--extra-vars", "ansible_ssh_user=ubuntu"]
  }
  post-processor "manifest" {
    output = "manifest-app.json"
  }
}

# build {
#   name = "redis-insight"
#   sources = ["sources.googlecompute.ft-iac-template"]

#   provisioner "ansible" {
#     playbook_file = "ansible/redis.yml"
#   }
#   post-processor "manifest" {
#     output = "manifest-redis.json"
#   }
# }