FROM node:24-alpine
RUN mkdir -p /usr/app

#Indica directorio de trabajo
WORKDIR /usr/app

# Copia ficheros dentro del directorio de trabajo establecido
COPY ./ ./

RUN npm install
RUN npm run build

RUN cp -r ./dist ./server/public
RUN cd server && npm ci

CMD ["node", "server/index.js"]
