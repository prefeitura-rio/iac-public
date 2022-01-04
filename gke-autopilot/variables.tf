variable "project_id" {
    description = "The GCP project ID to use for the cluster."
}

variable "bucket_name" {
    description = "Name of the GCS bucket for storing Terraform data"
}

variable "region" {
    description = "The GCP region to use for the cluster."
    default = "southamerica-east1"
}