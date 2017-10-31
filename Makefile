.PHONY: install test

install:
	bundle install --path vendor/bundle

clean:
	rm -rf vendor/
	rm -rf Pods/

test:
	xcodebuild test -project Example/RFIBANHelper.xcodeproj -scheme RFIBANHelper build test -destination platform='iOS Simulator,name=iPhone 7,OS=latest'
	bundle exec pod lib lint --quick
