variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-west-2"
}

variable "project" {
  description = "Project/name prefix for resources."
  type        = string
  default     = "tf-cicd-demo"
}

variable "ec2_instance_type" {
  description = "Instance type for the demo EC2."
  type        = string
  default     = "t3.micro"
}

variable "allow_ssh_cidr" {
  description = "CIDR allowed to SSH (22). Change to your IP for safety."
  type        = string
  default     = "0.0.0.0/0"
}

variable "create_bucket" {
  description = "Create a demo S3 bucket (true) or skip (false)."
  type        = bool
  default     = true
}
