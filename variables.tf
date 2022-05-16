
# ---------------------------------------------------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------------------------------------------------

variable "prefix" {
  description = "The prefix to be applied to all resources"
  default     = "poc-kda"
}

variable "region" {
  description = "The name of the region"
  default     = "us-east-2"
}

# ---------------------------------------------------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------------------------------------------------


variable "public_subnets" {
  type        = list(any)
  description = "The list of public subnets in VPC"
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------------------------------------------------------

variable "jar_name" {
  description = "The name of the jar to be uploaded to s3"
  default     = "kda-hershbhasin-2.0.jar"
}

# ---------------------------------------------------------------------------------------------------------------------
# Kinesis Analytics Application
# ---------------------------------------------------------------------------------------------------------------------


variable "source_topic" {
  description = "msk source topic"
  default     = "source"
}

variable "destination_topic_1" {
  description = "msk destination topic"
  default     = "account1"
}

variable "destination_topic_2" {
  description = "msk destination topic"
  default     = "account2"
}

variable "filter_1" {
  description = "filter 1"
  default     = "1"
}

variable "filter_2" {
  description = "filter 2"
  default     = "2"
}