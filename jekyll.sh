#!/bin/bash

touch ./Gemfile.lock
chmod a+w ./Gemfile.lock

podman run -it --rm --name jekyll \
  -v ./:/srv/jekyll:rw,slave,Z \
  --publish 4000:4000 \
  -e JEKYLL_UID=1000 \
  -e JEKYLL_GID=1000 \
  docker.io/jekyll/jekyll:4 \
  jekyll serve --drafts
