docker build -t ghorg-sync .
docker run -it --rm \
    --name ghorg-sync \
    -e TZ=Europe/Vienna \
    -e CRON_SCHEDULE="* * * * *" \
    -v ${PWD}/config/ghorg:/root/.config/ghorg \
    -v ${PWD}/config/rclone:/root/.config/rclone \
    ghorg-sync \
    $@