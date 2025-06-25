provider "aws" {
  region = "eu-central-1"
}

module "networking" {
  source = "./modules/networking"
}

module "ec2" {
  source = "./modules/ec2"
}