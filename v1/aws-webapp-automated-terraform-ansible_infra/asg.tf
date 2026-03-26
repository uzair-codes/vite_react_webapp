resource "aws_autoscaling_group" "web_asg" {
  name                      = "web-asg"
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  desired_capacity          = var.asg_desired_capacity
  vpc_zone_identifier       = [for s in aws_subnet.private : s.id]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns          = [aws_lb_target_group.web_tg.arn]
  health_check_type          = "ELB"
  health_check_grace_period  = 300

  tag {
    key                 = "Name"
    value               = "web_asg_instance"
    propagate_at_launch = true
  }
}
