FROM node:22-alpine

WORKDIR /app

# Alpine's repository version of yt-dlp can lag behind TikTok extractor changes.
# Install yt-dlp in an isolated Python environment and allow pre-releases so a
# fresh Render build always gets the latest extractor fixes.
RUN apk add --no-cache ffmpeg python3 py3-pip ca-certificates \
    && python3 -m venv /opt/yt-dlp \
    && /opt/yt-dlp/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/yt-dlp/bin/pip install --no-cache-dir --upgrade --pre "yt-dlp[default]" \
    && /opt/yt-dlp/bin/yt-dlp --version

ENV PATH="/opt/yt-dlp/bin:$PATH"

COPY package*.json ./

RUN npm ci --omit=dev --no-audit --no-fund \
    && npm cache clean --force

COPY . .

RUN mkdir -p data logs

ENV NODE_ENV=production

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

CMD ["node", "index.js"]
