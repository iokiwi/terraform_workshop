
# Terraform and terraform providers

https://registry.terraform.io/providers/hashicorp/aws/latest/docs


# Terraform overiew

 * Concepts
     * IaC
     * Immutable infrastructure

# Part 1: Hello, World!

## Installing Terraform Locally

Instead of installing a specific version of terraform we will install a terraform
version manager called tfenv

1. Follow the steps for manuall installation https://github.com/tfutils/tfenv#manual
2. Create a handy alias (optional)
   ```bash
   alias tf="terraform"
   ```
3. Restart your terminal or source your bashrc file
   ```bash
   source ~/.bashrc
   ```
4. Check your tfenv install
   ```bash
   $ tfenv
   tfenv 2.2.2-84-g459d15b
   Usage: tfenv <command> [<options>]

   Commands:
      install       Install a specific version of Terraform
      use           Switch a version to use
      uninstall     Uninstall a specific version of Terraform
      list          List all installed versions
      list-remote   List all installable versions
      version-name  Print current version
      init          Update environment to use tfenv correctly.
      pin           Write the current active version to ./.terraform-version
   ```
5. Finally, install terraform
   ```bash
   tfenv install latest
   ```
6. Check your terraform install
   ```bash
   $ terraform -version
   Terraform v1.4.4
   on linux_amd64

   Your version of Terraform is out of date! The latest version
   is 1.4.5. You can update by downloading from https://www.terraform.io/downloads.html
   ```

## Hello World

```
$ cd lab_1
```
```bash
$ terraform init
```
Result
```bash
Initializing the backend...

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
```bash
$ terraform plan
```
Result
```
Changes to Outputs:
  + hello = "Hello, World!"

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
```bash
$ terraform apply
```
```
Changes to Outputs:
  + hello = "Hello, World!"

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

hello = "Hello, World!"
```

```bash
$ terraform destroy
```
```
Changes to Outputs:
  - hello = "Hello, World!" -> null

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

Destroy complete! Resources: 0 destroyed.
```

# Part 2: Terraform Language Features and Syntax

HCL = **H**ashicorp **C**onfiguration **L**anguage
<!-- 
 * HCL vs  -->

terraform.tf

## Outputs

https://developer.hashicorp.com/terraform/language/values/outputs
* Great for debugging
* Outputs of one module can be referenced in another module (advanced)

Declaring an output

```hcl
output "greeting" {
   value = "Hello, World!"
}
```

Go to [lab1_outputs/terraform.tf](lab2_locals/terraform.tf)




## Local Values
<hr>

https://developer.hashicorp.com/terraform/language/values/locals

A local value assigns a name to an expression, so you can use the name multiple times within a module instead of repeating the expression.

I think of them like declaring global constants for reuse

Declaring a local

```
locals {
   name = "Simon"
}
```

Referencing a local
```
output "hello" {
   value = "Hello, ${local.name}!"
}
```

Try it in [lab2_locals/terraform.tf](lab2_locals/terraform.tf)

## Variables
<hr>

https://developer.hashicorp.com/terraform/language/values/variables

Declaring a variable

```
variable "name" {
   type = string
   description = "Your name, so we can greet you"
}
```

Referencing a variable

```
output "greeting" {
   value = "Hello, ${var.name}!"
}
```

Try it in [lab3_variables/terraform.tf](lab3_variables/terraform.tf)

```bash
$ cd lab3_variables
```

```
$ terraform init
```

```
$ terraform plan
var.name
  Your name, so we can greet you

  Enter a value:
```

What happened?

If no values are configured for a variable, terraform will interactively prompt for a value.

###  Specifying values for variables

Using the CLI

```
$ terraform plan -var "name=John"
```

Using an Environment Variable prefixed with `TF_VAR_`

```bash
$ TF_VAR_name="John" terraform plan
```

Using a var file named `terraform.tfvars` in the current working directroy

```
$ cat terraform.tfvars
name = "John"
```

Using any other file ending with `.tfvars` and the `-var-file` cli argument

```bash
$ terraform plan -var-file="alt.tfvars"
```

Declaring the variable definition with a default value

```terraform
variable "name" {
   default = "Joseph"
   type = string
   description = "Your name, so we can greet you"
}
```

### Variable Precedence

You can mix and match as many of the above methods. The precidence is detailed here
https://developer.hashicorp.com/terraform/language/values/variables#variable-definition-precedence

Terraform loads variables in the following order, with later sources taking precedence over earlier ones:

1. Default value of variable (lowest precidence)
2. Environment variables
3. `terraform.tfvars` File
4. `-var` or `-var-file` (highest precidence)


## Types and Functions

### Types

https://developer.hashicorp.com/terraform/language/expressions/types

 * numbers
 * strings
 * maps/object
 * lists/tuples

Lists/Tuples

```
backoff_sequence = [
   1, 1, 2, 3, 5, 8, 13
]
```

```
backoff_sequence[4]       # 5
```

Maps/Objects

```
person = {
   name = "eve"
   objective = "mischief"
}
```

```
person.objective    # "mischief"
```

### Functions
https://developerhashicorp.com/terraform/language/functions

Terraform has many built in functions to help us manipulate data. We cannot define our own though.

```
length(backoff_sequence)  # 7
```

```
toset(backoff_sequence)   # [1, 2, 3, 5, 8, 13]
```

## Key Takeaways

 * We can use the `output` directive display information from our terrform configuration to us.
 * We can define `variables` and specify them in several to give our terrform flexability
 * We can use terraform built in functions to help us handle data

# Part 2: Creating Resources in AWS

## Setup

[lab5_aws_provider](lab5_aws_provider/terraform.tf)

The Terraform AWS Provider

```
terraform {
    required_version = ">= 1.4.4"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}
```

```
provider "aws" {
    region = "ap-southeast-2"
}
```

## Data

For getting information about AWS resources that are not created as part of our IAC

 * Declaring
 * Referencing

## Resources

For creating resources in aws

 * Declaring
 * Referencing

## Part 4: Terraform state

 * ## local state
 * ## remote state

More

 * Modules - https://developer.hashicorp.com/terraform/language/modules
 * Meta Arguments
    * count - https://developer.hashicorp.com/terraform/language/meta-arguments/count
    * for_each - https://developer.hashicorp.com/terraform/language/meta-arguments/for_each
 * Workspaces - https://developer.hashicorp.com/terraform/language/state/workspaces
    * We don't currently use this feature.
    * Instead we sort of do a similar thing manually by having separate env/test and env/prod directories
