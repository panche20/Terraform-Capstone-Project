variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ssh_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed SSH access"
  default     = ["0.0.0.0/0"] # restrict in prod!
}

variable "tags" {
  type    = map(string)
  default = {}
}
