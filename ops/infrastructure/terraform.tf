variable "deployment_target" {
  type = string
  description = "environment to build"
  default = "staging"
}

variable "key_name" {
  type = string
  description = "Name of ssh key pair created for EC2 access"
}

variable "gigadb_db_database" {
  type = string
  description = "Name of PostgreSQL database"
}

variable "gigadb_db_user" {
  type = string
  description = "Name of PostgreSQL database user"
}

variable "gigadb_db_password" {
  type = string
  description = "Password for PostgreSQL database"
}

terraform {
    backend "http" {
    }
}



data "external" "callerUserName" {
  program = ["${path.module}/getIAMUserNameToJSON.sh"]
}

provider "aws" {
  region     = "ap-east-1"
  default_tags {
      tags = {
        Environment = var.deployment_target,
        Owner = data.external.callerUserName.result.userName
      }
    }


}

# Create virtual private cloud network for RDS and EC2 instances to be launched in
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

  database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]

  # Enable communication from internet to RDS is via an internet gateway to 
  # provide public access to RDS instance - not recommended for production! 
  create_database_subnet_group = false
  create_database_subnet_route_table = true
  create_database_internet_gateway_route = true
  enable_dns_hostnames = true
  enable_dns_support = true

  # NAT gateways provide resources in private subnets that do not have
  # public IP address with outbound access to the public Internet or other AWS
  # resources. NAT gateways are placed in public subnet. Will create one NAT
  # gateway for all private_subnets and database_subnets. NAT gateway will be
  # placed in first public subnet in public_subnets block.
//  enable_nat_gateway = true
//  single_nat_gateway = true
//  one_nat_gateway_per_az = false

  tags = {
    Owner = data.external.callerUserName.result.userName
    Environment = var.deployment_target
  }
}


module "ec2" {
  source = "../../modules/aws-instance"

  owner = data.external.callerUserName.result.userName
  deployment_target = var.deployment_target
  key_name = var.key_name
  eip_tag_name = "eip-ape1-${var.deployment_target}-${data.external.callerUserName.result.userName}-gigadb"
  ec2_subnet_id = module.vpc.public_subnets[0]
  vpc_id = module.vpc.vpc_id
  database_cidr_blocks = module.vpc.database_subnets_cidr_blocks
  ec2_cidr_block = module.vpc.public_subnets_cidr_blocks[0]
}

output "ec2_private_ip" {
  value = module.ec2.instance_ip_addr
}

# Container for multiple resources
module "rds" {
  source = "../../modules/rds-instance"
  owner = data.external.callerUserName.result.userName
  deployment_target = var.deployment_target
  gigadb_db_database = var.gigadb_db_database
  gigadb_db_user = var.gigadb_db_user
  gigadb_db_password = var.gigadb_db_password
  rds_subnet_ids = module.vpc.database_subnets
  # ec2_cidr_block is required for security group of RDS to
  # allow it to be accessed by GigaDB website on EC2 instance
  ec2_cidr_block = module.vpc.public_subnets_cidr_blocks[0]
  vpc_id = module.vpc.vpc_id
}

output "rds_instance_address" {
  value = module.rds.db_instance_addr
}
