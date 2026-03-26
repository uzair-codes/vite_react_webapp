variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.1.0/24"
}

variable "public_subnets" {
  type = list(string)
  default = [
    "192.168.1.0/26",
    "192.168.1.64/26",
  ]
}

variable "private_subnets" {
  type = list(string)
  default = [
    "192.168.1.128/26",
    "192.168.1.192/26",
  ]
}

variable "key_name" {
  description = "EC2 key pair name to use for SSH (already created)"
  type        = string
  default     = "publi-key"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to bastion (set to YOUR_IP/32 for best security)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "asg_min_size" {
  type    = number
  default = 2
}
variable "asg_desired_capacity" {
  type    = number
  default = 2
}
variable "asg_max_size" {
  type    = number
  default = 4
}
