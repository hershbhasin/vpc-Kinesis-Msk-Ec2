
# ---------------------------------------------------------------------------------------------------------------------
# msk cluster security group
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "msk_sg" {
  name        = "${var.prefix}-msk-sg"
  description = "msk security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
    security_groups  = [ aws_security_group.msk_client_sg.id ] # allow inbound from ec2, KDA   
   
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-ec2-sg"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# msk cluster
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "msk_cw" {
  name = "${var.prefix}-msk_broker_logs"
}

resource "aws_msk_cluster" "msk" {
  cluster_name           = "${var.prefix}-msk-cluster"
  kafka_version          = "2.8.1"
  number_of_broker_nodes = 3
  enhanced_monitoring    = "PER_TOPIC_PER_BROKER"

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    ebs_volume_size = 1000
    client_subnets = [
      aws_subnet.public_subnets.0.id,
      aws_subnet.public_subnets.1.id,
      aws_subnet.public_subnets.2.id

    ]
   
    security_groups = [aws_security_group.msk_sg.id]
  }
  encryption_info {

    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_cw.name
      }

    }
  }


}
