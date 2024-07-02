copy plugins:
docker cp {path}/myallo-auth kong:/usr/local/share/lua/5.1/kong/plugins

copy updated kong.conf file:
docker cp {path}/kong.conf kong:/etc/kong/kong.conf
