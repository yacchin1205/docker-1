# BigBlueButton docker

## Define variables with host and container name ( only used during the setup )
```
NAME=shailon
HOSTNAME=$NAME.bbbvm.imdt.com.br
```

## Create folder and clone the BBB code
```
mkdir $HOME/$NAME/
cd $HOME/$NAME/
git clone https://github.com/bigbluebutton/bigbluebutton.git

cd

BBB_SRC_FOLDER=$HOME/$NAME/bigbluebutton
```

## Download the certificates
```
mkdir $HOME/$NAME/certs/ -p
wget http://a.bbbvm.imdt.com.br/certs/fullchain.pem -O $HOME/$NAME/certs/fullchain.pem
wget http://a.bbbvm.imdt.com.br/certs/privkey.pem -O $HOME/$NAME/certs/privkey.pem
```

## Create the container ( version 2.3 )

```
docker run -d --name=$NAME --hostname=$HOSTNAME --env="container=docker" --env="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" --env="DEBIAN_FRONTEND=noninteractive" --volume="/var/run/docker.sock:/var/run/docker.sock:rw" --cap-add="NET_ADMIN" --network=docker_backend --privileged --volume="$HOME/$NAME/certs/:/local/certs:rw" --volume="/sys/fs/cgroup:/sys/fs/cgroup:ro" --volume="$BBB_SRC_FOLDER:/home/bbb/src:rw" -t imdt/bigbluebutton:2.3.x

docker exec -u bbb -it $NAME /bin/bash -l 
```

