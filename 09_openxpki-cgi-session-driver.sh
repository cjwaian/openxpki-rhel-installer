#!/bin/sh



# Starting
source ./install.config;
echo "Starting to set up openxpki-cgi-session-driver..";



# OpenXPKI uses a special perl module to track http sessions
# Ref: https://openxpki.readthedocs.io/en/stable/quickstart.html?highlight=session



# Install OpenXPKI CGI Sesssion Driver
cd $WORK_DIR//$OPENXPKI_SRC_DIR/core/server/CGI_Session_Driver;
make;
make install;



# Set Perms
chown -f -R root:root /usr/share/perl5/CGI
chmod -f 755 /usr/share/perl5/CGI/Session
chmod -f 755 /usr/share/perl5/CGI/Session/Driver
chmod -f 644 /usr/share/perl5/CGI/Session/Driver/openxpki.pm



# Create directory to store sessions written to disk
# TODO: Test/Fix feature might be broken
mkdir -p $SESSION_DIR;
chown -f $APACHE_USER:$APACHE_USER $SESSION_DIR;
chmod -f 755 $SESSION_DIR;



# Exiting
echo "Finished setting up openxpki-cgi-session-driver..";
exit 0;
