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

locals {
  primary_region_vpc_id  = "vpc-0601da11524bf785c"
  recovery_region_vpc_id = "vpc-0a8b3956e0bb88f20"
}


resource "aws_security_group" "primary_asg_security_group" {
  provider = aws.primary

  name        = "db_security_group"
  description = "Allows all incoming connections"
  vpc_id      = local.primary_region_vpc_id
}

resource "aws_security_group_rule" "primary_asg_security_group_rule_in" {
  provider = aws.primary

  security_group_id = aws_security_group.primary_asg_security_group.id
  type              = "ingress"
  description       = "All connectivity"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
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
  vpc_security_group_ids       = [aws_security_group.primary_asg_security_group.id]

  backup_retention_period     = 7
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  apply_immediately           = true
  deletion_protection         = false
  delete_automated_backups    = true
  skip_final_snapshot         = true
}



resource "aws_security_group" "recovery_asg_security_group" {
  provider = aws.recovery

  name        = "db_security_group"
  description = "Allows all incoming connections"
  vpc_id      = local.recovery_region_vpc_id
}

resource "aws_security_group_rule" "recovery_asg_security_group_rule_in" {
  provider = aws.recovery

  security_group_id = aws_security_group.recovery_asg_security_group.id
  type              = "ingress"
  description       = "All connectivity"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_db_instance" "read_replica" {
  provider = aws.recovery

  identifier = "avbank-db-rr"

  replicate_source_db = aws_db_instance.database.arn
  instance_class      = "db.t3.micro"

  multi_az                     = false
  publicly_accessible          = true
  performance_insights_enabled = false
  monitoring_interval          = 0
  vpc_security_group_ids       = [aws_security_group.recovery_asg_security_group.id]

  backup_retention_period     = 0
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  apply_immediately           = true
  deletion_protection         = false
  delete_automated_backups    = true
  skip_final_snapshot         = true
}