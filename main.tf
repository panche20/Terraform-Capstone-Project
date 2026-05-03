terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# ── Locals ─────────────────────────────────────────
locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    CreatedBy   = "Chetan"
  }
}

# ── VPC ────────────────────────────────────────────
module "vpc" {
  source = "./vpc"

  name = local.name_prefix
  cidr = var.vpc_cidr
  azs  = var.azs
  tags = local.common_tags
}

# ── Security Groups ────────────────────────────────
module "security" {
  source = "./security"

  name            = local.name_prefix
  vpc_id          = module.vpc.vpc_id
  ssh_cidr_blocks = var.ssh_cidr_blocks
  tags            = local.common_tags
}

# ── Load Balancer ──────────────────────────────────
module "loadbalancer" {
  source = "./loadbalancer"

  name              = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
  app_port          = var.app_port
  health_check_path = "/health"
  certificate_arn   = var.certificate_arn
  tags              = local.common_tags
}

# ── Compute ────────────────────────────────────────
module "compute" {
  source = "./compute"

  name              = local.name_prefix
  environment       = var.environment
  instance_type     = var.instance_type
  public_subnet_ids = module.vpc.public_subnet_ids
  app_sg_id         = module.security.app_sg_id
  target_group_arns = [module.loadbalancer.target_group_arn]
  docker_image      = var.docker_image
  min_size          = var.min_instances
  max_size          = var.max_instances
  desired_capacity  = var.desired_instances
  tags              = local.common_tags
}
