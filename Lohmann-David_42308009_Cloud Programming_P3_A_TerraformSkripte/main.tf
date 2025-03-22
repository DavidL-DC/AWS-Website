provider "aws" {
  region = "eu-central-1"
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "meinewebsiteiu"
  website_file = "./meine_website.html"
}

module "cloudfront" {
  source            = "./modules/cloudfront"
  s3_bucket_domain  = module.s3.bucket_domain_name
}

output "s3_website_url" {
  value = module.s3.website_url
}

output "cloudfront_url" {
  value = module.cloudfront.cloudfront_url
}
