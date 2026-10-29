# syntax=docker/dockerfile:1.7

# =============================================================================
# Builder stage — installs production dependencies only, on a fresh Node base.
# =============================================================================

# Use a current, supported Node LTS release and pin the point version for reproducible builds.
FROM node:24.22.2-slim AS builder

WORKDIR /app

# TODO(step-4b): copy package.json and package-lock.json, then install deps.
COPY app/package.json app/package-lock.json ./
RUN npm ci --omit=dev

# TODO(step-4c): copy the rest of the app source into /app.
COPY app/ .

# =============================================================================
# Runtime stage — slim final image. Nothing from builder's caches leaks in.
# =============================================================================

# Use the same Node release in the runtime image.
FROM node:24.22.2-slim

WORKDIR /app

# TODO(step-4e): copy the fully-installed app from the builder stage.
COPY --from=builder /app /app

ENV NODE_ENV=production
EXPOSE 3000

# TODO(step-4f): add a HEALTHCHECK that probes http://localhost:3000/health.
#   IMPORTANT: the Node slim image does NOT ship with curl or wget.
#   Use Node's built-in http module instead:
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=5 \
CMD node -e "require('http').get('http://localhost:3000/health', r => process.exit(r.statusCode===200?0:1)).on('error', () => process.exit(1))"

# TODO(step-4g): declare the container start command.
CMD ["node", "src/index.js"]
