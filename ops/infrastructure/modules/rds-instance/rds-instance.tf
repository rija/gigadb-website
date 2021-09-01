################################################################################
# Supporting Resources
################################################################################

# Create virtual private cloud network for RDS instance to be launched in
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2"

  name = "vpc-ape1-${var.deployment_target}-gigadb"
  # CIDR block is a range of IPv4 addresses in the VPC
  cidr = "10.99.0.0/18"
  # This means that the main route table has the following routes:
  # Destination = 10.99.0.0/18 , Target = local

  # VPC spans all the availability zones (AZs) in the region
  azs              = ["ap-east-1a", "ap-east-1b", "ap-east-1c"]
  
  # We can add one or more subnets into each AZ. A subnet is required to launch
  # AWS resources into a VPC and is a range of IP addresses. Each subnet has a 
  # CIDR block which is a subset of the VPC CIDR block.
  
  # Public subnet will contain resources with public IP addresses and routes
  # Do these public subnets need a custom route table that points to an IGW?
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  public_subnet_tags = {
    Name = "overridden-name-public"
  }

  # Internet gateway is designed to expose resources with public IPs to
  # inbound traffic from the internet. All public subnets must route to an
  # Internet Gateway for non-local addresses. This is what makes the subnet
  # public.

  # Need to create and attach an Internet Gateway (called it igw-blah-blah) 
  # to the VPC to give resources access to the internet. RDS instance will need 
  # a public IP or an elastic IP. The subnet's route table needs to point to the 
  # internet gateway. Need to ensure network ACL and security groups rules allow 
  # traffic to flow to and from RDS
  
  # Private subnets will contain resources that do not have public IPs. They 
  # have private IPs and can only interact with resources inside same network
  # If resources in private subnet needs internet access then they need a NAT
  # device
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]

  # NAT gateways provide resources in private subnets that do not have
  # public IP address with outbound access to the public Internet or other AWS
  # resources. NAT gateways are placed in public subnet. Will create one NAT 
  # gateway for each private subnet - a total of 3 NAT gateways
//  enable_nat_gateway = true
//  single_nat_gateway = true
//  one_nat_gateway_per_az = false

  database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]
  
  # Enable communication from internet to RDS is via an internet gateway to 
  # provide public access to RDS instance - not recommended for production! 
  create_database_subnet_group = true
  create_database_subnet_route_table = true
  create_database_internet_gateway_route = true
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Owner = var.owner
    Environment = var.deployment_target
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = "secgrp-ape1-${var.deployment_target}-rds"
  description = "Security group for GigaDB RDS"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from public internet"
      cidr_blocks = "0.0.0.0/0"
    },
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

  subnet_ids             = module.vpc.database_subnets
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
