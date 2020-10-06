.PHONY: install test

install:
	bundle config set path 'vendor/bundle'
	bundle install

clean:
	rm -rf vendor/
	rm -rf Pods/

test:
	xcodebuild test -project Example/RFIBANHelper.xcodeproj -scheme RFIBANHelper build test -destination platform='iOS Simulator,name=iPhone 7,OS=latest'
	bundle exec pod lib lint --quick

publish:
	bundle exec pod trunk push RFIBAN-Helper.podspec
