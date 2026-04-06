FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./

FROM base AS builder
RUN npm ci
COPY . .
RUN npx prisma generate
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN apk add --no-cache curl
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# App standalone build
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Prisma: tudo necessario para migrations e seed
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/prisma.config.ts ./prisma.config.ts
COPY --from=builder /app/src/generated ./src/generated
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/VERSION ./VERSION
COPY --from=builder /app/update.sh ./update.sh

RUN mkdir -p uploads && chown nextjs:nodejs uploads
USER nextjs
EXPOSE 3000
ENV PORT=3000
CMD ["node", "server.js"]
