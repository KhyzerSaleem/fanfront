# ------------------------------
# Stage 1: Install dependencies and build the Next.js app
# ------------------------------
FROM node:20-alpine AS deps

# Set working directory inside container
WORKDIR /app

# Copy lockfile and package.json to install dependencies
COPY package.json package-lock.json ./

# Install ALL dependencies (including devDependencies)
RUN npm ci

# Copy all project files (excluding what's in .dockerignore)
COPY . .

# Build the Next.js app for production
RUN npm run build

# ------------------------------
# Stage 2: Run the production build
# ------------------------------
FROM node:20-alpine AS runner

# Set environment to production
ENV NODE_ENV=production

# Set working directory
WORKDIR /app

# Copy ONLY what’s needed for runtime
COPY --from=deps /app/public ./public
COPY --from=deps /app/.next ./.next
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/package.json ./package.json
COPY --from=deps /app/next.config.mjs ./next.config.mjs
COPY --from=deps /app/tailwind.config.ts ./tailwind.config.ts
COPY --from=deps /app/postcss.config.mjs ./postcss.config.mjs
COPY --from=deps /app/src ./src

# Optional: copy any other config or ts files you use
COPY --from=deps /app/tsconfig.json ./tsconfig.json
COPY --from=deps /app/.env ./.env

# Expose the port used by Next.js
EXPOSE 3000

# Start the Next.js production server
CMD ["npm", "run", "dev"]
