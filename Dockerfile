# ---- deps: installe toutes les dépendances (dev incluses, nécessaires pour build) ----
FROM node:24-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# ---- build: compile le TypeScript en JS (dist/) ----
FROM node:24-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# ---- prod-deps: dépendances de prod uniquement (image finale plus légère) ----
FROM node:24-alpine AS prod-deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# ---- runtime: image finale, ne contient que le strict nécessaire pour tourner ----
FROM node:24-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY assets ./assets
COPY package.json ./

# Uploaded files (profiles, banners, events…): mount a volume here (UPLOAD_ROOT=/app/uploads).
RUN mkdir -p /app/uploads

EXPOSE 3000
CMD ["node", "dist/main"]
