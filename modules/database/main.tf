terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"
      configuration_aliases = [
        aws.primary,
        aws.recovery
      ]
    }
  }
}


resource "aws_db_instance" "database" {
  provider = aws.primary

  identifier = "avbank-db"

  engine         = "postgres"
  engine_version = "13.7"
  instance_class = "db.t3.micro"

  db_name  = "avbank"
  username = "postgres"
  password = "postgres"

  allocated_storage = 10
  storage_type      = "gp2"

  multi_az                     = true
  publicly_accessible          = true
  performance_insights_enabled = false
  monitoring_interval          = 0

  backup_retention_period    = 7
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = false
  apply_immediately          = true
  deletion_protection        = false
  delete_automated_backups   = true
  skip_final_snapshot        = true
}

resource "aws_db_instance" "read_replica" {
  provider = aws.recovery

  identifier          = "avbank-db-rr"

  replicate_source_db = aws_db_instance.database.arn
  instance_class = "db.t3.micro"

  multi_az                     = false
  publicly_accessible          = true
  performance_insights_enabled = false
  monitoring_interval          = 0

  backup_retention_period    = 7
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = false
  apply_immediately          = true
  deletion_protection        = false
  delete_automated_backups   = true
  skip_final_snapshot        = true
}