# Kubernetes Container Cluster Terraform Module (Google)

A simple module that makes it easy to create a container cluster consisting of both
[preemptible](https://cloud.google.com/preemptible-vms/) and non-preemptible nodes, with minimal effort.

The preemptible nodes have taints applied to them, to ensure that pods need to be explicitly tolerant of the preemptible
(referred to as "unstable" in this module). 
