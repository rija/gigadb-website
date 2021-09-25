variable "deployment_target" {
  type = string
  description = "environment to build"
  default = "staging"
}

variable "key_name" {
  type = string
  description = "Name of ssh key pair created for EC2 access"
}

variable "aws_region" {
  type = string
  description = "AWS region where deployment occurs"
  default = "ap-east-1"
}

terraform {
    backend "http" {
    }
}



data "external" "callerUserName" {
  program = ["${path.module}/getIAMUserNameToJSON.sh"]
}

provider "aws" {
  region     = var.aws_region
  default_tags {
      tags = {
        Environment = var.deployment_target,
        Owner = data.external.callerUserName.result.userName
      }
    }


}


module "ec2" {
  source = "../../modules/aws-instance"

  owner = data.external.callerUserName.result.userName
  deployment_target = var.deployment_target
  key_name = var.key_name
  eip_tag_name = "eip-gigadb-${var.deployment_target}-${data.external.callerUserName.result.userName}"
}

output "ec2_private_ip" {
  value = module.ec2.instance_ip_addr
}