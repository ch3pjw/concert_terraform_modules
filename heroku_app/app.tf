variable "name" {}
variable "subdomain" {}
variable "source_git_url" {}
variable "config_vars" {
  default = {}
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
  provisioner "local-exec" {
    command = <<EOF
      cd /tmp;
      rm -fr ${var.name}_deploy;
      git clone ${var.source_git_url} ${var.name}_deploy;
      cd ${var.name}_deploy;
      git remote add heroku ${heroku_app.app.git_url};
      git push heroku master;
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
