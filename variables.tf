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
            region = "europe-west9"
        },
    }
}

variable "size" {
    type = string
    description = "The size of the instance"
    default = "small"
}

variable "sizes" {
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