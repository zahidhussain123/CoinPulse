# Build the React application.
FROM node:22-bookworm-slim AS builder

WORKDIR /app

# Cache dependency installation until the package files change.
COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

COPY . .

# Temporary workaround for the existing CSS warning in react-scripts.
# Set to true after fixing the warning: docker build --build-arg CI=true ...
ARG CI=false
RUN CI=${CI} npm run build

# Serve only the compiled files in the runtime image.
FROM nginx:stable-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build/ /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
