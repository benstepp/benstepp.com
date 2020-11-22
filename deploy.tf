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
