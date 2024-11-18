resource "aws_route_table" "main_public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = provider::slugify::slug("${local.application_name}-${var.environment}-public")
    Environment = var.environment
  }
}

resource "aws_route_table_association" "main_public" {
  count = length(aws_subnet.main_public)
  route_table_id = aws_route_table.main_public.id
  subnet_id = aws_subnet.main_public[count.index].id
}

resource "aws_route_table" "main_private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = provider::slugify::slug("${local.application_name}-${var.environment}-private")
    Environment = var.environment
  }
}

resource "aws_route_table_association" "main_private" {
  count = length(aws_subnet.main_private)
  route_table_id = aws_route_table.main_private.id
  subnet_id = aws_subnet.main_private[count.index].id
}
