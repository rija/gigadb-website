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