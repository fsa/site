#!/bin/bash

# Gemfile lock has to be owned by apache:apache
touch ./Gemfile.lock
chmod a+w ./Gemfile.lock

# Jekyll runs as Apache
podman run -it --rm --name jekyll \
  -v ./:/srv/jekyll:rw,slave,Z \
  --publish 4000:4000 \
  -e JEKYLL_UID=1000 \
  -e JEKYLL_GID=1000 \
  docker.io/jekyll/jekyll:4.1.0 \
  jekyll serve --drafts --trace