FROM rust:alpine3.16 as rust_builder
WORKDIR /build
COPY scripts/install_rust_package /build/
RUN \
    apk --no-cache add musl-dev~=1 curl~=7 && \
    mkdir -p /build/bin && \
    :

FROM rust_builder as mdbook_builder
RUN \
    ./install_rust_package mdbook 0.4.20 && \
    /build/bin/mdbook --version && \
    :

FROM rust_builder as mdbook_mermaid_builder
RUN \
    ./install_rust_package mdbook-mermaid 0.11.1 && \
    /build/bin/mdbook-mermaid --version && \
    :

FROM alpine:3.16 as node_builder
WORKDIR /npm

COPY package.json package-lock.json /npm/
RUN \
    apk --no-cache upgrade && \
    apk --no-cache add npm~=8 && \
    npm ci && npm cache clean --force

FROM rust:alpine3.16
WORKDIR /book
ENV PATH $PATH:/npm/node_modules/.bin

RUN \
    apk --no-cache upgrade && \
    apk --no-cache add npm~=8 && \
    :
COPY --from=mdbook_builder /build/bin/* /usr/local/bin/
COPY --from=mdbook_mermaid_builder /build/bin/* /usr/local/bin/
COPY --from=node_builder /npm /npm
