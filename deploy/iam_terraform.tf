

resource "aws_iam_role" "terraform" {
  name = "Terraform"
  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = var.github_ref
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.terraform.name
}
