data "aws_iam_policy" "ssm_managed" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-web-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.ssm_managed.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-web-instance-profile"
  role = aws_iam_role.ec2_role.name
}
