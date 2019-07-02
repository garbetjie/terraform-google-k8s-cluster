output "master_version" {
  value = google_container_cluster.cluster.master_version
  description = "Current version of the master in the cluster."
}

output "endpoint" {
  value = google_container_cluster.cluster.endpoint
  description = "IP address of this cluster's Kubernetes master."
}

output "instance_group_urls" {
  value = google_container_cluster.cluster.instance_group_urls
  description = "List of instance group URLs which have been assigned to the cluster."
}
