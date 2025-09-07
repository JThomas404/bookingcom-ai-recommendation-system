# Hardcoded values to break dependency cycle
locals {
  api_gateway_url = "https://df5ib6jx72.execute-api.us-east-1.amazonaws.com/dev"
  cloudfront_cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

resource "aws_cloudfront_distribution" "bkr-distribution" {
  origin {
    domain_name              = var.website_bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.bkr-oac.id
  }
  enabled             = true
  default_root_object = "index.html"

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    cache_policy_id = local.cloudfront_cache_policy_id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.tags
}

resource "aws_cloudfront_origin_access_control" "bkr-oac" {
  name                              = "bkr-oac"
  description                       = "OAC for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "bkr-bucket-policy" {
  bucket = var.website_bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${var.website_bucket_name}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.bkr-distribution.arn
          }
        }
      }
    ]
  })
}

resource "aws_s3_object" "bkr-index-html" {
  bucket       = var.website_bucket_name
  key          = "index.html"
  content_type = "text/html"
  content = templatefile("${path.module}/templates/index.html", {
    api_gateway_url = local.api_gateway_url
  })
  source_hash = md5(templatefile("${path.module}/templates/index.html", {
    api_gateway_url = local.api_gateway_url
  }))

  tags = var.tags
}

resource "aws_s3_object" "bkr-style-css" {
  bucket       = var.website_bucket_name
  key          = "style.css"
  content_type = "text/css"
  source       = "${path.module}/templates/style.css"
  source_hash  = filemd5("${path.module}/templates/style.css")

  tags = var.tags
}
