# Kubernetes Container Cluster Terraform Module (Google)

A simple module that makes it easy to create a container cluster consisting of both
[preemptible](https://cloud.google.com/preemptible-vms/) and non-preemptible nodes, with minimal effort.

The preemptible nodes have taints applied to them, to ensure that pods need to be explicitly tolerant of the preemptible
nodes before being executed on them.

> This module has an external data source that requires Python to be installed, and the `gcloud` command line tool to be
> available and configured for use.


## Usage

```hcl
module "my_cluster" {
  source = "garbetjie/k8s-cluster/google"
  
  name = "my-cluster"
  location = "europe-west4"
  min_master_version = "latest"
  master_ipv4_cidr_block = "172.16.0.0/28"
  
  node_pools = [
    {
      disk_size_gb = 50
      disk_type = "pd-standard"
      machine_type = "g1-small"
      labels = {}
    }
  ]
  
  preemptible_node_pools = [
    {
      disk_size_gb = 50
      disk_type = "pd-standard"
      machine_type = "n1-standard-1"
      labels = {
        node-stability = "preemptible"
      }
      taints = [
        {
          key = "node-stability"
          value = "preemptible"
          effect = "NoExecute"
        }
      ]
    }
  ]
}
```


## Inputs

| Name                      | Description                                                                                    | Type                                                          | Default                                                                     | Required |
|---------------------------|------------------------------------------------------------------------------------------------|---------------------------------------------------------------|-----------------------------------------------------------------------------|----------|
| name                      | Name of the Kubernetes cluster to create. This can be the same across different regions.       | string                                                        | n/a                                                                         | Yes      |
| location                  | Region/zone in which the cluster should be created.                                            | string                                                        | n/a                                                                         | Yes      |
| min_master_version        | Minimum Kubernetes version of the cluster master.                                              | string                                                        | `"latest"`                                                                  | No       |
| master_ipv4_cidr_block    | IP address block of the master. If left empty, it will be automatically generated for you.     | string                                                        | `""`                                                                        | No       |
| node_pools                | List of node pools to configure with non-preemptible instances. Structure is documented below. | list(object)                                                  | `[]`                                                                        | No       |
| node_pools[].disk_size_gb | Size of the node's disk (in GB).                                                               | number                                                        | `50`                                                                        | No       |
| node_pools[].disk_type    | Type of disk (can be one of `pd-standard` or `pd-ssd`)                                         | string                                                        | `"pd-standard"`                                                             | No       |
| node_pools[].machine_type | Class of machine to use.                                                                       | string                                                        | `"g1-small"`                                                                | No       |
| node_pools[].labels       | Map of labels to apply to node.                                                                | map(string)                                                   | `{}`                                                                        | No       |
| preemptible_node_pools    | List of node pools to configure with preemptible instances. Structure is documented below.     | list                                                          | `[]`                                                                        | No       |
| node_pools[].disk_size_gb | Size of the node's disk (in GB).                                                               | number                                                        | `50`                                                                        | No       |
| node_pools[].disk_type    | Type of disk (can be one of `pd-standard` or `pd-ssd`)                                         | string                                                        | `"pd-standard"`                                                             | No       |
| node_pools[].machine_type | Class of machine to use.                                                                       | string                                                        | `"n1-standard-1"`                                                           | No       |
| node_pools[].labels       | Map of labels to apply to node.                                                                | map(string)                                                   | `{}`                                                                        | No       |
| node_pools[].taints       | List of taints to apply to the node.                                                           | list(object({key = string, value = string, effect = string})) | `[{ key = "node-stability", value = "preemptible", effect = "NoExecute" }]` | No       |


## Outputs

| Name                | Type         | Description                                                          |
|---------------------|--------------|----------------------------------------------------------------------|
| master_version      | string       | Current version of the master in the cluster.                        |
| endpoint            | string       | IP address of this cluster's Kubernetes master.                      |
| instance_group_urls | list(string) | List of instance group URLs which have been assigned to the cluster. |
