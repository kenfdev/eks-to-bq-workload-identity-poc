# Connect an EKS pod to BigQuery via Workload Identity Federation 

## Prerequisites

- An EKS cluster already exists
- An google cloud project already exists
  - You have a BigQuery dataset and table
    - You can create one with the `bigquery/customers.csv` if you want

## Create the PoC

### Create the EKS cluster

If you haven't created the cluster yet, you can use the `eks/cluster.yaml`.

```sh
# This will take a while...
eksctl create cluster -f cluster.yaml
```

### Create AWS and Google Cloud Resources via Terraform

#### Terraform init

```sh
cd terraform
terraform init
```

#### Deploy via Terraform

```sh
terraform apply
```

### Build the sample app and push to a docker registery

```sh
cd app

# Use the $TAG_NAME where you can push the image
docker build -t $TAG_NAME .
docker push $TAG_NAME
```

### Deploy k8s resources

Edit the `k8s/serviceaccount.yaml` and put your iam role(bigquery-workload-identity-role) arn.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: example-sa
  namespace: example-ns
  annotations:
    eks.amazonaws.com/role-arn: "<YOUR ROLE ARN>" # <-- here
```

Deploy your resources.

```sh
cd k8s
kubectl apply -f .
```

## Check the PoC

```sh
# Check if the pod completed
kubectl --namespace example-ns get pods

# Check the logs
kubectl --namespace example-ns logs bigquery-sample-app-7f94fbdfcc-nt9pd
```

If you see something like the following, it worked!

```
> bigquery-sample-app@1.0.0 start /app
> node app.js

Job 23876dc4-caa8-44b3-a45c-dfa7ee6cc86a started.
Rows:
{
  int64_field_0: 1,
  string_field_1: 'John',
  string_field_2: 'Doe',
  string_field_3: 'johndoe@example.com',
  string_field_4: '555-123-4567',
  timestamp_field_5: BigQueryTimestamp { value: '2023-01-01T00:00:00.000Z' }
}
{
  int64_field_0: 2,
  string_field_1: 'Jane',
  string_field_2: 'Smith',
  string_field_3: 'janesmith@example.com',
  string_field_4: '555-987-6543',
  timestamp_field_5: BigQueryTimestamp { value: '2023-02-15T00:00:00.000Z' }
}
{
  int64_field_0: 3,
  string_field_1: 'Jim',
  string_field_2: 'Brown',
  string_field_3: 'jimbrown@example.com',
  string_field_4: '555-555-5555',
  timestamp_field_5: BigQueryTimestamp { value: '2023-03-10T00:00:00.000Z' }
}
```