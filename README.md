# Serval CORE Worker
*Serval CORE Worker* is an extension of the *CORE worker* for the MACI experiment suite. Serval is integrated in CORE to enable fast development of experiments using MACI.

## Standalone Quickstart
Although this container is intended to be used with MACI, it works as a standalone container. To work with the CORE GUI, some prequisites have to be met.

1. Install X11 / XQuartz
2. Configure X to allow connections from network clients (XQuartz -> Settings -> Security -> Allow Network Clients)
3. Add the remote docker host to the `xhost` access control list (`xhost +<DOCKER_HOST_IP>`) OR disable the access control list (`xhost +`).

The container can be started adding your IP to the DISPLAY variable: 
```
docker run --rm --privileged -v /lib/modules:/lib/modules -it --cap-add=NET_ADMIN -e DISPLAY=<IP>:0 umrds/serval_core_worker-gui
```

##### Hint: Docker for Mac users can use the special hostname `docker.for.mac.localhost`:
```
docker run --rm --privileged -v /lib/modules:/lib/modules -it --cap-add=NET_ADMIN -e DISPLAY=docker.for.mac.localhost:0 umrds/serval_core_worker-gui
```



## Serval
Serval is compiled from source during the `docker build` process and installed in `$PATH`. 

The `servald` processes on the CORE nodes are isolated by setting `$SERVALINSTANCE_PATH` to `$PWD` either in `/root/.bashrc` (interactive) or `/root/.serval` through `$BASH_ENV` (non-interactive).

### Widgets
Some CORE GUI widgets are defined to interactively inspect the serval daemon. 

### Default Config
```
interfaces.0.match=*
server.motd="<NODE_NAME>"
api.restful.users.pum.password=pum123
debug.rhizome=true
``` 

### Mobile phone node
A mobile phone node is added to `dotcore/nodes.conf`, which has serval started by default. 



## MACI: Headless and GUI worker

This worker is available with a gui (based on `maciresearch/core_worker-gui`) to be used during experiment development as well as a headless version (based on `maciresearch/core_worker`) for lightweight experiment runs. 

### Build images
```
docker build -t umrds/serval_core_worker .
docker build -t umrds/serval_core_worker-gui -f Dockerfile.gui .
``` 