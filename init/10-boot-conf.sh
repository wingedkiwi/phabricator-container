#!/bin/bash

set -euo pipefail
set -x

config_ssh_key() {
    local file_name=ssh_host_${1}_key
    if [ -e /config/${file_name} ]; then
        echo "Copy $1 private key"
        cp /config/${file_name} /etc/ssh/${file_name}
        chmod 600 /etc/ssh/${file_name}
        echo "Derive $1 public key"
        ssh-keygen -y -f /etc/ssh/${file_name} > /etc/ssh/${file_name}.pub
    fi
}

update-ca-certificates

if [ -e /config/update-exim4.conf.conf ]; then
    echo "Copy update-exim4.conf.conf..."
    cp -f /config/update-exim4.conf.conf /etc/exim4/update-exim4.conf.conf
fi

echo "Apply update-exim4.conf..."
update-exim4.conf

pushd /opt/phabricator

if [ -e /config/script.pre ]; then
    echo "Applying pre-configuration script..."
    /config/script.pre
else
    set +x
    echo "+++++ MISSING CONFIGURATION +++++"
    echo ""
    echo "You must specify a preconfiguration script for "
    echo "this Docker image.  To do so: "
    echo ""
    echo "  1) Create a 'script.pre' file in a directory "
    echo "     called 'config', somewhere on the host. "
    echo ""
    echo "  2) Run this Docker instance again with "
    echo "     -v path/to/config:/config passed as an "
    echo "     argument."
    echo ""
    echo "+++++ BOOT FAILED! +++++"
    exit 1
fi

popd

config_ssh_key rsa
config_ssh_key dsa
config_ssh_key ecdsa
config_ssh_key ed25519

pushd /opt/phabricator
if [ -e /config/preamble.php ]; then
    echo "Copy preamble script"
    cp /config/preamble.php support/preamble.php
    chown git:wwwgrp-phabricator support/preamble.php
    chmod 755 support/preamble.php
fi
popd

if [ -e /config/script.premig ]; then
    echo "Applying pre-migration script..."
    /config/script.premig
fi

echo "Applying any pending DB schema upgrades..."
/opt/phabricator/bin/storage upgrade --force

pushd /opt/phabricator

if [ -e /config/script.post ]; then
    echo "Applying post-configuration script..."
    /config/script.post
fi

popd
