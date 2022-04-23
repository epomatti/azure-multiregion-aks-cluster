# azure-solution-geo-failover

A demo application to practice failover to different Geo-locations.

```hcl
az login

terraform init
terraform plan
terraform apply -auto-approve
```

```sh
sudo az aks install-cli
```
```sh
az aks get-credentials -g $group -n $aks
kubectl get nodes

kubectl apply -f k8s.yaml
kubectl get services --watch
```

### Local Development

```hcl
terraform fmt -check
terraform validate
```