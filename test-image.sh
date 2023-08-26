IMAGE="";PORT=""
docker rm -f casjaysdevdocker-$IMAGE;
rm -Rf "$HOME/.local/share/srv/docker/casjaysdevdocker-$IMAGE";
docker run -d  --pull always --restart always --privileged --name casjaysdevdocker-$IMAGE \
--hostname $IMAGE -e TZ=${TIMEZONE:-America/New_York} \
-v $HOME/.local/share/srv/docker/casjaysdevdocker-$IMAGE/rootfs/data:/data:z \
-v $HOME/.local/share/srv/docker/casjaysdevdocker-$IMAGE/rootfs/config:/config:z \
-p $PORT casjaysdevdocker/$IMAGE:latest
docker ps -a | grep -q "casjaysdevdocker-$IMAGE" && dockermgr log --follow casjaysdevdocker-$IMAGE
