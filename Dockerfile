# Use official Node.js LTS image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install OS dependencies (e.g., for sharp or native modules)
RUN apk add --no-cache libc6-compat

# Copy package files first (for caching npm install)
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm install

# Copy the rest of the code
COPY . .

# Expose port used by `npm run dev`
EXPOSE 3000

# Start Next.js in development mode
CMD ["npm", "run", "dev"]
