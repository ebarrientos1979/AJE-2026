output "website_url" {
  description = "CloudFront Distribution URL"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.website.bucket
}
