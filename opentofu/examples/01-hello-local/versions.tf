terraform {
  required_version = ">= 1.8"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Local state file — fine for learning.
  # Swap for an S3/GCS/HTTP backend before sharing with a team.
  backend "local" {
    path = "/tofu-state/hello-local/terraform.tfstate"
  }
}
