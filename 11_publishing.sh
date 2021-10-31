#!/bin/sh



# Starting
source ./install.config;
echo "Starting to set up publishing..";



# This is where CA & CRL are published via the webui i.e. written to disk
mkdir -p $OPENXPKI_PUBLISH_DIR;
chown -f $OPENXPKI_USR:$OPENXPKI_USR $OPENXPKI_PUBLISH_DIR;
chmod -f 755 $OPENXPKI_PUBLISH_DIR;
# Configure @ config.d/realm/$REALM/publishing.yaml



# Exiting
echo "Finished setting up publishing..";
exit 0;
