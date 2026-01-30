output "website_url" {
  description = "Website URL"
  value       = "http://${aws_s3_bucket.website.bucket}.s3-website-${aws_s3_bucket.website.region}.amazonaws.com"
}

output "bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.website.bucket
}
