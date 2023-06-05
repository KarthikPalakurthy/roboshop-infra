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
  num_cache_nodes = each.value.num_cache_nodes
  replicas_per_node_group = each.value.replicas_per_node_group
  engine = each.value.engine
  engine_version = each.value.engine_version
}

module "rabbitmq" {
  source = "github.com/KarthikPalakurthy/tf-rabbitmq-module"
  env = var.env
  bastion_cidr= var.bastion_cidr

  for_each = var.rabbitmq
  subnet_ids = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name , null), "private_subnet_ids", null), each.value.subnet_name, null), "subnet_ids", null )
  allow_cidr_blocks = lookup(lookup(lookup(lookup(var.vpc , each.value.vpc_name , null), "private_subnets" , null),"app", null), "cidr_block", null)
  vpc_id = lookup(lookup(module.vpc , each.value.vpc_name , null), "vpc_id" , null)
  engine_type        = each.value.engine_type
  engine_version     = each.value.engine_version
  host_instance_type = each.value.host_instance_type
  deployment_mode    = each.value.deployment_mode
}

module "alb" {
  source = "github.com/KarthikPalakurthy/tf-alb-module"
  env = var.env

  for_each = var.alb
  subnet_ids = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name , null), each.value.subnet_type, null), each.value.subnet_name, null), "subnet_ids", null )
  allow_cidr_blocks = each.value.internal ? concat(lookup(lookup(lookup(lookup(var.vpc , each.value.vpc_name , null), "private_subnets" , null),"web", null), "cidr_block", null), lookup(lookup(lookup(lookup(var.vpc , each.value.vpc_name , null), "private_subnets" , null),"app", null), "cidr_block", null)) : [ "0.0.0.0/0"]
  vpc_id = lookup(lookup(module.vpc , each.value.vpc_name , null), "vpc_id" , null)
  subnet_name = each.value.subnet_name
  internal = each.value.internal
  dns_domain= each.value.dns_domain
}

module "apps" {
  source = "github.com/KarthikPalakurthy/tf-app-module"
  env = var.env

  depends_on = [module.docdb, module.rds, module.alb, module.rabbitmq]
  for_each = var.apps
  subnet_ids = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name , null), each.value.subnet_type, null), each.value.subnet_name, null), "subnet_ids", null )
  alb = lookup(lookup(module.alb,each.value.alb,null ), "dns_name", null )
  alb_arn = lookup(lookup(module.alb,each.value.alb,null ), "alb_arn", null )
  allow_cidr_blocks = lookup(lookup(lookup(lookup(var.vpc , each.value.vpc_name , null), each.value.allow_cidr_subnets_type , null),each.value.allow_cidr_subnets_name, null), "cidr_block", null)
  listener = lookup(lookup(module.alb,each.value.alb,null ), "listener", null )
  vpc_id = lookup(lookup(module.vpc , each.value.vpc_name , null), "vpc_id" , null)
  component = each.value.component
  port_number = each.value.port_number
  desired_capacity = each.value.desired_capacity
  max_size = each.value.max_size
  min_size = each.value.min_size
  instance_type = each.value.instance_type
  priority = each.value.priority

  bastion_cidr = var.bastion_cidr
  monitor_cidr = var.monitor_cidr
}

module "minikube" {
  source = "github.com/scholzj/terraform-aws-minikube"

  aws_region    = "us-east-1"
  cluster_name  = "Minikube"
  aws_instance_type = "t3.medium"
  ssh_public_key = "~/.ssh/id_rsa.pub"
  aws_subnet_id =  element(lookup(lookup(lookup(lookup(module.vpc, "main", null), "public_subnets", null), "public", null), "subnet_ids", null), 0)

  ami_image_id = data.aws_ami.centos8.id
  hosted_zone = var.hosted_zone
  hosted_zone_private = false

  tags = {
    Application = "Minikube"
  }

  addons = [
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/storage-class.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/heapster.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/dashboard.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/external-dns.yaml"
  ]
}

output "MINIKUBE_SERVER" {
  value = "ssh centos@${module.minikube.public_ip}"
}

output "KUBE_CONFIG" {
  value = "scp centos@${module.minikube.public_ip}:/home/centos/kubeconfig ~/.kube/config"
}