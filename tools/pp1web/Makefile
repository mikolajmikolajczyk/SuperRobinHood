IMAGE := ghcr.io/mikolaj/pp1web
TAG   := latest

.PHONY: dev build preview docker push clean

dev:
	npm run dev

build:
	npm run build

preview: build
	npm run preview

docker:
	docker build -t $(IMAGE):$(TAG) .

push: docker
	docker push $(IMAGE):$(TAG)

clean:
	rm -rf dist node_modules
