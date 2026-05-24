resource "aws_db_instance" "cachet_db" {
  identifier        = "cachet-db"
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  username          = "admin"
  password          = var.db_password

  # Networking
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_security_group_id]

  skip_final_snapshot = true
  publicly_accessible = false
}
