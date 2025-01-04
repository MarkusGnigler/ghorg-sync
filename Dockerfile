FROM alpine:3.21

RUN apk add --update --no-cache \
    tar zip \
    supercronic tzdata \
    git \
    curl

# rclone
# COPY --from=rclone/rclone:latest /usr/bin/rclone /usr/bin/rclone
RUN \
    curl -L -o /tmp/rclone.zip https://downloads.rclone.org/rclone-current-linux-amd64.zip && \
    unzip /tmp/rclone.zip -d /tmp && \
    mv /tmp/rclone-*-linux-amd64/rclone /usr/local/bin/rclone && \
    chmod +x /usr/local/bin/rclone && \
    rm -rf /tmp/rclone.zip /tmp/rclone-*-linux-amd64
RUN mkdir -p /root/.config/rclone
VOLUME [ "/root/.config/rclone" ]

# # ghorg
# # COPY --from=ghcr.io/gabrie30/ghorg:latest /usr/local/bin/ghorg /usr/local/bin/ghorg
RUN \
    curl -L -o /tmp/ghorg.tar.gz https://github.com/gabrie30/ghorg/releases/download/v1.11.0/ghorg_1.11.0_Linux_x86_64.tar.gz && \
    tar -xzf /tmp/ghorg.tar.gz -C /tmp && \
    mv /tmp/ghorg /usr/local/bin/ghorg && \
    chmod +x /usr/local/bin/ghorg && \
    rm /tmp/ghorg.tar.gz
RUN mkdir -p /root/.config/ghorg
VOLUME [ "/root/.config/ghorg" ]
VOLUME [ "/data" ]

WORKDIR /app

# scripts
COPY scripts/*.sh /app/
RUN chmod +x /app/*.sh

ENV \
    DATA_PATH=/data \
    COMPRESSION=zip
    
ENTRYPOINT [ "sh", "./entrypoint.sh" ]