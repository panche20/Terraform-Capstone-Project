output "alb_dns_name" {
  value       = module.loadbalancer.alb_dns_name
  description = "Access your app at this URL"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnet_ids
}

output "private_subnets" {
  value = module.vpc.private_subnet_ids
}

output "asg_name" {
  value = module.compute.asg_name
}

output "ami_used" {
  value = module.compute.ami_id
}

output "app_url" {
  value       = "http://${module.loadbalancer.alb_dns_name}"
  description = "Application URL"
}
