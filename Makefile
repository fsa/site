serve:
	hugo server --bind 0.0.0.0 --port 1313 -D

build:
	hugo --minify

clean:
	rm -rf public/ resources/

.PHONY: serve build clean
