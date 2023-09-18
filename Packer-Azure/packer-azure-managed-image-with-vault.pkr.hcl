packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}
locals {
  #At a minmimum, VAULT_ADDR and VAULT_TOKEN should be set as env variables
  #https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/contextual/vault
  client_secret = vault("/secret/data/az-creds", "client-secret") 
}

source "azure-arm" "ubuntu" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  client_id                         = "73fbcbf5-315f-453c-b2e2-26bf1f22914a"
  client_secret                     = "${local.client_secret}"
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_publisher                   = "canonical"
  image_sku                         = "22_04-lts-gen2"
  location                          = "East US"
  managed_image_name                = "Packer-Ubuntu-Vault"
  managed_image_resource_group_name = "bfbarkhouse-packertest-rg"
  os_type                           = "Linux"
  subscription_id                   = "e53f7cc8-2313-4dfb-b862-b7da7db87b25"
  tenant_id                         = "71cce8e2-b0ac-41bf-ae73-21d9f41b2b2b"
  vm_size                           = "Standard_DS2_v2"
}

build {
  sources = ["source.azure-arm.ubuntu"]
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["mkdir /custom"]
  }
}

#vault demo commands
#.\vault.exe server -dev -dev-root-token-id="dev-only-token"
#$env:VAULT_ADDR="http://127.0.0.1:8200"
#$env:VAULT_TOKEN="dev-only-token"
#.\vault.ext login
#.\vault.exe secrets enable kv-v2
#.\vault.exe kv put -mount=secret az-creds client-secret=mSc8Q~57kUmeMH5HvTnFJrdl-eTlblyuOIxPOceT