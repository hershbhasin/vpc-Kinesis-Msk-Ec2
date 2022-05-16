# ---------------------------------------------------------------------------------------------------------------------
# outputs
# ---------------------------------------------------------------------------------------------------------------------

output "msk_cluster_arn" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.msk.arn
}


output "zookeeper_connect_string" {
  value = aws_msk_cluster.msk.zookeeper_connect_string
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.msk.bootstrap_brokers_tls
}


