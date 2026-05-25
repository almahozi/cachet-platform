# 1. Trust the GitHub OIDC provider
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # Standard thumbprint for GitHub Actions
}

# 2. Define the CI/CD Role that GitHub will assume
resource "aws_iam_role" "github_actions" {
  name = "cachet-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub": "repo:almahozi/cachet-platform:*"
        }
      }
    }]
  })
}

# 3. Allow this role to trigger commands on your EC2 instance via SSM
resource "aws_iam_role_policy" "ssm_send_command" {
  name = "allow-ssm-send-command"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "ssm:SendCommand"
      Resource = ["arn:aws:ssm:*:*:document/AWS-RunShellScript", "arn:aws:ec2:*:*:instance/*"]
    }]
  })
}

resource "aws_iam_role_policy" "describe_ec2_instances" {
  name = "allow-describe-ec2-instances"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
        Action   = ["ec2:DescribeInstances"]
        Resource = ["*"]
    }]
  })
}