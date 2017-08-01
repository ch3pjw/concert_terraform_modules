variable "git_url" {}
variable "clone_path" {}
variable "commit_sha" {}
variable "target_branch" {
  description = "The branch we will hard-reset to the specified commit sha"
  default = "deploy"
}

data "external" "repo" {
  program = ["${path.module}/cache_repo.py"]
  query = {
    git_url = "${var.git_url}"
    clone_path = "${var.clone_path}"
    commit_sha = "${var.commit_sha}"
    target_branch = "${var.target_branch}"
  }
}

output "clone_path" {
  value = "${var.clone_path}"
}

output "target_branch" {
   value = "${var.target_branch}"
}
