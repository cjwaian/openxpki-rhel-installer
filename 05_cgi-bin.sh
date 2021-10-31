#!/bin/sh



# Starting
source ./install.config;
echo "Starting to set up cgi-bin..";


# dnf -y install mod_fcgid perl-FCGI perl-CGI perl-CGI-Fast
# Most deps should be previously perl deps: perl-FCGI perl-CGI perl-CGI-Fast
# mod_fcgid will be installed with apache



# Make CGI Directory(/usr/lib/cgi-bin)
mkdir -p $CGI_BIN_DIR;
chown -f root:root $CGI_BIN_DIR;
chmod -f 755 $CGI_BIN_DIR;

# Copy .fcgi files to dir
cp $OPENXPKI_SRC_DIR/core/server/cgi-bin/*.fcgi $CGI_BIN_DIR/;

# Set Permissions on .fcgi files
chown -f -R root:root $CGI_BIN_DIR/;
chmod -f -R 755 $CGI_BIN_DIR/;



# Exiting
echo "Finished setting up cgi-bin..";
exit 0;