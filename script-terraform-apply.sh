#!/bin/bash

echo "Beginning the deployment"
date

cd ./tf-acn-webservers

echo "Initialize Terraform"
terraform init 

echo "Formating terraform code"
terraform fmt 

echo "Validating the code"
terraform validate 

echo "Planning the resources"
terraform plan -out terraform.tfplan 

echo "Applying the changes"
terraform apply "terraform.tfplan"

echo "Finishing the deployment"
date

echo "Removing .terraform folder"
rm -rf tf-acn-webservers/.terraform*

echo "Removing terraform.tfplan file"
rm -rf tf-acn-webservers/terraform.tfplan