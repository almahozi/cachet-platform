resource "aws_db_instance" "cachet_db" {
  identifier        = "cachet-db"
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  db_name           = "cachet"
  username          = "admin"
  password          = "yagHxgDb0GCwf89EXdTkm4HqGTJmkNHp"



  # Networking
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_security_group_id]

  skip_final_snapshot = true
  publicly_accessible = false
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/cachet/prod/DB_HOST"
  type  = "String"
  value = aws_db_instance.cachet_db.endpoint
}
