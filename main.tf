module "vpc" {
  source = "github.com/KarthikPalakurthy/tf-vpc-module"
  env=var.env
  default_vpc_id = var.default_vpc_id
  for_each = var.vpc
  cidr_block = each.value.cidr_block
}

#module "subnets" {
#  source = "github.com/KarthikPalakurthy/tf-subnet-module"
#  env=var.env
#  default_vpc_id = var.default_vpc_id
#  vpc_id = lookup(lookup(module.vpc,"main",null ),"vpc_id",null )
#
#  for_each = var.subnets
#  cidr_block = each.value.cidr_block
#  availability_zone = each.value.availability_zone
#  name = each.value.name
#  vpc_peering_connection_id = lookup(lookup(module.vpc,"main",null ),"vpc_peering_connection_id",null )
#  internet_gw = lookup(each.value,"internet_gw",false )
#  nat_gw = lookup(each.value, "nat_gw", false)
#  internet_gw_id = lookup(lookup(module.vpc,"main",null ),"internet_gw_id",null )
#}
#
