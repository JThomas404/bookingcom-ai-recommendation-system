output "cloudfront-domain-name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.bkr-distribution.domain_name
}
