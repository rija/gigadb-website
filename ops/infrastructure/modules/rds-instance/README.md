# rds-instance

## Preparation

Make sure you have configured AWS by providing it with config and credentials
files in the ~/.aws directory

## Create RDS instance

This module contains a main.tf file. From this directory, fetch dependent 
modules:
```
$ terraform get
Downloading terraform-aws-modules/rds/aws 3.3.0 for db...
- db in .terraform/modules/db
- db.db_instance in .terraform/modules/db/modules/db_instance
- db.db_option_group in .terraform/modules/db/modules/db_option_group
- db.db_parameter_group in .terraform/modules/db/modules/db_parameter_group
- db.db_subnet_group in .terraform/modules/db/modules/db_subnet_group
Downloading terraform-aws-modules/rds/aws 3.3.0 for db_default...
- db_default in .terraform/modules/db_default
- db_default.db_instance in .terraform/modules/db_default/modules/db_instance
- db_default.db_option_group in .terraform/modules/db_default/modules/db_option_group
- db_default.db_parameter_group in .terraform/modules/db_default/modules/db_parameter_group
- db_default.db_subnet_group in .terraform/modules/db_default/modules/db_subnet_group
Downloading terraform-aws-modules/rds/aws 3.3.0 for db_disabled...
- db_disabled in .terraform/modules/db_disabled
- db_disabled.db_instance in .terraform/modules/db_disabled/modules/db_instance
- db_disabled.db_option_group in .terraform/modules/db_disabled/modules/db_option_group
- db_disabled.db_parameter_group in .terraform/modules/db_disabled/modules/db_parameter_group
- db_disabled.db_subnet_group in .terraform/modules/db_disabled/modules/db_subnet_group
Downloading terraform-aws-modules/security-group/aws 4.3.0 for security_group...
- security_group in .terraform/modules/security_group
Downloading terraform-aws-modules/vpc/aws 3.6.0 for vpc...
- vpc in .terraform/modules/vpc
```

Initialize a working directory containing Terraform configuration files.
```
$ terraform init
Initializing modules...

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching ">= 2.42.0, >= 2.49.0, >= 3.28.0"...
- Finding hashicorp/random versions matching ">= 2.2.0, >= 3.1.0"...
- Installing hashicorp/aws v3.54.0...
- Installed hashicorp/aws v3.54.0 (signed by HashiCorp)
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Create an execution plan. This currently results in an error:
```
$ terraform plan
module.db_default.random_password.master_password[0]: Refreshing state... [id=none]
module.db_default.module.db_instance.random_id.snapshot_identifier[0]: Refreshing state... [id=YKKbWA]
module.db.module.db_parameter_group.aws_db_parameter_group.this[0]: Refreshing state... [id=complete-postgresql-20210819062736219800000001]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.security_group.aws_security_group.this_name_prefix[0] will be created
  + resource "aws_security_group" "this_name_prefix" {
      + arn                    = (known after apply)
      + description            = "Complete PostgreSQL example security group"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = (known after apply)
      + name_prefix            = "complete-postgresql-"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Environment" = "dev"
          + "Name"        = "complete-postgresql"
          + "Owner"       = "user"
        }
      + tags_all               = {
          + "Environment" = "dev"
          + "Name"        = "complete-postgresql"
          + "Owner"       = "user"
        }
      + vpc_id                 = (known after apply)
    }
<snip>
</snip>
Plan: 34 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform
apply" now.
```

Execute Terraform plan:
```
$ terraform apply
```

In addition to `AmazonRDSFullAccess` and `AmazonVPCFullAccess` policies, the 
following AWS IAM policy is required to permit a user to create RDS instances:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:ListInstanceProfilesForRole",
                "iam:ListAttachedRolePolicies",
                "iam:TagRole",
                "iam:DeleteRole",
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:ListRolePolicies"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AmazonRDSFullAccess1",
            "Action": [
                "rds:*",
                "application-autoscaling:DeleteScalingPolicy",
                "application-autoscaling:DeregisterScalableTarget",
                "application-autoscaling:DescribeScalableTargets",
                "application-autoscaling:DescribeScalingActivities",
                "application-autoscaling:DescribeScalingPolicies",
                "application-autoscaling:PutScalingPolicy",
                "application-autoscaling:RegisterScalableTarget",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:DeleteAlarms",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeCoipPools",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeLocalGatewayRouteTables",
                "ec2:DescribeLocalGatewayRouteTableVpcAssociations",
                "ec2:DescribeLocalGateways",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcs",
                "ec2:GetCoipPoolUsage",
                "sns:ListSubscriptions",
                "sns:ListTopics",
                "sns:Publish",
                "logs:DescribeLogStreams",
                "logs:GetLogEvents",
                "outposts:GetOutpostInstanceTypes"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Sid": "AmazonRDSFullAccess2",
            "Action": "pi:*",
            "Effect": "Allow",
            "Resource": "arn:aws:pi:*:*:metrics/rds/*"
        },
        {
            "Sid": "AmazonRDSFullAccess3",
            "Action": "iam:CreateServiceLinkedRole",
            "Effect": "Allow",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": [
                        "rds.amazonaws.com",
                        "rds.application-autoscaling.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Sid": "AmazonVPCFullAccess1",
            "Effect": "Allow",
            "Action": [
                "ec2:AcceptVpcPeeringConnection",
                "ec2:AcceptVpcEndpointConnections",
                "ec2:AllocateAddress",
                "ec2:AssignIpv6Addresses",
                "ec2:AssignPrivateIpAddresses",
                "ec2:AssociateAddress",
                "ec2:AssociateDhcpOptions",
                "ec2:AssociateRouteTable",
                "ec2:AssociateSubnetCidrBlock",
                "ec2:AssociateVpcCidrBlock",
                "ec2:AttachClassicLinkVpc",
                "ec2:AttachInternetGateway",
                "ec2:AttachNetworkInterface",
                "ec2:AttachVpnGateway",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateCarrierGateway",
                "ec2:CreateCustomerGateway",
                "ec2:CreateDefaultSubnet",
                "ec2:CreateDefaultVpc",
                "ec2:CreateDhcpOptions",
                "ec2:CreateEgressOnlyInternetGateway",
                "ec2:CreateFlowLogs",
                "ec2:CreateInternetGateway",
                "ec2:CreateLocalGatewayRouteTableVpcAssociation",
                "ec2:CreateNatGateway",
                "ec2:CreateNetworkAcl",
                "ec2:CreateNetworkAclEntry",
                "ec2:CreateNetworkInterface",
                "ec2:CreateNetworkInterfacePermission",
                "ec2:CreateRoute",
                "ec2:CreateRouteTable",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSubnet",
                "ec2:CreateTags",
                "ec2:CreateVpc",
                "ec2:CreateVpcEndpoint",
                "ec2:CreateVpcEndpointConnectionNotification",
                "ec2:CreateVpcEndpointServiceConfiguration",
                "ec2:CreateVpcPeeringConnection",
                "ec2:CreateVpnConnection",
                "ec2:CreateVpnConnectionRoute",
                "ec2:CreateVpnGateway",
                "ec2:DeleteCarrierGateway",
                "ec2:DeleteCustomerGateway",
                "ec2:DeleteDhcpOptions",
                "ec2:DeleteEgressOnlyInternetGateway",
                "ec2:DeleteFlowLogs",
                "ec2:DeleteInternetGateway",
                "ec2:DeleteLocalGatewayRouteTableVpcAssociation",
                "ec2:DeleteNatGateway",
                "ec2:DeleteNetworkAcl",
                "ec2:DeleteNetworkAclEntry",
                "ec2:DeleteNetworkInterface",
                "ec2:DeleteNetworkInterfacePermission",
                "ec2:DeleteRoute",
                "ec2:DeleteRouteTable",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSubnet",
                "ec2:DeleteTags",
                "ec2:DeleteVpc",
                "ec2:DeleteVpcEndpoints",
                "ec2:DeleteVpcEndpointConnectionNotifications",
                "ec2:DeleteVpcEndpointServiceConfigurations",
                "ec2:DeleteVpcPeeringConnection",
                "ec2:DeleteVpnConnection",
                "ec2:DeleteVpnConnectionRoute",
                "ec2:DeleteVpnGateway",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeCarrierGateways",
                "ec2:DescribeClassicLinkInstances",
                "ec2:DescribeCustomerGateways",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeEgressOnlyInternetGateways",
                "ec2:DescribeFlowLogs",
                "ec2:DescribeInstances",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeIpv6Pools",
                "ec2:DescribeLocalGatewayRouteTables",
                "ec2:DescribeLocalGatewayRouteTableVpcAssociations",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeMovingAddresses",
                "ec2:DescribeNatGateways",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeNetworkInterfaceAttribute",
                "ec2:DescribeNetworkInterfacePermissions",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribePrefixLists",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroupReferences",
                "ec2:DescribeSecurityGroupRules",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeStaleSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcClassicLink",
                "ec2:DescribeVpcClassicLinkDnsSupport",
                "ec2:DescribeVpcEndpointConnectionNotifications",
                "ec2:DescribeVpcEndpointConnections",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeVpcEndpointServiceConfigurations",
                "ec2:DescribeVpcEndpointServicePermissions",
                "ec2:DescribeVpcEndpointServices",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpnConnections",
                "ec2:DescribeVpnGateways",
                "ec2:DetachClassicLinkVpc",
                "ec2:DetachInternetGateway",
                "ec2:DetachNetworkInterface",
                "ec2:DetachVpnGateway",
                "ec2:DisableVgwRoutePropagation",
                "ec2:DisableVpcClassicLink",
                "ec2:DisableVpcClassicLinkDnsSupport",
                "ec2:DisassociateAddress",
                "ec2:DisassociateRouteTable",
                "ec2:DisassociateSubnetCidrBlock",
                "ec2:DisassociateVpcCidrBlock",
                "ec2:EnableVgwRoutePropagation",
                "ec2:EnableVpcClassicLink",
                "ec2:EnableVpcClassicLinkDnsSupport",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:ModifySecurityGroupRules",
                "ec2:ModifySubnetAttribute",
                "ec2:ModifyVpcAttribute",
                "ec2:ModifyVpcEndpoint",
                "ec2:ModifyVpcEndpointConnectionNotification",
                "ec2:ModifyVpcEndpointServiceConfiguration",
                "ec2:ModifyVpcEndpointServicePermissions",
                "ec2:ModifyVpcPeeringConnectionOptions",
                "ec2:ModifyVpcTenancy",
                "ec2:MoveAddressToVpc",
                "ec2:RejectVpcEndpointConnections",
                "ec2:RejectVpcPeeringConnection",
                "ec2:ReleaseAddress",
                "ec2:ReplaceNetworkAclAssociation",
                "ec2:ReplaceNetworkAclEntry",
                "ec2:ReplaceRoute",
                "ec2:ReplaceRouteTableAssociation",
                "ec2:ResetNetworkInterfaceAttribute",
                "ec2:RestoreAddressToClassic",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:UnassignIpv6Addresses",
                "ec2:UnassignPrivateIpAddresses",
                "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
                "ec2:UpdateSecurityGroupRuleDescriptionsIngress"
            ],
            "Resource": "*"
        }
    ]
}
```