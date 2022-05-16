
# ---------------------------------------------------------------------------------------------------------------------
# data
# ---------------------------------------------------------------------------------------------------------------------

data "aws_ami" "amazon-linux-2" {
 most_recent = true
 owners      = ["amazon"]


 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

# ---------------------------------------------------------------------------------------------------------------------
# ec2
# ---------------------------------------------------------------------------------------------------------------------
#terraform destroy -target aws_instance.ec2

resource "aws_instance" "ec2" {
  ami           = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "t2.medium"
  subnet_id = aws_subnet.public_subnets.3.id
  vpc_security_group_ids = [aws_security_group.msk_client_sg.id]
  # user_data = "${file("ec2_config.sh")}"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  tags = {
    Name = "${var.prefix}-ec2"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# security groups
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "msk_client_sg" {
  name        = "${var.prefix}-msk-client-sg"
  description = "security group for msk clients"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Inbound to msk client"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Outbound to msk "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-msk-client-sg"
  }
}


# allow ec2 sg to access default sg where msk runs
# resource "aws_security_group_rule" "add-ec2sg-to-defaultsg" {
#   type = "ingress"
#   from_port = 0
#   to_port = 0
#   protocol = -1
#   security_group_id = aws_default_security_group.default.id
#   source_security_group_id = aws_security_group.ec2_sg.id
# }

# ---------------------------------------------------------------------------------------------------------------------
# Roles & policy
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "ec2_role" {
  name               = "${var.prefix}-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        }
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "ec2_policy" {
  name   = "${var.prefix}-ec2-policy"
  role   = aws_iam_role.ec2_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kafka:*",
        "es:*",
        "ec2:DescribeInstances",
        "dynamodb:ListTables",
        "ec2messages:GetEndpoint",
        "ssmmessages:OpenControlChannel",
        "ec2messages:GetMessages",
        "ssm:ListInstanceAssociations",
        "ec2:DescribeSnapshots",
        "ssm:UpdateAssociationStatus",
        "ec2messages:DeleteMessage",
        "ssm:UpdateInstanceInformation",
        "ec2messages:FailMessage",
        "ssmmessages:OpenDataChannel",
        "dynamodb:GetItem",
        "ssm:GetParametersByPath",
        "dynamodb:BatchGetItem",
        "ssm:DescribeAssociation",
        "logs:DescribeLogGroups",
        "dynamodb:PutItem",
        "dynamodb:Scan",
        "ec2messages:AcknowledgeMessage",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "ssm:GetParameters",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ec2:DescribeImages",
        "ec2messages:SendReply",
        "ssm:ListAssociations",
        "ssm:UpdateInstanceAssociationStatus",
        "dynamodb:GetRecords",
        "logs:*",
        "secretsmanager:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.prefix}-ec2-profile"
  role = "${aws_iam_role.ec2_role.name}"
}
