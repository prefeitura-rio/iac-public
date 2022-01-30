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
  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "${var.project_id}-pool-main"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1
  node_config {
    machine_type = var.machine_type
    preemptible  = var.preemptible_nodes
  }
}

resource "google_container_node_pool" "prod_autoscale_node_pool" {
  name       = "${var.project_id}-pool-dynamic"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 0

  # autoscaling {
  #     min_node_count = 0
  #     max_node_count = 2
  # }

  node_config {
    preemptible  = true
    machine_type = "e2-small"
    disk_size_gb = "100"
  }
}
