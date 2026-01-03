FROM debian:bookworm-slim

# 基本ツールと WebP 対応 ImageMagick
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        imagemagick \
        webp \
        ca-certificates \
        zip \
        wget \
    && rm -rf /var/lib/apt/lists/*

# 確認用

WORKDIR /work/

# docker build -t imgtest .
# docker run --rm -v ./work:/work imgtest convert itemIcons.png -define webp:lossless=true -define webp:method=6 itemIcons.webp
# docker run --rm -v ./work:/work imgtest compare -metric PSNR itemIcons.png itemIcons.webp NULL: