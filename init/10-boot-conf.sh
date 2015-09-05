#!/bin/bash

set -euo pipefail
set -x

update-ca-certificates

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
