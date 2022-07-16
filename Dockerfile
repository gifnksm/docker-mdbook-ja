FROM rust:alpine as rust_builder
WORKDIR /build

RUN \
    apk add build-base --no-cache && \
    cargo install mdbook --root /build && \
    cargo install mdbook-mermaid --root /build && \
    :

FROM node:alpine
WORKDIR /book

RUN \
    apk upgrade && \
    npm install -g markdownlint-cli && \
    :
COPY --from=rust_builder /build/bin/* /usr/bin/
