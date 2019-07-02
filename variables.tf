variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "address_link" {
  type = string
}

variable "master_ipv4_cidr_block" {
  type = string
  default = ""
}

variable "min_master_version" {
  type = "string"
  default = "latest"
}

variable "stable_node_pools" {
  type = list
  default = []
}

variable "stable_node_pool_defaults" {
  type = object
  default = {
    disk_size_gb = 50
    disk_type = "pd-standard"
    machine_type = "g1-small"
    preemptible = false
    labels = {}
  }
}

variable "unstable_node_pools" {
  type = list
  default = []
}

variable "unstable_node_pool_taint" {
  type = object({ key = string, value = string, effect = string})
  default = {
    key = "node-stability"
    value = "unstable"
    effect = "NoExecute"
  }
}
