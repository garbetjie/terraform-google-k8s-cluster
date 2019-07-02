variable "name" {
  type = string
  description = "Name of the Kubernetes cluster to create. This can be the same across different regions."
}

variable "location" {
  type = string
  description = "Region/zone in which the cluster should be created."
}

variable "master_ipv4_cidr_block" {
  type = string
  default = ""
  description = "Minimum Kubernetes version of the cluster master."
}

variable "min_master_version" {
  type = "string"
  default = "latest"
  description = "Minimum Kubernetes version of the cluster master."
}

variable "node_pools" {
  type = list
  default = []
  description = "List of node pools to configure with non-preemptible instances."
}
