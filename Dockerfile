FROM rust:1.87-slim AS builder

RUN apt-get update && apt-get install -y \
    git \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Пинаем конкретный тег чтобы не ловить сломанный main
RUN git clone --depth=1 --branch 3.3.28 https://github.com/telemt/telemt.git /app
WORKDIR /app

# codegen-units=1 и jobs=1 сильно экономят RAM (Rust компиляция жрёт много)
ENV RUSTFLAGS="-C codegen-units=1"
RUN cargo build --release --jobs 1

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/telemt /usr/local/bin/telemt

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
