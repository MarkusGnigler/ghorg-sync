#!/bin/sh

RESET='\033[0m'
function color() {
    local stamp=$(date "+%Y-%m-%d %H:%M:%S")
    local text="[$stamp] $2"
    case $1 in
        red)     echo -e "\033[31m${text}${RESET}" ;;
        green)   echo -e "\033[32m${text}${RESET}" ;;
        yellow)  echo -e "\033[33m${text}${RESET}" ;;
        blue)    echo -e "\033[34m${text}${RESET}" ;;
        none)    echo "$text" ;;
    esac
}

# --- functions ---

# ghorg

gsync() {
    color blue "Starting gitlab sync"

    output=$(ghorg clone all-groups --preserve-dir --path=$DATA_PATH 2>&1)

    if [[ $? != 0 ]]; then
        color red "ghorg failed:"
        echo red $output
        exit 1
    fi
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
# rclone remote derectory
REMOTE_DIR=${REMOTE_DIR:-remote:GitRepoBackup}
# Minimum age for cleanup (e.g., 7 days)
MIN_AGE=${MIN_AGE:-7d}  

rclone_setup() {
    rclone config
}

rclone_sync() {
    local source_dircetory=$1

    color blue "Starting remote sync"

    rclone copy $source_dircetory $REMOTE_DIR
    if [[ $? != 0 ]]; then
        color red "Upload failed: $?"
    fi
}

rclone_cleanup() {
    color blue "Cleanup remote"

    rclone lsf --min-age $MIN_AGE $REMOTE_DIR | \
    while read -r file; do
        rclone delete "$REMOTE_DIR/$file"
    done
    if [[ $? != 0 ]]; then
        color red "Cleanup failed: $?"
    fi
}

# cleanup

cleanup() {
    local source_dircetory=$1

    color blue "Cleanup data folder"

    rm -rf $source_dircetory/*
}

# --- run it ---

main() {
    gsync

    color blue "Starting compression"
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
            color red "ERROR: Unsupported compression type. Use 'zip' or 'tar'."
            exit 1
            ;;
    esac

    rclone_sync $DIRECTORY_PATH

    rclone_cleanup

    cleanup $DATA_PATH

    color green "Finished"
    echo ""
}

main

exit 0