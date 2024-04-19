#export PACKER_PLUGIN_PATH=<your top level plugin folder>
packer {
  required_plugins {
    docker = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/docker"
    }
  }
}
variable "registry_server" { #export PKR_VAR_registry_server=<your remote server URL> or use packer build -var-file="<path to .pkrvars.hcl>"
  type      = string
  sensitive = true #Sensitive vars are hidden from output
}
variable "registry_repository" { #export PKR_VAR_registry_repository=<your remote repo path> or use packer build -var-file="<path to .pkrvars.hcl>"
  type = string
}
variable "registry_user" { #export PKR_VAR_registry_user=<your username> or use packer build -var-file="<path to .pkrvars.hcl>"
  type      = string
  sensitive = true #Sensitive vars are hidden from output
}
variable "registry_password" { #export PKR_VAR_registry_password=<your password or use packer build -var-file="<path to .pkrvars.hcl>"
  type      = string
  sensitive = true #Sensitive vars are hidden from output
}

source "docker" "alpine" {
  image  = "alpine:latest"
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
  hcp_packer_registry {
    bucket_name = "alpine"

    bucket_labels = {
      "team" = "docker",
      "os"   = "alpine"
    }

    build_labels = {
      "alpine-version" = "3.19.1",
      "build-time"     = timestamp()
    }
  }
  post-processors {
    post-processor "docker-tag" {
      repository = "${var.registry_repository}/alpine" #Tag the image with the URL to the repository
      tags       = ["0.1", "latest"]
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

