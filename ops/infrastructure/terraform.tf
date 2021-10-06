# ------------------------------------------------------------------------------
# DEPLOY A GIGADB APPLICATION IN AWS
# This terraform script sets up a complete GigaDB application in AWS. A VPC is 
# created in AWS cloud into which an EC2 instance hosting a Docker Host and a 
# RDS instance hosting the PostgreSQL database are launched into.
# ------------------------------------------------------------------------------

provider "aws" {
  region     = "ap-east-1"
  # Default tags will propagate into child modules and resources
  default_tags {
    tags = {
      Environment = var.deployment_target,
      Owner = data.external.callerUserName.result.userName
    }
  }
}

terraform {
  backend "http" {
  }
}

variable "deployment_target" {
  type = string
  description = "Environment to build"
  default = "staging"
}

variable "key_name" {
  type = string
  description = "Name of ssh key pair for EC2 access"
}

variable "gigadb_db_database" {
  type = string
  description = "Name of PostgreSQL database"
}

variable "gigadb_db_user" {
  type = string
  description = "Username for PostgreSQL database "
}

variable "gigadb_db_password" {
  type = string
  description = "Password for PostgreSQL database"
}

data "external" "callerUserName" {
  program = ["${path.module}/getIAMUserNameToJSON.sh"]
}

# A custom virtual private cloud network for RDS and EC2 instances
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2"

  name = "vpc-ape1-${var.deployment_target}-gigadb"
  # CIDR block is a range of IPv4 addresses in the VPC. This cidr block below 
  # means that the main route table has the following routes: Destination = 
  # 10.99.0.0/18 , Target = local
  cidr = "10.99.0.0/18"
  
  # VPC spans all the availability zones in region
  azs = ["ap-east-1a", "ap-east-1b", "ap-east-1c"]

  # We can add one or more subnets into each AZ. A subnet is required to launch
  # AWS resources into a VPC and is a range of IP addresses. Each subnet has a 
  # CIDR block which is a subset of the VPC CIDR block.

  # Public subnets will contain resources with public IP addresses and routes
  # A internet gateway is automatically created for these public subnets. An 
  # internet gateway exposes resources with public IPs to inbound traffic 
  # from the internet. All public subnets route to an Internet Gateway for 
  # non-local addresses which is what makes the subnet public.
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  public_subnet_tags = {
    Name = "subnet-public"
  }

  # Private subnets contain resources that do not have public IPs. They have 
  # private IPs and can only interact with resources inside the same network
  # Resources in a private subnet needing internet access require a NAT device
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  private_subnet_tags = {
    Name = "subnet-private"
  }

  database_subnets = ["10.99.6.0/24", "10.99.7.0/24", "10.99.8.0/24"]
  database_subnet_tags = {
    Name = "subnet-database"
  }

  # You can enable communication from internet to RDS is via an internet gateway
  # to provide public access to RDS instance, but is not recommended for 
  # production! These parameters are all false so no public access to RDS
  create_database_subnet_group = false
  create_database_subnet_route_table = false
  create_database_internet_gateway_route = false

  # Required to access DNS server for installing postgresql package
  enable_dns_hostnames = true
  enable_dns_support = true

  # NAT gateways provide resources in private subnets that do not have
  # public IP address with outbound access to the public Internet or other AWS
  # resources. NAT gateways are placed in public subnet. Does RDS instance need 
  # a NAT as it will be placed in private subnet? Access to it will be via a 
  # bastion server.
  # enable_nat_gateway = false
  # single_nat_gateway = false
  # one_nat_gateway_per_az = false
}



# EC2 instance for hosting Docker Host
//module "ec2_dockerhost" {
//  source = "../../modules/aws-instance"
//
//  owner = data.external.callerUserName.result.userName
//  deployment_target = var.deployment_target
//  key_name = var.key_name
//  eip_tag_name = "eip-ape1-${var.deployment_target}-${data.external.callerUserName.result.userName}-gigadb"
//  vpc_id = module.vpc.vpc_id
//  ec2_subnet_id = module.vpc.public_subnets[0]
//}

//output "ec2_dockerhost_private_ip" {
//  value = module.ec2_dockerhost.instance_ip_addr
//}

# EC2 instance for bastion server to access RDS for PostgreSQL admin
module "ec2_bastion" {
  source = "../../modules/bastion-aws-instance"

  owner = data.external.callerUserName.result.userName
  deployment_target = var.deployment_target
  key_name = var.key_name
  eip_tag_name = "eip-ape1-${var.deployment_target}-${data.external.callerUserName.result.userName}-bastion"
  vpc_id = module.vpc.vpc_id
  # Bastion EC2 instance goes into a public subnet for developers to access it
  public_subnet_id = module.vpc.public_subnets[0]

  # Security group rule required to allow port 22 SSH connections from 
  # 0.0.0.0/0. No need to configure source IP of developer because EC2 bastion 
  # instance will be immediately destroyed after admin is finished.
}

output "bastion_private_ip" {
  value = module.ec2_bastion.bastion_private_ip
}

output "bastion_public_ip" {
  description = "Public IP address of the EC2 bastion instance"
  value       = module.ec2_bastion.bastion_public_ip
}

# RDS instance for hosting GigaDB's PostgreSQL database
module "rds" {
  source = "../../modules/rds-instance"

  owner = data.external.callerUserName.result.userName
  deployment_target = var.deployment_target

  vpc_id = module.vpc.vpc_id
  rds_subnet_ids = module.vpc.database_subnets
  # ec2_cidr_block is required for security group of RDS to allow it to be
  # accessed by GigaDB application from EC2 dockerhost instance
//  ec2_cidr_block = module.vpc.public_subnets_cidr_blocks[0]

  gigadb_db_database = var.gigadb_db_database
  gigadb_db_user = var.gigadb_db_user
  gigadb_db_password = var.gigadb_db_password

  # Security group rule required to allow port 5432 connections from private IP
  # of bastion server and ec2_dockerhost instance.
}

output "rds_instance_address" {
  value = module.rds.rds_instance_address
}

output "rds_instance_endpoint" {
  value = module.rds.rds_instance_endpoint
}