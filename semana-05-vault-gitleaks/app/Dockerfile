# Imagen de la aplicación de laboratorio Way Créditos Lab.
# BASE_IMAGE permite usar una imagen Node local cuando no hay acceso a Docker Hub.
ARG BASE_IMAGE=node:22-bookworm-slim
FROM ${BASE_IMAGE}

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund
COPY server.js ./

ENV PORT=3000
EXPOSE 3000
USER nobody
CMD ["node", "server.js"]
