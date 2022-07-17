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
    npm install --omit dev -g markdownlint-cli && \
    npm install --omit dev -g textlint && \
    npm install --omit dev -g textlint-rule-doubled-spaces && \
    npm install --omit dev -g textlint-rule-footnote-order && \
    npm install --omit dev -g textlint-rule-preset-ja-technical-writing && \
    npm install --omit dev -g textlint-rule-no-empty-section && \
    npm install --omit dev -g textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet && \
    npm install --omit dev -g textlint-rule-period-in-list-item && \
    npm install --omit dev -g textlint-rule-prefer-tari-tari && \
    npm install --omit dev -g textlint-rule-ja-hiragana-keishikimeishi && \
    npm install --omit dev -g textlint-rule-ja-hiragana-fukushi && \
    npm install --omit dev -g textlint-rule-ja-hiragana-hojodoushi && \
    npm install --omit dev -g textlint-rule-ja-no-orthographic-variants && \
    npm install --omit dev -g @textlint-rule/textlint-rule-no-duplicate-abbr && \
    npm install --omit dev -g @textlint-ja/textlint-rule-no-insert-dropping-sa && \
    npm install --omit dev -g @textlint-ja/textlint-rule-no-synonyms && \
    npm install --omit dev -g sudachi-synonyms-dictionary && \
    npm cache clean --force && \
    :
COPY --from=rust_builder /build/bin/* /usr/local/bin/
