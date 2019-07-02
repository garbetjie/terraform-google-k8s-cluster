variable "name" {
  type = string
}

variable "location" {
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

variable "node_pools" {
  type = list
  default = []
}

variable "preemptible_node_pools" {
  type = list
  default = []
}
