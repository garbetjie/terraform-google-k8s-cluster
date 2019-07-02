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
