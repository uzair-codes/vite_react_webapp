# 🌍 AWS WebApp Automated – Terraform + Ansible

## 📌 Overview

This project demonstrates a **DevOps pipeline** that fully automates the deployment of a **Vite React Webapp** on AWS.

It follows **Infrastructure-as-Code (IaC)** + **Configuration Management** best practices:

* **Terraform** provisions AWS infrastructure (networking, security, compute, scaling).
  * **Application Load Balancer (ALB)** ensures high availability and traffic distribution.
  * **Auto Scaling Group (ASG)** automatically replaces failed instances and scales based on demand.
* **Ansible** configures EC2 instances and deploys the React app.
* **Jenkins Pipeline** automate the whole workflow

---

## 🏗️ Project Architecture

### High-Level Flow

```bash
Terraform  →  AWS Infrastructure  →  Ansible  →  App Deployment
```

### Components

* **VPC** with private & public subnets across multiple AZs
* **Bastion Host** for secure SSH into private instances
* **NAT Gateway** for outbound access from private subnets
* **ASG + Launch Template** for EC2 lifecycle management
* **ALB** exposing portfolio to the internet
* **IAM Roles** with least-privilege access for EC2 & SSM
* **Ansible Playbooks** installing Node.js, Nginx, cloning repo, building & deploying app

---

## 📂 Repository Structure

```bash
03_vite-react-web-app/
├── v1/             # Version 1
├── v2/             # Version 2
├── Jenkinsfile     # Jenkins Pipeline
└── README.md       # Project overview (this file)
```

---

## 🚀 Setup Flow

### 1️⃣ Provision Infrastructure (Terraform)

```bash
cd infra/
terraform init    
terraform plan -out plan.out
terraform apply "plan.out"
```

Outputs include:

* `alb_dns_name` → Public URL to access portfolio
* `bastion_public_ip` → SSH entry point

### 2️⃣ Configure & Deploy App (Ansible)

```bash
cd ../ansible/
ansible-inventory -i inventories/aws_ec2.yml --graph   # Verify inventory
ansible-playbook -i inventories/aws_ec2.yml deploy.yml -vv  # Deploy app
```

Now open your **ALB DNS name** in the browser → ✅ Portfolio app live!

---

## 🖼️ Architecture Diagram

![Project Architecture](assets/architecture.png)

---

## 🌟 Key Features

* **IaC + Config Management** → Terraform + Ansible in a single workflow.
* **Highly Available** → ASG + ALB ensure zero downtime during instance replacement.
* **Dynamic Inventory** → Ansible auto-discovers new EC2s created by ASG.
* **Secure Access** → Bastion host with SSH ProxyCommand.
* **Scalable App Deployment** → Every new EC2 gets app auto-installed.

---

## 🐞 Troubleshooting

* **Terraform apply fails** → Check IAM permissions or Elastic IP quota.
* **Ansible inventory empty** → Verify instance tags (`Name=web_asg_instance`).
* **Portfolio app missing after ASG replacement** → Ensure latest **cloud-init.sh** or rerun **Ansible playbook**.
* **Nginx errors** → Validate with `nginx -t` on instance.

---

## 🔮 Future Improvements

* ✅ Add **SSL/TLS (HTTPS)** with ACM + ALB
* ✅ Implement **CI/CD pipeline** with GitHub Actions (Terraform + Ansible automation)
* ✅ Modularize Terraform (VPC, ASG, ALB modules)
* ✅ Add **Monitoring & Alerts** (CloudWatch + SNS)
* ✅ Add **Blue-Green / Canary Deployments** for zero downtime

---

## 🎯 Learning Outcomes

By completing this project, you will understand:

* How to design a **production-grade AWS architecture**
* Using **Terraform** for repeatable infrastructure automation
* Using **Ansible** for consistent app deployment across multiple instances
* Orchestrating **Bastion, ALB, ASG** in real-world cloud setups
* The **DevOps workflow** from infra → config → app

---

✨ Congratulations — you’ve built a **self-healing, automated deployment pipeline** for your React portfolio app!

---
