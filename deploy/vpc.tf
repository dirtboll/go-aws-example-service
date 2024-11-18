resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = provider::slugify::slug("${local.application_name}-${var.environment}")
    Environment = var.environment
  }
}

resource "aws_subnet" "main_public" {
  
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, var.subnet_cidr_suffix - local.vpc_cidr_suffix, 3 + count.index)
  map_public_ip_on_launch = true
  tags = {
    Name        = provider::slugify::slug("${local.application_name}-${var.environment}-public-${data.aws_availability_zones.available.names[count.index]}")
    Environment = var.environment
  }
}

resource "aws_subnet" "main_private" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, var.subnet_cidr_suffix - local.vpc_cidr_suffix, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name        = provider::slugify::slug("${local.application_name}-${var.environment}-private-${data.aws_availability_zones.available.names[count.index]}")
    Environment = var.environment
  }
}
