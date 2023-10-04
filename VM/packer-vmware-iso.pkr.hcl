#export PACKER_PLUGIN_PATH=../plugins
packer {
  required_plugins {
    vmware = {
      version = "~> 1"
      source  = "github.com/hashicorp/vmware"
    }
  }
}
source "vmware-iso" "ubuntu" {
  iso_url          = "http://old-releases.ubuntu.com/releases/precise/ubuntu-12.04.2-server-amd64.iso"
  iso_checksum     = "md5:af5f788aee1b32c4b2634734309cc9e9"
  ssh_username     = "packer"
  ssh_password     = "packer"
  shutdown_command = "shutdown -P now"
  output_directory = "vmware"
}

build {
  sources = ["sources.vmware-iso.ubuntu"]
}