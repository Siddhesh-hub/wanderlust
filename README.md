# Wanderlust - Your Ultimate Travel Blog 🌍✈️

A three‑tier MERN (MongoDB, Express, React, Node) travel‑blog application deployed
end‑to‑end on AWS.  The goal of this mega‑project is to demonstrate a complete
DevSecOps/GitOps pipeline: build, test, scan, containerize, push, and finally
release to a Kubernetes cluster running in EKS.  Contributors can learn React,
Docker, Jenkins, Terraform, ArgoCD and more while getting hands‑on with open
source tools.

---

## 🧭 Overview

- **Code repository** stored in GitHub.
- **CI** builds and scans artifacts via Jenkins; containers are published to a
  registry.
- **CD** managed by ArgoCD which watches a Git repo and syncs manifests to
  Kubernetes.
- **Cluster** runs on Amazon EKS.  The entire cluster (VPC, subnets, node groups,
  IAM roles, etc.) is provisioned with **Terraform**.
- **Monitoring/quality**: Prometheus + Grafana, SonarQube, OWASP Dependency
  Check, Trivy filesystem scans, Redis caching, etc.

This README walks you through the features of the project and then provides a
step‑by‑step setup guide using Terraform for the infrastructure.

---

## ✨ Features

- Full CICD pipeline with Jenkins (master + worker nodes)
- GitOps deployment via ArgoCD
- Infrastructure as code using Terraform
- Dockerized MERN application with caching (Redis)
- Automated security scans (OWASP, Trivy)
- Code quality checks using SonarQube
- Monitoring stack deployed with Helm (Prometheus & Grafana)
- AWS EKS cluster hosted in `us-west-1` with multiple node groups
- Sample email notifications and Jenkins pipelines

---

## ⚙️ Prerequisites

1. **AWS account** with programmatic access (access key / secret key).
2. Install the following on your Jenkins master / provisioning machine:
   - Docker
   - Terraform 1.5+ (required for EKS module)
   - AWS CLI
   - Kubectl (to interact with EKS)
   - Git
3. SSH key pair for EC2 (used by Terraform when creating instances).
4. Optional: familiarity with Ubuntu 22.04 LTS (the AMI used by Terraform).

> **Note:** This walkthrough assumes deployment in the _us-west-1_ region.

---

## 🚀 Step‑by‑step Setup

### 1. Provision infrastructure with Terraform

All IPs, security groups, EC2 instances, and the EKS cluster are created via
Terraform modules located under the `terraform/` directory in this repository.
You no longer need to run `eksctl` manually.

```bash
cd terraform
tfenv install   # or ensure terraform 1.x is available
terraform init
# answer the prompts or set variables via -var-file
terraform apply
```

When complete you will have:
- VPC with public/private subnets
- Security groups allowing SSH, HTTP, HTTPS, Jenkins, Redis, etc.
- EC2 instance for Jenkins master and a worker instance
- EKS control plane and managed node group (capacity_type=ON_DEMAND or SPOT)

> To destroy everything: `terraform destroy`.


### 2. Jenkins master installation

SSH to the master instance created by Terraform and install Jenkins:

```bash
sudo apt update -y
sudo apt install fontconfig openjdk-17-jre -y
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key \
  | sudo gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] \
  https://pkg.jenkins.io/debian-stable binary/' \
  | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update && sudo apt install jenkins -y
sudo systemctl enable --now jenkins
```

Access Jenkins at `http://<MASTER_IP>:8080` and complete the setup wizard.


### 3. Configure Jenkins worker node

1. On the worker EC2 instance (also created by Terraform) install Java:

   ```bash
   sudo apt update && sudo apt install openjdk-17-jre -y
   ```

2. Give the worker an IAM role with administrative access (attached by Terraform
   to the instance profile).
3. Generate an SSH keypair on the master and copy the public key to
   `/root/.ssh/authorized_keys` on the worker.
4. In Jenkins master, go to **Manage Jenkins → Nodes → New Node** and configure
   a permanent agent using SSH, pointing at the worker’s public IP.


### 4. Deploy EKS cluster components via Terraform

Terraform already created the cluster, but you must configure `kubectl`:

```bash
aws eks update-kubeconfig --region us-west-1 --name ${cluster_name}
kubectl get nodes   # should show the managed node group
```

Apply any additional Helm charts (e.g. Prometheus & Grafana) or manifests
with Helm/Kubectl as needed.


### 5. Install and configure ArgoCD

Follow the ArgoCD installation section in the repository (or use Helm) and
point it at the Git repository containing your Kubernetes manifests.  This
will automate the CD pipeline.


### 6. Security and quality tooling

- **OWASP Dependency Check** and **Trivy** scans are executed as part of the
  Jenkins CI jobs (see Jenkinsfiles).
- Set up **SonarQube** by deploying the provided container image and
  configuring your Jenkins pipeline to push analysis results.


### 7. Monitoring with Helm

Use the bundled Helm charts to install Prometheus and Grafana into the cluster:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

Customize dashboards as required.


### 8. Cleanup

When you’re finished with the demo, reverse the steps:

1. Delete ArgoCD applications.
2. `terraform destroy` from the `terraform/` directory to remove all AWS
   resources.
3. Optionally remove local Jenkins workspace data.

---

## 📚 Additional Resources

See the original README for in‑depth screenshots and links to individual tool
installations.  Those sections remain valid; this document focuses on the
sequence and updates relevant to Terraform.

---

Happy hacking! 💡
