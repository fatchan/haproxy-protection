#!/bin/sh
tor -f /etc/tor/torrc &
sleep 30
if [ -f /var/lib/tor/hidden_service/hostname ]; then
    echo "Hidden Service Address:"
    cat /var/lib/tor/hidden_service/hostname
else
    echo "Hidden service address file not found."
fi

#keep the container running
tail -f /dev/null
