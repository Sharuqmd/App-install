terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
}
