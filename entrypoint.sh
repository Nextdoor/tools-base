#!/bin/bash

set -e

# if running root, fix permissions and drop root
if [[ $(id -u) -eq 0 ]]; then
    # Fixup user:user uid:gid to match host
    USER=user
    GROUP=user
    VOLUME=/work/target
    HOST_UID="$(stat -c '%u' $VOLUME)"
    HOST_GID="$(stat -c '%g' $VOLUME)"
    USER_UID="$(id -u $USER)"
    USER_GID="$(id -g $USER)"
    if [[ $HOST_UID -ne $USER_UID || $HOST_GID -ne $USER_GID ]]; then
        chown $USER_UID:$USER_GID /work
        groupmod -g $USER_GID $GROUP
        usermod -u $USER_UID -g $USER_GID $USER
        chown -R $USER_UID:$USER_GID /home/$USER
    fi
    # Drop root and run as matched user
    exec gosu "$USER" "$@"
else
    # Continue execution as requested user
    exec "$@"
fi
