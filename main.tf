module "network" {
  source = "github.com/KarthikPalakurthy/tf-vpc-module"
  env=var.env
  default_vpc_id = var.default_vpc_id

  for_each = var.vpc
  cidr_block= each.value.cidr_block
  subnet_cidr= each.value.subnet_cidr
}

