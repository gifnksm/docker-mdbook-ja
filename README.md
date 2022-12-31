# docker-mdbook-ja

Dockerfile including [mdBook] and tools for writing Japanese technical documentation.

This container contains the following tools:

* [mdBook]
* [mdbook-mermaid](https://github.com/badboy/mdbook-mermaid)
* [mdbook-linkcheck](https://github.com/Michael-F-Bryan/mdbook-linkcheck)
* [mdbook-pdf](https://github.com/HollowMan6/mdbook-pdf)
* [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli)
* [textlint](https://textlint.github.io/)
* cargo (for `mdbook test`)

[mdBook]: https://github.com/rust-lang/mdBook

## Container Image

The following pre-built images are available:

* [`ghcr.io/gifnksm/mdbook-ja`](https://github.com/gifnksm/docker-mdbook-ja/pkgs/container/mdbook-ja) (GitHub Container Registry)
* [`registry.gitlab.com/gifnksm/docker-mdbook-ja`](https://gitlab.com/gifnksm/docker-mdbook-ja/container_registry/3281810) (GitLab Container Registry)

## Usage

Running with Docker:

```console
# running mdBook
$ docker run \
    -it --rm --init --user $(id -u):$(id -g) -v $(pwd):/book:rw --net host \
    ghcr.io/gifnksm/mdbook-ja \
    mdbook serve

# running markdown lint
$ docker run \
    -it --rm --init --user $(id -u):$(id -g) -v $(pwd):/book:rw --net host \
    ghcr.io/gifnksm/mdbook-ja \
    markdownlint .
```

You can also use Compose:

```yaml
# docker-compose.ymlversion: '3.9'

x-service:
  &default-service
  image: ghcr.io/gifnksm/mdbook-ja
  init: true
  volumes: [".:/book:rw"]
  network_mode: "host"
  user: "${UID}:${GID}"

services:
  mdbook:
    <<: *default-service
    entrypoint: ["mdbook"]
    command: ["serve"]

  mdbook-mermaid:
    <<: *default-service
    entrypoint: ["mdbook-mermaid"]

  markdownlint:
    <<: *default-service
    entrypoint: ["markdownlint"]

  textlint:
    <<: *default-service
    entrypoint: ["textlint"]
```

```console
# setting up environment variables
$ echo "UID=$(id -u)" >> .env
$ echo "GID=$(id -u)" >> .env

# serving mdBook website
$ docker compose up

# running mdBook build
$ docker compose run --rm mdbook build

# running markdown lint
$ docker compose run --rm markdownlint .
```

## Source Repository

This repository is hosted at:

* <https://github.com/gifnksm/docker-mdbook-ja>
* <https://gitlab.com/gifnksm/docker-mdbook-ja>
