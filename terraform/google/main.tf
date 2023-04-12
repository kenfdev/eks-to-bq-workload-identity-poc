provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
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
  workload_identity_pool_provider_id = "aws-provider"
  workload_identity_pool_id          = google_iam_workload_identity_pool.aws_pool.workload_identity_pool_id
  display_name                       = "AWS Provider"

  oidc {
    issuer_uri        = var.eks_cluster_oidc_issuer_url
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
