#!/bin/sh



# Starting
source ./install.config;
echo "Starting to import certificates..";

### Gerate Certifiactes (Optional) - Testing Purposes Only ###
# Comment this out to skip to this step and just import cert you provide
# Will only generate missing certs.
./gen-certs.sh;



### OpenXPKI Trust Chain ###
# Root - Certificate
$INSTALLSITESCRIPT/openxpkiadm certificate import --file $ROOT_CA_CERT;
cp $ROOT_CA_CERT $OPENXPKI_CONFIG_DIR/tls/chain/$(basename $ROOT_CA_CERT);

# Issuer - Certificate
$INSTALLSITESCRIPT/openxpkiadm certificate import --file $ISSUER_CA_CERT;
cp $ISSUER_CA_CERT $OPENXPKI_CONFIG_DIR/tls/chain/$(basename $ISSUER_CA_CERT);



## Alias Tokens
# Datavault - Certificate & Key
$INSTALLSITESCRIPT/openxpkiadm alias --file $DATAVAULT_CERT --realm $REALM --token datasafe --key $DATAVAULT_KEY;
sleep 1;

# Issuer CA - Certificate & Key
$INSTALLSITESCRIPT/openxpkiadm alias --file $ISSUER_CA_CERT --realm $REALM --token certsign --key $ISSUER_CA_KEY;

# SCEP RA - Certificate & Key
$INSTALLSITESCRIPT/openxpkiadm alias --file $SCEP_RA_CERT --realm $REALM --token scep  --key $SCEP_RA_KEY;



## Install Web Certs
cp $WEB_CERT $OPENXPKI_CONFIG_DIR/tls/endentity/$(basename $WEB_CERT);
cp $WEB_KEY $OPENXPKI_CONFIG_DIR/tls/private/$(basename $WEB_KEY);
# SSLCertificateChainFile is obsolete > Apache 2.4.8 - combine into cert
cat $ISSUER_CA_CERT >> $OPENXPKI_CONFIG_DIR/tls/endentity/$(basename $WEB_CERT);
cat $ROOT_CA_CERT >> $OPENXPKI_CONFIG_DIR/tls/endentity/$(basename $WEB_CERT);



# Set Permissions
chown -f -R root:root $OPENXPKI_CONFIG_DIR/tls/chain;
chmod -f 640 $(find $OPENXPKI_CONFIG_DIR/tls/chain -type f);

chown -f -R root:root $OPENXPKI_CONFIG_DIR/tls/endentity;
chmod -f 640 $(find $OPENXPKI_CONFIG_DIR/tls/endentity -type f);

chown -f -R root:root $OPENXPKI_CONFIG_DIR/tls/private;
chmod -f 600 $(find $OPENXPKI_CONFIG_DIR/tls/private -type f);

chown -f -R $OPENXPKI_USR:root $OPENXPKI_CONFIG_DIR/local/keys;
chmod -f 640 $(find $OPENXPKI_CONFIG_DIR/local/keys -type f);



# Exiting
echo "Finished importing certificates..";
exit 0;
