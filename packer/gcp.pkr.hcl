packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "googlecompute" "ft-iac-template" {
  #source_image_family = "ubuntu-2204-lts"
  source_image = "ubuntu-2204-jammy-v20250305"
  credentials_file = "pandeo-423613-b63c6ccba88d.json"
  disk_size = 10
  machine_type = "e2-medium"
  ssh_username = "ubuntu"
  zone = "europe-west4-a"
  project_id = "pandeo-423613"
  preemptible = true # Low cost
  communicator = "ssh"
  omit_external_ip = false
  use_internal_ip = true
  use_iap = true

  network = "pandeo"
  subnetwork = "pandeo"
}

build {
  name = "ft-iac-template"
  sources = ["sources.googlecompute.ft-iac-template"]
  
  provisioner "ansible" {
    playbook_file = "ansible/app.yml"
  }
  post-processor "manifest" {
    output = "manifest-app.json"
  }
}

build {
  name = "redis-insight"
  sources = ["sources.googlecompute.ft-iac-template"]
  
  provisioner "ansible" {
    playbook_file = "ansible/redis.yml"
  }
  post-processor "manifest" {
    output = "manifest-redis.json"
  }
}