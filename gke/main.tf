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
  name             = "${var.project_id}-gke"
  location         = var.region
  enable_autopilot = true

  network    = "projects/${var.shared_vpc_host_project}/global/networks/vpc-vpn-iplan-us"
  subnetwork = "projects/${var.shared_vpc_host_project}/regions/${var.region}/subnetworks/${var.shared_vpc_subnet_name}"
  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-rj-sme-pods"
    services_secondary_range_name = "gke-rj-sme-services"
  }

  networking_mode = "VPC_NATIVE"
}
