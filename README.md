# docker-centos-sshd-systemd

Docker image for CentOS including SSHD and SystemD.

## Specifications

##### OS

* SSHD
* systemd

##### Users

* user=`root`, password=`root`
* user=`user`, password=`user`
	* passwordless sudo user
	* owns SSH key

##### SSHD

* root login is not permitted
* password authentification is not permitted
* user authentification is passwordless via SSH key
	* ssh public key `./secret/ssh/sshkey.pub` is imported into container

##### SSH-key

* passphrase is unset
* owned by user

## Usage

##### Build

```sh
docker build --rm --tag=abc --label="xyz" .
```

##### Run

* note the important **`--privileged`** parameter

```sh
docker run --tty --detach --privileged --publish 22:22 --label="xyz" -v /sys/fs/cgroup:/sys/fs/cgroup:ro abc
```

##### Work

```sh
# get container ID
CONTAINER_ID=$(docker ps --quiet --all --filter "status=running" --filter "label=xyz")


# get container IP
CONTAINER_IP=$(docker inspect ${CONTAINER_ID} | grep -E '^\s*"IPAddress": ".*$' | grep -ohE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | head -1)


# connect to the running container
ssh -i ./secret/ssh/sshkey user@${CONTAINER_IP}
```

##### Stop

```sh
docker stop `docker ps --quiet --all --filter "status=running" --filter "label=xyz"`
```

## FAQ

##### Warning: Remote host identification has changed

* warning output:

```txt
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ECDSA key sent by the remote host is
SHA256:xxxxxxxxxxxxx/xxxxxxxxxxxxxxxxxxx/xxxxxxxxx.
Please contact your system administrator.
Add correct host key in /home/${USER}/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /home/${USER}/.ssh/known_hosts:2
  remove with:
  ssh-keygen -f "/home/${USER}/.ssh/known_hosts" -R "172.17.0.2"
ECDSA host key for 172.17.0.2 has changed and you have requested strict checking.
Host key verification failed.
```

* solution:

```sh
echo > ~/.ssh/known_hosts
```

##### How to change the placeholding SSH keys?

1. clone this repository
1. change the ssh key files in `./secret/ssh/sshkey`
1. build it (follow the usage instruction from [*Build* section](#build))

## Further Reading

Container problem relater to systemd:

* https://serverfault.com/questions/824975/failed-to-get-d-bus-connection-operation-not-permitted

CentOS7 container including only systemd:

* https://hub.docker.com/r/centos/systemd

How to run systemd in a container:

* https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container/

Dockerize an SSH service:

* https://docs.docker.com/engine/examples/running_ssh_service/
