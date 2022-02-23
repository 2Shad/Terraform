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

### Set-up ssh keys
Generate ssh keys by `ssh-keygen -t rsa -b 2048`.

#### To add the keys to terraform add `key_name= "aws_key"` to the `"aws_instance"` resource, in the same resource also add a `connection` section:
```
connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("/home/user/.ssh/aws_key")
      timeout     = "4m"
   }
```

#### You also need to add another `aws_key_pair` resource in the file:
```
resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDbvRN/gvQBhFe+dE8p3Q865T/xTKgjqTjj56p1IIKbq8SDyOybE8ia0rMPcBLAKds+wjePIYpTtRxT9UsUbZJTgF+SGSG2dC6+ohCQpi6F3xM7ryL9fy3BNCT5aPrwbR862jcOIfv7R1xVfH8OS0WZa8DpVy5kTeutsuH5suehdngba4KhYLTzIdhM7UKJvNoUMRBaxAqIAThqH9Vt/iR1WpXgazoPw6dyPssa7ye6tUPRipmPTZukfpxcPlsqytXWlXm7R89xAY9OXkdPPVsrQdkdfhnY8aFb9XaZP8cm7EOVRdxMsA1DyWMVZOTjhBwCHfEIGoePAS3jFMqQjGWQd user@pc"
}
```