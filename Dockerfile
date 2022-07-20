FROM alpine:3.16 as rust_builder
WORKDIR /build

RUN \
    apk --no-cache upgrade && \
    apk --no-cache add build-base~=0.5 cargo~=1 && \
    cargo install mdbook --version 0.4.20 --root /build && \
    cargo install mdbook-mermaid --version 0.11.1 --root /build && \
    :

FROM alpine:3.16 as node_builder
WORKDIR /npm

COPY package.json package-lock.json /npm/
RUN \
    apk --no-cache upgrade && \
    apk --no-cache add npm~=8 && \
    npm install && npm cache clean --force

FROM alpine:3.16
WORKDIR /book
ENV PATH $PATH:/npm/node_modules/.bin

RUN \
    apk --no-cache upgrade && \
    apk --no-cache add npm~=8 cargo~=1 && \
    :
COPY --from=rust_builder /build/bin/* /usr/local/bin/
COPY --from=node_builder /npm /npm
