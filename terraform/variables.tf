variable "domain_name" {
  description = "Custom domain for the site. Leave empty to use the CloudFront default domain for preview/testing."
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region for the S3 bucket and primary resources (CloudFront is global; ACM certificate always uses us-east-1)."
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name for AWS resource naming."
  type        = string
  default     = "sheldon-fitness"
}

variable "environment" {
  description = "Environment tag (for example: prod, staging)."
  type        = string
  default     = "prod"
}

variable "aws_account_id" {
  description = "AWS account ID for resource naming."
  type        = string
  default     = "179174776097"
}
