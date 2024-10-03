# Configure remote state storage
terraform {
  backend "s3" {
    bucket = "mine-terraform-bucket"
    key    = "terraform/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "terraform-entry-table"
  }
}
