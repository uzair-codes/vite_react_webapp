resource "aws_launch_template" "web_lt" {
  name_prefix   = "web-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    security_groups             = [aws_security_group.web_sg.id]
    associate_public_ip_address = false
  }

  user_data = base64encode(file("${path.module}/scripts/cloud-init.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "web_asg_instance" }
  }
}
