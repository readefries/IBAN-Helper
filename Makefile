.PHONY: install test

install:
	gem install bundler --install-dir vendor/gems
	bundle config set path 'vendor/bundle'
	bundle install

import:
	./import.sh

clean:
	rm -rf vendor/
	rm -rf Pods/

test:
	swift build && swift test

validate:
	bundle exec pod lib lint --quick --allow-warnings

publish:
	bundle exec pod trunk push RFIBAN-Helper.podspec --allow-warnings
