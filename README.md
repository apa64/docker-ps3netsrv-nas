# Docker and ps3netsrv on Synology DS216j NAS

> My Docker and ps3netsrv setup for Synology DS216j NAS.

## Docker setup

```shell
# download
$ curl https://download.docker.com/linux/static/stable/armhf/docker-28.0.1.tgz -o docker-28.0.1.tgz
#...
$ tar xzvf docker-28.0.1.tgz
docker/
docker/ctr
docker/containerd-shim-runc-v2
docker/docker
docker/docker-init
docker/containerd
docker/docker-proxy
docker/runc
docker/dockerd

# install bin
$ sudo mv docker/* /usr/local/bin

# env
$ sudo mkdir /volume1/@docker

# config
$ sudo mkdir /usr/local/etc/docker
$ sudo chmod a+rx /usr/local/etc/docker
$ sudo vi /usr/local/etc/docker/daemon.json
# sisältö:
{
  "storage-driver": "vfs",
  "iptables": false,
  "bridge": "none",
  "data-root": "/volume1/@docker"
}
$ sudo chmod a+r /usr/local/etc/docker/daemon.json
$ sudo synogroup --add docker root
Group Name: [docker]
Group Type: [AUTH_LOCAL]
Group ID:   [65536]
Group Members:
0:[root]

# start script, system runs at boot with "<scriptname> start"
$ sudo cp S01docker.sh /usr/local/etc/rc.d
$ sudo chmod a+rx /usr/local/etc/rc.d/S01docker.sh
```

Add user to docker group:
- Synology Control Panel - User & Group - User - **nasadmin** - Edit - User Groups - **docker** - add - Save

## PS3netsrv setup

- Copy S99ps3netsrv.sh start script to `/usr/local/etc/rc.d/S99ps3netsrv.sh`.
