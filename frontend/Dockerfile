# Stage 1: Build Flutter Web application
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# Stage 2: Production Nginx Server
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

# SPA Routing configuration
RUN printf 'server {\n\
    listen 3000;\n\
    location / {\n\
        root /usr/share/nginx/html;\n\
        index index.html index.htm;\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
