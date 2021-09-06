################################################################################
# Supporting Resources
################################################################################

module myip {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = "secgrp-ape1-${var.deployment_target}-rds"
  description = "Security group for GigaDB RDS"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from EC2 instance and developer IP"
      //cidr_blocks = "0.0.0.0/0"
      cidr_blocks = "${var.ec2_cidr_block},${module.myip.address}/32"
    }
  ]

  tags = {
    Owner = var.owner
    Environment = var.deployment_target
  }
}

################################################################################
# RDS Module
################################################################################

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "rds-ape1-${var.deployment_target}-gigadb"

  create_db_option_group    = false
  create_db_parameter_group = false

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "9.6"
  family               = "postgres9" # DB parameter group
  major_engine_version = "9"         # DB option group
  instance_class       = "db.t3.micro"

  allocated_storage = 20

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  name                   = var.gigadb_db_database
  username               = var.gigadb_db_user
  password               = var.gigadb_db_password
  port                   = 5432

  publicly_accessible = true

  subnet_ids             = var.rds_subnet_ids
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Owner = var.owner
    Environment = var.deployment_target
    Name = "rds_server_${var.deployment_target}'"
  }
}

output "db_instance_addr" {
  value = module.db.db_instance_address
}
