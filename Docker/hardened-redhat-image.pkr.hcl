packer {
  required_plugins {
    docker = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/docker"
    }
  }
}

locals {
  current_date = formatdate("YYYYMMDDhhmm", timestamp())
}

source "docker" "redhat-ubi9" {
  image   = "redhat/ubi9:latest" #use a trusted minimalist base image
  commit  = true
  cap_drop = ["SYS_ADMIN"] #Drop SYS_ADMIN Linux capability
  changes = [
    "USER nonrootuser", #run as a non-root user
  ]

}

build {
  name    = "redhat-ubi9-hardened-${local.current_date}"
  sources = ["source.docker.redhat-ubi9"]
  //   hcp_packer_registry {
  //   bucket_name = ""
  //   description = ""

  //   bucket_labels = {
  //     "key" = "value"
  //   }

  //   build_labels = {
  //     "key" = "value"
  //     "key" = "value"
  //   }
  // }
    post-processors {
    post-processor "docker-tag" {
      repository = "redhat-ubi9-hardened"
      tags       = [local.current_date, "latest"]
    }
    }
    provisioner "shell" {
    inline = [
      "adduser nonrootuser",
      "yum install -y policycoreutils selinux-policy selinux-policy-targeted libselinux libselinux-utils" #Install SELinux
    ]
  }
  provisioner "file" {
    #Copying SELinux policy to image
    source = "selinux-config"
    destination = "/etc/selinux/config"
  }
}
#docker run -it <id> --
#https://www.redhat.com/en/blog/hardening-docker-containers-images-and-host-security-toolkit 
#https://dl.dod.cyber.mil/wp-content/uploads/devsecops/pdf/Final_DevSecOps_Enterprise_Container_Hardening_Guide_1.2.pdf 
