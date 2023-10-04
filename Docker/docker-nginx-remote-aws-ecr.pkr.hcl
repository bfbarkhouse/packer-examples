#export PACKER_PLUGIN_PATH=../plugins
#export AWS creds
#export HCP_CLIENT_ID
#export HCP_CLIENT_SECRET
#export HCP_PROJECT_ID
packer {
  required_plugins {
    docker = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image  = "ubuntu"
  commit = true
  changes = [
    "WORKDIR /var/www",
    "ENV HOSTNAME www.example.com",
    "EXPOSE 80 443",
    "LABEL version=1.0",
    "ENTRYPOINT [\"nginx\", \"-g\", \"daemon off;\"]"
  ]
}

build {
  sources = [
    "source.docker.ubuntu"
  ]
  hcp_packer_registry {
    bucket_name = "nginx"

    description = "nginx images"

    bucket_labels = {
      "package" = "nginx"
    }

    build_labels = {
      "os" = "ubuntu"
      "version" = "0.10"
    }
  }
  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install --no-install-recommends -y nginx"
    ]
  }
  post-processors {
    post-processor "docker-tag" {
      repository = "983083522813.dkr.ecr.us-east-1.amazonaws.com/bbarkhouse-docker-nginx"
      tags       = ["0.10", "latest"]
    }

    post-processor "docker-push" {
      ecr_login = true
      #export AWS creds as env variables
      login_server = "983083522813.dkr.ecr.us-east-1.amazonaws.com/bbarkhouse-docker-nginx"
    }
  }
}

