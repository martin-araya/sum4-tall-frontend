# ── ETAPA 1: Compilar Flutter Web ─────────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

COPY . .

# URL relativa: nginx hace el proxy /api → backend:8000
RUN flutter build web --release \
    --dart-define=API_URL=/api/v1 \
    --dart-define=FLUTTER_WEB_USE_SKIA=true

# ── ETAPA 2: Servir con Nginx + Reverse Proxy ──────────────────────────────────
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
