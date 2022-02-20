# Terraform AWS IAM User

## Overview

This is a parametrized [Terraform module](https://learn.hashicorp.com/tutorials/terraform/module) for creating [an Identity and Access Management (IAM) user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html)
with complementary resources, e.g. [access keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).

## Prerequisites

* [AWS IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html) with adequate privileges
* [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) that's properly [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
* [Terraform](https://www.terraform.io/)
  * NB you can use [`tfswitch`](https://tfswitch.warrensbox.com/) to manage different versions of Terraform

### Prerequisites for pre-commit-terraform

**a)** dependencies

The [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform) util requires the latest versions of the following dependencies:

* [pre-commit](https://pre-commit.com/#install)
* [terraform-docs](https://github.com/terraform-docs/terraform-docs)
* [tflint](https://github.com/terraform-linters/tflint)
* [tfsec](https://github.com/aquasecurity/tfsec)
* [terrascan](https://github.com/accurics/terrascan)

On macOS, you can install the above with [brew](https://brew.sh/):

```bash
brew install pre-commit terraform-docs tflint tfsec terrascan
```

**b)** usage

The tool will run automatically before each commit if [git hooks scripts](https://pre-commit.com/#3-install-the-git-hook-scripts) are installed in the project's root:

```bash
pre-commit install
```

For a manual run, execute the below command:

```bash
pre-commit run -a
```

**NB the configuration file is located in `.pre-commit-config.yaml`**

## Usage

```terraform
### GROUPS - START
resource "aws_iam_group" "administrators" {
  name = "administrators"
  path = "/users/"
}

resource "aws_iam_group_policy_attachment" "administrator_access" {
  group      = aws_iam_group.administrators.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # an AWS-manager policy
}
### GROUPS - END


### USERS - START
module "break_glass" {
  source        = "git@github.com:rafalkrol-xyz/tf-aws-config.git?ref=v1.0.0"
  name          = "break-glass"
  groups        = [aws_iam_group.administrators.name]
  force_destroy = true
  pgp_key       = "keybase:YOUR_KEYBASE_USERNAME" # Either a base-64 encoded PGP public key, or a keybase username in the form keybase:username.
}

output "break-glass-aws_iam_user-credentials" {
  description = "The break_glass user's credentials"
  value       = module.break_glass.aws_iam_user_credentials
}
### USERS - END
```

### Note on tags

[Starting from AWS Provider for Terraform v3.38.0 (with Terraform v0.12 or later onboard), you may define default tags at the provider level, streamlining tag management](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider).
The functionality replaces the now redundant per-resource tags configurations, and therefore, this module has dropped the support of a `tags` variable.
Instead, set the default tags in your parent module:

```terraform
### PARENT MODULE - START
locals {
  tags = {
    key1   = "value1"
    key2   = "value2"
    keyN   = "valueN"
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = local.tags
  }
}

# NB the default tags are implicitly passed into the module: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags
module "break_glass" {
  source        = "git@github.com:rafalkrol-xyz/tf-aws-config.git?ref=v1.0.0"
  name          = "break-glass"
  groups        = [aws_iam_group.administrators.name]
  force_destroy = true
  pgp_key       = "keybase:YOUR_KEYBASE_USERNAME" # Either a base-64 encoded PGP public key, or a keybase username in the form keybase:username.
}
### PARENT MODULE - END
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_group_membership.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_group_membership) | resource |
| [aws_iam_user_login_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_login_profile) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_aws_iam_access_key"></a> [create\_aws\_iam\_access\_key](#input\_create\_aws\_iam\_access\_key) | A flag indicating whether an IAM access key ('a set of credentials that allow API requests to be made as an IAM user') should be created for a given user | `bool` | `true` | no |
| <a name="input_create_aws_iam_user"></a> [create\_aws\_iam\_user](#input\_create\_aws\_iam\_user) | A flag indicating whether an IAM user should be created | `bool` | `true` | no |
| <a name="input_create_aws_iam_user_group_membership"></a> [create\_aws\_iam\_user\_group\_membership](#input\_create\_aws\_iam\_user\_group\_membership) | A flag indicating whether a group membership should be created for a given user | `bool` | `true` | no |
| <a name="input_create_aws_iam_user_login_profile"></a> [create\_aws\_iam\_user\_login\_profile](#input\_create\_aws\_iam\_user\_login\_profile) | A flag indicating whether an IAM user login (for AWS Console) should be created for a given user | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | After the terraform docs: 'When destroying this user, destroy even if it has non-Terraform-managed IAM access keys, login profile or MFA devices. Without force\_destroy a user with non-Terraform-managed access keys and login profile will fail to be destroyed.' | `bool` | `false` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | A list of groups the user should become a member of | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the IAM user | `string` | n/a | yes |
| <a name="input_password_reset_required"></a> [password\_reset\_required](#input\_password\_reset\_required) | Whether the user should be forced to reset the generated password on first login. | `bool` | `false` | no |
| <a name="input_path"></a> [path](#input\_path) | The path in which the IAM user should be created | `string` | `"/users/"` | no |
| <a name="input_pgp_key"></a> [pgp\_key](#input\_pgp\_key) | Either a base-64 encoded PGP public key, or a keybase username in the form keybase:username. Used to encrypt the password and the access key on output to the console. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_iam_user_credentials"></a> [aws\_iam\_user\_credentials](#output\_aws\_iam\_user\_credentials) | The credentials of a given IAM user |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
