#!/bin/bash
## DESCRIPTION
## Uses curl to update multiple dynamic dns entries
## based on https://helmingstay.blogspot.com/p/afraidorg-script-for-amazon-ec2.html
## 
## INSTRUCTIONS 
## FIRST, update <-DIRECT_URLS-> (below)
## THEN, it doesn't hurt to do the following (change permissions)
## chmod 700 ddns.sh
## FINALLY, add the following line to crontab
## */5 * * * * /<-PATH->/ddns.sh >/dev/null 2>&1

PATH="/root/ddns"
OLDIP_FILE="${PATH}/ip.tmpfile"

IPV4="https://api.ipify.org"
IPV6="https://ifconfig.me"
CURRENTIP=$(/usr/bin/curl -s "${IPV4}")

DIRECT_URLS=(
  "https://www.duckdns.org/update?domains=<-DOMAIN1;DOMAIN2...->&token=<-APIkey->&ip=$CURRENTIP"
  "https://freedns.afraid.org/dynamic/update.php?<-APIkey->"
)

echo "Current IP: $CURRENTIP"

if [ ! -e "${OLDIP_FILE}" ]; then
echo "Creating ${OLDIP_FILE}"
echo "0.0.0.0" > "${OLDIP_FILE}"
fi

OLDIP=$(/usr/bin/cat "${OLDIP_FILE}")

if [ "${CURRENTIP}" != "${OLDIP}" ]; then
echo "Issuing update command"
for URL in "${DIRECT_URLS[@]}"; do
echo "Updating $URL"
/usr/bin/curl -s -k "{$URL}" > "${PATH}/ddns.log"
done
fi

echo "Saving IP"
echo "${CURRENTIP}" > "${OLDIP_FILE}"
