# Use Rust Bookworm image for ARM compatibility
FROM rust:bookworm as builder

# Install build dependencies (OpenSSL, pkg-config, etc.)
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy dependency files first to cache them
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

# Copy source code and rebuild
COPY src ./src
RUN cargo build --release

# Final stage
FROM debian:bookworm-slim

# Install runtime dependencies (including curl)
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    curl \  
    && rm -rf /var/lib/apt/lists/*

# Copy the binary
COPY --from=builder /app/target/release/rust-chromedriver-example /usr/local/bin/

# Copy wait script
COPY wait-for-selenium.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wait-for-selenium.sh

# Entrypoint
ENTRYPOINT ["sh", "-c", "/usr/local/bin/wait-for-selenium.sh && exec /usr/local/bin/rust-chromedriver-example"]