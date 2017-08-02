variable "name" {}
variable "subdomain" {}
variable "source_git_url" {}
variable "commit_sha" {}
variable "cache_dir" {}
variable "config_vars" {
  default = {}
}


module "app_git_repo" {
  source = "git@github.com:ch3pjw/concert_terraform_modules.git//git_repo"
  git_url = "${var.source_git_url}"
  clone_path = "${var.cache_dir}/${var.source_git_url}"
  commit_sha = "${var.commit_sha}"
}

resource "heroku_app" "app" {
  name = "${var.name}"
  region = "eu"
  buildpacks = [
    "heroku/python"
  ]
  # Yes, it's rather odd that to pass the config_vars as a variable you have to
  # enclose the map in a list, when you can define it statically without the
  # enclosing list:
  # config_vars = [
  #   "${var.config_vars}"
  # ]
}


resource "null_resource" "git_push" {
  triggers {
    source_git_url = "${var.source_git_url}"
    commit_sha = "${var.commit_sha}"
  }
  provisioner "local-exec" {
    command = <<EOF
      cd ${module.app_git_repo.clone_path}
      if ! git config remote.heroku.url > /dev/null; then
        git remote add heroku ${heroku_app.app.git_url}
      fi
      git push heroku ${module.app_git_repo.target_branch}:master
    EOF
  }
}

output "git_url" {
  value = "${heroku_app.app.git_url}"
}

output "web_url" {
  value = "${heroku_app.app.web_url}"
}



resource "heroku_domain" "co_uk" {
  app = "${heroku_app.app.name}"
  hostname = "${var.subdomain}.concertdaw.co.uk"
}

resource "heroku_domain" "hyphen_co_uk" {
  app = "${heroku_app.app.name}"
  hostname = "${var.subdomain}.concert-daw.co.uk"
}

resource "heroku_domain" "com" {
  app = "${heroku_app.app.name}"
  hostname = "${var.subdomain}.concertdaw.com"
}

resource "heroku_domain" "hyphen_com" {
  app = "${heroku_app.app.name}"
  hostname = "${var.subdomain}.concert-daw.com"
}

output "domain_map" {
  value = "${map(
    heroku_domain.co_uk.hostname, heroku_domain.co_uk.cname,
    heroku_domain.hyphen_co_uk.hostname, heroku_domain.hyphen_co_uk.cname,
    heroku_domain.com.hostname, heroku_domain.com.cname,
    heroku_domain.hyphen_com.hostname, heroku_domain.hyphen_com.cname
    )}"
}
