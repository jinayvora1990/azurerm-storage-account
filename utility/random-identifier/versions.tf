terraform {
  required_version = ">= 1.5.6"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}
