module "network" {
  source = "github.com/KarthikPalakurthy/tf-vpc-module"

  for_each = var.vpc
  cidr_block= each.value.cidr_block
}

