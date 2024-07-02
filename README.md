# MyAllo Auth


### Installation

Docker and destination container (kong) must me running

copy plugins: 
```sh
docker cp {path}/myallo-auth kong:/usr/local/share/lua/5.1/kong/plugins
```

copy updated kong.conf file: 
```sh
docker cp {path}/kong.conf kong:/etc/kong/kong.conf
```
