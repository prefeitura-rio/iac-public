variable "project_id" {
  description = "The GCP project ID to use for the cluster."
}

variable "bucket_name" {
  description = "Name of the GCS bucket for storing Terraform data"
}

variable "region" {
  description = "The GCP region to use for the cluster."
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone to use for the cluster."
  default     = "us-central1-c"
}

variable "shared_vpc_host_project" {
  description = "The ID of the host project which hosts the shared VPC"
  default     = "datario"
}

variable "shared_vpc_subnet_name" {
  description = "The name of the subnet to use for the shared VPC"
  default     = "sub-us-iplan"
}

variable "machine_type" {
  description = "The machine type to use for the cluster's main pool."
  default     = "custom-2-3072"
}
