FROM alpine as rust_builder
WORKDIR /build

RUN \
    apk --no-cache upgrade && \
    apk --no-cache add build-base rust cargo && \
    cargo install mdbook --root /build && \
    cargo install mdbook-mermaid --root /build && \
    :

FROM alpine
WORKDIR /book

RUN \
    apk --no-cache upgrade && \
    apk --no-cache add npm cargo && \
    npm install --production -g markdownlint-cli && \
    npm cache clean --force && \
    :
COPY --from=rust_builder /build/bin/* /usr/local/bin/
