# Cloud image: UI + API + Python worker (no need for your PC to stay on)

FROM python:3.11-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    NODE_ENV=production \
    PORT=8787 \
    PYTHON=python3

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates build-essential \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# CPU-only PyTorch (smaller than full CUDA build)
COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install torch --index-url https://download.pytorch.org/whl/cpu \
    && pip install -r requirements.txt

COPY package.json package-lock.json ./
COPY client/package.json client/package-lock.json ./client/
RUN npm ci && npm ci --prefix client

COPY . .
RUN npm run build \
    && npm prune --omit=dev \
    && npm prune --omit=dev --prefix client

EXPOSE 8787
CMD ["npm", "start"]
