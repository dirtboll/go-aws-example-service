data "aws_iam_policy_document" "ecs_node" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_node" {
  name_prefix        = "${local.application_name}${var.environment}ECSNode"
  assume_role_policy = data.aws_iam_policy_document.ecs_node.json
}

resource "aws_iam_role_policy_attachment" "ecs_node" {
  role       = aws_iam_role.ecs_node.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_node" {
  name_prefix = "${local.application_name}${var.environment}ECSNode"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs_node.name
}
