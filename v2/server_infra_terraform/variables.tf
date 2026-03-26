#################   Provider Region   ################
variable "provider_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}
#################   SSH Key   ########################
variable "key_pair_name" {
  type    = string
  default = "ssh-key" # Replace with your actual key pair name
}

#################   Webserver   ######################

#################   CIDRs   ##########################
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.1.0/24"
}
variable "pub_cidr" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["192.168.1.0/26", "192.168.1.64/26", ]
}
variable "pvt_cidr" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["192.168.1.128/26", "192.168.1.192/26", ]
}
variable "bastion_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
################# ASG Capacity   #####################
variable "asg_desired_capacity" {
  type    = number
  default = 2
}
variable "asg_min_capacity" {
  type    = number
  default = 1
}
variable "asg_max_capacity" {
  type    = number
  default = 4
}
################# Webserver Instances ################
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
################# ASG & Launch Template ##############
variable "launch_template_name" {
  type    = string
  default = "webserver_lt"
}
variable "autoscalig_grp_name" {
  type    = string
  default = "webserver-asg"
}
################# ALB & Target Group #################
variable "webserver_alb_name" {
  type    = string
  default = "webserver-alb"
}
variable "webserver_alb_tg_name" {
  type    = string
  default = "webserver-alb-tg"
}

################# user_data ##########################
# variable "user_data_script_path" {
#   type = string
#   default = "../assets/script.sh"
# }