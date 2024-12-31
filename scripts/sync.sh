#!/bin/sh

GREEN='\033[0;32m'
RESET='\033[0m'
log() {
    local text=$1

    echo -e "${GREEN}${text}${RESET}"
}
function color() {
    case $1 in
        red)     echo -e "\033[31m$2\033[0m" ;;
        green)   echo -e "\033[32m$2\033[0m" ;;
        yellow)  echo -e "\033[33m$2\033[0m" ;;
        blue)    echo -e "\033[34m$2\033[0m" ;;
        none)    echo "$2" ;;
    esac
}

# --- functions ---

# ghorg

gsync() {
    ghorg clone all-groups --preserve-dir --path=$DATA_PATH > /dev/null
}

# compressions

zipit() {
    local source_dircetory=$1
    

    zip -q -r $source_dircetory $DATA_PATH
}

tarit() {
    local source_dircetory=$1

    tar -czvf $source_dircetory -C $(dirname $DATA_PATH) $(basename $DATA_PATH)
}

# rclone

rclone_setup() {
    rclone config
}

rclone_sync() {
    local source_dircetory=$1

    rclone sync $source_dircetory remote:GitRepoBackup
}

# cleanup

cleanup() {
    local source_dircetory=$1

    rm -rf $source_dircetory/*
}

# --- run it ---

main() {
    log "Starting gitlab sync"
    gsync

    log "Starting compression"
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    case "$COMPRESSION" in
        zip)
            FILE_NAME="backup_${TIMESTAMP}.zip"
            DIRECTORY_PATH="$DATA_PATH/$FILE_NAME"
            zipit $DIRECTORY_PATH
            ;;
        tar)
            FILE_NAME="backup_$TIMESTAMP.tar.gz"
            DIRECTORY_PATH="$DATA_PATH/$FILE_NAME"
            tarit $DIRECTORY_PATH
            ;;
        *)
            echo "ERROR: Unsupported compression type. Use 'zip' or 'tar'."
            exit 1
            ;;
    esac

    log "Starting remote sync"
    rclone_sync $DIRECTORY_PATH

    log "Cleanup data folder"
    cleanup $DATA_PATH

    log "Finished"
    echo ""
}

main

exit 0