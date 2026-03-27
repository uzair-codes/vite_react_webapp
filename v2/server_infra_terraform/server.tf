terraform {
  required_version = ">= 1.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.32.0"
    }
  }
  backend "s3" {
    bucket       = "jenkins-terraform-ansible-tfstate"
    key          = "default/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
provider "aws" {
  region = var.provider_region
}

module "ssh_key_pair" {
  source          = "git::https://github.com/uzair-codes/learn_devops.git//5_Iac_Terraform/modules/ssh_key"
  key_name        = var.key_pair_name
  # public_key_path = "${path.module}/keys/ssh-key.pub"
  public_key_path = "${path.module}/keys/id_rsa.pub"
}

module "webserver" {
  source                = "git::https://github.com/uzair-codes/learn_devops.git//5_Iac_Terraform/modules/webserver"
  vpc_cidr              = var.vpc_cidr
  pub_cidr              = var.pub_cidr
  pvt_cidr              = var.pvt_cidr
  bastion_ssh_cidr      = var.bastion_ssh_cidr
  asg_min_capacity      = var.asg_min_capacity
  asg_desired_capacity  = var.asg_desired_capacity
  asg_max_capacity      = var.asg_max_capacity
  instance_type         = var.instance_type
  launch_template_name  = var.launch_template_name
  autoscalig_grp_name   = var.autoscalig_grp_name
  webserver_alb_name    = var.webserver_alb_name
  webserver_alb_tg_name = var.webserver_alb_tg_name
  key_pair_name         = module.ssh_key_pair.key_name
}