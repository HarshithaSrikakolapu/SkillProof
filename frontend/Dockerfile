# Stage 1: Build Flutter Web
FROM debian:latest AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y curl git unzip

# Verify git
RUN git --version

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable web
RUN flutter config --enable-web

# Copy files
RUN mkdir /app
COPY . /app
WORKDIR /app

# Get packages and build
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:1.21-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
