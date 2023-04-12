provider "aws" {
  region = "ap-northeast-1"
}

data "aws_iam_policy_document" "assume_role_with_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/${var.eks_cluster_oidc_issuer_url}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.eks_cluster_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:${var.ksa_name}"]
    }
  }
}

resource "aws_iam_role" "bigquery_workload_identity_role" {
  name               = "bigquery-workload-identity-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_with_oidc.json
}

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  url = var.eks_cluster_oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  # Hardcoding the thumbprint_list value is safe in terms of security,
  # but it might require manual updates if the value changes.
  # Using a dynamic method to obtain the thumbprint is a more robust solution but requires additional work.
  thumbprint_list = [
    "75e652d4d05359d11ffa3976c0dbccaf60d2b28d",
  ]
}
