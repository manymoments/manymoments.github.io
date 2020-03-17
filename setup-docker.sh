# Make sure you have [Docker](https://www.docker.com/) installed.
docker build -t beautiful-jekyll "$PWD"
touch Gemfile.lock
chmod a+w Gemfile.lock
docker run -d -p 4000:4000 --name beautiful-jekyll -v "$PWD":/srv/jekyll beautiful-jekyll
