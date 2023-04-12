variable "project_id" {}

variable "project_number" {}

variable "region" {
  default = "asia-northeast1"
}

variable "zone" {
  default = "asia-northeast1-a"
}

variable "ksa_name" {
  default     = "example-ns:example-sa"
  description = "kubernetes service account name"
}
