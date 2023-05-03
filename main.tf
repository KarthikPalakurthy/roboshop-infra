module "network" {
  source = "github.com/KarthikPalakurthy/tf-vpc-module"
  env=var.env
  default_vpc_id = var.default_vpc_id

  for_each = var.vpc
  public_cidr_block= each.value.public_cidr_block
  private_subnet_cidr= each.value.private_subnet_cidr
}

