-include .env.local

serve:
	hugo server --bind 0.0.0.0 --port 1313 -D

deploy: build rsync

build:
	hugo --minify

rsync:
	@test -n "$(DEPLOY_PATH)" || (echo "DEPLOY_PATH is required" && exit 1)
	rsync -aHv public/ ${DEPLOY_PATH}

clean:
	rm -rf public/ resources/

.PHONY: serve build clean deploy rsync

