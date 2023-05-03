module "network" {
  source = "github.com/KarthikPalakurthy/tf-vpc-module"
  env=var.env
  default_vpc_id = var.default_vpc_id

  for_each = var.vpc
  cidr_block = each.value.cidr_block
  public_subnet_cidr= each.value.public_subnet_cidr
  private_subnet_cidr= each.value.private_subnet_cidr
}

