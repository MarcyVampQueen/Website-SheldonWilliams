output "s3_bucket_name" {
  description = "Name of the S3 bucket."
  value       = aws_s3_bucket.website.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name. Use this for preview/testing before DNS is configured."
  value       = aws_cloudfront_distribution.website.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID used for cache invalidation."
  value       = aws_cloudfront_distribution.website.id
}

output "route53_nameservers" {
  description = "Route 53 nameservers for the configured custom domain."
  value       = var.domain_name != "" ? aws_route53_zone.website[0].name_servers : []
}

output "website_url" {
  description = "Custom domain URL when one is configured."
  value       = var.domain_name != "" ? "https://${var.domain_name}" : null
}

output "cloudfront_url_for_testing" {
  description = "CloudFront URL to use for testing before DNS is configured."
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}
