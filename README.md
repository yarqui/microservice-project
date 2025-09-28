# Terraform AWS Infrastructure for Lesson 5

This project uses Terraform to provision a foundational cloud infrastructure on AWS. It is designed to be modular, scalable, and follow best practices for managing infrastructure as code, including remote state management with S3 and DynamoDB.

The infrastructure consists of three main components:

1. **S3 Backend:** A secure S3 bucket and DynamoDB table for storing and locking the Terraform state.

2. **VPC:** A custom Virtual Private Cloud (VPC) with public and private subnets to create an isolated network environment.

3. **ECR:** An Elastic Container Registry (ECR) repository for storing Docker images.

---

## Project Structure

The project is organized into a root configuration and reusable modules to promote clarity and maintainability.

```
lesson-5/
│
├── main.tf          # Main file for orchestrating and connecting all modules.
├── backend.tf       # Backend configuration for remote state storage (S3 + DynamoDB).
├── outputs.tf       # Root outputs to display key resource information.
│
├── modules/         # Directory containing all reusable modules.
│   │
│   ├── s3-backend/  # Module for creating the S3 bucket and DynamoDB table.
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── vpc/         # Module for creating the VPC and networking resources.
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── ecr/         # Module for creating the ECR repository.
│       ├── ecr.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── README.md        # Project documentation (this file).
```

## Usage Commands

To deploy and manage this infrastructure, navigate to the `lesson-5` directory and use the following Terraform commands.

**1. Initialize the Workspace**
This command downloads the necessary provider plugins (in this case, for AWS) and configures the backend. It must be run before any other commands.

```bash
terraform init
```

**2. Plan the Changes**
This command creates an execution plan, showing you what resources Terraform will create, modify, or destroy. It's a safe way to preview changes before applying them.

```bash
terraform plan
```

**2. Apply the Changes**
This command applies the changes described in the plan, creating the actual infrastructure in your AWS account. You will be prompted to confirm before any resources are provisioned.

```bash
terraform apply
```

**4. Destroy the Infrastructure**
This command will destroy all the resources created by this Terraform configuration. This is crucial for avoiding unwanted costs in a learning environment.

```bash
terraform destroy
```

## Module Explanations

**1. `s3-backend` Module**

This module is responsible for creating the foundational resources needed for secure, remote state management.

- `s3.tf`: Provisions a private S3 bucket with versioning and server-side encryption enabled. This bucket stores the terraform.tfstate file, which keeps a record of your managed infrastructure. Versioning is enabled to protect against accidental state file corruption or deletion.

- `dynamodb.tf`: Provisions a DynamoDB table with a primary key of LockID. This table is used for state locking, which prevents multiple users or automation pipelines from running terraform apply at the same time and corrupting the state.

**2. `vpc` Module**

This module builds a secure and isolated network environment in AWS.

- `vpc.tf`: Creates the core networking components:

  - An AWS VPC to provide a logically isolated section of the AWS cloud.

  - Three public subnets, which are connected to the internet via an Internet Gateway. Resources like web servers or load balancers would be placed here.

  - Three private subnets, which are not directly accessible from the internet. Resources like databases or backend application servers would be placed here for security.

- `routes.tf`: Configures the route tables that control the flow of traffic. It creates a route in the public route table that directs all outbound traffic (0.0.0.0/0) to the Internet Gateway, granting resources in public subnets internet access.

**3. `ecr` Module**

This module creates a private repository for storing and managing your Docker container images.

- `ecr.tf`:

  - Provisions an AWS ECR (Elastic Container Registry) repository. This provides a secure and scalable location to push your application's Docker images.

  - Configures image scanning on push, which automatically checks your container images for common software vulnerabilities.

  - Sets up a lifecycle policy to automatically expire and clean up older images, helping to manage storage costs.
