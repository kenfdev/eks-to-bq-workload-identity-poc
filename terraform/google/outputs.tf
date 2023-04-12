output "google_service_account_email" {
  value       = google_service_account.bigquery_sa.email
  description = "The email address of the Google service account."
}
