#!/bin/bash

aws s3 mb s3://varrow-academy-devops-networking-terraform-backend-us-east-1
aws s3api put-bucket-versioning --bucket varrow-academy-devops-networking-terraform-backend-us-east-1 --versioning-configuration Status=Enabled --region us-east-1

aws s3 mb s3://varrow-academy-devops-compute-terraform-backend-us-east-1
aws s3api put-bucket-versioning --bucket varrow-academy-devops-compute-terraform-backend-us-east-1 --versioning-configuration Status=Enabled --region us-east-1
echo "All done :)"