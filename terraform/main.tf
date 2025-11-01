terraform {
  required_version = ">=1.3.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.99.1"
    }
  }
  #Cloud connection with HCP terraform
  cloud {
    organization = "ds9-solutions"
    workspaces {
      name = "agent_knowledge_test"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}