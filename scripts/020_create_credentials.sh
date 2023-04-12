#!/bin/bash

SERVICE_ACCOUNT=""
PROJECT_ID=""
PROJECT_NUMBER=""
POOL="aws-pool"
PROVIDER="aws-provider"
gcloud iam workload-identity-pools create-cred-config \
  "projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL}/providers/${PROVIDER}" \
  --subject-token-type="urn:ietf:params:oauth:token-type:jwt" \
  --service-account="${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --credential-source-file="/var/run/secrets/eks.amazonaws.com/serviceaccount/token" \
  --credential-source-type="text" \
  --output-file="config-aws-eks-provider.json"
