module "network" {
  source = "github.com/KarthikPalakurthy/tf-vpc-module"
  env=var.env
  default_vpc_id = var.default_vpc_id

  for_each = var.vpc
  public_subnet_cidr= each.value.public_subnet_cidr
  private_subnet_cidr= each.value.private_subnet_cidr
}

