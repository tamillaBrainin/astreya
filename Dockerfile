FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
ARG API_BASE_URL=

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter config --enable-web && flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:1.27-alpine
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
