# Stage 1: Build the app
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package files first for caching
COPY package*.json ./

# Install all dependencies (including devDeps for build)
RUN npm install

# Copy the rest of the source code
COPY . .

# Build the NestJS app (creates dist/main.js)
RUN npm run build


# Stage 2: Production image
FROM node:18-alpine AS production
WORKDIR /app

# Copy only the built files and prod deps
COPY package*.json ./
RUN npm install --only=production

# Copy built output from builder stage
COPY --from=builder /app/dist ./dist

# Expose the app port
EXPOSE 5000

# Start the app
CMD ["node", "dist/main.js"]







# # Use official Node image
# FROM node:18-alpine

# WORKDIR /app

# COPY package*.json ./
# RUN npm install

# COPY . .

# # Expose backend port
# EXPOSE 5000

# CMD ["npm", "run", "start:prod"]
