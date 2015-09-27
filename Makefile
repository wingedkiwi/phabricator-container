NAME = wingedkiwi/phabricator
VERSION = 0.0.1

.PHONY: all build run

all: build

run:
	docker run --rm -it -v `pwd`/config:/config $(NAME):$(VERSION)

run-mysql:
	docker run --rm -it -p 3306:3306 -e MYSQL_ROOT_PASSWORD=notasecret mariadb

run-bash:
	docker run --rm -it -v `pwd`/config:/config $(NAME):$(VERSION) /bin/bash

build:
	docker build -t $(NAME):$(VERSION) --rm .
