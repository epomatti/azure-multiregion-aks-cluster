# azure-solution-geo-failover

A demo application to practice failover to different Geo-locations.

```hcl
az login

terraform init
terraform plan
terraform apply -auto-approve
```


### Local Development

```hcl
terraform fmt -check
terraform validate
```