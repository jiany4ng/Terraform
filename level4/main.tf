provider "aws" {
  region = var.region
}

module "networking" {
  source = "./modules/networking"
}

module "ec2" {
  source = "./modules/ec2"
}

variable "region" {
  default = "eu-central-1"
}