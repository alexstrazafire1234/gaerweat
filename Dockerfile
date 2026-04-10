FROM rust:1.87-slim AS builder

RUN apt-get update && apt-get install -y \
    git \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/telemt/telemt.git /app
WORKDIR /app
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/telemt /usr/local/bin/telemt

# Entrypoint генерирует config.toml из env переменных и запускает telemt
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
