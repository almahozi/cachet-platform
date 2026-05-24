data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_instance" "cachet_server" {
  ami = data.aws_ami.latest_amazon_linux.id 
  instance_type = "t3.micro"

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id = var.subnet_id

  # This script runs once when the instance first boots
  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    db_endpoint = var.db_endpoint
  })

  tags = {
    Name = "cachet-app-server"
  }
}