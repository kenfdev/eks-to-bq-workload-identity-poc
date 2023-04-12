variable "aws_account_id" {}

variable "eks_cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster."
}

variable "ksa_name" {
  default = "example-ns:example-sa"
}
