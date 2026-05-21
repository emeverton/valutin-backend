FROM node:20

WORKDIR /app

COPY apps/backend/package.json ./

# Force dev deps install so TypeScript and build tools are available for medusa build
RUN NODE_ENV=development npm install --legacy-peer-deps

COPY apps/backend/ .

ENV NODE_OPTIONS="--max-old-space-size=4096"

RUN npx medusa build

EXPOSE 9000

ENV NODE_ENV=production

CMD ["npx", "medusa", "start"]
