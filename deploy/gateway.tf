resource "aws_internet_gateway" "main" {
  tags = {
    Name = provider::slugify::slug("${local.application_name}-${var.environment}")
    Environment = var.environment
  }
}

resource "aws_internet_gateway_attachment" "main" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id = aws_vpc.main.id
}

resource "aws_egress_only_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = provider::slugify::slug("${local.application_name}-${var.environment}")
    Environment = var.environment
  }
}

resource "aws_route" "main_public" {
  route_table_id = aws_route_table.main_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route" "main_public_ipv6" {
  route_table_id = aws_route_table.main_public.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id = aws_egress_only_internet_gateway.main.id
}