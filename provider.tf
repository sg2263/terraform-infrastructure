terraform {
  backend "remote" {
    organization = "Shubhradip-Org-789"

    workspaces {
      name = "chatapp-dev" 
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  required_version = ">=1.1.0"
}