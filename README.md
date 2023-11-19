# Build ElasticFusion in Docker

``` sh
docker compose build
docker-compose up
```

Manually start ElasticFusion:

``` sh
docker container run -it --rm --gpus all \
  -v ./ElasticFusion:/home/user/ElasticFusion \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --network=host \
  -e DISPLAY=${DISPLAY} nvidia11 bash
MESA_GL_VERSION_OVERRIDE=3.3 ./ElasticFusion -l ../dyson_lab.klg
```
