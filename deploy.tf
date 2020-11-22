terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.8.0"
    }
  }

  backend "s3" {
    bucket = "benstepp-terraform"
    key = "benstepp"
    region = "us-east-1"
  }
}

variable "dns_zone_id" {
  default = "ZTCVR71C2FFQT"
}

provider "aws" {
  profile = "default"
  region = "us-east-1"
}

resource "aws_s3_bucket" "benstepp" {
  bucket = "benstepp.com"
  acl = "private"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.benstepp.id
  key = "index.html"
  source = "./dist/index.html"
  etag = filemd5("./dist/index.html")
  acl = "public-read"
  cache_control = "no-cache"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "favicon" {
  bucket = aws_s3_bucket.benstepp.id
  key = "favicon.ico"
  source = "./dist/favicon.ico"
  etag = filemd5("./dist/favicon.ico")
  acl = "public-read"
  cache_control = "no-cache"
  content_type = "image/x-icon"
}

resource "aws_cloudfront_distribution" "cloudfront" {
  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"
  aliases = ["benstepp.com"]

  origin {
    domain_name = aws_s3_bucket.benstepp.bucket_regional_domain_name
    origin_id = aws_s3_bucket.benstepp.id

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods = ["HEAD", "GET"]
    compress = true
    target_origin_id = aws_s3_bucket.benstepp.id
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.benstepp.arn
    ssl_support_method = "sni-only"
    cloudfront_default_certificate = true
  }
}

resource "aws_acm_certificate" "benstepp" {
  domain_name = "benstepp.com"
  subject_alternative_names = ["*.benstepp.com"]
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.benstepp.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      record = dvo.resource_record_value
      type = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name = each.value.name
  records = [each.value.record]
  ttl = 60
  type = each.value.type
  zone_id = var.dns_zone_id
}

resource "aws_acm_certificate_validation" "benstepp" {
  certificate_arn = aws_acm_certificate.benstepp.arn
  validation_record_fqdns =[for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "benstepp" {
  zone_id = var.dns_zone_id
  name = "benstepp.com"
  type = "A"

  alias {
    name = aws_cloudfront_distribution.cloudfront.domain_name
    zone_id = aws_cloudfront_distribution.cloudfront.hosted_zone_id
    evaluate_target_health = true
  }
}
