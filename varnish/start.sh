#!/bin/sh
set -e

varnishd -F -a /shared-sockets/haproxy-to-varnish-cache.sock -f /etc/varnish/default.vcl -s file,/var/lib/varnish/cache.bin,1G -p feature=+http2 &
varnishncsa -a -w /var/log/varnish/access.log -D
tail -f /var/log/varnish/access.log

wait
