#----------------------------------------------------------------------------------------------------------------------
# Security Groups
# ---------------------------------------------------------------------------------------------------------------------
# resource "aws_security_group" "kda_sg" {
#   name        = "${var.prefix}-kda-sg"
#   description = "kda security group"
#   vpc_id      = aws_vpc.vpc.id

#   ingress {
#     description = "Inbound "
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     self        = true
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.prefix}-kda-sg"
#   }
# }


#----------------------------------------------------------------------------------------------------------------------
# Roles & Policies
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "kinesis_app_role" {
  name               = "${var.prefix}-kinesis_app_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "kinesisanalytics.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "kinesis_app_policy" {
  name   = "${var.prefix}-kinesis_app_permissions"
  role   = aws_iam_role.kinesis_app_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ReadCode",
            "Effect": "Allow",
            "Action": [
                "s3:*",   
                 "logs:*",       
                 "ec2:*"
                
            ],
            "Resource": "*"
        }
        
    ]
}
EOF
}
#----------------------------------------------------------------------------------------------------------------------
# Cloud watch
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "yada" {
  name = "/aws/kinesis-analytics/${var.prefix}-${var.destination_topic_1}"
}

resource "aws_cloudwatch_log_stream" "kinesis_app_log-1" {
  name           = "${var.prefix}-app-logstream-${var.destination_topic_1}"
  log_group_name = aws_cloudwatch_log_group.yada.name
}

resource "aws_cloudwatch_log_group" "yada2" {
  name = "/aws/kinesis-analytics/${var.prefix}-${var.destination_topic_2}"
}

resource "aws_cloudwatch_log_stream" "kinesis_app_log-2" {
  name           = "${var.prefix}-app-logstream-${var.destination_topic_2}"
  log_group_name = aws_cloudwatch_log_group.yada2.name
}


#----------------------------------------------------------------------------------------------------------------------
# Flink Application 1
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_kinesisanalyticsv2_application" "app1" {
  name                   = "${var.prefix}-kinesis_application-${var.destination_topic_1}"
  runtime_environment    = "FLINK-1_13"
  service_execution_role = aws_iam_role.kinesis_app_role.arn
  
  cloudwatch_logging_options {
      log_stream_arn = aws_cloudwatch_log_stream.kinesis_app_log-1.arn
    }

  application_configuration {
    
    application_code_configuration {
      code_content {
        s3_content_location {
          bucket_arn = aws_s3_bucket.example.arn
          file_key   = aws_s3_bucket_object.example.key
        }
      }

      code_content_type = "ZIPFILE"
    }

    vpc_configuration {
     
      security_group_ids = [aws_security_group.msk_client_sg.id,aws_security_group.msk_sg.id]

      subnet_ids         = [
        aws_subnet.public_subnets.0.id,
        aws_subnet.public_subnets.1.id,
        aws_subnet.public_subnets.2.id
      ]
    }


    environment_properties {
      property_group {
        property_group_id = "KafkaSource"

        property_map = {
          "bootstrap.servers"       = aws_msk_cluster.msk.bootstrap_brokers_tls
          "security.protocol"       = "SSL"
          "ssl.truststore.location" = "/usr/lib/jvm/java-11-amazon-corretto/lib/security/cacerts"
          "ssl.truststore.password" = "changeit"
          "topic"                   = var.source_topic
          "filter"                  = var.filter_1
          "group.id"                = "1"
        }
      }

      property_group {
        property_group_id = "KafkaSink"

        property_map = {
          "bootstrap.servers"       = aws_msk_cluster.msk.bootstrap_brokers_tls
          "security.protocol"       = "SSL"
          "ssl.truststore.location" = "/usr/lib/jvm/java-11-amazon-corretto/lib/security/cacerts"
          "ssl.truststore.password" = "changeit"
          "topic"                   = var.destination_topic_1
          "transaction.timeout.ms"  = "1000"
           "group.id"                = "2"
        }
      }
    }

    application_snapshot_configuration{
      snapshots_enabled = false
     }

    flink_application_configuration {
      checkpoint_configuration {
        configuration_type = "DEFAULT"
        checkpointing_enabled = true
      }

      monitoring_configuration {
        configuration_type = "CUSTOM"
        log_level          = "INFO"
        metrics_level      = "APPLICATION"
      }


      parallelism_configuration {
        auto_scaling_enabled = true
        configuration_type   = "CUSTOM"
        parallelism          = 1
        parallelism_per_kpu  = 1
      }
    }
  }

  tags = {
    Environment = "test"
  }
}

#----------------------------------------------------------------------------------------------------------------------
# Flink Application 2
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_kinesisanalyticsv2_application" "app2" {
  name                   = "${var.prefix}-kinesis_application-${var.destination_topic_2}"
  runtime_environment    = "FLINK-1_13"
  service_execution_role = aws_iam_role.kinesis_app_role.arn
  
  cloudwatch_logging_options {
      log_stream_arn = aws_cloudwatch_log_stream.kinesis_app_log-2.arn
    }

  application_configuration {
    
    application_code_configuration {
      code_content {
        s3_content_location {
          bucket_arn = aws_s3_bucket.example.arn
          file_key   = aws_s3_bucket_object.example.key
        }
      }

      code_content_type = "ZIPFILE"
    }

    vpc_configuration {
      
      security_group_ids = [aws_security_group.msk_client_sg.id,aws_security_group.msk_sg.id]
      subnet_ids         = [
        aws_subnet.public_subnets.0.id,
        aws_subnet.public_subnets.1.id,
        aws_subnet.public_subnets.2.id
      ]
    }


    environment_properties {
      property_group {
        property_group_id = "KafkaSource"

        property_map = {
          "bootstrap.servers"       = aws_msk_cluster.msk.bootstrap_brokers_tls
          "security.protocol"       = "SSL"
          "ssl.truststore.location" = "/usr/lib/jvm/java-11-amazon-corretto/lib/security/cacerts"
          "ssl.truststore.password" = "changeit"
          "topic"                   = var.source_topic
          "filter"                  = var.filter_2
        }
      }

      property_group {
        property_group_id = "KafkaSink"

        property_map = {
          "bootstrap.servers"       = aws_msk_cluster.msk.bootstrap_brokers_tls
          "security.protocol"       = "SSL"
          "ssl.truststore.location" = "/usr/lib/jvm/java-11-amazon-corretto/lib/security/cacerts"
          "ssl.truststore.password" = "changeit"
          "topic"                   = var.destination_topic_2
          "transaction.timeout.ms"  = "1000"
        }
      }
    }

    application_snapshot_configuration{
      snapshots_enabled = false
    }

    flink_application_configuration {
      checkpoint_configuration {
        configuration_type = "DEFAULT"
        checkpointing_enabled = true
      }

      monitoring_configuration {
        configuration_type = "CUSTOM"
        log_level          = "INFO"
        metrics_level      = "APPLICATION"
      }


      parallelism_configuration {
        auto_scaling_enabled = true
        configuration_type   = "CUSTOM"
        parallelism          = 1
        parallelism_per_kpu  = 1
      }
    }
  }

  tags = {
    Environment = "test"
  }
}

