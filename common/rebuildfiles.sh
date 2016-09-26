#!/bin/bash

cp -rf /etc/asterisk/local/common/privatenodes.txt /etc/asterisk/local/privatenodes.txt
sleep 1
echo "Privatenodes.txt file Copied"

cp -rf /etc/asterisk/local/common/commands.include  /etc/asterisk/commands.include
sleep 1
echo "commands.include file Copied"

cp -rf /etc/asterisk/local/common/nodes.include /etc/asterisk/nodes.include
sleep 1
echo "Nodes.include file Copied"

cp -rf /etc/asterisk/local/common/rebuildfiles.sh /usr/local/bin/rebuildfiles.sh
sleep 1
echo "rebuildfiles.sh file Copied"

cp -rf /etc/asterisk/local/common/rebuildcalls.sh /usr/local/bin/rebuildcalls.sh
sleep 1
echo "rebuildcalls.sh file Copied"

/usr/local/sbin/astdb.php
echo "astdb updated" 
sleep 1

/usr/local/bin/write_node_callsigns
echo "rebuild callsign names"
sleep 1

/usr/bin/asterisk -rx reload
echo "Asterisk reloaded"

echo "Done!"
exit


