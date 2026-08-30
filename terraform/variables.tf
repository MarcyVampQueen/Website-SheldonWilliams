variable "domain_name" {
  description = "The domain name for Sheldon's fitness website (e.g., sheldon-fitness.com)"
  type        = string
  default     = "example.com"  # Replace with actual domain when known
}

variable "aws_region" {
  description = "AWS region for the S3 bucket. CloudFront is global."
  type        = string
  default     = "us-east-1"
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
