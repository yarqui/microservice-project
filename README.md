# Deploying a Django Application to AWS EKS with Terraform and Helm

This project demonstrates a complete, production-style workflow for deploying a containerized Django application on the **Amazon Elastic Kubernetes Service (EKS)**.

The entire cloud infrastructure, including a custom VPC, the EKS cluster, and an Elastic Container Registry (ECR) for the Docker image, is provisioned using **Terraform**. The Django application and its PostgreSQL database are packaged and deployed as a cohesive unit using a **Helm chart**.

This repository serves as a comprehensive guide to integrating Infrastructure as Code (IaC) with Kubernetes container orchestration.

---

## Key Technologies

* **Cloud Provider:** AWS
* **Infrastructure as Code:** Terraform
* **Containerization:** Docker
* **Container Orchestration:** Kubernetes (AWS EKS)
* **Package Management:** Helm
* **Application:** Django
* **Database:** PostgreSQL

---

## Project Structure

The project is organized into `lesson-7/` for all infrastructure and Kubernetes code.

```
lesson-7/
├── main.tf               # Main Terraform file to orchestrate all modules.
├── backend.tf            # Configuration for remote state with S3.
├── outputs.tf            # Root outputs for key infrastructure details.
│
├── modules/              # Reusable Terraform modules.
│   ├── s3-backend/       # S3 bucket and DynamoDB table for Terraform state.
│   ├── vpc/              # Custom VPC, subnets, and networking.
│   ├── ecr/              # ECR repository for the Docker image.
│   └── eks/              # EKS cluster and node group.
│
└── charts/               # Helm charts for application deployment.
    └── django-app/
        ├── Chart.yaml    # Chart metadata and dependencies (PostgreSQL).
        ├── values.yaml   # Configuration values for the chart.
        └── templates/    # Kubernetes manifest templates.
            ├── _helpers.tpl
            ├── configmap.yaml
            ├── deployment.yaml
            ├── hpa.yaml
            └── service.yaml
```
# Deployment Commands
Follow these steps from the project's root directory.

## Phase 1: Provision Cloud Infrastructure (Terraform)
This phase creates the S3 backend, VPC, ECR repository, and the EKS cluster.

1. Navigate to the Terraform directory:
```
cd lesson-7
```
2. Create the S3 Backend for Terraform State:
We use a two-step process to have Terraform manage its own remote state bucket.
```
# Temporarily disable the backend configuration
mv backend.tf backend.tf.disabled

# Initialize locally and create the S3 bucket and DynamoDB table
terraform init
terraform apply -target=module.s3_backend -auto-approve

# Re-enable the backend configuration
mv backend.tf.disabled backend.tf

# Re-initialize, this time migrating the state to the newly created S3 bucket
terraform init -migrate-state
```
3. Deploy the VPC, ECR, and EKS Cluster:
```
terraform apply -auto-approve
```
4. Configure `kubectl` to Access the New Cluster:
This command retrieves the access credentials for your new cluster and automatically configures your local `kubeconfig` file.
```
aws eks --region us-east-1 update-kubeconfig --name $(terraform output -raw eks_cluster_name)
```
Verify the connection. You should see one or more nodes in the Ready status.
```
kubectl get nodes
```
## Phase 2: Build and Push the Application Image (Docker)
This phase builds the Django application Docker image and pushes it to the ECR repository.
```
# Navigate to the Django application directory
cd ../docker/django/neoversity/

# Get the ECR URL from Terraform output and store it in a variable
export ECR_URL=$(terraform -chdir=../../../lesson-7 output -raw ecr_repository_url)

# Log Docker into the ECR repository
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

# Build, tag, and push the image
docker build -t $ECR_URL:latest .
docker push $ECR_URL:latest
```

## Phase 3: Deploy the Application (Helm)
This phase deploys the Django application and its PostgreSQL database to your EKS cluster using the Helm chart.
```
# Navigate to the Helm chart directory
cd ../../../lesson-7/charts/django-app/

# The helm upgrade --install command is idempotent: it will install the chart
# if it's not present, or upgrade it if it's already deployed.
helm upgrade my-django-release . \
  --install \
  --set image.repository=$ECR_URL \
  --namespace django --create-namespace
  ```
## Phase 4: Verify the Deployment
```
# Watch the pods start up.
# The postgresql pod will start first, then the django pods will run their init container
# for migrations, and finally, all pods will show 'Running' and '1/1'.
# Press Ctrl+C to exit when they are ready.
kubectl get pods -n django --watch

# Get the public URL of the application's Load Balancer
kubectl get svc -n django
```

Copy the `EXTERNAL-IP` address for the `my-django-release-service` and paste it into your browser. You will see your live Django application!

---
# Tearing Down the Infrastructure
To avoid ongoing AWS costs, destroy all the created resources when you are finished.

## 1. Uninstall the Helm Release:
This deletes the Django application, the PostgreSQL database, the Load Balancer, and the Persistent Volume.
```
helm uninstall my-django-release -n django
```
## 2. Destroy the Terraform Infrastructure:
This destroys the EKS cluster, VPC, ECR repository, and S3 backend resources.
```
# Navigate to the Terraform directory
cd ../../../lesson-7/

# Destroy all resources
terraform destroy -auto-approve
```

