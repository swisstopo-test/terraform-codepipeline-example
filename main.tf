provider "aws" {
  version = "~> 2.5.0"
  region  = "eu-west-1"
}

provider "github" {
    token        = "${var.github_token}"
    organization = "${var.github_org}"
    version = "~> 1.3.0"
}

