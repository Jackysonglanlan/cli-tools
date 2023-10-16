#!/bin/bash
#
# retrieveip.txt - Script containing two functions to automatically grab IP dynamically
#

RetrieveIP() {
  nic="$1"
  TEMP=""

  if ! /sbin/ifconfig | grep $nic > /dev/null; then
    echo -e "\n\n interface $nic does not exist...  Aborting!"
    exit 1;
  fi

  TEMP=`ifconfig $nic | awk '/inet addr/ { gsub(".*:", "", $2) ; print
$2 }'`

  if [ "$TEMP" = '' ]; then
    echo "Aborting: Unable to determine the IP of $nic ... DHCP problem?"
    exit 1
  fi
}

RetrieveBC() {
  nic="$1"
  BROADCAST=`ifconfig $nic | awk '/inet addr/ { gsub(".*:", "", $3) ; print $3 }'`
}
