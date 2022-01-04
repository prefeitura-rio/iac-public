# Configure the Google Cloud provider
terraform {
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "3.89.0"
        }
    }
}

data "terraform_remote_state" "project_id" {
    backend   = "gcs"
    workspace = terraform.workspace

    config = {
        bucket = var.bucket_name
        prefix = "terraform-project"
    }
}

provider "google" {
    project = var.project_id
    region  = var.region
}

resource "google_container_cluster" "primary" {
    name     = "${var.project_id}-gke"
    location = var.region
    enable_autopilot = true
}
