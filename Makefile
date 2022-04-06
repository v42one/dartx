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

publish.confirm:
	PUB_HOSTED_URL=https://pub.dev melos publish --no-dry-run --yes

install.pubtidy:
	dart pub global activate --source path packages/pubtidy

tidy: install.pubtidy
	melos exec -c 1 -- "pubtidy"

dep:
	melos dep

clean:
	melos clean

fmt:
	melos format