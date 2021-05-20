NAME=socat-tunnel
SRC_PORT=80
TARGET_HOST=remote_host
TARGET_PORT=80

docker rm -f $NAME

docker run -d --name $NAME --publish 0.0.0.0:$SRC_PORT:12345 --restart unless-stopped \
    alpine/socat \
    -d -d tcp-listen:12345,reuseaddr,fork,max-children=1000 tcp:$TARGET_HOST:$TARGET_PORT

docker ps
