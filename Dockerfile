FROM node:20

WORKDIR /app

COPY apps/backend/package.json ./

RUN npm install --legacy-peer-deps

COPY apps/backend/ .

ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV NODE_ENV=production

RUN npx medusa build

EXPOSE 9000

CMD ["npx", "medusa", "start"]
