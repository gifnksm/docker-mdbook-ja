FROM rust:alpine as rust_builder
WORKDIR /workdir

RUN apk add build-base
RUN cargo install mdbook --root /workdir
RUN cargo install mdbook-mermaid --root /workdir

FROM node:alpine
WORKDIR /workdir

RUN \
    apk upgrade && \
    npm install -g markdownlint-cli && \
    :
COPY --from=rust_builder /workdir/bin/* /usr/bin/
