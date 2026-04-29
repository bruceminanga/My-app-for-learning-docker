# STAGE 1: build
FROM node:22.14.0-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
                                

# STAGE 2: serve
FROM nginx:1.29.8-alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"] 