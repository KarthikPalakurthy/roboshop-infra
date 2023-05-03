env = "dev"
default_vpc_id = "vpc-096e167dbab1ac004"

vpc = {
  main = {
    cidr_block = "10.0.0.0/16"
    public_subnet_cidr = ["10.0.0.1/24","10.0.0.254/24"]
    private_subnet_cidr = [ "10.0.1.1/24","10.0.1.254/24"]
  }
}