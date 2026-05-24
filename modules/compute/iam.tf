# Define the Trust Policy (Allows EC2 to assume this role)

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create the IAM Role
resource "aws_iam_role" "ssm_role" {
  name               = "cachet-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Attach the AWS Managed Policy for SSM
resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create the Instance Profile
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "cachet-ssm-profile"
  role = aws_iam_role.ssm_role.name
}