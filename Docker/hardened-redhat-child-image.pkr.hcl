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

locals {
  current_date = formatdate("YYYYMMDDhhmm", timestamp())
}
data "hcp-packer-artifact" "golden" {
  bucket_name = "Red-Hat-Universal-Base-Image"
  channel_name = "latest"
  platform = "docker"
  region = "docker"
}
source "docker" "redhat-ubi9" {
  image = data.hcp-packer-artifact.golden.labels["PackerArtifactID"]
  commit = true
  login          = true
  login_server   = "${var.registry_server}"
  login_username = "${var.registry_user}"
  login_password = "${var.registry_password}"
  changes = [
    "WORKDIR /var/www",
    "ENV HOSTNAME www.example.com",
    "EXPOSE 80 443",
    "LABEL version=1.0",
    "ENTRYPOINT nginx -g 'daemon off;'"
  ]
}

build {
  name    = "redhat-ubi9-hardened-child-${local.current_date}"
  sources = ["source.docker.redhat-ubi9"]
  hcp_packer_registry {
    bucket_name = "Red-Hat-Universal-Child-Image"
    description = "Child image of hardened RH UBI9"

    bucket_labels = {
      "os"       = "Red Hat UBI Child"
      "hardened" = "true"
      "platform" = "OpenShift"
      "team"     = "Containers"
    }

    build_labels = {
      "build-time" = timestamp()
      "os-version" = "9.3-1610"
      "packages"   = "nginx"
    }
  }
  provisioner "shell" {
    #remote_folder = "/home/nonrootuser/packer"
    inline = [
      "yum install -y nginx"
    ]
  }
  post-processors {
    post-processor "docker-tag" {
      repository = "${var.registry_repository}/redhat-ubi9-hardened-child"
      tags       = [local.current_date, "latest"]
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
#docker run -it <id> --
#https://www.redhat.com/en/blog/hardening-docker-containers-images-and-host-security-toolkit 
#https://dl.dod.cyber.mil/wp-content/uploads/devsecops/pdf/Final_DevSecOps_Enterprise_Container_Hardening_Guide_1.2.pdf 
