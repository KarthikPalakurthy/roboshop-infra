module "vpc" {
  source = "github.com/KarthikPalakurthy/tf-vpc-module"
  env=var.env
  default_vpc_id = var.default_vpc_id

  for_each = var.vpc
  cidr_block = each.value.cidr_block
  public_subnets = each.value.public_subnets
  private_subnets = each.value.private_subnets
  availability_zone = each.value.availability_zone
}

module "docdb" {
  source = "github.com/KarthikPalakurthy/tf-docdb-module"
  env = var.env

  for_each = var.docdb
  subnet_ids = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name , null), "private_subnet_ids", null), each.value.subnet_name, null), "subnet_ids", null )
  allow_cidr_blocks = lookup(lookup(lookup(lookup(var.vpc , each.value.vpc_name , null), "private_subnets" , null),"app", null), "cidr_block", null)
  vpc_id = lookup(lookup(module.vpc , each.value.vpc_name , null), "vpc_id" , null)
  engine_version = each.value.engine_version
  no_of_instances = each.value.no_of_instances
  instance_class = each.value.instance_class
}


module "rds" {
  source = "github.com/KarthikPalakurthy/tf-rds-module"
  env = var.env

  for_each = var.rds
  subnet_ids = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name , null), "private_subnet_ids", null), each.value.subnet_name, null), "subnet_ids", null )
  allow_cidr_blocks = lookup(lookup(lookup(lookup(var.vpc , each.value.vpc_name , null), "private_subnets" , null),"app", null), "cidr_block", null)
  vpc_id = lookup(lookup(module.vpc , each.value.vpc_name , null), "vpc_id" , null)
  engine = each.value.engine
  engine_version = each.value.engine_version
  no_of_instances = each.value.no_of_instances
  instance_class = each.value.instance_class
}

module "elasticache" {
  source = "github.com/KarthikPalakurthy/tf-elasticache-module"
  env = var.env

  for_each = var.elasticache
  subnet_ids = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name , null), "private_subnet_ids", null), each.value.subnet_name, null), "subnet_ids", null )
  allow_cidr_blocks = lookup(lookup(lookup(lookup(var.vpc , each.value.vpc_name , null), "private_subnets" , null),"app", null), "cidr_block", null)
  vpc_id = lookup(lookup(module.vpc , each.value.vpc_name , null), "vpc_id" , null)
  node_type = each.value.node_type
  num_node_groups = each.value.num_node_groups
  replicas_per_node_group = each.value.replicas_per_node_group
}

output "vpc" {
  value = module.vpc
}