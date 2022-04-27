

```sh
docker run -d --name mongodb -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=app \
  -e MONGO_INITDB_ROOT_PASSWORD=devpass \
  mongo
```


https://github.com/pypa/setuptools/issues/3278

pipenv install

export SETUPTOOLS_USE_DISTUTILS=stdlib
