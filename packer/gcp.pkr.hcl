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
  #source_image_family = "ubuntu-2204-lts"
  source_image = var.source_image
  credentials_file = var.credentials_file
  disk_size = var.disk_size
  machine_type = var.machine_type
  ssh_username = "ubuntu"
  zone = var.zone
  project_id = var.project_id
  preemptible = true # Low cost
  communicator = "ssh"
  omit_external_ip = false
  use_internal_ip = true
  use_iap = true
  image_name = "ft-iac-{{timestamp}}"
  network = var.network
  subnetwork = var.subnetwork
}

source "googlecompute" "redis-insight-template" {
  #source_image_family = "ubuntu-2204-lts"
  source_image = var.source_image
  credentials_file = var.credentials_file
  disk_size = var.disk_size
  machine_type = var.machine_type
  ssh_username = "ubuntu"
  zone = var.zone
  project_id = var.project_id
  preemptible = true # Low cost
  communicator = "ssh"
  omit_external_ip = false
  use_internal_ip = true
  use_iap = true
  image_name = "redis-insight-{{timestamp}}"
  network = var.network
  subnetwork = var.subnetwork
}

build {
  name = "ft-iac-template"
  sources = ["sources.googlecompute.ft-iac-template"]
  
  provisioner "ansible" {
    playbook_file = var.playbook_file_app
  }
  post-processor "manifest" {
    output = "manifest-app.json"
  }
}

build {
  name = "redis-insight"
  sources = ["sources.googlecompute.redis-insight-template"]
  
  provisioner "ansible" {
    playbook_file = var.playbook_file_redis
  }
  post-processor "manifest" {
    output = "manifest-redis.json"
  }
}


variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "source_image" {
  type        = string
  description = "Source image to use for the instance"
}

variable "credentials_file" {
  type        = string
  description = "Path to the Google Cloud credentials file"
}
variable "zone" {
  type        = string
  description = "Zone to deploy the instance"
}


variable "machine_type" {
  type        = string
  description = "Machine type to use for the instance"
}

variable "network" {
  type        = string
  description = "Network"
  default = "default"
}

variable "subnetwork"{
	type = string
	description = "Subnetwork"
	default = "default"
}

variable "disk_size" {
  type        = number
  description = "Disk size in GB"
  default = 10
}

variable "playbook_file_redis"{
	type = string
	description = "Path to the playbook file for redis"
}

variable "playbook_file_app"{
	type = string
	description = "Path to the playbook file for app"
}