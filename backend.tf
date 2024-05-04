terraform {
  backend "s3" {
    bucket = "your-s3-bucket-name"
    key    = "terraform-statefile"
    prefix = "deploy_iam/"
    region = "us-west-1"
  }
}
