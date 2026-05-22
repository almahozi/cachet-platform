terraform {
  cloud {
    organization = "mahozi"

    workspaces {
      project = "Cachet Platform"
      name = "cachet-platform"
    }
  }

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.92"
    }
  }
}

provider "aws" {
    region = "eu-central-1"
}