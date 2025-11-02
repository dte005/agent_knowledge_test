# ===================================================================
# Terraform configuration
# ===================================================================

terraform {
  required_version = ">=1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
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
  access_key = var.AWS_KEY_ID
  secret_key = var.AWS_KEY_SECRET
  region     = "us-east-1"
  default_tags {
    tags = {
      "owner" : "dte005"
      "managed-by" : "terraform"
    }
  }
}