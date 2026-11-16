# Crea fase base, genera carpeta contenedora e indica directorio de trabajo
FROM node:24-alpine AS base
RUN mkdir -p /usr/app
WORKDIR /usr/app

# Copia ficheros dentro del directorio de trabajo establecido, instala dependencias y genera build
FROM base  AS front-build
COPY ./ ./
RUN npm install
RUN npm run build

# Copia los archivos necesarios para despliegue
FROM base AS release
COPY --from=front-build /usr/app/dist ./public
COPY ./server/package.json ./
COPY ./server/package-lock.json ./
COPY ./server/index.js ./
# Omite dependencias de desarrollo
RUN npm ci --omit=dev

ENV PORT=8083

CMD ["node", "index.js"]
