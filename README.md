phabricator-container
---------------------

_phabricator-container_ is a port of [hach-que-docker/phabricator](https://github.com/hach-que-docker/phabricator) that differs in the following points:

  - Based on [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker) instead of [hach-que-docker/systemd-none](https://github.com/hach-que-docker/systemd-none)
  - Doesn't use SSH login on Port 24
  - Allows preamble.php configuration
  - Allows sshd keys configuration
  - Currently no support for SSL

Configuration
-------------

To configure this image, create a `config` directory, with the following files in it:
  - An executable `script.pre` file to configure phabricator. See below.
  - Optionally a `preamble.php` file. See the [phabricator docs](https://secure.phabricator.com/book/phabricator/article/configuring_preamble/) to learn more about preamble configuration.
  - Optionally include the following keys for the sshd server:
    - `ssh_host_rsa_key`, `ssh_host_rsa_key.pub`
    - `ssh_host_ed25519_key`, `ssh_host_ed25519_key.pub`
    - `ssh_host_ecdsa_key`, `ssh_host_ecdsa_key.pub`
    - `ssh_host_dsa_key`, `ssh_host_dsa_key.pub`

Example `script.pre` file:

    #!/bin/bash

    # Set the name of the host running MySQL:
    ./bin/config set mysql.host "example.com"

    # If MySQL is running on a non-standard port:
    #./bin/config set mysql.port 3306

    # Set the username for connecting to MySQL:
    ./bin/config set mysql.user "root"

    # Set the password for connecting to MySQL:
    ./bin/config set mysql.pass "password"

    # Set the base URI that will be used to access Phabricator:
    ./bin/config set phabricator.base-uri "http://myphabricator.com/"

Usage
----------

    /usr/bin/docker run -p 80:80 -p 22:22 -p 22280:22280 -v /path/to/config:/config -v /path/to/repo/storage:/srv/repo --name=phabricator wingedkiwi/phabricator-container

What do these parameters do?

    -p 80:80 = forward the host's HTTP port ot Phabricator for web access
    -p 22:22 = forward the host's SSH port to Phabricator for repository access
    -p 22280:22280 = forward the host's 22280 port for the notification server
    -v path/to/config:/config = map the configuration from the host to the container
    -v path/to/repo/storage:/srv/repo = map the repository storage from the host to the container
    --name phabricator = the name of the container
    wingedkiwi/phabricator-container = the name of the image


