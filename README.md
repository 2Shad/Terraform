# Infrastructure as Code with Terraform
## What is Terraform
### Terraform Architecture
#### Terraform default file/folder structure
##### .gitignore
###### AWS keys with Terraform security


### Terraform commands
- `terraform init` To initialize Terraform
- `terraform plan` checks the script
- `terraform apply` implements the script
- `terraform destroy` to delete everything

### Terraform file/folder structure
- `.tf` extension - `main.tf` (runner file)
- Apply **DRY**

### Set up AWS keys as an ENV in windows machine
- `AWS_ACCESS_KEY_ID` for aws access keys
- `AWS_SECRET_ACCESS_KEY` for aws secret key
- Windows search `env` and open **Edit the system Environment variable**
- Select **Environment Variables**
- Under **User variables for $User** select **New** and add the 2 variables