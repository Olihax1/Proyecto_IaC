# --- S3 + CloudFront + WAF (Frontend) ---
resource "aws_s3_bucket" "frontend" {
  bucket = "${local.nombre}-frontend-${data.aws_caller_identity.actual.account_id}"
  tags   = local.tags
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "s3-frontend"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-frontend"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.certificado_acm_arn == "" ? true : false
    acm_certificate_arn            = var.certificado_acm_arn == "" ? null : var.certificado_acm_arn
    ssl_support_method             = var.certificado_acm_arn == "" ? null : "sni-only"
    minimum_protocol_version       = var.certificado_acm_arn == "" ? null : "TLSv1.2_2021"
  }

  web_acl_id = aws_wafv2_web_acl.waf.arn

  tags = local.tags
}