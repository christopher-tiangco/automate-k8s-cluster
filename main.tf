# Uncomment this if using Ubuntu 22.04 at the master node as its default iptables conflict with k3s CoreDNS
# See https://slack-archive.rancher.com/t/10027691/anyone-else-run-into-issues-with-ubuntu-22-04-and-coredns-dn
#resource "ssh_resource" "use_legacy_iptables" {
#  host        = var.master_node.host
#  user        = var.master_node.user
#  private_key = file(var.master_node.private_key)
#  timeout     = "10m"
#  commands = [
#    "sudo update-alternatives --set iptables /usr/sbin/iptables-legacy",
#  ]
#}

resource "ssh_resource" "install_k3s_to_master" {
  # depends_on  = [ssh_resource.use_legacy_iptables] # Uncomment this if using Ubuntu 22.04 (see above)
  host        = var.master_node.host
  user        = var.master_node.user
  private_key = file(var.master_node.private_key)
  timeout     = "10m"
  commands = [
    "apt update",
    "apt install curl -y",
    "curl -sfL ${local.k3s.download_url} | INSTALL_K3S_VERSION=${local.k3s.version} sh -s - server --write-kubeconfig-mode 644 --disable=traefik",
    "echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc"
  ]
}

resource "ssh_resource" "uninstall_k3s_from_master" {
  when        = "destroy"
  host        = var.master_node.host
  user        = var.master_node.user
  private_key = file(var.master_node.private_key)
  commands    = ["bash -c 'k3s-killall.sh; k3s-uninstall.sh;'"]
}

resource "ssh_resource" "export_k3s_master_token" {
  depends_on  = [ssh_resource.install_k3s_to_master]
  host        = var.master_node.host
  user        = var.master_node.user
  private_key = file(var.master_node.private_key)
  timeout     = "1m"
  commands    = ["cat /var/lib/rancher/k3s/server/node-token"]
}

resource "ssh_resource" "install_k3s_to_workers" {
  depends_on  = [ssh_resource.export_k3s_master_token]
  for_each    = local.worker_nodes
  host        = each.value.host
  user        = each.value.user
  private_key = file(var.master_node.private_key)
  commands = [
    "apt update",
    "apt install curl -y",
    "curl -sfL ${local.k3s.download_url} | INSTALL_K3S_VERSION=${local.k3s.version} K3S_NODE_NAME=${each.value.hostname} K3S_URL=${local.k3s_master_node_url} K3S_TOKEN=${chomp(ssh_resource.export_k3s_master_token.result)} sh -"
  ]
}

resource "ssh_resource" "uninstall_k3s_from_workers" {
  when        = "destroy"
  for_each    = local.worker_nodes
  host        = each.value.host
  user        = each.value.user
  private_key = file(var.master_node.private_key)
  commands    = ["bash -c 'k3s-killall.sh; k3s-agent-uninstall.sh;'"]
}
