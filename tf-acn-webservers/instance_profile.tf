############################################# TERRAFORM #############################################
resource "aws_iam_role" "ec2_role" {
  name = "tf-ec2-assume-role${random_string.suffix.result}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "tf-ec2-instance-role${random_string.suffix.result}"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "nodegroup_role_attachment_1" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}
