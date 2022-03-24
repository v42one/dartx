bootstrap:
	dart pub global activate melos && melos bootstrap

gen:
	melos generate

lint:
	melos analyze --no-select

test:
	melos test --no-select

publish:
	PUB_HOSTED_URL=https://pub.dev melos publish

dep:
	melos dep

clean:
	melos clean

fmt:
	melos format