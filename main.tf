data google_project project {

}

data external master_ipv4_cidr_block {
  program = ["python", "${path.module}/get_next_master_ipv4_cidr_block.py"]

  query {
    project = data.google_project.project.project_id
    location = var.location
    cluster = var.name
  }
}

resource google_container_cluster cluster {
  name = var.name
  remove_default_node_pool = true
  node_count = 1
  location = var.location
  min_master_version = var.min_master_version

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
    }
  }

  ip_allocation_policy {
    create_subnetwork = true
  }

  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = coalesce(var.master_ipv4_cidr_block, data.external.master_ipv4_cidr_block.result.cidr_block)
  }

  addons_config {
    kubernetes_dashboard {
      disabled = true
    }
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource google_container_node_pool stable {
  count = length(var.node_pools)

  name_prefix = format("%s-stable-", var.name)
  cluster = google_container_cluster.cluster.name
  location = var.location

  node_config {
    disk_size_gb = lookup(var.node_pools[count.index], "disk_size_gb", var.node_pool_defaults.disk_size_gb)
    disk_type = lookup(var.node_pools[count.index], "disk_type", var.node_pool_defaults.disk_type)
    image_type = "COS"
    machine_type = lookup(var.node_pools[count.index], "machine_type", var.node_pool_defaults.machine_type)
    preemptible = false
    labels = lookup(var.node_pools[count.index], "labels", var.node_pool_defaults.labels)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource google_container_node_pool unstable {
  count = length(var.unstable_node_pools)

  name_prefix = format("%s-unstable-", var.name)
  cluster = google_container_cluster.cluster.name
  location = var.location

  node_config {
    disk_size_gb = lookup(var.unstable_node_pools[count.index], "disk_size_gb", var.unstable_node_pool_defaults.disk_size_gb)
    disk_type = lookup(var.unstable_node_pools[count.index], "disk_type", var.unstable_node_pool_defaults.disk_type)
    image_type = "COS"
    machine_type = lookup(var.unstable_node_pools[count.index], "machine_type", var.unstable_node_pool_defaults.machine_type)
    preemptible = true
    labels = lookup(var.unstable_node_pools[count.index], "labels", var.unstable_node_pool_defaults.labels)
    taint = lookup(var.unstable_node_pools[count.index], "taints", var.unstable_node_pool_defaults.taints)
  }

  lifecycle {
    create_before_destroy = true
  }
}
