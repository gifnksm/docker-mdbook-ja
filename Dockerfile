FROM rust:slim as base
WORKDIR /build
COPY scripts/install_rust_package /build/
RUN \
    set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl unzip && \
    curl -fsSL https://deb.nodesource.com/setup_current.x > setup_current.x && \
    bash setup_current.x && \
    rm setup_current.x && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /build/bin && \
    :

FROM base as mdbook_builder
RUN \
    set -eux && \
    ./install_rust_package mdbook 0.4.21 && \
    /build/bin/mdbook --version && \
    :

FROM base as mdbook_mermaid_builder
RUN \
    set -eux && \
    ./install_rust_package mdbook-mermaid 0.11.1 && \
    /build/bin/mdbook-mermaid --version && \
    :

FROM base as mdbook_linkcheck_builder
RUN \
    set -eux && \
    ./install_rust_package mdbook-linkcheck 0.7.6 && \
    /build/bin/mdbook-linkcheck --version && \
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
COPY --from=node_builder /npm /npm
