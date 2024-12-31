# ghorg-sync

A thin wrapper around [ghorg](https://github.com/gabrie30/ghorg) to add remote syncing capabilities with rclone.

---

### Config

#### scheduling

Possible env settings are:

```bash
CRON_SCHEDULE="* * * * *"
CRON_COMMAND=/app/sync.sh
```

#### ghorg

ghorg is configured via the regular [config-file](https://github.com/gabrie30/ghorg#configuration) and its mounted under `/root/.config/ghorg`

#### rclone

rclone is configured via the regular [config-file](https://rclone.org/docs/) and its mounted under `/root/.config/rclone`


### Examples

The `--init` flag is neccessary for the setgid of the crond binary

```bash
docker run -d \
    --init \
    -v ${PWD}/config/ghorg:/root/.config/ghorg \
    -v ${PWD}/config/rclone:/root/.config/rclone \
    ghcr.io/markusgnigler/ghorg-sync:latest
```