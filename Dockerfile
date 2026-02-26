# ============================================================
# Stage 1: Build whisper.cpp
# ============================================================
FROM debian:bookworm-slim AS whisper-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake g++ make ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/ggerganov/whisper.cpp.git /whisper.cpp

WORKDIR /whisper.cpp
RUN cmake -B build -DCMAKE_BUILD_TYPE=Release -DGGML_NATIVE=OFF \
    && cmake --build build --config Release -j "$(nproc)"

# ============================================================
# Stage 2: Clone source and build frontend
# ============================================================
FROM node:20-slim AS frontend-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/fltman/transcriber.git /src

WORKDIR /src/frontend
RUN npm ci --silent && npm run build

# ============================================================
# Stage 3: Final image
# ============================================================
FROM python:3.12-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    curl \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Python dependencies
COPY --from=frontend-builder /src/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy whisper.cpp binary and shared library
COPY --from=whisper-builder /whisper.cpp/build/bin/whisper-cli /usr/local/bin/whisper-cli
COPY --from=whisper-builder /whisper.cpp/build/src/libwhisper.so* /usr/local/lib/
COPY --from=whisper-builder /whisper.cpp/build/ggml/src/libggml*.so* /usr/local/lib/
RUN ldconfig

# Copy built frontend
COPY --from=frontend-builder /src/frontend/dist /app/frontend/dist

# Copy application code from cloned source
COPY --from=frontend-builder /src/main.py /src/config.py /src/database.py /src/model_config.py /src/preferences.py /src/ws_manager.py ./
COPY --from=frontend-builder /src/api/ ./api/
COPY --from=frontend-builder /src/services/ ./services/
COPY --from=frontend-builder /src/tasks/ ./tasks/
COPY --from=frontend-builder /src/models/ ./models/
COPY --from=frontend-builder /src/model_presets/ ./model_presets/

# Create directories
RUN mkdir -p /app/storage /data/whisper-models /app/logs

# Config files
COPY nginx.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

VOLUME ["/app/storage", "/data/whisper-models"]

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
