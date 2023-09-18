#export PACKER_PLUGIN_PATH=../plugins
#export AWS creds
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
#Set a local variable to the current datetime in a readable format
locals {
  current_date = formatdate("YYYYMMDDhhmm", timestamp())
}
#Create EBS-backed AMI by launching a source AMI and re-packaging it into a new AMI after provisioning.
source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-demo-ubuntu-22-${local.current_date}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "packer-demo-ubuntu-22-latest"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
}