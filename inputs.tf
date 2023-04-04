variable "master_node" {
  description = "k8s master control plane"
  type = object({
    host        = string
    user        = string
    private_key = string
  })
}

variable "worker_nodes" {
  description = "Multiple k8s data plane"
  type = list(object({
    host     = string
    user     = string
    hostname = string
  }))
  default = []
}