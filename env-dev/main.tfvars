env = "dev"
default_vpc_id = "vpc-096e167dbab1ac004"

vpc = {
  main = {
    cidr_block = "10.0.0.0/16"
    availability_zone = ["us-east-1a","us-east-1b"]
    public_subnets = {
      public = {
        name = "public"
        cidr_block = ["10.0.0.0/24","10.0.1.0/24"]
        internet_gw = true
      }
    }
    private_subnets = {
      web = {
        name = "web"
        cidr_block = ["10.0.2.0/24","10.0.3.0/24"]
        nat_gw = true
      }

      app = {
        name = "app"
        cidr_block = ["10.0.4.0/24","10.0.5.0/24"]
        nat_gw = true
      }

      db = {
        name = "db"
        cidr_block = ["10.0.6.0/24","10.0.7.0/24"]
        nat_gw = true
      }
    }
  }
}

docdb = {
  main = {
    vpc_name = "main"
    subnet_name = "db"
    engine_version = "4.0.0"
    no_of_instances = 1
    instance_class = "db.t3.medium"
  }
}

rds = {
  main = {
    vpc_name = "main"
    subnet_name = "db"
    engine = "aurora-mysql"
    engine_version = "5.7.mysql_aurora.2.11.1"
    no_of_instances = 1
    instance_class = "db.t3.small"
  }
}

elasticache = {
  main = {
    vpc_name = "main"
    subnet_name = "db"
    node_type = "cache.t3.micro"
    num_node_groups             = 2
    replicas_per_node_group     = 1
  }
}

rabbitmq = {
  main = {
    vpc_name           = "main"
    subnet_name       = "db"
    engine_type        = "RabbitMQ"
    engine_version     = "3.10.10"
    host_instance_type = "mq.t3.micro"
    deployment_mode    = "SINGLE_INSTANCE"
  }
}

alb = {

  public_alb = {
    vpc_name = "main"
    subnet_name = "public"
    subnet_type = "public_subnet_ids"
    internal = false
  }
  private_alb = {
    vpc_name = "main"
    subnet_name = "app"
    subnet_type = "private_subnet_ids"
    internal = true
  }
}

apps ={
  frontend = {
    component          = "frontend"
    vpc_name           = "main"
    subnet_type        = "private_subnets"
    subnet_name        = "web"
    port_number = 80
  }
  catalogue = {
    component          = "catalogue"
    vpc_name           = "main"
    subnet_type        = "private_subnets"
    subnet_name        = "app"
    port_number = 8080
  }
}
