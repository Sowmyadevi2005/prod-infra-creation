terraform {
  # Terraform configuration block
  backend "s3" {
    # Remote state storage configuration
    bucket         = "l2-track-statefile"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "prod-dynomodb"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

}
provider "aws" {
  region = "us-east-1"
}
