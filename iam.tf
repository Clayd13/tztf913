resource "aws_iam_role" "manage_ec2_tags" {
  name = "show_ec2_tags"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_policy" "manage_ec2_tags" {
  name        = "manage_ec2_tags"
  path        = "/"
  description = "policy_for_manage_ec2_tags"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action = [
          "ec2:CreateTags",
          "ec2:DescribeTags"
        ]
        Effect = "Allow"
        # Resource = "arn:aws:ec2:*:*:instance/*"
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "manage_ec2_tags" {
  role       = aws_iam_role.manage_ec2_tags.name
  policy_arn = aws_iam_policy.manage_ec2_tags.arn
}

resource "aws_iam_instance_profile" "manage_ec2_tags_profile" {
  name = "manage_ec2_tags"
  role = aws_iam_role.manage_ec2_tags.name
}


