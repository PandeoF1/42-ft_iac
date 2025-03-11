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
  source_image_family = "ubuntu-2204-lts"
  disk_size = 10
  machine_type = "f1-micro"
  ssh_username = "packer"
  zone = "europe-west4-a"
  project_id = "pandeo-423613"
}

build {
  sources = ["sources.googlecompute.ft-iac-template"]
  
  provisioner "ansible" {
    playbook_file = "ansible/docker.yml"
  }
  post-processor "manifest" {
    output = "packer/manifest.json"
  }
}