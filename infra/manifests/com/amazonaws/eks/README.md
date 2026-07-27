# `eks.caseysparkz.com`

These manifests deploy an EKS cluster to `us-west-2`.

## Usage

1. Run `terraform init`.
1. Run `terraform apply`.
1. Run `aws eks update-kubeconfig --name "$(terraform output -raw module.eks.cluster_name)"`
