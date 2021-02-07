# Deploy con Docker

### Creamos las variables de entorno

*api/.env*

```
# Postgres
POSTGRES_HOST=gw-db
POSTGRES_DATABASE=<database name, eg. geoworks_development>
POSTGRES_USER=<postgres-user>
POSTGRES_PASSWORD=<postgres-password>

# App
APP_PORT=3001
```

### Obtenemos privilegios de root:

``` sh
sudo su
```

### Creamos las imágenes:

``` sh
docker-compose build
```

### Creamos y levantamos los contenedores:

``` sh
docker-compose up -d
```

Ahora deberíamos poder conectarnos a la api apuntando a `http://<subdomain>.st.geoworks.com.ar:<APP_PORT>/api/v1`



# Comandos útiles de Docker:

- Listar los contenedores: `sudo docker ps -a` ([+info](https://docs.docker.com/engine/reference/commandline/ps/))

- Arrancar un contenedor: `sudo docker start <nombre-contenedor>` ([+info](https://docs.docker.com/engine/reference/commandline/start/))

- Detener un contenedor: `sudo docker stop <nombre-contenedor>` ([+info](https://docs.docker.com/engine/reference/commandline/stop/))

- Capturar los logs de un contenedor: `sudo docker logs <nombre-contenedor>` ([+info](https://docs.docker.com/engine/reference/commandline/logs/))

- Seguir los logs con docker-compose: `sudo docker-compose logs -f` ([+info](https://docs.docker.com/compose/reference/logs/))

- Listar los volúmenes: `sudo docker volume ls` ([+info](https://docs.docker.com/engine/reference/commandline/volume/))
