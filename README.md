phabricator-container
---------------------

_phabricator-container_ is a port of [hach-que-docker/phabricator](https://github.com/hach-que-docker/phabricator) that differs in the following points:

- Based on [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker) instead of [hach-que-docker/systemd-none](https://github.com/hach-que-docker/systemd-none)
- Doesn't use SSH login on Port 24
- Allows preamble.php configuration
- Currently no support for SSL

Usage
----------

To configure this image, create a `config` directory, with a `script.pre` file inside it.  This
file should be marked as executable.  Place the following content in that file:

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

Additionally you can create a `preamble.php` script in the `config` directory. See the [phabricator docs](https://secure.phabricator.com/book/phabricator/article/configuring_preamble/) to know more about preamble configuration.

To run this image:

    /usr/bin/docker run -p 80:80 -p 22:22 -p 22280:22280 -v /path/to/config:/config -v /path/to/repo/storage:/srv/repo --name=phabricator wingedkiwi/phabricator-container

What do these parameters do?

    -p 80:80 = forward the host's HTTP port ot Phabricator for web access
    -p 22:22 = forward the host's SSH port to Phabricator for repository access
    -p 22280:22280 = forward the host's 22280 port for the notification server
    -v path/to/config:/config = map the configuration from the host to the container
    -v path/to/repo/storage:/srv/repo = map the repository storage from the host to the container
    --name phabricator = the name of the container
    wingedkiwi/phabricator-container = the name of the image


