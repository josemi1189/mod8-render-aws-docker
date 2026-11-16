# Despliegue en Render usando Docker

🔗 [Repositorio GitHub](https://github.com/josemi1189/mod8-render-docker)

🔗 [Despliegue en Render con Docker](https://mod8-render-docker.onrender.com)

1. Debemos generar los archivos de configuración para generar la imagen en **Docker Hub**. Se debe optimizar la imagen de forma que contenga solo los archivos necesarios.

   `Dockerfile`:

   ```docker
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

   # Instala dependencias omitiendo las de desarrollo
   RUN npm ci --omit=dev

   CMD ["node", "index.js"]
   ```

   `.dockerignore`: Debe incluir todo lo que no sea necesario subir a Docker. Si utilizamos .env.production no deberá incluirse para permitir su subida.

   ```
   node_modules
   dist
   .github
   .gitignore
   .env.development
   ```

2. Generar imagen del repositorio con la versión que corresponda:

   `docker build -t <nombre-app>:<número de versión> .`

   ```
   docker build -t render-docker:1 .
   ```

   **NOTA:** El comando incluye un punto . al final necesario que indica la ruta o directorio donde se encuentra el archivo Dockerfile y permite indicar directorio al que le queremos dar acceso.

3. Una vez ejecutado el comando, podemos comprobar si la imagen se ha compilado correctamente con el comando `docker images`:

   ![Crea imagen de Docker](docs/create-image.jpg)

4. Crear contenedor Docker y confirmar que la aplicación carga correctamente.

   `docker run --name <nombre-contenedor> -p <puerto local:puerto del proceso del contenedor> - e PORT=<puerto> <nombre-imagen>:<versión>`

   ```
   docker run --name render-docker-container -p 8083:8083 render-docker:1
   ```

   🔗 [http://localhost:8083](http://localhost:8083)

   ![Crea contenedor de Docker](docs/contenedor.jpg)

   > Permite generar tantos contenedores como sean necesarios utilizando distinto nombre de contenedor y distinto puerto.

   ```
   docker run --name render-docker-container2 -p 8083:8083 render-docker:1
   ```

5. Publicar imagen en Dockerhub.
   1. Es necesario estar logueado en docker para tener acceso mediante línea de comandos. Podemos loguearnos o confirmar que lo estamos ejecutando:

      ```
      docker login
      ```

   2. Para subir la imagen a DockerHub, el nombre debe incluir nuestro nombre de usuario. Si en local hemos creado la imagen sin utilizar formato `usuario-docker/nombre-imagen`, es posible asignarle un alias para que nos permita publicarla.

      `docker tag \<imagen-local:versión> \<usuario>/\<nombre-imagen:version>`

      ```
      docker tag render-docker:1 josemi1189/render-docker:1
      ```

   3. Subir imagen a Docker Hub:

      `docker push \<alias-imagen-creada>`

      ```
      docker push josemi1189/render-docker:1
      ```

      ![Imagen versión 1 en Docker Hub](docs/imagen-dockerhub.jpg)

   4. De esta forma se compila con la arquitectura del sistema de nuestro equipo. Para compilar con distintas arquitecturas podemos ejecutar el comando:

      `docker buildx build --platform linux/amd64,linux/arm64 -t <nombre_repositorio_dockerHub:versión> <--push (opcional)> .`

      > --push: Publica la imagen multi-arquitectura en Docker Hub.

      ```
      docker buildx build --platform linux/amd64,linux/arm64 -t josemi1189/render-docker:2 --push .
      ```

      ![Imagen creada con multi-arquitectura](docs/multi-arquitectura.jpg)

6. Para publicar en Render, debemos generar un **Web Service** y enlazar con nuestro repositorio de GitHub con la diferencia de que al elegir el lenguaje utilizado deberá estar seleccionado **Docker**.

   ![Configuración de Render](docs/despliegue-render.jpg)

   ![Despliegue en Render](docs/deploy.jpg)
