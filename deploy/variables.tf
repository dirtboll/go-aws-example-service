variable "app_name" {
  type        = string
  description = "The application name"
  default     = "news"
}

variable "app_image_tag" {
  type        = string
  description = "Image tag of the app to deploy"
}

variable "pgpool_image_tag" {
  type        = string
  description = "Image tag of the app to deploy"
}

variable "environment" {
  type        = string
  description = "Eenvironment if the infrastructure (production/staging/development)"
  default     = "Production"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the AWS VPC"
  default     = "10.0.0.0/16"
}

locals {
  vpc_cidr_suffix = tonumber(regex("([0-9]+)$", var.vpc_cidr)[0])
}

variable "subnet_cidr_suffix" {
  type        = number
  description = "The size of a single subnet in CIDR prefix (e.g. 16 for /16)"
  default     = 24
}

variable "asg_max_size" {
  type        = number
  description = "Auto Scaling Group maximum node size"
  default     = 2
}

variable "instance_type" {
  type        = string
  description = "Launch template instance type"
  default     = "t3.micro"
}

variable "instance_block_size" {
  type        = number
  description = "Launch template instance root disk size"
  default     = 30
}

variable "app_domain" {
  type        = string
  description = "The domain used to expose app in HTTPS"
}

variable "public_key" {
  type        = string
  description = "SSH public key for the instance"
  nullable    = true
}

variable "github_ref" {
  type        = list(string)
  description = "GitHub ref to be trusted for CI/CD (format: repo:<org>/<repo>:<branch-ref>)"
}
