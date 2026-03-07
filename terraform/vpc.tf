module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.cluster_name
  cidr = var.cidr_block

  azs             = var.azs
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs
  intra_subnets   = var.intra_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true


  tags = {
    Terraform   = "true"
    Environment = "lab"
    Project     = "wanderlust"
  }
}
