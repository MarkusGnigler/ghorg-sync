docker run -it --rm \
    -e TZ=Europe/Vienna \
    -e CRON_SCHEDULE="* * * * *" \
    -v ${PWD}/config/ghorg:/root/.config/ghorg \
    -v ${PWD}/config/rclone:/root/.config/rclone \
    ghcr.io/markusgnigler/ghorg-sync:latest \
    $@