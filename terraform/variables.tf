variable "domain_name" {
  description = "The domain name for Sheldon's fitness website (e.g., sheldon-fitness.com)"
  type        = string
  default     = "example.com"  # Replace with actual domain when known
}

variable "aws_region" {
  description = "AWS region for S3 bucket and primary resources (CloudFront is global; ACM certificate always in us-east-1)"
  type        = string
  default     = "us-west-2"
}

variable "certificate_email" {
  description = "Email address for ACM certificate notifications (not published)"
  type        = string
  default     = "admin@example.com"  # Replace with actual email
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "sheldon-fitness"
}

variable "environment" {
  description = "Environment tag (e.g., prod, staging)"
  type        = string
  default     = "prod"
}

# CloudFront cache settings
variable "default_ttl" {
  description = "Default cache TTL in seconds for CloudFront"
  type        = number
  default     = 86400  # 1 day
}

variable "max_ttl" {
  description = "Max cache TTL in seconds for CloudFront"
  type        = number
  default     = 604800  # 7 days
}

variable "aws_account_id" {
  description = "AWS account ID for resource naming"
  type        = string
  default     = "179174776097"
}
