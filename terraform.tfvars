aws_region        = "eu-north-1"
project           = "url-shortener"
environment       = "dev"
vpc_cidr          = "10.0.0.0/16"
azs               = ["eu-north-1a", "eu-north-1b"]
instance_type = "t3.micro"
app_port          = 8000
min_instances     = 1
max_instances     = 2
desired_instances = 1
docker_image      = "ghcr.io/panche20/url-shortener:v1.0.4"

