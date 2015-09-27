#!/bin/bash

_cleanup() {
    echo "Stopping phd daemon"
    /usr/bin/sv down /etc/service/phd
}

trap _cleanup SIGINT SIGTERM
sleep infinity&
