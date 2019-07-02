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
  type = object({
    disk_size_gb = number
    disk_type = string
    machine_type = string
    labels = map(string)
  })

  default = {
    disk_size_gb = 50
    disk_type = "pd-standard"
    machine_type = "g1-small"
    labels = { node-stability = "stable" }
  }
}

variable "unstable_node_pools" {
  type = list
  default = []
}

variable "unstable_node_pool_defaults" {
  type = object({
    disk_size_gb = number
    disk_type = string
    machine_type = string
    labels = map(string)
    taints = list(object({ key = string, value = string, effect = string}))
  })

  default = {
    disk_size_gb = 50
    disk_type = "pd-standard"
    machine_type = "g1-small"
    labels = { node-stability = "unstable" }
    taints = [{
      key = "node-stability"
      value = "unstable"
      effect = "NoExecute"
    }]
  }
}
