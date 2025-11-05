# frontend/Dockerfile
# Stage 1: Base with deps
FROM node:18-alpine AS base
RUN apk add --no-cache libc6-compat bash curl

WORKDIR /app
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Stage 2: Builder
FROM base AS builder
WORKDIR /app

COPY --from=base /app/node_modules ./node_modules
COPY . .

ARG ENVIRONMENT=production
ARG NEXT_PUBLIC_API_URL="http://localhost:5000"

RUN if [ -f .env.${ENVIRONMENT} ]; then \
      echo "Using .env.${ENVIRONMENT}"; \
      cp .env.${ENVIRONMENT} .env; \
    else \
      echo "Creating .env dynamically"; \
      printf "NEXT_PUBLIC_API_URL=%s\n" "${NEXT_PUBLIC_API_URL}" > .env; \
    fi

RUN npm run build

# Stage 3: Runner
FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001

# Copy build output for standalone Next.js
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT=3000
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD wget -qO- http://localhost:3000/ || exit 1

# ✅ Correct entrypoint for Next.js standalone mode
CMD ["node", "server.js"]




# # ==========================
# # Stage 1: Base image with dependencies
# # ==========================
# FROM node:18-alpine AS base

# RUN apk add --no-cache libc6-compat bash curl

# WORKDIR /app

# # Copy package files first
# COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# # Install dependencies based on lockfile
# RUN \
#   if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
#   elif [ -f package-lock.json ]; then npm ci; \
#   elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i; \
#   else echo "Lockfile not found." && exit 1; \
#   fi

# # ==========================
# # Stage 2: Builder
# # ==========================
# FROM base AS builder
# WORKDIR /app

# # Copy dependencies from base
# COPY --from=base /app/node_modules ./node_modules

# # Copy frontend code
# COPY . .

# # Copy correct environment file
# ARG ENVIRONMENT=development
# COPY .env.${ENVIRONMENT} .env

# # Build Next.js app
# RUN npm run build

# # ==========================
# # Stage 3: Production image
# # ==========================
# FROM node:18-alpine AS runner
# WORKDIR /app

# ENV NODE_ENV=production

# RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001

# # Copy built files
# COPY --from=builder /app/public ./public
# COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./ 
# COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
# COPY --from=builder /app/package.json ./package.json

# USER nextjs

# EXPOSE 3000
# ENV PORT=3000
# ENV HOSTNAME="0.0.0.0"

# HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
#   CMD wget -qO- http://localhost:3000/ || exit 1

# CMD ["node", "server.js"]
