# azure-solution-geo-failover

A demo application to practice failover across geo-locations.

## Deployment

Login to Azure:

```sh
az login
```
Create the infrastructure:

```sh
cd ./infrastructure

terraform init
terraform plan
terraform apply -auto-approve
```

Connect to the Kubernetes cluster:

```sh
az aks get-credentials -g 'rg-openvote555-westus' -n 'aks-openvote555-westus'

kubectl get nodes
```

Setup the credentials resources:

```sh
cp __config__/empty-secrets.env secrets.env

kubectl create secret generic solution-secrets --from-env-file=secrets.env
```

Deploy the applications and services:

```
kubectl apply -f kubernetes.yaml
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
pipenv install --dev

# start
python3 -m flask run
```

### Frontend

```sh
yarn install
yarn dev -o
```

### Terraform

```sh
terraform init
terraform plan
terraform apply -auto-approve
```

## Docker Development

docker build --tag poll .
docker build --tag vote .

docker run -p 4000:8080 --name poll-app poll
docker run -p 5000:8080 --name vote-app vote

With compose:

```sh
docker-compose build
docker-compose up
```

## Minikube

```
minikube start
minikube addons enable ingress
kubectl create secret generic solution-secrets --from-env-file=secrets.env
```

## Sources

```
https://pipenv-fork.readthedocs.io/en/latest/basics.html
https://sourcery.ai/blog/python-docker/
https://stackoverflow.com/questions/24238743/flask-decorator-to-verify-json-and-json-schema
https://docs.microsoft.com/en-us/azure/aks/concepts-network
https://docs.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new
https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview
https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/secure-baseline-aks
https://azure.github.io/application-gateway-kubernetes-ingress/how-tos/networking/
https://github.com/Azure/AKS/releases/tag/2022-02-24
https://docs.microsoft.com/en-us/azure/aks/configure-kubenet
https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-log-query
https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-add-health-probes
```