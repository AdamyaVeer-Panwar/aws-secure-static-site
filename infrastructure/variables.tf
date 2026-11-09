variable "aws_region" {
  description = "AWS region in which the S3 bucket is created. CloudFront is a global service."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Short prefix used for resource names and tags."
  type        = string
  default     = "adamya-aws-static-site"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name may contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment tag."
  type        = string
  default     = "demo"
}
