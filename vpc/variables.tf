variable "name" {
  type        = string
  description = "Name prefix for all VPC resources"
}

variable "cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
