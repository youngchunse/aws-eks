terraform {
  backend "s3" {
    bucket               = "terraform-state-demo-dev-application"
    dynamodb_table       = "terraform-state-demo-dev-application-lock"
    key                  = "dev/us-east-1/eks"
    region               = "us-east-1"
  }
}
