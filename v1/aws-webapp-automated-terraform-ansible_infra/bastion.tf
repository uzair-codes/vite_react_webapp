resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = { Name = "bastion" }
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  domain      = "vpc"
  tags     = { Name = "bastion-eip" }
}
