#export PACKER_PLUGIN_PATH=<your top level plugin folder>
packer {
  required_plugins {
    docker = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/docker"
    }
  }
}
variable "registry_server" {
  type = string
  #export PKR_VAR_registry_user=<your username> or use packer build -var-file="<path to .pkrvars.hcl>"
  #Sensitive vars are hidden from output
  sensitive = true
}
variable "registry_repository" {
  type = string
  #export PKR_VAR_registry_user=<your username> or use packer build -var-file="<path to .pkrvars.hcl>"
}
variable "registry_user" {
  type = string
  #export PKR_VAR_registry_user=<your username> or use packer build -var-file="<path to .pkrvars.hcl>"
  #Sensitive vars are hidden from output
  sensitive = true
}
variable "registry_password" {
  type = string
  #export PKR_VAR_registry_password=<your username> or use packer build -var-file="<path to .pkrvars.hcl>"
  #Sensitive vars are hidden from output
  sensitive = true
}

source "docker" "alpine" {
  image  = "${var.registry_repository}/alpine:latest" #URL to the repository where the desired image is located within the remote registry 
  commit = true
  changes = [
    #This is an example modification to the original image
    "WORKDIR /custom",
  ]
  #when using a remote registry, the server URL and user credentials must be set in order to pull the image
  login          = true
  login_server   = "${var.registry_server}"
  login_username = "${var.registry_user}"
  login_password = "${var.registry_password}"
}

build {
  sources = [
    "source.docker.alpine"
  ]
  post-processors {
    post-processor "docker-tag" {
      repository = "${var.registry_repository}/alpine" #Tag the image with the URL to the repository
      tags       = ["0.2", "latest"]
    }
    post-processor "docker-push" {
      #when using a remote registry, the server URL and user credentials must be set in order to push the new image
      login          = true
      login_server   = "${var.registry_server}"
      login_username = "${var.registry_user}"
      login_password = "${var.registry_password}"
    }
  }
}

