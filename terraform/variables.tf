locals {
  timestamp = "${timestamp()}"
  timestamp_no_hyphens = "${replace("${local.timestamp}", "-", "")}"
  timestamp_no_spaces = "${replace("${local.timestamp_no_hyphens}", " ", "")}"
  timestamp_no_t = "${replace("${local.timestamp_no_spaces}", "T", "")}"
  timestamp_no_z = "${replace("${local.timestamp_no_t}", "Z", "")}"
  timestamp_no_colons = "${replace("${local.timestamp_no_z}", ":", "")}"
  timestamp_sanitized = "${local.timestamp_no_colons}"
}

variable "name" {
  type = string
  description = "The name of the service"
}

variable "region" {
  type = string
  description = ""
  validation {
    condition = var.region != ""
    error_message = "Region must not be empty"
  }
}

variable "area" {
    type = map(object({
        region = string
        zones = list(string)
    }))
    description = "The list of regions to deploy resources"
    default = {
        EU = {
            region = "europe-west1"
            zones = [
                "europe-west1-b",
                "europe-west1-c",
            ]
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

variable "cloud_engine_size" {
    type = map(object({
        tier = string
    }))
    description = "The sizes of the instances"
    default = {
        small  = {
            tier = "f1-micro"
        }
        medium = {
            tier = "f1-micro"
        }
        large = {
            tier = "e2-medium"
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

variable "session_under_redis" {
    type = bool
    description = "Use Redis for session storage"
    default = false
  
}

variable "database_replicas" {
    type = bool
    description = "Use database replicas"
    default = false
}