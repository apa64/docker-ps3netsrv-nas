# Docker and ps3netsrv on Synology DS216j NAS

> My Docker and ps3netsrv setup for Synology DS216j NAS.

The problem is that there's no longer a supported Docker package from Synology for the DS216j. Luckily there's an ARM build of Docker which can be run even in such a resource constrained platform.

## 0. Start setup

SSH to the NAS.

## 1. Docker setup

```shell
# Download Docker
$ curl https://download.docker.com/linux/static/stable/armhf/docker-28.0.1.tgz -o docker-28.0.1.tgz
# Unpack
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

# Install
$ sudo mv docker/* /usr/local/bin

# Create a data directory to avoid running out of space on root partition.
$ sudo mkdir /volume1/@docker

# Create Docker configuration
$ sudo mkdir /usr/local/etc/docker
$ sudo chmod a+rx /usr/local/etc/docker
# Copy `daemon.json` from this repo to `/usr/local/etc/docker`
$ cat > daemon.json
...
$ sudo cp daemon.json /usr/local/etc/docker
$ sudo chmod a+r /usr/local/etc/docker/daemon.json

# Create group
$ sudo synogroup --add docker root
Group Name: [docker]
Group Type: [AUTH_LOCAL]
Group ID:   [65536]
Group Members:
0:[root]

# Copy the start script from this repo, system runs it at boot with "<scriptname> start"
$ cat > S01docker.sh
...
$ sudo cp S01docker.sh /usr/local/etc/rc.d
$ sudo chmod a+rx /usr/local/etc/rc.d/S01docker.sh
```

Add user to `docker` group:
- Synology Control Panel - User & Group - User - **YOUR-NAS-USER** - Edit - User Groups - `docker` - add - Save

## 2. PS3netsrv setup

- The script assumes that the data to serve on NAS is in share `data` folder `/ps3netsrv` (`/volume1/data/ps3netsrv`). Modify the `docker run` command as needed.
- Copy `S99ps3netsrv.sh` start script from this repo to `/usr/local/etc/rc.d/S99ps3netsrv.sh`.

```shell
$ cat > S99ps3netsrv.sh
...
$ sudo cp S99ps3netsrv.sh /usr/local/etc/rc.d
$ sudo chmod a+rx /usr/local/etc/rc.d/S99ps3netsrv.sh
```

## 3. Done

Restart the NAS.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

Distributed under the [MIT](https://choosealicense.com/licenses/mit/) License. See `LICENSE` for details.

## Acknowledgments

This repository is made possible and builds on the work of the following talented people and projects:

- [aldostools and ps3netsrv (GitHub)](https://github.com/aldostools/webMAN-MOD/tree/master/_Projects_/ps3netsrv)
- [shawly/docker-ps3netsrv (GitHub)](https://github.com/shawly/docker-ps3netsrv/)
- [shawly/ps3netsrv (DockerHub)](https://hub.docker.com/r/shawly/ps3netsrv)
- [DaveMDS/get-docker.sh (GitHub Gist)](https://gist.github.com/DaveMDS/c35d77e51e0186a4fe2e577f51a5b09a)
- [PSX-Place PS3 forums](https://www.psx-place.com/forums/#playstation-3-forums.5)
- [Make a README](https://www.makeareadme.com/)

## Contact

- GitHub repository: [apa64/docker-ps3netsrv-nas](https://github.dev/apa64/docker-ps3netsrv-nas/)
- Mastodon: [@apa64@mementomori.social](https://mementomori.social/@apa64)
