.PHONY: install test

# Install Ruby dependencies
# Note: Requires ruby-dev package for native extensions: sudo apt-get install ruby-dev
BUNDLE_PATH := $(shell ruby -e 'puts File.join(Gem.user_dir, "bin", "bundle")')

install:
	@echo "Installing Ruby dependencies..."
	@echo "Note: If installation fails, install ruby-dev: sudo apt-get install ruby-dev"
	gem install bundler
	$(BUNDLE_PATH) config set --local path 'vendor/bundle'
	$(BUNDLE_PATH) install
	gem install bundler --install-dir vendor/gems
	bundle config set path 'vendor/bundle'
	bundle install

import:
	./import.php

clean:
	rm -rf vendor/
	rm -rf Pods/

test:
	xcodebuild test -project Example/RFIBANHelper.xcodeproj -scheme RFIBANHelper build test -destination platform='iOS Simulator,name=iPhone 11,OS=latest'

validate:
	$(BUNDLE_PATH) exec pod lib lint --quick --allow-warnings

publish:
	$(BUNDLE_PATH) exec pod trunk push RFIBAN-Helper.podspec --allow-warnings
