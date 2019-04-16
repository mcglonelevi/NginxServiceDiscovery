# Nginx Service Discovery - Experimental

## Introduction

This was an experiment that I did to see if I could build a very basic service discovery script for Nginx.  There is a very basic ruby script that detects changes in DNS entries for upstream hosts.  When `docker-compose up -d --scale web=<NUMBER>` is run, the DNS entries for the web service are updated.  The script will reload the Nginx config every minute.

This is basically a hack job at the moment.  **Do not run this in production.**

## Setup

If you want to run this, install Packer, Ansible, and Docker:

https://www.packer.io/
https://www.ansible.com/
https://www.docker.com/

After installing all of these, run `packer build build.json`

Run `docker image list` and get the ID of the most recent image.  Paste that value into docker-compose.yml file replacing this value: 7e2aa9410ab3

Run `docker-compose up -d`

Then, run `docker exec -it nginx-service-discovery_nginx-discovery_1 /bin/bash` to open a shell into the service discovery box.

Then run `cd dns-sync && ruby poll.rb`.  This will start the DNS refresh.

In your web browser, you can open `http://localhost:8080/`.  Use network inspector to watch the X-Upstream header change.

To see how failed requests are handled, run `docker-compose up -d --scale web=2` and refresh a few times until you get
directed to the downed host.  You should see two ip addresses in the X-Upstream header.  When the config refreshes, you
can check /etc/nginx/nginx.conf inside the container to make sure the number of upstreams matches the number of containers
running the web service.
