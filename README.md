## NGINX Configuration for newbook.cakephp.org

This repository contains primarily just the NGINX configuration used to serve the
[newbook.cakephp.org](https://newbook.cakephp.org) website and all its versions.

Changes commited to this branch get auto deployed via dokku to our server and applied immediately.

Don't get confused by the `Procfile` and `web.py` file as they are only needed for dokku to actually
build a working container - which doesn't do anything.

The NGINX config gets extract out of that image and applied to the main NGINX server running on the host.