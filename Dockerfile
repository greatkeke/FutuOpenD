# ============================================================
# FutuOpenD Docker Image
# Latest version: 10.6.6608 (auto-downloaded at build time)
# ============================================================

FROM ubuntu:18.04 AS downloader

ARG OPEND_VERSION=10.6.6608
ARG OPEND_URL=https://softwaredownload.futunn.com/Futu_OpenD_${OPEND_VERSION}_Ubuntu18.04.tar.gz

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Download and extract — tarball has double-nested dirs:
#   Futu_OpenD_VER/
#   ├── Futu_OpenD-GUI_VER/   (GUI, not needed)
#   ├── README.txt
#   └── Futu_OpenD_VER/       ← command-line version (this is what we want)
#       ├── FutuOpenD
#       ├── AppData.dat
#       └── lib*.so
RUN curl -sL -o opend.tar.gz "${OPEND_URL}" \
    && tar xzf opend.tar.gz \
    && mv Futu_OpenD_${OPEND_VERSION}_Ubuntu18.04/Futu_OpenD_${OPEND_VERSION}_Ubuntu18.04 /tmp/opend \
    && rm -rf opend.tar.gz Futu_OpenD_${OPEND_VERSION}_Ubuntu18.04 \
    && ls -la /tmp/opend/

# ============================================================
# Runtime image
# ============================================================
FROM ubuntu:18.04

LABEL maintainer="keke"
LABEL description="Futu OpenD API service"
LABEL version="10.6.6608"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl1.1 \
    openssl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy OpenD command-line binaries from downloader stage
COPY --from=downloader /tmp/opend/ /app/

# Make binaries executable
RUN chmod +x /app/FutuOpenD /app/FTWebSocket /app/FTUpdate 2>/dev/null || true

RUN mkdir -p /app/config

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 11111
EXPOSE 22222

# HEALTHCHECK --interval=30s --timeout=5s --start-period=180s --retries=3 \
#     CMD bash -c 'echo > /dev/tcp/localhost/11111' || exit 1

CMD ["/app/entrypoint.sh"]
