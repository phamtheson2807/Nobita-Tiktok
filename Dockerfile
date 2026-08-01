FROM node:22-alpine

# Set working directory
WORKDIR /app

# yt-dlp is the shared fallback for every supported public platform.
RUN apk add --no-cache ffmpeg yt-dlp python3

# Copy package files
COPY package*.json ./

# Install npm dependencies
RUN npm ci --omit=dev --no-audit --no-fund \
    && npm cache clean --force

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p data logs

ENV NODE_ENV=production

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Start application
CMD ["node", "index.js"]
