
variable "project_id" {
  type    = string
    description = "Google Cloud Project ID"
}
variable "source_image" {
  type    = string
	description = "Source image to use for the instance"
}
variable "source_image_family"{
	type    = string
	description = "Source image family to use for the instance"
}
variable "zone"{
	type    = string
	description = "Zone to deploy the instance"
}
variable "machine_type"{
	type    = string
	description = "Machine type to use for the instance"
}

variable "startup_script_file"{
	type    = string
	description = "Path to the startup script file"
	default = "./script/startup.sh"
}

# source "type" "name" {
#   ...
# }

# build {
#   ...
# }