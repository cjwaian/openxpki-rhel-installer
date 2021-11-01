#!/bin/sh



# Starting
source ./install.config;
echo "Starting to set up logging directory..";



# Create Log Directory
mkdir -p $OPENXPKI_LOG_DIR;
chown -f $OPENXPKI_USR:$OPENXPKI_USR $OPENXPKI_LOG_DIR;
chmod -f 755 $OPENXPKI_LOG_DIR;



# openxpki.log
touch $OPENXPKI_LOG_DIR/openxpki.log;
chown -f $OPENXPKI_USR:root $OPENXPKI_LOG_DIR/openxpki.log;
chmod -f 600 $OPENXPKI_LOG_DIR/openxpki.log;

# scep.log
touch $OPENXPKI_LOG_DIR/scep.log;
chown -f $APACHE_USER:$APACHE_USER $OPENXPKI_LOG_DIR/scep.log;
chmod -f 644 $OPENXPKI_LOG_DIR/scep.log;

# soap.log
touch $OPENXPKI_LOG_DIR/soap.log;
chown -f $APACHE_USER:$APACHE_USER $OPENXPKI_LOG_DIR/soap.log;
chmod -f 644 $OPENXPKI_LOG_DIR/soap.log;

# webui.log
touch $OPENXPKI_LOG_DIR/webui.log;
chown -f $APACHE_USER:$APACHE_USER $OPENXPKI_LOG_DIR/webui.log;
chmod -f 644 $OPENXPKI_LOG_DIR/webui.log;

#rpc.log
touch $OPENXPKI_LOG_DIR/rpc.log;
chown -f $APACHE_USER:$APACHE_USER $OPENXPKI_LOG_DIR/rpc.log;
chmod -f 644 $OPENXPKI_LOG_DIR/rpc.log;


# SELinux
# semanage fcontext -a -t httpd_sys_script_ra_t $OPENXPKI_LOG_DIR/webui.log;
semanage fcontext -a -t httpd_sys_ra_content_t $OPENXPKI_LOG_DIR/webui.log;
restorecon $OPENXPKI_LOG_DIR/webui.log;

semanage fcontext -a -t httpd_sys_ra_content_t $OPENXPKI_LOG_DIR/rpc.log;
restorecon $OPENXPKI_LOG_DIR/rpc.log;

semanage fcontext -a -t httpd_sys_ra_content_t $OPENXPKI_LOG_DIR/scep.log;
restorecon $OPENXPKI_LOG_DIR/scep.log;

semanage fcontext -a -t httpd_sys_ra_content_t $OPENXPKI_LOG_DIR/soap.log;
restorecon $OPENXPKI_LOG_DIR/soap.log;


# Exiting
echo "Finished setting up logging directory..";
exit 0;
