terraform {
  backend "s3" {
    region = "ap-south-1"
    encrypt = true
  }
}
