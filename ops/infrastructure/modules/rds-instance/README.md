# rds-instance

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
│ Error: error configuring Terraform AWS Provider: error validating provider credentials: error calling sts:GetCallerIdentity: InvalidClientTokenId: The security token included in the request is invalid.
│       status code: 403, request id: 5f5893f7-dbad-44de-8528-a0112560cd86
│ 
│   with provider["registry.terraform.io/hashicorp/aws"],
│   on main.tf line 1, in provider "aws":
│    1: provider "aws" {
```