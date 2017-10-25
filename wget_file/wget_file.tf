variable "url" {}
variable "dest_dir" {}

data "external" "file" {
  program = ["${path.module}/cache_file.py"]
  query = {
    dest_dir = "${var.dest_dir}"
    url = "${var.url}"
  }
}

output "path" {
  value = "${data.external.file.result.path}"
}
