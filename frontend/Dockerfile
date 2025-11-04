# frontend/Dockerfile
# Multi-stage build for Next.js/Reactish app, but DOES NOT rely on copying .env files from context.

FROM node:18-alpine AS base
RUN apk add --no-cache libc6-compat bash curl

WORKDIR /app

# copy package manifest for caching
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# install deps
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Builder
FROM base AS builder
WORKDIR /app

# copy node_modules from base
COPY --from=base /app/node_modules ./node_modules

# copy app sources
COPY . .

# Build-time build args for environment values (pass from CI)
ARG ENVIRONMENT=development
ARG NEXT_PUBLIC_API_URL="http://localhost:3000"

# Create .env file from build args if no .env.<ENVIRONMENT> exists in context.
# (We avoid COPY .env.* so the build won't fail if .env isn't present in repo.)
RUN if [ -f .env.${ENVIRONMENT} ]; then \
      echo "Using provided .env.${ENVIRONMENT} from context"; \
      cp .env.${ENVIRONMENT} .env; \
    else \
      echo "No .env.${ENVIRONMENT} found in context — creating .env from build-args"; \
      printf "NEXT_PUBLIC_API_URL=%s\n" "${NEXT_PUBLIC_API_URL}" > .env; \
      # printf "SOME_OTHER_VAR=%s\n" "${SOME_OTHER_VAR}" >> .env; \
    fi

# Build (Next.js or react depends on your npm script)
RUN npm run build

# Runner image
FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001

# copy built artefacts (adjust paths according to your framework)
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder /app/package.json ./package.json

USER nextjs

EXPOSE 3000
ENV PORT=3000
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD wget -qO- http://localhost:3000/ || exit 1

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
