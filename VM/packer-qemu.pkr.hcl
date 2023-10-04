#export PACKER_PLUGIN_PATH=../plugins
packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}
source "qemu" "example" {
  iso_url           = "http://mirror.raystedman.net/centos/6/isos/x86_64/CentOS-6.9-x86_64-minimal.iso"
  iso_checksum      = "md5:af4a1640c0c6f348c6c41f1ea9e192a2"
  output_directory  = "output_centos_tdhtest"
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  disk_size         = "5000M"
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "path/to/httpdir"
  ssh_username      = "root"
  ssh_password      = "s0m3password"
  ssh_timeout       = "20m"
  vm_name           = "tdhtest"
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  boot_wait         = "10s"
  boot_command      = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos6-ks.cfg<enter><wait>"]
}

build {
  sources = ["source.qemu.example"]
}