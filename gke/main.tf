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
  name                     = "${var.project_id}-gke"
  location                 = var.zone
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = "projects/${var.shared_vpc_host_project}/global/networks/vpc-vpn-iplan-us"
  subnetwork = "projects/${var.shared_vpc_host_project}/regions/${var.region}/subnetworks/${var.shared_vpc_subnet_name}"

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-${var.project_id}-pods"
    services_secondary_range_name = "gke-${var.project_id}-services"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.project_id}-pool-main"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1
  node_config {
    machine_type = var.machine_type
  }
}
