# Project Title
Amazon EKS Cluster Deployment with Terraform
## Team Members
- Marwan Emam (Setup & S3 Backend, Compute & EKS(3.3,3.4,3.5,3.6), App Deployment)
- Omar Osama (Networking Module, Compute & EKS(3.1,3.2,3.7,3.8), README Documentation)

## Project Overview

This project demonstrates the deployment of a production-grade Amazon EKS cluster using Terraform Infrastructure as Code.

The architecture includes:
.Custom VPC with multi-AZ subnets
.Amazon EKS cluster (Kubernetes v1.31)
.Managed node group
.AWS Load Balancer Controller
.Private ECR repository
.Jump Server (SSM-only access)
.Nginx containerized application deployed via Kubernetes
.ALB Ingress exposing the application to the internet

The entire infrastructure is modularized into separate Terraform modules with remote state stored in S3.

## Architecture
[Architecture diagram] (docs/Screenshots/architecture-diagram.png)

[Component descriptions]

| Layer         | Component                    | Purpose                            |
| ------------- | ---------------------------- | ---------------------------------- |
| Network       | VPC (10.10.0.0/16)           | Multi-AZ network isolation         |
| Public        | ALB + NAT Gateway            | Internet access & outbound routing |
| Private       | EKS Nodes + Jump Server      | Application & management           |
| Orchestration | Amazon EKS                   | Managed Kubernetes control plane   |
| Registry      | Amazon ECR                   | Private container registry         |
| Ingress       | AWS Load Balancer Controller | ALB management via Kubernetes      |
| IaC           | Terraform                    | Infrastructure automation          |


## Prerequisites

Local Tools:
  .Terraform >= 1.5.0
  .AWS CLI >= 2.x
  .kubectl >= 1.29
  .Helm >= 3.12
  .Git
  .Docker

## Project Structure

VARROW_GRADUATION_PROJECT/
├── README.md
├── .gitignore
├── docs/
│   └── Screenshots/
│       ├── Destroying EKS.png
│       ├── ECR repo - Overall Terraform output.png
│       ├── EKS add-ons.png
│       └── EKS cluster.png
├── k8s/
│   ├── deployment.yaml
│   ├── ingress.yaml
│   ├── nginx-config-simple.yaml
│   └── nginx-ingress-final.yaml
├── scripts/
│   └── create-s3-backends.sh
└── terraform/
    ├── networking/
    │   ├── backend.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── providers.tf
    │   ├── variables.tf
    │   └── .terraform.lock.hcl
    └── compute/
        ├── alb-controller.tf
        ├── aws-auth.yaml
        ├── aws-auth-patch.yaml
        ├── aws-auth-correct.yaml
        ├── backend.tf
        ├── ecr.tf
        ├── eks-addons.tf
        ├── eks-cluster.tf
        ├── eks-node-group.tf
        ├── iam.tf
        ├── iam_policy.json
        ├── jump-server.tf
        ├── jump-server-policies.tf
        ├── main.tf
        ├── outputs.tf
        ├── providers.tf
        ├── security-groups.tf
        ├── session-manager-plugin.deb
        └── .terraform.lock.hcl


## Deployment Instructions

### Step 1: Clone Repository
Run:
  .git clone <repository-url>
  .cd <repository-name>

### Step 2: Create S3 Buckets
Run:
  .bash scripts/create-s3-backends.sh
Buckets created:
.varrow-academy-devops-networking-terraform-backend-us-east-1
.varrow-academy-devops-compute-terraform-backend-us-east-1
### Step 3: Deploy Networking Module
Run:
  .cd terraform/networking
  .terraform init
  .terraform validate
  .terraform plan
  .terraform apply
Resources created:
  .VPC
  .Subnets (Public, Private, Intra)
  .Internet Gateway
  .NAT Gateway
  .Route Tables
### Step 4: Deploy Compute Module
Run:
  .cd ../compute
  .terraform init
  .terraform validate
  .terraform plan
  .terraform apply
Resources created:
  .IAM Roles
  .Security Groups
  .ECR repository
  .EKS cluster
  .EKS add-ons
  .Managed Node Group
  .Jump Server
### Step 5: Configure kubectl
Connect via AWS Systems Manager → Session Manager.
Then run:
  .aws eks update-kubeconfig --name varrow-eks-cluster --region us-east-1 kubectl get nodes

Nodes should show Ready.
### Step 6: Install ALB Controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=varrow-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

### Step 7: Deploy Application
docker pull nginx:latest
docker tag nginx:latest <ecr-uri>:latest
docker push <ecr-uri>:latest

### Step 8: Verify Deployment
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml

## Kubernetes Manifests
Deployment:
  .2 replicas
  .Uses ECR image
Exposes port 80:
  .Service
  .ClusterIP
  .Port 80
Ingress:
  .Internet-facing ALB
  .Target type: IP
  .HTTP listener on port 80

## Configuration

### Environment Variables
Terraform authenticates using AWS credentials configured via AWS CLI or exported environment variables.
#### Configure using AWS CLI (Recommended)
Run:
  .aws configure
Provide:
.AWS Access Key ID
.AWS Secret Access Key
.Default region: us-east-1
.Output format: json  

### Terraform Variables
Networking Module Variables:
Defined in:
 .terraform/networking/variables.tf

| Variable             | Type         | Default   | Description                              |
| -------------------- | ------------ | --------- | ---------------------------------------- |
| environment          | string       | —         | Environment name (e.g., dev)             |
| region               | string       | us-east-1 | AWS region                               |
| cluster_name         | string       | —         | EKS cluster name used for subnet tagging |
| vpc_cidr             | string       | —         | CIDR block for the VPC                   |
| azs                  | list(string) | —         | Availability zones                       |
| public_subnet_cidrs  | list(string) | —         | Public subnet CIDRs                      |
| private_subnet_cidrs | list(string) | —         | Private subnet CIDRs                     |
| intra_subnet_cidrs   | list(string) | —         | Intra subnet CIDRs                       |

Compute Module Variables:
Defined in:
 .terraform/compute/variables.tf

| Variable            | Type   | Default            | Description               |
| ------------------- | ------ | ------------------ | ------------------------- |
| aws_region          | string | us-east-1          | AWS region                |
| environment         | string | dev                | Environment name          |
| cluster_name        | string | varrow-eks-cluster | EKS cluster name          |
| ecr_repository_name | string | varrow-nginx       | ECR repository name       |
| eks_version         | string | 1.31               | Kubernetes version        |
| vpc_cni_version     | string | v1.18.3-eksbuild.3 | VPC CNI add-on version    |
| coredns_version     | string | v1.11.1-eksbuild.9 | CoreDNS add-on version    |
| kube_proxy_version  | string | v1.31.1-eksbuild.2 | kube-proxy add-on version |
| ebs_csi_version     | string | v1.35.0-eksbuild.1 | EBS CSI driver version    |


## Testing
1. ALB Access Test:
  .Open ALB DNS
  .Nginx welcome page loads

2. Node Health:
  Run:
    .kubectl get nodes

  Status: Ready 

3. Pod Status:
  Run:
    .kubectl get pods

  Pods running successfully

4. Scaling Test:
  Run:
    .kubectl scale deployment nginx-deployment --replicas=3

  Verify 3 pods running.

5. Self-Healing Test:
  Run:
    .kubectl delete pod <pod-name>
  
  Pod automatically recreated.
## Troubleshooting
Issue: ALB not provisioning
 .Verify subnet tags:
   .kubernetes.io/role/elb
   .kubernetes.io/role/internal-elb
Issue: Nodes Not Ready
  .Check security groups
  .Verify IAM role attached

Issue: Controller CrashLoop
  .Verify IAM OIDC provider created
  .Verify service account annotation
## Cleanup Instructions
Destroy compute first:
 .Run:
   .cd terraform/compute
   .terraform destroy -auto-approve

Then networking:
 .Run:
   .cd ../networking
   .terraform destroy -auto-approve

Delete ECR repository:
 .Run:
   .aws ecr delete-repository --repository-name varrow-nginx --force


## Lessons Learned
.mportance of subnet tagging for ALB discovery
.Terraform remote state management
.IAM role configuration for EKS
.Kubernetes self-healing mechanisms
.Infrastructure dependency ordering
.Cost awareness in cloud environments

## References
.AWS EKS Documentation
.Terraform AWS Provider Documentation
.AWS Load Balancer Controller Docs
.Kubernetes Official Documentation
.Helm Documentation