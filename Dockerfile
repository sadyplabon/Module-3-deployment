# syntax=docker/dockerfile:1

# 1) Install deps
FROM node:22-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# 2) Runtime image
FROM node:22-alpine AS runner
ENV NODE_ENV=production
WORKDIR /app

# copy deps and app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# run as non-root
RUN addgroup -S nodejs && adduser -S nodeuser -G nodejs
USER nodeuser

# the app listens on 3000 per README
EXPOSE 3000

# PM2 isn't needed inside containers—let Docker/K8s manage restarts
CMD ["node", "src/server.js"]

