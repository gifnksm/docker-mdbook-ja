FROM alpine:3.16 as rust_builder
WORKDIR /build

COPY scripts/install_rust_package /build/

RUN \
    apk --no-cache upgrade && \
    ./install_rust_package mdbook 0.4.20 && \
    ./install_rust_package mdbook-mermaid 0.11.1 && \
    :

FROM alpine:3.16 as node_builder
WORKDIR /npm

COPY package.json package-lock.json /npm/
RUN \
    apk --no-cache upgrade && \
    apk --no-cache add npm~=8 && \
    npm ci && npm cache clean --force

FROM alpine:3.16
WORKDIR /book
ENV PATH $PATH:/npm/node_modules/.bin

RUN \
    apk --no-cache upgrade && \
    apk --no-cache add npm~=8 cargo~=1 && \
    :
COPY --from=rust_builder /build/bin/* /usr/local/bin/
COPY --from=node_builder /npm /npm
