# Multi-stage Dockerfile for MERN Chat App

# Stage 1: Build the React frontend
FROM node:16-alpine AS frontend-build

# Set working directory for frontend
WORKDIR /app/frontend

# Copy frontend package files
COPY frontend/package*.json ./

# Install frontend dependencies with legacy peer deps flag
RUN npm install --legacy-peer-deps

# Copy frontend source code
COPY frontend/ ./

# Build the React app for production
RUN npm run build

# Stage 2: Setup the Node.js backend
FROM node:16-alpine AS production

# Set working directory
WORKDIR /app

# Copy root package files
COPY package*.json ./

# Install backend dependencies
RUN npm install --legacy-peer-deps --only=production

# Copy backend source code
COPY backend/ ./backend/

# Copy the built frontend from the first stage
COPY --from=frontend-build /app/frontend/build ./frontend/build

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership of the app directory to nodejs user
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose the port that the app runs on
EXPOSE 5000

# Set environment variable for production
ENV NODE_ENV=production

# Health check to ensure the container is working properly
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "const http = require('http'); \
    const options = { hostname: 'localhost', port: process.env.PORT || 5000, path: '/', timeout: 2000 }; \
    const req = http.request(options, (res) => { \
      if (res.statusCode === 200) process.exit(0); \
      else process.exit(1); \
    }); \
    req.on('error', () => process.exit(1)); \
    req.on('timeout', () => process.exit(1)); \
    req.end();"

# Start the application
CMD ["node", "backend/server.js"]
