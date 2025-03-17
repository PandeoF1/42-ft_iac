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
  source_image = "ubuntu-2204-jammy-v20250305"
  credentials_file = var.credentials_file
  disk_size = 10
  machine_type = "e2-medium"
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
  source_image = "ubuntu-2204-jammy-v20250305"
  credentials_file = var.credentials_file
  disk_size = 10
  machine_type = "e2-medium"
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
  provisioner "file" {
    source      = "app"
    destination = "/home/ubuntu/docker"
  }
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo usermod -aG docker ubuntu",
      "sudo docker compose -f /home/ubuntu/docker/docker-compose.yaml build",
    ]
  }
  post-processor "manifest" {
    output = "manifest-app.json"
  }
}

build {
  name = "redis-insight"
  sources = ["sources.googlecompute.redis-insight-template"]
  
  provisioner "file" {
    source      = "redis"
    destination = "/home/ubuntu/docker"
  }
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo usermod -aG docker ubuntu",
      "sudo docker compose -f /home/ubuntu/docker/docker-compose.yaml pull",
    ]
  }
  post-processor "manifest" {
    output = "manifest-redis.json"
  }
}


variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "credentials_file" {
  type        = string
  description = "Path to the Google Cloud credentials file"
}
variable "zone" {
  type        = string
  description = "Zone to deploy the instance"
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
