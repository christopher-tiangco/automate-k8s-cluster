# Provisioning a Kubernetes cluster via Terraform

Terraform configuration for setting up a Kubernetes cluster using Rancher's k3s.

## Prerequisites
- Terraform CLI
- At least two Linux machines, one designated as the master node and the other as a worker node
- The host that's running the Terraform CLI can SSH to the master node without using a password
- Master node can SSH to the worker node(s) without using a password

## Important
- I wrote this configuration so I can automate setting up Kubernetes cluster into my Raspberry Pi 4s. Setting up networking and enabling container features for the Pis are beyond the scope of this configuration. The configuration hopefully can be applied to other non-Pi environments.
- Make sure to add an `inputs.tfvars` file (which is set to be ignored by the repository) for setting the server targets. Below is the format:
```
master_node = {
  host        = "`ip address of the master node`"
  private_key = "`path/filename of the ssh private key for root user`"
  user        = "root"
}

worker_nodes = [{
  host     = "`ip address of the worker node`"
  user     = "root"
  hostname = "`any hostname that is uniquely named`"
  }
]
```
- NOTE: The `worker_nodes` variable above is a list of objects. Add more objects if using more than one worker nodes
- If a different version of Kubernetes is needed, modify `k3s.version` @ `locals.tf`.
- By default, k3s use `traefik` for ingress controller. I disabled it for this configuration as I will be using `ingress-nginx`.
- To run the configuration, simply do the following commands
```
terraform init
terraform apply -var-file="inputs.tfvars"
```
