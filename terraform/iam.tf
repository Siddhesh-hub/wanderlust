# IAM Role for EC2 instances to allow them to interact with AWS services
resource "aws_iam_role" "eks_access_role" {
  name = "eks_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the AmazonEKSWorkerNodePolicy to the role
resource "aws_iam_role_policy" "eks_describe_policy" {
  role = aws_am_role.eks_access_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "*"
      }
    ]
  })
}

# Create an instance profile for the EC2 instances to use the IAM role
resource "aws_iam_instance_profile" "eks_instance_profile" {
  name = "eks-instance-profile"
  role = aws_iam_role.eks_access_role.name
}