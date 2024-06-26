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

source "docker" "redhat-ubi9" {
  image    = "redhat/ubi9:latest" #use a trusted minimalist base image
  commit   = true
  cap_drop = ["SYS_ADMIN"] #Drop SYS_ADMIN Linux capability
  changes = [
    #"USER nonrootuser", #run as a non-root user
  ]

}

build {
  name    = "redhat-ubi9-hardened-${local.current_date}"
  sources = ["source.docker.redhat-ubi9"]
  hcp_packer_registry {
    bucket_name = "Red-Hat-Universal-Base-Image"
    description = "Implements OS hardening rules"

    bucket_labels = {
      "os"       = "Red Hat UBI"
      "hardened" = "true"
      "platform" = "OpenShift"
      "team"     = "Containers"
    }

    build_labels = {
      "build-time" = timestamp()
      "os-version" = "9.3-1610"
      "packages"   = "policycoreutils, selinux-policy, selinux-policy-targeted, libselinux, libselinux-utils"
    }
  }

  provisioner "shell" {
    inline = [
      "yum install -y policycoreutils selinux-policy selinux-policy-targeted libselinux libselinux-utils" #Install SELinux
      #"adduser nonrootuser"
    ]
  }
  provisioner "file" {
    #Copying custom SELinux policy to image
    source      = "selinux-config"
    destination = "/etc/selinux/config"
  }
  post-processors {
    post-processor "docker-tag" {
      repository = "${var.registry_repository}/redhat-ubi9-hardened"
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
#http://localhost:5001/v2/_catalog