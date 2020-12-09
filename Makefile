.PHONY: install test

install:
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
	bundle exec pod lib lint --quick

publish:
	bundle exec pod trunk push RFIBAN-Helper.podspec
