# azure-solution-geo-failover

A demo application to practice failover across geo-locations.

## Deployment

Login to Azure:

```sh
az login
```
Deploy the infrastructure:

```sh
terraform -chdir='infrastructure' init
terraform -chdir='infrastructure' apply -auto-approve
```

Create the secrets and configuration:

```sh
terraform -chdir='infrastructure/kubernetes' init
terraform -chdir='infrastructure/kubernetes' apply -auto-approve
```

Connect to the Kubernetes cluster:

```sh
az aks get-credentials \
  -g 'rg-openvote555-westus' \
  -n 'aks-openvote555-westus'
```

Deploy the applications and services:

```
kubectl apply -f kubernetes.yaml
```

## Local Development

### Resources

```sh
docker run -d --name mongodb -p 27017:27017 mongo
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

## Local development with Cloud resources

This will create the necessary resources to develop locally but with Azure resources instead of locals, which is useful to test before pushing for integration testing.

```sh
terraform -chdir='infrastructure/development' init
terraform -chdir='infrastructure/development' apply -auto-approve
```

Set the Key Vault URI to your `.env` file.

Authentication works via local context, so you must be connected with `az login`. Microsoft SDKs will automatically detect the authenticated context when connecting to the Key Vault.


## Docker Development

```
docker build --tag poll .
docker build --tag vote .

docker run -p 4000:8080 --name poll-app poll
docker run -p 5000:8080 --name vote-app vote
```

With compose:

```sh
docker-compose build
docker-compose up
```

## Minikube

```sh
minikube start
minikube addons enable ingress

kubectl apply -f kubernetes/minikube/mongo.yaml
kubectl apply -f kubernetes/kubernetes.yaml
kubectl apply -f kubernetes/minikube/nginx-ingress.yaml

minikube tunnel
```

### Minikube with Cloud Resources

To use Minikube with Azure real resources, create the appropriate Config Maps and Secrets:

```sh
kubectl create secret generic solution-secrets --from-literal=COSMOSDB_CONNECTION_STRING="$COSMOSDB_CONNECTION_STRING"
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
http://pylint-messages.wikidot.com/all-messages
```