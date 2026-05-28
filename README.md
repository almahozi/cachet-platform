# Cachet Platform

A practice DevOps project that provisions AWS infrastructure using Terraform and deploys the [Cachet](https://github.com/cachethq/cachet) open source status page application using Docker and GitHub Actions.

---

## Architecture

```
                        ┌─────────────────────────────────────┐
                        │              AWS VPC                 │
                        │           10.0.0.0/16                │
                        │                                      │
                        │  ┌──────────────────────────────┐   │
     Internet ──────────┼──│     Public Subnet             │   │
     (Port 80)          │  │     10.0.1.0/24               │   │
                        │  │                               │   │
                        │  │  ┌─────────────────────────┐ │   │
                        │  │  │   EC2 (Amazon Linux 2023)│ │   │
                        │  │  │                         │ │   │
                        │  │  │  ┌───────────────────┐  │ │   │
                        │  │  │  │  Cachet Container  │  │ │   │
                        │  │  │  └────────┬──────────┘  │ │   │
                        │  │  │           │              │ │   │
                        │  │  │  ┌────────▼──────────┐  │ │   │
                        │  │  │  │  Redis Container   │  │ │   │
                        │  │  │  └───────────────────┘  │ │   │
                        │  │  └─────────────────────────┘ │   │
                        │  └──────────────────────────────┘   │
                        │                                      │
                        │  ┌──────────────────────────────┐   │
                        │  │  Private Subnets              │   │
                        │  │  10.0.2.0/24 / 10.0.3.0/24   │   │
                        │  │                               │   │
                        │  │       ┌─────────────┐         │   │
                        │  │       │  RDS MySQL  │         │   │
                        │  │       └─────────────┘         │   │
                        │  └──────────────────────────────┘   │
                        └─────────────────────────────────────┘
```

---

## Infrastructure (Terraform)

Infrastructure is provisioned using Terraform with a modular structure, and state is stored remotely in S3.

### Modules

**Networking**
- VPC (`10.0.0.0/16`) with DNS support enabled
- 1 public subnet for EC2
- 2 private subnets for RDS (multi-AZ requirement)
- Internet Gateway and public route table
- DB subnet group
- Security groups for EC2 (`cachet-web-sg`) and RDS (`cachet-db-sg`)
  - EC2 SG: allows inbound HTTP (port 80), all outbound, egress to RDS on port 3306
  - RDS SG: allows inbound MySQL (port 3306) from EC2 SG only


**Database**
- RDS MySQL 8.0 instance in private subnets
- Not publicly accessible
- RDS endpoint stored in AWS SSM Parameter Store as `/cachet/prod/DB_HOST`

**Compute**
- EC2 instance (Amazon Linux 2023) in the public subnet
- IAM role with `AmazonSSMManagedInstanceCore` for SSM access (no SSH needed)
- `user_data` script that installs Docker, Docker Compose, and SSM agent on first boot

**IAM**
- GitHub Actions IAM role using OIDC (no long-lived AWS credentials)
- Permissions: `ec2:DescribeInstances`, `ssm:SendCommand`, `ssm:GetParameter`
- Scoped to the `almahozi/cachet-platform` repository

### Remote State

Terraform state is stored in S3 with native locking:

```hcl
backend "s3" {
  bucket       = "cachet-platform-state-406708888206-eu-central-1-an"
  key          = "cachet/terraform.tfstate"
  region       = "eu-central-1"
  use_lockfile = true
}
```

---

## Application (Docker)

Cachet runs via Docker Compose on the EC2 instance with two containers:

| Container | Image | Role |
|---|---|---|
| `cachet` | `cachethq/docker:latest` | Cachet status page app (nginx + php-fpm) |
| `cachet-redis` | `redis:alpine` | Session and cache store |

Both containers share the `cachet-net` bridge network. The app listens on port 8000 internally, mapped to port 80 on the host.

Configuration is injected via environment variables. Dynamic values (`APP_KEY`, `DB_HOST`) are read from a `.env` file written by the CI/CD pipeline at deploy time.

---

## CI/CD (GitHub Actions)

The deploy pipeline runs on every push to `master`.

### Flow

```
Push to master
      ↓
Checkout code
      ↓
Assume AWS IAM role via OIDC
      ↓
Fetch DB_HOST from SSM Parameter Store
      ↓
Find EC2 instance by Name tag
      ↓
SSM Send Command to EC2:
  - Fetch DB_HOST from SSM
  - Write .env file
  - Pull docker-compose.yml from GitHub
  - docker-compose pull && docker-compose up -d
```

### GitHub Secrets Required

| Secret | Description |
|---|---|
| `AWS_ROLE_ARN` | ARN of the GitHub Actions IAM role |
| `APP_KEY` | Laravel app key (`base64:...`) |

### No SSH Required

Deployment uses AWS SSM Send Command exclusively — no SSH keys, no open port 22.

---

## Deployment

### Prerequisites
- Terraform >= 1.x
- AWS CLI configured
- GitHub repository secrets set (`AWS_ROLE_ARN`, `APP_KEY`)

### Provision Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### Deploy Application

Push to `master` — GitHub Actions handles the rest.