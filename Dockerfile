####################
# BASE IMAGE
####################
FROM ubuntu:20.04

ARG TARGETARCH

####################
# INSTALLATIONS
####################
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
        curl \
        cron \
        fuse \
        unionfs-fuse \
        bc \
        unzip \
        wget \
        ca-certificates && \
    update-ca-certificates && \
    apt-get install -y openssl && \
    sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/{apt,dpkg,cache,log}/

####################
# ENVIRONMENT VARIABLES
####################
# Encryption
ENV ENCRYPT_MEDIA "1"
ENV READ_ONLY "1"

# Rclone
ENV BUFFER_SIZE "500M"
ENV MAX_READ_AHEAD "30G"
ENV CHECKERS "16"
ENV RCLONE_CLOUD_ENDPOINT "gd-crypt:"
ENV RCLONE_LOCAL_ENDPOINT "local-crypt:"

# Plexdrive
ENV PLEXDRIVE_VERSION "5.1.0"
ENV CHUNK_SIZE "1M"
ENV MAX_CHUNK "100"

# Time format
ENV DATE_FORMAT "+%F@%T"

# Local files removal
ENV REMOVE_LOCAL_FILES_BASED_ON "space"
ENV REMOVE_LOCAL_FILES_WHEN_SPACE_EXCEEDS_GB "100"
ENV FREEUP_ATLEAST_GB "80"
ENV REMOVE_LOCAL_FILES_AFTER_DAYS "30"

# Plex
ENV PLEX_URL ""
ENV PLEX_TOKEN ""

#cron
ENV CLOUDUPLOADTIME "0 1 * * *"
ENV RMDELETETIME "0 6 * * *"

####################
# S6 overlay
####################
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_KEEP_ENV=1

ADD https://github.com/just-containers/s6-overlay/releases/download/v2.1.0.2/s6-overlay-amd64-installer /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer /

####################
# SCRIPTS
####################
COPY setup/* /usr/bin/
COPY install.sh /
COPY scripts/* /usr/bin/
COPY root /

RUN chmod a+x /install.sh && \
    sh /install.sh && \
    chmod a+x /usr/bin/* && \
    groupmod -g 1000 users && \
	useradd -u 911 -U -d / -s /bin/false abc && \
	usermod -G users abc

####################
# VOLUMES
####################
# Define mountable directories.
VOLUME /data /cloud-encrypt /cloud-decrypt /local-decrypt /local-media /log

RUN chmod -R 777 /data /log && \
    mkdir /config

####################
# WORKING DIRECTORY
####################
WORKDIR /data

####################
# ENTRYPOINT
####################
ENTRYPOINT ["/init"]
CMD cron -f
