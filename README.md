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
- **Monitoring**: Prometheus & Grafana
- **Application:** Django
- **Database:** PostgreSQL (AWS RDS)

---

## Project Architecture & Workflow

The automation follows these steps:

1.  A developer pushes code changes to the GitHub repository.
2.  A GitHub Webhook detects the push and sends a notification to the Jenkins server.
3.  Jenkins triggers a pipeline that:
    -   Builds a new Docker image for the Django application using Kaniko.
    -   Pushes the tagged image to the Amazon ECR repository.
    -   Updates the `tag:` in the `values.yaml` file of the Helm chart within the Git repository.
    -   Commits and pushes this configuration change back to the repository.
4.  Argo CD, which is continuously monitoring the repository, detects the new commit.
5.  Argo CD "syncs" the application, applying the updated Helm chart to the EKS cluster.
6.  Kubernetes pulls the newly tagged Docker image from ECR and performs a rolling update of the Django application pods.

---

## Key Terraform Modules

### RDS Database Module (`/modules/rds`)

This module is responsible for provisioning a fully managed PostgreSQL database on AWS. It is designed to be flexible, supporting both standard **AWS RDS** and high-availability **AWS Aurora**. The module handles networking, security groups, and parameter groups.

#### Example Usage (`main.tf`)

```terraform
module "database" {
  source = "./modules/rds"

  # --- Architecture (Controlled by a single variable) ---
  use_aurora             = false
  aurora_replica_count   = 2 # This is ignored if use_aurora is false
  
  # --- Network ---
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  publicly_accessible    = false
  allowed_cidr_blocks    = [module.vpc.vpc_cidr_block]

  # --- Database Config ---
  db_name                = "djangodbrds"
  db_username            = "django_user"
  db_password            = var.db_password
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.medium"
  
  # --- Parameters ---
  parameter_group_params = [
    { name = "max_connections", value = "150", apply_method = "pending-reboot" },
    { name = "log_statement", value = "ddl", apply_method = "pending-reboot" }
  ]

  tags = {
    Project     = "Neoversity"
    Environment = "Production"
  }
}
```

#### Input Variables

| Variable | Description | Type |
| :--- | :--- | :--- |
| `use_aurora` | If true, creates an Aurora Cluster. If false, creates a standard RDS instance. | `bool` |
| `aurora_replica_count` | The number of read replicas for an Aurora cluster. Ignored if `use_aurora` is false. | `number` |
| `db_name` | The name for the database instance/cluster and the database itself. | `string` |
| `db_username` | The username for the master user. | `string` |
| `db_password` | The password for the master user. | `string` |
| `engine` | The database engine (e.g., 'postgres', 'aurora-postgresql'). | `string` |
| `engine_version` | The database engine version. | `string` |
| `instance_class`| The instance class for the DB (e.g., 'db.t3.medium'). | `string` |
| `vpc_id` | ID of the VPC where the DB will be deployed. | `string` |
| `private_subnet_ids` | A list of private subnet IDs. | `list(string)` |
| `public_subnet_ids` | A list of public subnet IDs. | `list(string)` |
| `publicly_accessible` | Determines if the database is publicly accessible. | `bool` |
| `allowed_cidr_blocks` | A list of CIDR blocks allowed to connect to the database. | `list(string)` |
| `allocated_storage` | Storage for standard RDS (in GB). Ignored for Aurora. | `number` |
| `multi_az` | Enable Multi-AZ for standard RDS. Ignored for Aurora. | `bool` |
| `skip_final_snapshot` | If true, a final snapshot will not be taken on deletion. | `bool` |
| `parameter_group_params` | A list of parameters to apply to the DB. | `list(object)` |
| `tags` | A map of tags to apply to all resources. | `map(string)` |

#### How to Configure the Database

You can easily change the database architecture, size, and version by modifying the variables passed to the module block.

-   **To Switch Between RDS and Aurora:**
    Change the `use_aurora` variable. For a standard, single-instance RDS database, set `use_aurora = false`. For a high-availability Aurora cluster, set `use_aurora = true`.

-   **To Change the Engine and Version:**
    Modify the `engine` and `engine_version` variables. Ensure the version is compatible with the chosen engine.
    -   *Standard RDS Example:* `engine = "postgres"`, `engine_version = "16.3"`
    -   *Aurora Example:* `engine = "aurora-postgresql"`, `engine_version = "15.3"`

-   **To Change the Instance Size (Performance):**
    Update the `instance_class` variable. You can choose any valid RDS instance class based on your performance needs.
    -   *Small / Test:* `instance_class = "db.t3.medium"`
    -   *Large / Production:* `instance_class = "db.r6g.large"`

---

## Project Structure

The project is organized into `final-project/` for all infrastructure and Kubernetes code.

```
final-project/
├── main.tf           # Main Terraform file to orchestrate all modules.
├── backend.tf          # Configuration for remote state with S3.
├── Jenkinsfile         # Declarative pipeline for the Jenkins CI job.
│
├── modules/            # Reusable Terraform modules.
│   ├── s3-backend/     # S3 bucket and DynamoDB table for Terraform state.
│   ├── vpc/            # Custom VPC, subnets, and networking.
│   ├── ecr/            # ECR repository for the Docker image.
│   ├── eks/            # EKS cluster and node group.
│   ├── rds/            # RDS / Aurora database provisioning.
│   ├── jenkins/        # Jenkins installation via Helm, with configuration.
│   └── argo_cd/        # Argo CD installation and Application setup via Helm.
│
└── charts/
    └── django-app/     # Helm chart for the Django application.
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
``````

## Deployment Commands

Follow these steps from the project's root directory.

### Phase 1: Provision Cloud Infrastructure (Terraform)

1.  Navigate to the Terraform directory:

    ```bash
    cd final-project
    ```

2.  Create the S3 Backend for Terraform State:
    We use a two-step process to have Terraform manage its own remote state bucket.

    ```bash
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

3.  Deploy the VPC, ECR, and EKS Cluster:

    ```bash
    terraform apply -auto-approve
    ```

4.  Configure `kubectl` to Access the New Cluster:
    This command retrieves the access credentials for your new cluster and automatically configures your local `kubeconfig` file.

    ```bash
    aws eks --region us-east-1 update-kubeconfig --name $(terraform output -raw eks_cluster_name)
    ```

    Verify the connection. You should see one or more nodes in the `Ready` status.

    ```bash
    kubectl get nodes
    ```

### Phase 2: Configure the GitHub Webhook

For Jenkins to be notified of git push events, you must set up a webhook in your GitHub repository.

1.  Get the Jenkins URL: Jenkins was installed with a Load Balancer. Get its public address:

    ```bash
    kubectl get svc jenkins -n jenkins
    ```

    Copy the **EXTERNAL-IP** address.

2.  Set up the Webhook in GitHub:
    -   Navigate to your forked repository on GitHub.
    -   Go to **Settings** > **Webhooks**.
    -   Click **Add webhook**.
    -   **Payload URL**: Paste the Jenkins URL and add `/github-webhook/` to the end. (e.g., `http://<your-jenkins-external-ip>/github-webhook/`)
    -   **Content type**: Select `application/json`.
    -   Leave the other settings as default and click **Add webhook**. You should see a green checkmark indicating a successful delivery.

### Phase 3: The CI/CD Pipeline in Action

With the platform running and the webhook configured, the pipeline is now live.

---

#### Trigger the Pipeline

Make a small, harmless change to your code (e.g., add a comment in the `README.md`) and push it to your `final-project` branch.

```bash
git commit -am "Triggering CI/CD pipeline"
git push origin final-project
```

---

#### How to Check the Jenkins Job

The Jenkins service is configured with the username **admin** and password **admin123**.

1.  Open the Jenkins URL in your browser and log in.
2.  You will see two jobs:
    -   `seed-job` (which created the main job)
    -   `goit-django-docker`
3.  Click on **goit-django-docker** to see its build history.
4.  The build triggered by your push should be running or recently completed.
5.  View its console output to see the Docker build and `git push` steps.

---

#### How to See the Result in Argo CD

**Get the Argo CD Password:** The initial admin password is stored in a Kubernetes secret. Retrieve it with this command:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**Get the Argo CD URL:** Argo CD was also installed with a Load Balancer.

```bash
kubectl get svc argocd-server -n argocd
```

1.  Open the Argo CD URL in your browser.
2.  Log in with the username **admin** and the password you just retrieved.
3.  You will see the **django-app** application.
4.  After Jenkins pushes the `values.yaml` update, the app status will change to **OutOfSync**.
5.  Argo CD will then automatically start syncing — the status will go through **Progressing** and finally become **Healthy**.
6.  You can visually see the new pods being created in the UI.

---

### Phase 4: Monitoring with Prometheus and Grafana

The monitoring stack, consisting of Prometheus and Grafana, is automatically deployed. Here’s how to access and use it.

---

#### Accessing Prometheus

Prometheus is used for collecting metrics from the Kubernetes cluster.

1.  **Forward the Prometheus Server Port:**
    Use `kubectl` to forward the port of the Prometheus server to your local machine.

    ```bash
    kubectl port-forward -n monitoring svc/prometheus-server 9090:80
    ```

2.  **Open the Prometheus UI:**
    Open your web browser and navigate to `http://localhost:9090`. Here you can run PromQL queries and check the status of monitored targets.

---

#### Accessing and Configuring Grafana

Grafana is used for visualizing the metrics collected by Prometheus.

1.  **Get the Grafana Admin Password:**
    The Grafana admin password is set to `admin123` in the Terraform module.

2.  **Forward the Grafana Port:**
    Use `kubectl` to forward the Grafana service port.

    ```bash
    kubectl port-forward svc/grafana 3000:80 -n monitoring
    ```

3.  **Log In to Grafana:**
    -   Open your web browser and go to `http://localhost:3000`.
    -   Log in with the username `admin` and the password `admin123`.

---

#### Adding Prometheus as a Data Source in Grafana

Grafana needs to be configured to pull data from Prometheus.

1.  **Navigate to Data Sources:**
    In the Grafana UI, go to **Configuration (gear icon)** > **Data Sources**.

2.  **Add Prometheus:**
    -   Click **Add data source** and select **Prometheus**.
    -   Set the **URL** to `http://prometheus-server.monitoring.svc:80`.
    -   Leave the other settings as default and click **Save & test**. You should see a "Data source is working" message.

---

#### Importing a Kubernetes Dashboard

Instead of building a dashboard from scratch, you can import a pre-built one.

1.  **Find a Dashboard:**
    Go to the [Grafana Dashboards](https://grafana.com/grafana/dashboards/) website and search for a Kubernetes dashboard. A popular one is **Kubernetes cluster monitoring (via Prometheus)** with ID `315`.

2.  **Import the Dashboard:**
    -   In the Grafana UI, go to **Dashboards (four squares icon)** > **Import**.
    -   Enter the dashboard ID (e.g., `315`) and click **Load**.
    -   In the next step, select your **Prometheus** data source from the dropdown menu.
    -   Click **Import**.

You should now have a comprehensive dashboard showing the health and performance of your EKS cluster.

---

## Tearing Down the Infrastructure

To avoid ongoing AWS costs, follow this safe, multi-step process to destroy all resources.

---

#### 1. Delete the Argo CD Application

This tells Argo CD to remove the Django application and its resources (Load Balancer, pods, etc.) from the production namespace.

```bash
kubectl delete application django-app -n argocd
```

---

#### 2. Destroy the Terraform Infrastructure

This command will destroy the EKS cluster, VPC, ECR, Jenkins, and Argo CD itself.

```bash
cd final-project
terraform destroy -auto-approve
```

Wait for this to complete.

---