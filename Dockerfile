# syntax=docker/dockerfile:1

FROM rust:slim as base
WORKDIR /build
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN <<EOF
    apt-get update
    apt-get install -y --no-install-recommends curl unzip chromium fonts-noto-cjk
    curl -fsSL https://deb.nodesource.com/setup_current.x > setup_current.x
    bash setup_current.x
    rm setup_current.x
    apt-get install -y --no-install-recommends nodejs
    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF

ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

SHELL ["/bin/sh", "-c"]

FROM base as rust_builder
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN <<EOF
    apt-get update
    apt-get install -y --no-install-recommends jq build-essential
    apt-get clean
    rm -rf /var/lib/apt/lists/*
    mkdir -p /build/bin
EOF

COPY . /build/

FROM rust_builder as mdbook_builder
RUN <<EOF
    ./scripts/install_rust_package mdbook
    /build/bin/mdbook --version
EOF

FROM rust_builder as mdbook_mermaid_builder
RUN ./scripts/install_rust_package mdbook-mermaid

FROM rust_builder as mdbook_linkcheck_builder
RUN ./scripts/install_rust_package mdbook-linkcheck

FROM base as node_builder
WORKDIR /npm
ENV PATH $PATH:/npm/node_modules/.bin

COPY package.json package-lock.json /npm/
RUN <<EOF
    npm ci
    npm cache clean --force
EOF

FROM base
WORKDIR /book
ENV PATH $PATH:/npm/node_modules/.bin
COPY --from=mdbook_builder /build/bin/* /usr/local/bin/
COPY --from=mdbook_mermaid_builder /build/bin/* /usr/local/bin/
COPY --from=mdbook_linkcheck_builder /build/bin/* /usr/local/bin/
COPY --from=node_builder /npm /npm
