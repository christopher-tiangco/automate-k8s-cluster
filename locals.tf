locals {
  worker_nodes = { for node in var.worker_nodes : node.host => node }
  k3s = {
    download_url = "https://get.k3s.io",
    version      = "v1.25.4+k3s1"
  }
  k3s_master_node_url = "https://${var.master_node.host}:6443"
}