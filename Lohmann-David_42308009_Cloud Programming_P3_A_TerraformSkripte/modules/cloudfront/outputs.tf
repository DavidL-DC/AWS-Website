output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.website_cdn.domain_name}"
}
