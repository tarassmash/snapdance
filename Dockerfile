# SnapDance для Railway: Node 20 + ffmpeg (обработка «как с телефона»)
FROM node:20-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends ffmpeg fonts-dejavu-core ca-certificates \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . .
ENV NODE_ENV=production
CMD ["node", "server.mjs"]
