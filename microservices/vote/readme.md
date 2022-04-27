export FLASK_APP=src/app.py
python3 -m flask

export FLASK_ENV=development

flask run --host=0.0.0.0






docker build --tag vote .

docker run --publish 5000:5000 --name vote-app vote
docker



https://sourcery.ai/blog/python-docker/