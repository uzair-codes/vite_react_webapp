# 🛠️ Ansible – Configuration Management & App Deployment

## 📌 Project Description

This Ansible project automates the **configuration management** and **deployment** of a React portfolio website on AWS EC2 instances created by the Terraform infrastructure.

It ensures every EC2 instance in the **Auto Scaling Group (ASG)** is consistently configured with:

* Node.js & npm installed
* Nginx as the reverse proxy
* Swap memory to avoid OOM errors
* Application code pulled from GitHub
* Production build deployed to Nginx webroot

---

## 📂 Repository Structure

```
ansible/
├── ansible.cfg                # Global Ansible configuration
├── group_vars/
│   └── all.yml                # Common SSH & proxy settings
├── inventories/
│   └── aws_ec2.yml            # Dynamic inventory using amazon.aws.aws_ec2 plugin
├── site.yml                   # Main playbook (deploy web app)
└── roles/
    └── webapp/
        ├── tasks/main.yml     # Tasks (install packages, deploy app, setup swap)
        ├── handlers/main.yml  # Handlers (restart nginx on config changes)
        ├── templates/
        │   └── portfolio.conf.j2  # Nginx site config template
```

---

## ⚙️ How It Works

1. **Dynamic Inventory** → `aws_ec2.yml` uses the `amazon.aws.aws_ec2` plugin to fetch running EC2 instances tagged by Terraform.
2. **Bastion Host Proxy** → `group_vars/all.yml` configures SSH ProxyCommand so Ansible connects to private instances via the Bastion host.
3. **Playbook Execution** → `site.yml` runs the **webapp** role on ASG instances.
4. **Idempotent Deployment** → App repo is cloned, built, and deployed consistently across all instances.

---

## 🚀 Step-by-Step Usage

### 1️⃣ Install dependencies

Make sure the **amazon.aws collection** and **boto3** are available:

```bash
python3 -m venv myvenv
source myvenv/bin/activate
pip install boto3 botocore ansible
ansible-galaxy collection install amazon.aws
```

### 2️⃣ Test inventory

Check that Ansible can discover your EC2 instances:

```bash
ansible-inventory -i inventories/aws_ec2.yml --graph
```

### 3️⃣ Run playbook

Deploy the portfolio app:

```bash
ansible-playbook -i inventories/aws_ec2.yml site.yml -vv
```

---

## 🌟 Key Features

* **System Update & Dependencies** → Updates apt cache, installs curl, git, build-essential, ca-certificates.
* **Node.js Setup** → Installs Node.js 20.x with npm.
* **Nginx Setup** → Configures and enables Nginx as a web server.
* **Swap Setup** → Creates a **1GB swap file** to prevent memory crashes during builds.
* **Git Clone** → Clones portfolio repo (`personal-portfolio`) from GitHub.
* **Build Process** → Runs `npm ci` + `npm run build` for optimized production build.
* **Deploy App** → Copies React build to `/var/www/personal-portfolio`.
* **Nginx Config** → Uses `portfolio.conf.j2` to serve app properly (SPA fallback + static assets).
* **Handlers** → Restart Nginx when config or app changes.

---

## 📜 Handlers & Templates

* **Handler:** `Restart nginx` ensures the server reloads only when required.
* **Template:** `portfolio.conf.j2` is an Nginx site config that:

  * Serves the React app from `/var/www/personal-portfolio`
  * Redirects unknown routes to `index.html` (SPA support)
  * Optimizes static asset delivery with caching

---

## 🐞 Troubleshooting

* **SSH Errors** → Check bastion public IP in `group_vars/all.yml` and ensure `~/.ssh/key.pem` matches.
* **Inventory Empty** → Ensure EC2 instances have the correct **tags** (`Name = web_asg_instance`).
* **Swap Issues** → If swap not created, check disk space and rerun role.
* **Nginx Errors** → Run `nginx -t` on instance to validate config.
* **App Not Building** → Ensure Node.js/npm versions are correct; check `/opt/personal-portfolio` logs.

---

## 🎯 Learning Outcomes

By working with this project, you will learn:

* How **Ansible dynamic inventory** integrates with AWS.
* Managing EC2 instances in **private subnets** via a Bastion host.
* Deploying a **React app with zero downtime** across an ASG.
* Writing **idempotent roles, tasks, and handlers** in Ansible.
* Combining Terraform + Ansible for full-stack DevOps automation.

---

# 🔥 At this point, you have a working automation pipeline:
**Terraform → AWS Infra → Ansible → App Deployment.**

---
