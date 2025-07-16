locals {
  s3_bucket        = var.s3_bucket_name
}

data "aws_cloudfront_distribution" "helm_cdn" {
  id = var.cloudfront_distribution_id
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  
  client_id_list = [
    "sts.amazonaws.com",
  ]
  
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  
  tags = {
    Name = "GitHub Actions OIDC Provider"
  }
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-helm-deployment"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/heads/${var.github_branch}"
          }
        }
      }
    ]
  })
  
  tags = {
    Name = "GitHub Actions Helm Deployment Role"
  }
}

resource "aws_iam_policy" "github_actions" {
  name        = "GitHubActionsHelmDeploymentPolicy"
  description = "Policy for GitHub Actions to deploy Helm charts to S3 and invalidate CloudFront"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject", 
          "s3:DeleteObject",
          "s3:PutObjectAcl"
        ]
        Resource = "arn:aws:s3:::${local.s3_bucket}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${local.s3_bucket}"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = data.aws_cloudfront_distribution.helm_cdn.arn
      }
    ]
  })
  
  tags = {
    Name = "GitHub Actions Helm Deployment Policy"
  }
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
} 
