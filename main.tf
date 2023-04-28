module "network" {
  source = "github.com/KarthikPalakurthy/tf-vpc-module"
  env=var.env

  for_each = var.vpc
  cidr_block= each.value.cidr_block
  subnet_cidr= each.value.subnet_cidr
}

