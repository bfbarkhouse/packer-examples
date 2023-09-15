#export PACKER_PLUGIN_PATH=<your top level plugin folder>
packer {
  required_plugins {
    docker = {
      version = ">= 1.0.1"
      source = "github.com/hashicorp/docker"
    }
  }
}
variable "registry_server" {
  type =  string
  #export PKR_VAR_registry_user=<your username> or use CLI/File methods
  // Sensitive vars are hidden from output
  sensitive = true
}
variable "registry_user" {
  type =  string
  #export PKR_VAR_registry_user=<your username> or use CLI/File methods
  // Sensitive vars are hidden from output
  sensitive = true
}
variable "registry_password" {
  type =  string
  #export PKR_VAR_registry_password=<your username> or use CLI/File methods
  // Sensitive vars are hidden from output
  sensitive = true
}

source "docker" "alpine" {
  image  = "localhost:5001/alpine-remote"
  commit = true
  changes = [
    #This is an example modification to the original image
    "WORKDIR /custom",
  ]
  login = true
  login_server = "${var.registry_server}"
  login_username = "${var.registry_user}"
  login_password = "${var.registry_password}"
}

build {
  #name    = "golden-docker-alpine"
  sources = [
    "source.docker.alpine"
  ]
  post-processors {
    post-processor "docker-tag" {
        repository =  "localhost:5001/alpine-remote"
        tags = ["0.2", "latest"]
      }
    post-processor "docker-push" {
      login = true
      login_server = "${var.registry_server}"
      login_username = "${var.registry_user}"
      login_password = "${var.registry_password}"
    }
}
}

