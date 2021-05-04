# Docker Compose for Swarm

This is a very basic example on how to use this image.

```
version: "3.4"
services:
  clusterVIP:
    image: eladhaim22/keepalived:latest
    hostname: "{{.Node.Hostname}}"
    volumes:
      - /mnt/myvol1/keepalived:/config
    deploy:
      mode: global
      resources:
        reservations:
          cpus: '0.1'
          memory: 5M
        limits:
          cpus: '0.5'
          memory: 10M
    environment:
      - PRIORITY=150
      - INTERFACE=eth0
      - ROUTER_ID=200
      - VIRTUAL_IPS=192.168.1.254
      - PASSWORD=any password you want
    networks:
      - outside
    cap_add:
      - NET_ADMIN

networks:
  outside:
    external:
      name: "host"
