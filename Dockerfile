# Production image: visitors hit only the running UI + API.
# Source stays on the server — not exposed via the public link.

FROM python:3.11-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Python deps (torch is large — expect multi‑GB image / slow first build)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Node deps
COPY package.json package-lock.json ./
COPY client/package.json client/package-lock.json ./client/
RUN npm ci && npm ci --prefix client

# App source
COPY . .

# Build React → client/dist (compiled assets only)
RUN npm run build

ENV PORT=8787
ENV PYTHON=python3
ENV NODE_ENV=production

EXPOSE 8787

# Single process: Express API + static UI; Python workers spawned on demand
CMD ["npm", "start"]
