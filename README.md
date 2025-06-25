```
 _____ ___ ___ ___  __  ___ __  ___ __ __ 
|_   _| __| _ \ _ \/  \| __/__\| _ \  V  |
  | | | _|| v / v / /\ | _| \/ | v / \_/ |
  |_| |___|_|_\_|_\_||_|_| \__/|_|_\_| |_|

```
[![Awesome](https://awesome.re/badge.svg)](https://awesome.re)

Terraform is an open-source tool by HashiCorp that allows you to define, provision, and manage cloud infrastructure using a declarative configuration language. It's widely used in DevOps to automate infrastructure provisioning across many cloud platforms.

## File Structure

Terraform projects typically follow a standard layout that encourages best practices and maintainability:

```
project/
├── main.tf             # Core infrastructure resources
├── variables.tf        # Input variables used in the configuration
├── outputs.tf          # Outputs shown after terraform apply
├── provider.tf         # Cloud provider configuration (e.g. AWS)
├── terraform.tfvars    # Environment-specific variable values
├── backend.tf          # (Optional) Remote state configuration
├── modules/            # Reusable logical components (e.g., ec2, networking)
└── environments/       # tfvars files per environment (dev, prod, etc.)
```

Each file serves a unique purpose in organizing your infrastructure-as-code for reuse, scaling, and clarity.



## Core AWS Components in This Demo

- **VPC (Virtual Private Cloud)**: A logically isolated network in AWS to launch resources.
- **Subnets**: IP range segments within a VPC. Public subnets allow internet access; private ones don’t.
- **Internet Gateway**: Connects a VPC to the internet.
- **Route Tables**: Control how traffic is routed within the VPC.
- **Security Groups**: Stateful firewalls attached to resources to control traffic.
- **EC2 Instances**: Virtual machines. We use Ubuntu and Amazon Linux in this demo.



## Project Levels Overview

Each level builds on the previous one, progressively improving structure, modularity, and maintainability.

Before running any level, it's important to understand the most commonly used Terraform commands:

- `terraform init`: Initializes a working directory containing Terraform configuration files. Downloads required providers and sets up backends.
- `terraform plan`: Creates an execution plan, showing what actions Terraform will take to achieve the desired state without making any changes.
- `terraform apply`: Applies the planned changes to your infrastructure. Use `-auto-approve` to skip manual confirmation.
- `terraform destroy`: Destroys all resources created by Terraform. Useful for cleaning up environments.
- `terraform validate`: Validates the syntax and configuration of your Terraform files.
- `terraform fmt`: Formats your code to follow standard Terraform style conventions.
- `terraform output`: Displays the values of outputs defined in your `outputs.tf` file.
- `terraform show`: Shows the current state or a plan file in a human-readable format.
- `terraform state`: Advanced command to inspect and manage the Terraform state file directly.
- `terraform taint`: Marks a specific resource for recreation during the next apply.
- `terraform import`: Brings an existing infrastructure resource into Terraform state.
- `terraform init`: Initializes the working directory containing Terraform configuration files. Downloads required providers and sets up the backend if configured.
- `terraform apply`: Applies the changes required to reach the desired state of the configuration. The `-auto-approve` flag skips the interactive approval prompt.
- `terraform apply -var-file`: Allows you to apply configurations using a specific set of variable values (e.g., per environment). bash terraform init terraform apply -auto-approve


To execute each level:
```bash
cd levelx && terraform init
terraform apply -auto-approve
````

### Level 1: Flat `main.tf`
All resources are defined in one file. Good for getting started or small demos.

### Level 2: Split by Purpose
Resources are split into `networking.tf` and `ec2.tf`. This improves clarity and file organization.


### Level 3: Modular Structure
Resources are moved into modules (`modules/networking`, `modules/ec2`) and called from a clean root file.


### Level 4: Parameterized with Variables
Adds `variables.tf` to make the project reusable. Hardcoded values (e.g., region, instance type) are abstracted.


### Level 5: Multiple Environments
Enables multiple environments (like dev and prod) with separate variable definitions in `environments/dev/terraform.tfvars`, `environments/prod/terraform.tfvars`, etc.

**To execute dev environment:**

```bash
terraform apply -var-file="../env/<environment>/terraform.tfvars" -auto-approve
```


