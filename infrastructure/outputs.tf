output "s3_bucket_name" {
  description = "Private S3 bucket that stores the website assets."
  value       = aws_s3_bucket.site.id
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID, used for cache invalidations."
  value       = aws_cloudfront_distribution.site.id
}

output "website_url" {
  description = "HTTPS URL served through CloudFront. Allow time for distribution deployment."
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}
