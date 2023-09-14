#export PACKER_PLUGIN_PATH=./plugins
packer {
  required_plugins {
    docker = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "jfrog_user" {
  type =  string
  #export PKR_VAR_jfrog_user=<your username> or use CLI/File methods
  // Sensitive vars are hidden from output
  sensitive = true
}

variable "jfrog_password" {
  type =  string
  #export PKR_VAR_jfrog_password=<your password> or use CLI/File methods
  // Sensitive vars are hidden from output
  sensitive = true
}

variable "jfrog_url" {
  type =  string
  #export PKR_VAR_jfrog_user=<your username> or use CLI/File methods
  // Sensitive vars are hidden from output
  sensitive = true
}

source "docker" "alpine" {
  image  = "alpine:latest"
  commit = true
  changes = [
    "WORKDIR /custom",
  ]
}

build {
  sources = [
    "source.docker.alpine"
  ]
  post-processors {
    #Apply name and tags
    post-processor "docker-tag" {
      repository = "artifactory/bbarkhouse-generic-alpine"
      tags       = ["0.1"]
    }
    #Save container image to file
    post-processor "docker-save" {
      path = "golden-docker-alpine-0_1.tar"
    }
    #Upload to Artifactory
    post-processor "shell-local" {
      inline = ["jf rt u golden-docker-alpine-*.tar bbarkhouse-generic-alpine --recursive=false --url ${var.jfrog_url} --user ${var.jfrog_user} --password ${var.jfrog_password}"]
    }
  }
}
#You can then download the image from Artifactory and run locally using "docker load --input <path to tar file>"

