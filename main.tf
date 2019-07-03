data google_project project {

}

data external master_ipv4_cidr_block {
  program = ["python", "${path.module}/get_next_master_ipv4_cidr_block.py"]
  query = {
    project = data.google_project.project.project_id
    location = var.location
    cluster = var.name
  }
}

resource google_container_cluster cluster {
  name = var.name
  remove_default_node_pool = true
  initial_node_count = 1
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
    enable_private_nodes = var.enable_private_nodes
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

resource google_container_node_pool pools {
  count = length(var.node_pools)

  name_prefix = lookup(var.node_pools[count.index], "name", "") != "" && lookup(var.node_pools[count.index], "name", "") != null ? format("%s-", var.node_pools[count.index].name) : null
  cluster = google_container_cluster.cluster.name
  location = var.location
  initial_node_count = lookup(var.node_pools[count.index], "node_count", 1)

  management {
    auto_repair = true
    auto_upgrade = true
  }

  dynamic "autoscaling" {
    for_each = contains(keys(var.node_pools[count.index]), "autoscaling") ? [var.node_pools[count.index].autoscaling] : []

    content {
      min_node_count = lookup(autoscaling.value, "min_node_count", lookup(var.node_pools[count.index], "node_count", 1))
      max_node_count = autoscaling.value.max_node_count
    }
  }

  node_config {
    disk_size_gb = lookup(var.node_pools[count.index], "disk_size_gb", 50)
    disk_type = lookup(var.node_pools[count.index], "disk_type", "pd-standard")
    image_type = "COS"
    machine_type = lookup(var.node_pools[count.index], "machine_type", "g1-small")
    preemptible = lookup(var.node_pools[count.index], "preemptible", false)
    labels = lookup(
      var.node_pools[count.index],
      "labels",
      lookup(var.node_pools[count.index], "preemptible", false) ? { node-stability="preemptible" } : {}
    )

    dynamic "taint" {
      for_each = lookup(
        var.node_pools[count.index],
        "taints",
        lookup(var.node_pools[count.index], "preemptible", false) ?
          [{ key="node-stability", value="preemptible", effect="NO_EXECUTE" }] :
          []
      )

      content {
        key = taint.value.key
        value = taint.value.value
        effect = taint.value.effect
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
