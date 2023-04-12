provider "aws" {
  region = "ap-northeast-1"
}

provider "google" {
  project = "eks-to-bq-poc"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

variable "ksa_name" {
  default = "example-ns:example-sa"
}

variable "project_number" {
  default = "261550595085"
}

locals {
  aws_account_id              = "543157227934"
  eks_cluster_oidc_issuer_url = "https://oidc.eks.ap-northeast-1.amazonaws.com/id/6CFC05600AE1CAE83C888DA3F179B813"
}

resource "google_service_account" "bigquery_sa" {
  account_id   = "bigquery-sa"
  display_name = "BigQuery Service Account"
}

resource "google_project_iam_member" "bigquery_data_viewer" {
  project = google_service_account.bigquery_sa.project
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.bigquery_sa.email}"
}

resource "google_project_iam_member" "bigquery_job_user" {
  project = google_service_account.bigquery_sa.project
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.bigquery_sa.email}"
}

resource "google_iam_workload_identity_pool" "aws_pool" {
  workload_identity_pool_id = "aws-pool"
  display_name              = "AWS Workload Identity Pool"
}

resource "google_iam_workload_identity_pool_provider" "aws_provider" {
  workload_identity_pool_provider_id = "aws-provider1"
  workload_identity_pool_id          = google_iam_workload_identity_pool.aws_pool.workload_identity_pool_id
  display_name                       = "AWS Provider"

  oidc {
    issuer_uri        = local.eks_cluster_oidc_issuer_url
    allowed_audiences = ["sts.amazonaws.com"]
  }
  attribute_mapping = {
    "google.subject"     = "assertion.sub"
    "attribute.ksa_name" = "assertion.sub.extract('system:serviceaccount:{ksa_name}')"
  }
}

resource "google_service_account_iam_binding" "service-account-iam" {
  service_account_id = google_service_account.bigquery_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members            = ["principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.aws_pool.workload_identity_pool_id}/attribute.ksa_name/${var.ksa_name}"]
}

data "aws_iam_policy_document" "assume_role_with_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${local.aws_account_id}:oidc-provider/${local.eks_cluster_oidc_issuer_url}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_cluster_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:${var.ksa_name}"]
    }
  }
}

resource "aws_iam_role" "bigquery_workload_identity_role" {
  name               = "bigquery-workload-identity-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_with_oidc.json
}

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  url = local.eks_cluster_oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "75e652d4d05359d11ffa3976c0dbccaf60d2b28d",
  ]
}
