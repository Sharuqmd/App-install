# Variables for dynamic configurations
variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "EKS Cluster name"
  default     = "my-cluster"
}

variable "k8s_version" {
  description = "Kubernetes version for EKS"
  default     = "1.21"
}

variable "s3_bucket" {
  description = "S3 bucket to store the Terraform state"
}




















































