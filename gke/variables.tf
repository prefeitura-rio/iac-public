variable "project_id" {
  description = "The GCP project ID to use for the cluster."
}

variable "bucket_name" {
  description = "Name of the GCS bucket for storing Terraform data"
}

variable "region" {
  description = "The GCP region to use for the cluster."
  default     = "southamerica-east1"
}

variable "zone" {
  description = "The GCP zone to use for the cluster."
  default     = "southamerica-east1-c"
}

variable "machine_type" {
  description = "The machine type to use for the cluster's main pool."
  default     = "custom-4-8192"
}

variable "preemptible_nodes" {
  description = "Should cluster's main pool nodes be preemptible"
  default     = false
}
