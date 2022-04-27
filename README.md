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

## Local Development

### Resources

```sh
docker run -d --name mongodb -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=app \
  -e MONGO_INITDB_ROOT_PASSWORD=devpass \
  mongo
```

### Python Microservices

```sh
# Creates venv in project, same as PIPENV_VENV_IN_PROJECT=1
mkdir .venv

# Ad-hoc fix for https://github.com/pypa/setuptools/issues/3278
export SETUPTOOLS_USE_DISTUTILS=stdlib

# get the dependencies
pipenv install

# start
export FLASK_ENV=development
export FLASK_APP=src/app.py
python3 -m flask run --host=0.0.0.0
```

### Terraform

```sh
# 
terraform init
terraform plan
terraform apply -auto-approve

# 
terraform fmt -check
terraform validate
```

## Docker Development

docker build --tag vote .

docker run --publish 5000:5000 --name vote-app vote


## Sources

```
https://sourcery.ai/blog/python-docker/
```