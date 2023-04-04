terraform {
  required_version = ">=1.3.0"

  required_providers {
    ssh = {
      source  = "loafoe/ssh"
      version = "2.3.0"
    }
  }
}

provider "ssh" {}