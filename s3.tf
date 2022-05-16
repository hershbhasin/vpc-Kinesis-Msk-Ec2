 # Create a s3 bucket
 # Upload a jar file to it
 
#---------------------------------------------------------------------------------------------------------------------
# locals
# ---------------------------------------------------------------------------------------------------------------------

locals {
  suffix            = "756983"
  local_bucket_name = "${var.prefix}-bucket-${local.suffix}"
  
}

# ---------------------------------------------------------------------------------------------------------------------
# s3 bucket
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "example" {
  bucket = local.local_bucket_name
}

resource "aws_s3_bucket_object" "example" {
  bucket = aws_s3_bucket.example.bucket
  key    = var.jar_name
  source = var.jar_name
}