# DevOps Assignment – AWS Infrastructure, CI/CD, Monitoring & Logging

## 1. Overview

This project implements an end-to-end DevOps workflow for deploying and monitoring a containerized application on AWS.

The implementation covers:

- Infrastructure provisioning using Terraform
- AWS VPC networking
- Public and private subnets
- EC2-based application hosting
- Amazon RDS PostgreSQL
- Application Load Balancer
- Security groups
- Docker containerization
- GitHub Actions CI/CD
- Automated unit and integration testing
- Container vulnerability scanning using Trivy
- Docker image publishing to GitHub Container Registry (GHCR)
- Staging and production deployment
- AWS IAM OIDC authentication for GitHub Actions
- AWS Systems Manager for deployment
- Manual approval for production deployment
- Amazon CloudWatch monitoring
- Centralized logging
- RDS backup strategy
- Email failure notifications using Amazon SES

The application itself is intentionally simple because the primary objective of this assignment is to demonstrate infrastructure, automation, security, monitoring and operational practices.

---

## 2. Architecture

```text
                         GitHub Repository
                                |
                         Pull Request
                                |
                    +-----------v-----------+
                    | GitHub Actions - CI   |
                    |-----------------------|
                    | Unit Tests             |
                    | Integration Tests      |
                    | Docker Build            |
                    | Trivy Security Scan    |
                    +-----------+-----------+
                                |
                           Merge to main
                                |
                    +-----------v-----------+
                    | Build Docker Image    |
                    | Push to GHCR          |
                    +-----------+-----------+
                                |
                    +-----------v-----------+
                    | Staging EC2           |
                    | Docker Application    |
                    +-----------+-----------+
                                |
                         Manual Approval
                                |
                    +-----------v-----------+
                    | Production EC2        |
                    | Docker Application    |
                    +-----------+-----------+

        Internet
           |
           v
   Application Load Balancer
           |
           v
     EC2 Application
           |
           v
      RDS PostgreSQL

           |
           v
      CloudWatch
   Metrics + Logs
```

The AWS infrastructure is provisioned using Terraform. The EC2 instances provisioned through Terraform are used as the staging and production application environments.

---

## 3. Technology Stack

| Area | Technology |
|---|---|
| Cloud Provider | AWS |
| Infrastructure as Code | Terraform |
| Application Hosting | Amazon EC2 |
| Containerization | Docker |
| Container Registry | GitHub Container Registry (GHCR) |
| CI/CD | GitHub Actions |
| Database | Amazon RDS PostgreSQL |
| Load Balancer | Application Load Balancer |
| Deployment | AWS Systems Manager |
| AWS Authentication | GitHub Actions OIDC |
| Monitoring | Amazon CloudWatch |
| Logging | Amazon CloudWatch Logs |
| Security Scanning | Trivy |
| Notifications | Amazon SES |
| Source Control | Git/GitHub |

AWS resources are deployed in the `ap-south-1` region.

---

## 4. Repository Structure

```text
devops-assignment/
│
├── .github/
│   └── workflows/
│       ├── pr.yml
│       └── deploy.yml
│
├── application/
│   ├── tests/
│   │   └── app.test.js
│   ├── Dockerfile
│   ├── index.html
│   └── package.json
│
├── terraform/
│   ├── provider.tf
│   ├── main.tf
│   ├── vpc.tf
│   ├── ec2.tf
│   ├── rds.tf
│   ├── alb.tf
│   ├── security_groups.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── backend.tf
│
├── .gitignore
├── README.md
└── ...
```

---

## 5. Infrastructure Provisioning

Terraform is used to provision:

- VPC
- Public subnets
- Private subnets
- Internet Gateway
- Route tables
- EC2 instances
- RDS PostgreSQL
- Application Load Balancer
- Target groups
- Security groups

### Terraform Initialization

```bash
cd terraform
terraform init
```

### Validate

```bash
terraform validate
```

### Review Changes

```bash
terraform plan
```

### Provision Infrastructure

```bash
terraform apply
```

### Destroy Infrastructure

When the environment is no longer required:

```bash
terraform destroy
```

---

## 6. Terraform Variables

Configurable infrastructure parameters are maintained in:

```text
terraform/variables.tf
```

This avoids hardcoding configuration values directly into resource definitions.

Variables cover configuration such as:

- AWS region
- VPC CIDR
- Subnet CIDRs
- EC2 configuration
- Database configuration
- Environment-related parameters

---

## 7. Terraform State Management

Terraform state tracks the resources provisioned by Terraform.

Generated Terraform state and working directories are excluded from source control using `.gitignore`.

Examples:

```text
.terraform/
*.tfstate
*.tfstate.*
```

For a larger production implementation, Terraform state can be stored in a secure remote backend such as Amazon S3 with appropriate access control, encryption and state locking.

---

## 8. Application

The application is located under:

```text
application/
```

Unit tests are located under:

```text
application/tests/
```

### Install Dependencies

```bash
cd application
npm install
```

### Run Unit Tests

```bash
npm test
```

---

## 9. Docker

The application is containerized using:

```text
application/Dockerfile
```

### Build Docker Image

```bash
cd application
docker build -t ember-app .
```

### Run Docker Container

```bash
docker run -d   --name ember-app   -p 80:80   ember-app
```

The application can then be accessed at:

```text
http://localhost
```

---

## 10. CI/CD Pipeline

GitHub Actions is used to implement CI/CD.

Workflows are located under:

```text
.github/workflows/
```

Main workflows:

```text
pr.yml
deploy.yml
```

---

## 11. Pull Request CI Pipeline

The Pull Request workflow automatically validates code changes.

```text
Pull Request
     |
     v
Checkout Code
     |
     v
Setup Node.js
     |
     v
Install Dependencies
     |
     v
Run Unit Tests
     |
     v
Build Docker Image
     |
     v
Run Integration Tests
     |
     v
Scan Docker Image
```

This provides an automated quality and security gate before changes are merged.

---

## 12. Unit and Integration Testing

### Unit Tests

Unit tests validate application functionality.

```bash
npm test
```

### Integration Tests

Integration testing is performed against the containerized application to verify that the application starts successfully and can be accessed after the Docker container is launched.

---

## 13. Container Security Scanning

Trivy is used to scan Docker images for known vulnerabilities.

The pipeline checks for:

```text
HIGH
CRITICAL
```

severity vulnerabilities.

The pipeline is configured to fail when applicable vulnerabilities are detected.

The container image is scanned before it is pushed to GitHub Container Registry.

---

## 14. Docker Image Publishing

After tests and security checks pass, the Docker image is published to GitHub Container Registry (GHCR).

Images are tagged using the Git commit SHA.

Example:

```text
ghcr.io/anjalivishwakarm/devops-assignment:<commit-sha>
```

Using the Git commit SHA provides an immutable reference to the exact version of the application.

---

## 15. AWS Authentication Using GitHub OIDC

GitHub Actions authenticates with AWS using OpenID Connect (OIDC).

Long-lived AWS access keys are not stored in the workflow.

```text
GitHub Actions
      |
      | OIDC Token
      v
AWS IAM OIDC Provider
      |
      | Assume Role
      v
Temporary AWS Credentials
      |
      v
AWS Resources
```

The IAM trust policy restricts which GitHub repository and branch can assume the deployment role.

---

## 16. Staging Deployment

After the Docker image is successfully built, scanned and pushed, it is deployed to the staging EC2 instance.

AWS Systems Manager (SSM) Run Command is used for deployment.

The deployment performs actions equivalent to:

```bash
docker pull <image>

docker stop ember-app || true

docker rm ember-app || true

docker run -d   --name ember-app   --restart unless-stopped   -p 80:80   <image>
```

SSM allows GitHub Actions to execute deployment commands on EC2 without requiring direct SSH access from the GitHub runner.

---

## 17. Production Deployment

Production deployment is configured using a protected GitHub Environment.

```text
Build
  |
  v
Security Scan
  |
  v
Push Image
  |
  v
Deploy to Staging
  |
  v
Manual Approval
  |
  v
Deploy to Production
```

The same tested Docker image is promoted to production rather than rebuilding a separate image.

---

## 18. Failure Notifications

Amazon SES is used for CI/CD failure notifications.

The notification contains information such as:

- Repository
- Branch
- Commit
- Workflow
- GitHub Actions run information

Sensitive configuration is stored using GitHub Secrets.

---

## 19. Monitoring

Amazon CloudWatch is used for infrastructure, application and database monitoring.

Two meaningful dashboards have been created.

---

## 20. Dashboard 1 – Infrastructure Monitoring

The infrastructure dashboard provides visibility into EC2 infrastructure.

Metrics include:

- CPU utilization
- Memory utilization
- Available memory
- Disk utilization
- Free disk space
- Swap utilization

The CloudWatch Agent is used to collect operating-system-level metrics that are not available through default EC2 monitoring.

Example metrics:

```text
CPUUtilization
mem_used_percent
mem_available
disk_used_percent
disk_free
swap_used_percent
```

---

## 21. Dashboard 2 – Application and Database Monitoring

The second dashboard provides visibility into application traffic, load balancer performance and RDS health.

### Application / Load Balancer Metrics

The dashboard includes:

- Request count
- HTTP 2XX responses
- HTTP 4XX responses
- Target response time / latency

### RDS Metrics

The dashboard includes:

- CPU utilization
- Database connections
- Read IOPS
- Write IOPS
- Free storage space
- Write latency
- Network throughput

---

## 22. Centralized Logging

Amazon CloudWatch Logs is used for centralized log collection.

### Application Logs

Application/container logs can be collected and centralized in CloudWatch Logs.

### System Logs

EC2 system-level logs can be collected using the CloudWatch Agent.

### Access Logs

Web server/access logs can be centralized in CloudWatch Logs to provide visibility into incoming HTTP requests.

Centralized logging allows troubleshooting without manually checking individual EC2 instances.

---

## 23. Database

Amazon RDS PostgreSQL is used as the managed database service.

RDS provides managed capabilities such as:

- Database infrastructure management
- Monitoring
- Automated backups
- Storage management
- Database availability features

CloudWatch provides native RDS metrics such as:

- CPU utilization
- Database connections
- Storage
- IOPS
- Latency
- Network throughput

---

## 24. Backup Strategy

Amazon RDS automated backups are used as the database backup strategy.

Automated backups provide protection against accidental data loss and allow the database to be restored when required.

For production, backup retention should be configured according to business requirements and defined Recovery Point Objective (RPO) and Recovery Time Objective (RTO).

Backup restoration should also be tested periodically.

---

## 25. Security Considerations

### IAM OIDC

GitHub Actions uses OIDC authentication instead of long-lived AWS access keys.

### IAM Role

GitHub Actions assumes an AWS IAM role with permissions required for deployment.

### Security Groups

AWS security groups control network traffic between resources.

Only required ports and communication paths are allowed.

### Private Database

The RDS database is designed to remain separated from direct public access.

### Container Security

Trivy scans Docker images for known HIGH and CRITICAL vulnerabilities before publishing.

### Secrets

Sensitive values are stored using GitHub Secrets rather than being hardcoded.

### Git Ignore

Generated and sensitive files are excluded from source control.

```text
.terraform/
*.tfstate
*.tfstate.*
.env
```

### Immutable Container Images

Docker images are tagged using Git commit SHA values so an exact application version can be identified and deployed.

---

## 26. Cost Optimization

Cost optimization measures include:

- Appropriately sized EC2 instances for the assignment
- Managed RDS instead of manually managing a database server
- CloudWatch instead of deploying a separate monitoring platform
- Avoiding unnecessary infrastructure components
- Stopping or terminating resources when not required
- Using a lightweight Docker image

For production, further optimization could include:

- EC2 right-sizing
- RDS right-sizing
- CloudWatch log retention policies
- Automated cleanup of unused resources
- Savings Plans or Reserved Instances where appropriate
- Auto Scaling based on workload

---

## 27. Challenges Faced and Resolutions

### Trivy Vulnerability Findings

The initial Docker image scan detected HIGH severity vulnerabilities in packages included in the container base image.

The container/base package versions were updated and the image was rebuilt. Trivy was then executed again to verify that the security scan passed.

### Docker Image Naming

The initial Docker build encountered an error because Docker repository names must use lowercase characters.

The GHCR image name was corrected to use lowercase characters.

### GitHub OIDC Authentication

The initial AWS deployment failed because the IAM OIDC trust relationship did not correctly authorize the GitHub Actions identity.

The IAM trust policy was updated to correctly match the GitHub repository and deployment branch.

### EC2 Instance Identification

The deployment initially encountered an issue where the EC2 instance ID was not correctly passed to the SSM command.

The GitHub repository variable was corrected and the instance ID was verified before deployment.

### GitHub Actions YAML Configuration

The workflow encountered YAML syntax and indentation issues during development.

The workflow structure was corrected and the pipeline was successfully executed.

### Production Deployment

The production deployment required troubleshooting around AWS authentication and deployment configuration.

After correcting the IAM and deployment configuration, the complete pipeline successfully executed.

---

## 28. Best Practices Implemented

- Infrastructure as Code using Terraform
- CI/CD automation using GitHub Actions
- Immutable Docker artifacts
- OIDC authentication
- Container vulnerability scanning
- Environment separation
- Manual production approval
- Centralized monitoring
- Centralized logging
- Database backup strategy
- Failure notifications

---

## 29. Future Improvements

### Infrastructure

- Remote Terraform state using Amazon S3
- State locking
- Terraform modules
- Auto Scaling Groups
- Multi-AZ application deployment

### Security

- AWS Secrets Manager
- More restrictive IAM policies
- Private application instances
- AWS WAF
- Additional dependency scanning

### CI/CD

- Automated rollback
- Blue-green deployments
- Canary deployments
- Deployment health checks
- Automated rollback on failed health checks

### Monitoring

- CloudWatch alarms
- SNS alerting
- Application Performance Monitoring
- More detailed application metrics
- Automated incident response

### Reliability

- Multi-AZ database configuration
- Defined RPO/RTO
- Disaster recovery strategy
- Automated backup restoration testing

---

## 30. Deployment Flow

```text
Developer
    |
    v
Create Pull Request
    |
    v
GitHub Actions
    |
    +--> Unit Tests
    |
    +--> Integration Tests
    |
    +--> Docker Build
    |
    +--> Trivy Security Scan
    |
    v
Merge to main
    |
    v
Build Docker Image
    |
    v
Push Image to GHCR
    |
    v
Deploy to Staging EC2
    |
    v
Manual Production Approval
    |
    v
Deploy to Production EC2
    |
    v
Application Running
    |
    +--> CloudWatch Metrics
    |
    +--> CloudWatch Logs
    |
    +--> RDS Monitoring
    |
    +--> SES Failure Notifications
```

---

## 31. Verification

### GitHub Actions

GitHub Actions provides visibility into:

- Build status
- Test results
- Trivy scan results
- Docker image publishing
- Staging deployment
- Production deployment
- Failure notifications

### AWS

AWS provides visibility through:

- EC2
- Application Load Balancer
- RDS
- Systems Manager
- CloudWatch
- IAM

### Application

The deployed application can be accessed through the Application Load Balancer endpoint.

---

## 32. Conclusion

This project demonstrates an end-to-end DevOps implementation on AWS.

The solution combines Infrastructure as Code, containerization, CI/CD, security scanning, controlled deployments, centralized monitoring, logging, database management, backup strategy and failure notification.

The architecture provides:

- Repeatable infrastructure provisioning
- Automated software delivery
- Security checks before deployment
- Controlled production releases
- Centralized observability
- Secure AWS authentication
- Operational visibility
- Database backup and recovery capability

The implementation can be further extended with automated rollback, Auto Scaling, AWS Secrets Manager, CloudWatch alarms, WAF, blue-green deployments and a fully remote Terraform state backend for a production environment.