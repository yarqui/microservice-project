# End-to-End CI/CD for a Django Application on AWS EKS

This project demonstrates a complete, end-to-end CI/CD pipeline for deploying a containerized Django application on the Amazon Elastic Kubernetes Service (EKS). The entire workflow is automated using a GitOps methodology.

Infrastructure is provisioned with Terraform, which sets up not only the EKS cluster and networking but also the CI/CD tooling itself: Jenkins for continuous integration and Argo CD for continuous delivery.

When a developer pushes a code change, a GitHub webhook triggers a Jenkins pipeline that automatically builds a new Docker image, pushes it to ECR, and updates a Helm chart configuration in Git. Argo CD then detects this change and automatically syncs the new version of the application to the EKS cluster.

---

## Key Technologies

- **Cloud Provider:** AWS
- **Infrastructure as Code:** Terraform
- **Containerization:** Docker
- **CI Server**: Jenkins
- **CD / GitOps Tool**: Argo CD
- **Container Orchestration:** Kubernetes (AWS EKS)
- **Package Management:** Helm
- **Application:** Django
- **Database:** PostgreSQL

---

## Project Architecture & Workflow

The automation follows these steps:

1. Developer pushes code changes to the GitHub repository.
2. A GitHub Webhook detects the push and sends a notification to the Jenkins server.
3. Jenkins triggers a pipeline that:
   - Builds a new Docker image for the Django application using Kaniko.
   - Pushes the tagged image to the Amazon ECR repository.
   - Updates the tag: in the values.yaml file of the Helm chart within the Git repository.
   - Commits and pushes this configuration change back to the repository.
4. Argo CD, which is continuously monitoring the repository, detects the new commit.
5. Argo CD "syncs" the application, applying the updated Helm chart to the EKS cluster.
6. Kubernetes pulls the newly tagged Docker image from ECR and performs a rolling update of the Django application pods.

---

## Project Structure

The project is organized into `lesson-10/` for all infrastructure and Kubernetes code.

```
lesson-10/
├── main.tf               # Main Terraform file to orchestrate all modules.
├── backend.tf            # Configuration for remote state with S3.
├── Jenkinsfile           # Declarative pipeline for the Jenkins CI job.
│
├── modules/              # Reusable Terraform modules.
│   ├── s3-backend/       # S3 bucket and DynamoDB table for Terraform state.
│   ├── vpc/              # Custom VPC, subnets, and networking.
│   ├── ecr/              # ECR repository for the Docker image.
│   ├── eks/              # EKS cluster and node group.
│   ├── jenkins/          # Jenkins installation via Helm, with configuration.
│   └── argo_cd/          # Argo CD installation and Application setup via Helm.
│
└── charts/
    └── django-app/       # Helm chart for the Django application.
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
```

# Deployment Commands

Follow these steps from the project's root directory.

## Phase 1: Provision Cloud Infrastructure (Terraform)

1. Navigate to the Terraform directory:

```
cd lesson-10
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
terraform apply -var-file="terraform.tfvars" -auto-approve
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

## Phase 2: Phase 2: Configure the GitHub Webhook

For Jenkins to be notified of git push events, you must set up a webhook in your GitHub repository.

1. Get the Jenkins URL: Jenkins was installed with a Load Balancer. Get its public address:

```
kubectl get svc jenkins -n jenkins
```

Copy the **EXTERNAL-IP** address

2. Set up the Webhook in GitHub:
   - Navigate to your forked repository on GitHub.
   - Go to Settings > Webhooks.
   - Click Add webhook.
   - Payload URL: Paste the Jenkins URL and add `/github-webhook/` to the end. (e.g., `http://<your-jenkins-external-ip>/github-webhook/`)
   - Content type: Select `application/json`.
   - Leave the other settings as default and click Add webhook. You should see a green checkmark indicating a successful delivery.

### Phase 3: The CI/CD Pipeline in Action

With the platform running and the webhook configured, the pipeline is now live.

---

#### **Trigger the Pipeline**

Make a small, harmless change to your code (e.g., add a comment in the `README.md`) and push it to your `lesson-10` branch.

```bash
git commit -am "Triggering CI/CD pipeline"
git push origin lesson-10
```

---

#### **How to Check the Jenkins Job**

The Jenkins service is configured with the username **admin** and password **admin123**.

1. Open the Jenkins URL in your browser and log in.
2. You will see two jobs:

   - `seed-job` (which created the main job)
   - `goit-django-docker`

3. Click on **goit-django-docker** to see its build history.
4. The build triggered by your push should be running or recently completed.
5. View its console output to see the Docker build and `git push` steps.

---

#### **How to See the Result in Argo CD**

**Get the Argo CD Password:** The initial admin password is stored in a Kubernetes secret. Retrieve it with this command:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**Get the Argo CD URL:** Argo CD was also installed with a Load Balancer.

```bash
kubectl get svc argocd-server -n argocd
```

1. Open the Argo CD URL in your browser.
2. Log in with the username **admin** and the password you just retrieved.
3. You will see the **django-app** application.
4. After Jenkins pushes the `values.yaml` update, the app status will change to **OutOfSync**.
5. Argo CD will then automatically start syncing — the status will go through **Progressing** and finally become **Healthy**.
6. You can visually see the new pods being created in the UI.

---

## Tearing Down the Infrastructure

To avoid ongoing AWS costs, follow this safe, multi-step process to destroy all resources.

---

#### **1. Delete the Argo CD Application**

This tells Argo CD to remove the Django application and its resources (Load Balancer, pods, etc.) from the production namespace.

```bash
kubectl delete application django-app -n argocd
```

---

#### **2. Destroy the Terraform Infrastructure**

This command will destroy the EKS cluster, VPC, ECR, Jenkins, and Argo CD itself. It will now work correctly because we have taught it the correct destruction order with `depends_on`.

```bash
cd lesson-10
terraform destroy -var-file="terraform.tfvars" -auto-approve
```

Wait for this to complete.

---
