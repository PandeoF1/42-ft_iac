variable "name" {
  type = string
  description = "The name of the service"
}

variable "zone" {
  type = string
  description = ""
  validation {
    condition = var.zone != ""
    error_message = "Region must not be empty"
  }
}

variable "regions" {
    type = map(object({
        region = string
    }))
    description = "The list of regions to deploy resources"
    default = {
        EU = {
            region = "europe-west4"
        },
    }
}

variable "size" {
    type = string
    description = "The size of the instance"
    default = "small"
    validation {
        condition = contains(["small", "medium", "large"], var.size)
        error_message = "Size must be small, medium or large"
    }
}

variable "cloud_run_size" {
    type = map(object({
        cpu = string
        memory = string
    }))
    description = "The sizes of the instances"
    default = {
        small  = {
            cpu = "1"
            memory = "512Mi"
        }
        medium = {
            cpu = "1"
            memory = "1024Mi"
        }
        large = {
            cpu = "2"
            memory = "2048Mi"
        }
    }
}

variable "cloud_sql_size" {
    type = map(object({
        tier = string
    }))
    description = "The sizes of the database instances"
    default = {
        small  = {
            tier = "db-f1-micro"
        }
        medium = {
            tier = "db-g1-small"
        }
        large = {
            tier = "db-n1-standard-1"
        }
    }
}


variable "replicas" {
    type = number
    description = "The number of replicas to deploy"
    default = 2
}

variable "project_id" {
    type = string
    description = "The project id"
}

variable "deletion_protection" {
    type = bool
    description = "The deletion protection"
    default = true
}

variable "domain" {
    type = string
    description = "The domain name"
}

variable "backups" {
    type = bool
    description = "Enable backups"
    default = true
}

variable "availability_type" {
    type = string
    description = "The availability type"
    default = "ZONAL"
    validation {
        condition = contains(["ZONAL", "REGIONAL"], var.availability_type)
        error_message = "Availability type must be ZONAL or REGIONAL"
    }
}

variable "docker_image" {
    type = string
    description = "The docker image"
}

variable "cloudflare_api_token" {
    type = string
    description = "The Cloudflare API token"
}

variable "cloudflare_zone_id" {
    type = string
    description = "The Cloudflare zone id"
}


variable "notification_channels_url" {
    type = string
    description = "The url of the notification channels"
}