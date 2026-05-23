terraform {
  backend "s3" {
    bucket         = "cachet-platform-state-406708888206-eu-central-1-an"
    key            = "cachet/terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile   = true
  }
}