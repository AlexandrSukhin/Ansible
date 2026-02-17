#!/bin/bash
CONTAINER=$1

echo "Реконструированная команда для $CONTAINER:"
echo "docker run \\"

# Образ
IMAGE=$(docker inspect --format='{{.Config.Image}}' $CONTAINER)
echo "  --name $CONTAINER \\"
echo "  $IMAGE \\"

# Порты
PORTS=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{$p}}:{{index $conf 0}.HostPort}} {{end}}' $CONTAINER)
if [ -n "$PORTS" ]; then
    for PORT in $PORTS; do
        echo "  -p $PORT \\"
    done
fi

# Тома
MOUNTS=$(docker inspect --format='{{range .Mounts}}{{.Source}}:{{.Destination}}:{{if .Mode}}{{.Mode}}{{else}}rw{{end}} {{end}}' $CONTAINER)
if [ -n "$MOUNTS" ]; then
    for MOUNT in $MOUNTS; do
        echo "  -v $MOUNT \\"
    done
fi

# Переменные окружения
ENV=$(docker inspect --format='{{range .Config.Env}}{{println "-e" .}}{{end}}' $CONTAINER)
if [ -n "$ENV" ]; then
    echo "$ENV \\" | tr '\n' ' '
fi

echo ""
