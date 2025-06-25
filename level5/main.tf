provider "aws" {
  region = var.region
}

module "networking" {
  source = "../level3_modules/modules/networking"
}

module "ec2" {
  source = "../level3_modules/modules/ec2"
  instance_type = var.instance_type
  key_name      = var.key_name
}
