variable "source_url" {}
variable "cache_dir" {}
variable "bucket_id" {}
variable "bucket_bucket" {
  description = "Oh the pain - badly named attribute people!"
}
variable "region" {}
variable "content_type" {}
variable "cache_control" {
  default = "max-age=604800"
}
variable "acl" {
  default = "public-read"
}


module "resource_file" {
  source = "git@github.com:concert/terraform_modules.git//wget_file"
  url = "${var.source_url}"
  dest_dir = "${var.cache_dir}"
}

resource "aws_s3_bucket_object" "object" {
  key = "${basename(var.source_url)}"
  bucket = "${var.bucket_bucket}"
  source = "${module.resource_file.path}"
  content_type = "${var.content_type}"
  cache_control = "${var.cache_control}"
  acl = "${var.acl}"
}


output "url" {
  # Because for some reason, aws_s3_bucket_object fails to tell you what its
  # resulting URL is:
  value = "https://s3.${var.region}.amazonaws.com/${var.bucket_id}/${aws_s3_bucket_object.object.id}"
}
