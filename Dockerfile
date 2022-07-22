FROM rust:alpine3.16 as rust_builder
WORKDIR /build
COPY scripts/install_rust_package /build/
RUN \
    set -eux && \
    apk --no-cache add curl~=7 musl-dev~=1 build-base~=0 perl~=5 && \
    mkdir -p /build/bin && \
    :

FROM rust_builder as mdbook_builder
RUN \
    set -eux && \
    ./install_rust_package mdbook 0.4.20 && \
    /build/bin/mdbook --version && \
    :

FROM rust_builder as mdbook_mermaid_builder
RUN \
    set -eux && \
    ./install_rust_package mdbook-mermaid 0.11.1 && \
    /build/bin/mdbook-mermaid --version && \
    :

FROM rust_builder as mdbook_linkcheck_builder
RUN \
    set -eux && \
    ./install_rust_package mdbook-linkcheck 0.7.6 && \
    /build/bin/mdbook-linkcheck --version && \
    :


FROM alpine:3.16 as node_builder
WORKDIR /npm

COPY package.json package-lock.json /npm/
RUN \
    set -eux && \
    apk --no-cache upgrade && \
    apk --no-cache add npm~=8 && \
    npm ci && npm cache clean --force

FROM rust:alpine3.16
WORKDIR /book
ENV PATH $PATH:/npm/node_modules/.bin
RUN \
    set -eux && \
    apk --no-cache upgrade && \
    apk --no-cache add npm~=8 musl-dev~=1 build-base~=0 perl~=5 && \
    :
COPY --from=mdbook_builder /build/bin/* /usr/local/bin/
COPY --from=mdbook_mermaid_builder /build/bin/* /usr/local/bin/
COPY --from=mdbook_linkcheck_builder /build/bin/* /usr/local/bin/
COPY --from=node_builder /npm /npm
