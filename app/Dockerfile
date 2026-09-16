FROM node:24-alpine AS base

WORKDIR /app

RUN corepack enable

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm build

RUN pnpm prune --prod


FROM node:24-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

RUN corepack enable

COPY --from=base /app/package.json ./package.json
COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app/dist ./dist

EXPOSE 3000

CMD ["node", "dist/server.js"]