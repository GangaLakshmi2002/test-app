# ==========================
# Stage 1: Base image with dependencies
# ==========================
FROM node:18-alpine AS base

# Install libc6-compat for compatibility
RUN apk add --no-cache libc6-compat bash curl

WORKDIR /app

# Copy package files first for caching dependencies
COPY frontend/package.json frontend/yarn.lock* frontend/package-lock.json* frontend/pnpm-lock.yaml* ./

# Install dependencies based on lockfile
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i; \
  else echo "Lockfile not found." && exit 1; \
  fi

# ==========================
# Stage 2: Builder
# ==========================
FROM base AS builder
WORKDIR /app

# Copy dependencies from base
COPY --from=base /app/node_modules ./node_modules

# Copy entire frontend code
COPY frontend/ ./

# Copy the correct environment file based on build argument
ARG ENVIRONMENT=development
COPY frontend/.env.${ENVIRONMENT} .env

# Build the frontend (Next.js)
RUN npm run build

# ==========================
# Stage 3: Production image
# ==========================
FROM node:18-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Create a non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001

# Copy built app from builder
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./ 
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder /app/package.json ./package.json

USER nextjs

# Expose port
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1

# Start app
CMD ["node", "server.js"]


# # Serve using Apache
# FROM httpd:2.4
# COPY --from=build /app/build/ /usr/local/apache2/htdocs/
# EXPOSE 80