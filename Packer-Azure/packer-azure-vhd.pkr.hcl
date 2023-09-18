packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}
variable "client_id" {
  type =  string
  sensitive = true
}
variable "client_secret" {
  type =  string
  sensitive = true
}
variable "subscription_id" {
  type =  string
  sensitive = true
}
variable "tenant_id" {
  type =  string
  sensitive = true
}
variable "resource_group" {
  type =  string
}
variable "os_type" {
  type =  string
}
variable "image_name" {
  type =  string
}
variable "location" {
  type =  string
}

source "azure-arm" "ubuntu" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  client_id                         = "${var.client_id}"
  client_secret                     = "${var.client_secret}"
  location                          = "${var.location}"
  #create a disk snapshot and copy it to your storage account, then obtain the blob url within your storage account. https://learn.microsoft.com/en-us/azure/virtual-machines/scripts/copy-snapshot-to-storage-account
  image_url = "https://bfbpackerstorage.blob.core.windows.net/vhd/packer-ubuntu-22-04-lts-gen2-20230916.vhd"
  os_type                           = "${var.os_type}"
  subscription_id                   = "${var.subscription_id}"
  tenant_id                         = "${var.tenant_id}"
  vm_size                           = "Standard_DS2_v2"
  capture_container_name = "packer"
  capture_name_prefix = "ubuntu"
  resource_group_name = "${var.resource_group}"
  storage_account = "bfbpackerstorage"
}

build {
  sources = ["source.azure-arm.ubuntu"]
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["mkdir /custom"]
  }
}
#the output will show the location of the new vhd file which can be extracted into a managed disk