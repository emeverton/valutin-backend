FROM node:20-alpine

# Native build tools needed by some Medusa dependencies
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copy monorepo root files
COPY package.json package-lock.json turbo.json .npmrc ./

# Copy backend package.json before installing so npm workspaces resolves correctly
COPY apps/backend/package.json apps/backend/

RUN npm install

COPY apps/backend/ apps/backend/

WORKDIR /app/apps/backend

RUN npx medusa build

EXPOSE 9000

CMD ["npx", "medusa", "start"]
