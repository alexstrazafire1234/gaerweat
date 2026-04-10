FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Качаем готовый бинарь с GitHub Releases — никакой компиляции
ARG TELEMT_VERSION=3.3.38
RUN curl -fL \
    --retry 5 \
    -o /tmp/telemt.tar.gz \
    "https://github.com/telemt/telemt/releases/download/${TELEMT_VERSION}/telemt-x86_64-linux-musl.tar.gz" \
    && tar -xzf /tmp/telemt.tar.gz -C /tmp \
    && mv /tmp/telemt /usr/local/bin/telemt \
    && chmod +x /usr/local/bin/telemt \
    && rm /tmp/telemt.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
