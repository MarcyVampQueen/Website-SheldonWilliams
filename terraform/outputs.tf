output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (use this for testing before DNS)"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (used for cache invalidation)"
  value       = aws_cloudfront_distribution.website.id
}

output "route53_nameservers" {
  description = "Route 53 nameservers (update domain registrar to point here)"
  value       = aws_route53_zone.website[0].name_servers
  condition   = var.domain_name != "example.com"
}

output "website_url" {
  description = "Final website URL"
  value       = "https://${var.domain_name}"
  condition   = var.domain_name != "example.com"
}

output "cloudfront_url_for_testing" {
  description = "CloudFront URL to use for testing before DNS is configured"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}
