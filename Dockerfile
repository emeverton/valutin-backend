FROM node:20

WORKDIR /app

# Copy monorepo root files
COPY package.json package-lock.json turbo.json .npmrc ./

# Copy backend package.json before installing so npm workspaces resolves correctly
COPY apps/backend/package.json apps/backend/

RUN npm install

COPY apps/backend/ apps/backend/

WORKDIR /app/apps/backend

# Increase memory for Vite admin dashboard build
ENV NODE_OPTIONS="--max-old-space-size=4096"

RUN npx medusa build

EXPOSE 9000

CMD ["npx", "medusa", "start"]
