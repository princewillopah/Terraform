terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }

  }
}