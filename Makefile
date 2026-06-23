backup:
	for server in $$(git remote -v | cut -f1 | uniq) ; do \
		if [[ $$server != "origin" ]] ; then \
			echo "git push $$server"; git push $$server ; \
		fi \
	done

backup-tags:
	for server in $$(git remote -v | cut -f1 | uniq) ; do \
		if [[ $$server != "origin" ]] ; then \
			echo "git push $$server --tags"; git push $$server --tags ; \
		fi \
	done

serve:
	hugo server --bind 0.0.0.0 --port 1313 -D

build:
	hugo --minify

clean:
	rm -rf public/ resources/

.PHONY: backup backup-tags serve build clean
