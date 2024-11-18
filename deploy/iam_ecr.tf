

resource "aws_iam_role" "ecr_push" {
  name = "ECRPush"
  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect  = "Allow"
        Action  = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = var.github_ref
          }
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "ecr_push_policy" {
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecr_push" {
  policy = data.aws_iam_policy_document.ecr_push_policy.json
  name   = "ECRPush"
}

resource "aws_iam_role_policy_attachment" "ecr_push" {
  policy_arn = aws_iam_policy.ecr_push.arn
  role       = aws_iam_role.ecr_push.name
}
