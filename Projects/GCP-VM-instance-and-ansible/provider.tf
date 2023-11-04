provider "google" {
  project = "durable-bond-403201"
  region = "europe-west1"
  credentials = "/home/princewillopah/DevOps-World/Terraform/durable-bond-key.json"
}

provider "tls" {
  // no config needed
}