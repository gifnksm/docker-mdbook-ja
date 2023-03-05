FROM rust:slim as base
WORKDIR /build
RUN \
    set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl unzip chromium fonts-noto-cjk && \
    curl -fsSL https://deb.nodesource.com/setup_current.x > setup_current.x && \
    bash setup_current.x && \
    rm setup_current.x && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    :

FROM base as rust_builder
RUN \
    set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /build/bin && \
    :
COPY . /build/

FROM rust_builder as mdbook_builder
RUN \
    set -eux && \
    ./scripts/install_rust_package mdbook && \
    /build/bin/mdbook --version && \
    :

FROM rust_builder as mdbook_mermaid_builder
RUN \
    set -eux && \
    ./scripts/install_rust_package mdbook-mermaid && \
    /build/bin/mdbook-mermaid --version && \
    :

FROM rust_builder as mdbook_linkcheck_builder
RUN \
    set -eux && \
    ./scripts/install_rust_package mdbook-linkcheck && \
    /build/bin/mdbook-linkcheck --version && \
    :

FROM rust_builder as mdbook_pdf_builder
RUN \
    set -eux && \
    ./scripts/install_rust_package mdbook-pdf && \
    :

FROM base as node_builder
WORKDIR /npm
ENV PATH $PATH:/npm/node_modules/.bin

COPY package.json package-lock.json /npm/
RUN \
    set -eux && \
    npm ci && \
    npm cache clean --force && \
    /npm/node_modules/.bin/markdownlint --version && \
    /npm/node_modules/.bin/textlint --version && \
    :

FROM base
WORKDIR /book
ENV PATH $PATH:/npm/node_modules/.bin
COPY --from=mdbook_builder /build/bin/* /usr/local/bin/
COPY --from=mdbook_mermaid_builder /build/bin/* /usr/local/bin/
COPY --from=mdbook_linkcheck_builder /build/bin/* /usr/local/bin/
COPY --from=mdbook_pdf_builder /build/bin/* /usr/local/bin/
COPY --from=node_builder /npm /npm
