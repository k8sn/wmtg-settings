#!/bin/bash

cp -r /etc/asterisk/local/common/privatenodes.txt /etc/asterisk/local/privatenodes.txt
sleep 1
echo "Privatenodes.txt file Copied"

/usr/local/sbin/astdb.php
echo "astdb updated"
sleep 1

/usr/local/bin/write_node_callsigns -o
echo "forcing rebuild callsign names"
sleep 1

/usr/bin/asterisk -rx reload
echo "Asterisk reloaded"

echo "Done!"
exit


