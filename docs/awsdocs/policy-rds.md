# AWS permissions policy for RDS

Policy Name: GigadbRDSAccess
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowRDSListDescribe",
            "Effect": "Allow",
            "Action": [
                "rds:Describe*",
                "rds:ListTagsForResource"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowEC2Describe",
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        },
        {
            "Sid": "AllowIAMListDescribe",
            "Effect": "Allow",
            "Action": [
                "iam:ListAttachedRolePolicies",
                "iam:GetRole",
                "iam:ListInstanceProfilesForRole"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CreateRDSInstance",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:TagRole",
                "iam:AttachRolePolicy",
                "ec2:CreateInternetGateway",
                "ec2:AttachInternetGateway",
                "ec2:AssociateVpcCidrBlock",
                "ec2:CreateRoute",
                "ec2:CreateRouteTable",
                "ec2:AssociateRouteTable",
                "ec2:CreateSubnet",
                "ec2:CreateDefaultSubnet",
                "ec2:ModifySubnetAttribute",
                "ec2:CreateSecurityGroup",
                "ec2:CreateVpc",
                "ec2:ModifyVpcAttribute",
                "ec2:GetManagedPrefixListEntries",
                "ec2:AssociateSubnetCidrBlock",
                "rds:CreateDBSubnetGroup",
                "rds:AddTagsToResource",
                "ec2:GetManagedPrefixListAssociations"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CreatePostgresRDSInstancesWithRegionAndInstanceTypeRestriction",
            "Effect": "Allow",
            "Action": "rds:CreateDBInstance",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "rds:DatabaseEngine": "postgres",
                    "rds:DatabaseClass": "db.t3.micro",
                    "aws:RequestedRegion": "ap-east-1"
                }
            }
        },
        {
            "Sid": "CreateRDSInstancesWithOwnerTagRestriction",
            "Effect": "Deny",
            "Action": "rds:CreateDBInstance",
            "Resource": "*",
            "Condition": {
                "StringNotLike": {
                    "aws:RequestTag/Owner": "${aws.username}"
                }
            }
        },
        {
            "Sid": "DeleteRDSInstance",
            "Effect": "Allow",
            "Action": [
                "iam:DeleteRole",
                "ec2:DeleteSubnet",
                "ec2:DeleteLocalGatewayRouteTableVpcAssociation",
                "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
                "ec2:DeleteRouteTable",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:UnassignIpv6Addresses",
                "ec2:DeleteInternetGateway",
                "ec2:UnassignPrivateIpAddresses",
                "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
                "ec2:DetachInternetGateway",
                "ec2:DisassociateRouteTable",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteVpc",
                "ec2:DeleteRoute",
                "rds:DeleteDBSubnetGroup",
                "rds:DeleteDBInstance"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ec2:ResourceTag/Owner": "${aws:username}"
                }
            }
        }
    ]
}
```