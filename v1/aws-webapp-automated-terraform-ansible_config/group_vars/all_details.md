
# Proxy Command Explanation

The `group_vars/all.yml` file is configuring **SSH connection behavior for all hosts in the Ansible inventory**.

Let’s break down the line step-by-step.

```yaml
ansible_ssh_common_args: >
  -o ProxyCommand="ssh -i ~/secrets/public-key.pem -W %h:%p ubuntu@3.109.11.90"
```

---

## 1️⃣ `group_vars/all.yml`

In Ansible:

* `group_vars/` → directory for variables assigned to host groups
* `all.yml` → variables applied to **every host in the inventory**

So this setting will affect **all SSH connections Ansible makes**.

---

## 2️⃣ `ansible_ssh_common_args`

This variable lets you **pass extra SSH options** when Ansible connects to hosts.

Ansible internally runs commands similar to:

```bash
ssh <options> user@host
```

`ansible_ssh_common_args` adds **extra SSH flags** to that command.

---

## 3️⃣ `ProxyCommand`

The key part:

```bash
-o ProxyCommand="ssh -i ~/secrets/public-key.pem -W %h:%p ubuntu@3.109.11.90"
```

This tells SSH:

👉 **Connect to the target host through another server first.**

This server is called a **Jump Host / Bastion Host**.

---

## 4️⃣ How the Connection Works

Suppose your inventory host is:

```bash
10.0.1.25
```

This machine is **inside a private network** and cannot be accessed directly.

Ansible will connect like this:

```bash
Your Machine
     │
     │ SSH
     ▼
Bastion Host (3.109.11.90)
     │
     │ SSH tunnel
     ▼
Target Host (10.0.1.25)
```

---

## 5️⃣ What Each Part Means

```bash
ssh -i ~/secrets/public-key.pem
```

Use this SSH **private key** to authenticate.

---

```bash
ubuntu@3.109.11.90
```

Connect to the **bastion server**.

---

```bash
-W %h:%p
```

This is an SSH forwarding option.

It means:

```bash
Forward traffic to:
%h = target host
%p = target port
```

Example:

```bash
10.0.1.25:22
```

---

## 6️⃣ What Ansible Actually Executes

If Ansible wants to connect to:

```bash
10.0.1.25
```

The final SSH command becomes something like:

```bash
ssh -o ProxyCommand="ssh -i ~/secrets/public-key.pem -W %h:%p ubuntu@3.109.11.90" ubuntu@10.0.1.25
```

---

## 7️⃣ Real DevOps Use Case

This is extremely common in **AWS private VPC architectures**.

Typical architecture:

```bash
Internet
   │
   ▼
Bastion Host (Public Subnet)
   │
   ▼
Private Servers (Private Subnet)
   ├── App Server
   ├── DB Server
   └── Worker Nodes
```

Only the **bastion host has a public IP**.

All other servers are private.

Ansible uses the bastion as a **gateway**.

---

## 8️⃣ Why `>` is Used in YAML

```yaml
ansible_ssh_common_args: >
```

`>` means **multi-line string folded into one line**.

So this:

```yaml
ansible_ssh_common_args: >
  -o ProxyCommand="ssh -i ~/secrets/public-key.pem -W %h:%p ubuntu@3.109.11.90"
```

Becomes:

```bash
-o ProxyCommand="ssh -i ~/secrets/public-key.pem -W %h:%p ubuntu@3.109.11.90"
```

---

## 9️⃣ Real-World Example Inventory

```ini
[private_servers]
10.0.1.25
10.0.1.30
```

Even though these are **private IPs**, Ansible can still reach them because of the **bastion proxy**.

---

✅ **Summary**

This configuration tells Ansible:

1. Connect to **bastion server (3.109.11.90)** using SSH key
2. Use it as a **jump host**
3. From there forward connection to the **target host**

So Ansible can manage **private servers that are not publicly accessible**.
