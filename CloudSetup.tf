provider "aws" {
  region = "eu-central-1"
}

# S3 Bucket für Website erstellen
resource "aws_s3_bucket" "website" {
  bucket = "meinewebsiteiu"
}

# Website-Hosting aktivieren
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website.bucket

  index_document {
    suffix = "meine_website.html"
  }
}

# Objekteigentümerschaft festlegen
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.website.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Bucket-Policy: Öffentlichen Zugriff erlauben
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# HTML-Datei hochladen
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.website.bucket
  key          = "meine_website.html"
  source       = "./meine_website.html"
  content_type = "text/html"

  acl = "public-read"
}

# CloudFront Distribution erstellen
resource "aws_cloudfront_distribution" "website_cdn" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  default_root_object = "meine_website.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# Ausgaben (URLs anzeigen)
output "s3_website_url" {
  value = aws_s3_bucket_website_configuration.website_config.website_endpoint
}

output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.website_cdn.domain_name}"
}
