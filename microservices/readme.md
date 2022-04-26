

```sh
docker run -d --name mongodb -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=app \
  -e MONGO_INITDB_ROOT_PASSWORD=devpass \
  mongo
```

pipenv install --python 3.6