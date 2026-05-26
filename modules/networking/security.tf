resource "aws_security_group" "cachet_sg" {
  name        = "cachet-web-sg"
  description = "Allow HTTP and SSH access for Cachet"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "cachet-sg"
  }
}

# Inbound Rule: HTTP (Port 80) from anywhere
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.cachet_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.cachet_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_security_group" "db_sg" {
  name = "cachet-db-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_egress_rule" "allow_db" {
  security_group_id = aws_security_group.cachet_sg.id
  from_port = 3306
  to_port = 3306
  ip_protocol = "tcp"
  referenced_security_group_id = aws_security_group.db_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql_from_ec2" {
  security_group_id            = aws_security_group.db_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.cachet_sg.id
}