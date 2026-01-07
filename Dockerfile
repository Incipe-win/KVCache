# Build stage
FROM ubuntu:22.04 AS builder

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    unzip \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install xmake
RUN curl -fsSL https://github.com/xmake-io/xmake/releases/download/v2.9.6/xmake-v2.9.6.x86_64.deb -o xmake.deb \
    && dpkg -i xmake.deb \
    && rm xmake.deb

# Set working directory
WORKDIR /app

# Copy xmake config
COPY xmake.lua .

# Copy source code
COPY include/ include/
COPY src/ src/
COPY tests/ tests/

# Build the project
RUN ~/.local/bin/xmake f -m release -y
RUN ~/.local/bin/xmake -y
RUN ~/.local/bin/xmake install -o /app/install kv_server

# Runtime stage
FROM ubuntu:22.04

# Create a non-root user
RUN useradd -m appuser

WORKDIR /app

# Copy the binary
COPY --from=builder /app/install/bin/kv_server /app/kv_server

# Create directory for AOF file and set permissions
RUN touch appendonly.aof && chown appuser:appuser appendonly.aof

# Switch to non-root user
USER appuser

# Expose the port
EXPOSE 8080

# Run the server
CMD ["./kv_server", "8080"]
