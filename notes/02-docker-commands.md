# Docker Command Cheat Sheet

## Setup check
```bash
docker --version
docker compose version
docker run hello-world
```

## Images
```bash
docker build -t myapp:1.0 .            # build an image from ./Dockerfile
docker build -f Dockerfile.naive .     # use a different Dockerfile
docker images                          # list images and sizes
docker pull nginx:alpine               # download an image
docker history myapp:1.0               # see layers and their sizes
docker rmi myapp:1.0                   # delete an image
```

## Containers
```bash
docker run -d --name web -p 8080:80 nginx:alpine   # run in background, map ports host:container
docker ps                                          # running containers
docker ps -a                                       # all containers, including stopped
docker logs -f web                                 # follow logs
docker exec -it web sh                             # open a shell inside
docker stop web && docker start web
docker rm web                                      # remove a stopped container
docker rm -f web                                   # force remove
docker stats                                       # live CPU/memory
docker inspect web                                 # full details (IP, mounts, env)
```

## Environment variables
```bash
docker run -d -e APP_ENV=production -e SECRET_KEY=abc myapp:1.0
docker run -d --env-file .env myapp:1.0
```

## Volumes
```bash
docker volume create mydata
docker volume ls
docker run -d -v mydata:/var/lib/postgresql/data postgres:16-alpine     # named volume
docker run -v "$(pwd)":/app myapp:1.0                                   # bind mount (host folder)
docker volume inspect mydata
docker volume rm mydata
```

## Networking
```bash
docker network ls
docker network create appnet
docker run -d --name db --network appnet postgres:16-alpine
docker network inspect appnet
```

## Docker Compose
```bash
docker compose up -d --build     # build and start everything in the background
docker compose ps                # status and health
docker compose logs -f web       # follow one service's logs
docker compose exec web sh       # shell into a service
docker compose down              # stop and remove containers + network (keeps volumes)
docker compose down -v           # ...and DELETE volumes (wipes data)
docker compose config            # print the resolved configuration
```

## Clean up
```bash
docker system df                 # disk usage
docker system prune              # remove stopped containers, unused networks, dangling images
```
