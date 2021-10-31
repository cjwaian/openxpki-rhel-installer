#!/bin/sh

# Starting
source ./install.config;
echo "Starting to set up web server..";



# Install HTTPd
dnf -y install httpd mod_fcgid mod_ssl;



# Download the Apache .conf if APACHE_CONF_FILE is NOT provided
if [ ! -f $APACHE_CONF_FILE ] ; then
    echo "Downloading Apache .conf to ${APACHE_CONF_FILE}";
    curl $APACHE_CONF_URL > $APACHE_CONF_FILE;

    # Modify the apache conf
    # SSLCertificateFile & SSLCertificateChainFile
    WEB_CERT_BASENAME=$(basename $WEB_CERT)
    sed -i "s~SSLCertificateFile.*$~SSLCertificateFile ${OPENXPKI_CONFIG_DIR}/tls/endentity/${WEB_CERT_BASENAME}~" $APACHE_CONF_FILE;
    sed -i "s~SSLCertificateChainFile.*$~SSLCertificateChainFile ${OPENXPKI_CONFIG_DIR}/tls/endentity/${WEB_CERT_BASENAME}~" $APACHE_CONF_FILE;

    # SSLCertificateKeyFile
    WEB_KEY_BASENAME=$(basename $WEB_KEY)
    sed -i "s~SSLCertificateKeyFile.*$~SSLCertificateKeyFile ${OPENXPKI_CONFIG_DIR}/tls/private/${WEB_KEY_BASENAME}~" $APACHE_CONF_FILE;

    # SSLCACertificatePath
    sed -i "s~SSLCACertificatePath.*$~SSLCACertificatePath ${OPENXPKI_CONFIG_DIR}/tls/chain/~" $APACHE_CONF_FILE;

    #DocumentRoot
    sed -i "s~DocumentRoot.*$~DocumentRoot ${WEB_ROOT_DIR}~" $APACHE_CONF_FILE;

    # ScriptAlias /scep
    sed -i "s~ScriptAlias /scep.*$~ScriptAlias /scep ${CGI_BIN_DIR}/scep.fcgi~" $APACHE_CONF_FILE;

    # ScriptAlias /healthcheck
    sed -i "s~ScriptAlias /healthcheck.*$~ScriptAlias /healthcheck ${CGI_BIN_DIR}/healthcheck.fcgi~" $APACHE_CONF_FILE;

    # ScriptAlias /rpc
    sed -i "s~ScriptAlias /rpc.*$~ScriptAlias /rpc ${CGI_BIN_DIR}/rpc.fcgi~" $APACHE_CONF_FILE;

    # ScriptAlias /.well-known/est
    sed -i "s~ScriptAlias /\.well-known/est.*$~ScriptAlias /\.well-known/est ${CGI_BIN_DIR}/est.fcgi~" $APACHE_CONF_FILE;

    # ScriptAlias /cmc
    sed -i "s~ScriptAlias /cmc.*$~ScriptAlias /cmc ${CGI_BIN_DIR}/cmc.fcgi~" $APACHE_CONF_FILE;

    sed -i "s~cgi-bin/webui.fcgi\s.*$~cgi-bin/webui.fcgi ${CGI_BIN_DIR}/webui.fcgi~" $APACHE_CONF_FILE;

    sed -i "s~\$\s.*/index.html\s\[L\]$~\$ ${WEB_OPENXPKI_DIR}/index.html [L]~" $APACHE_CONF_FILE;

    sed -i "s~)\s.*\$2\s\[L\,NC\]$~) ${WEB_OPENXPKI_DIR}/\$2 [L,NC]~" $APACHE_CONF_FILE;

    sed -i "s~Directory\s\"/usr/lib/cgi-bin/\"$~Directory \"${CGI_BIN_DIR}/\"~" $APACHE_CONF_FILE;

    sed -i "s~Directory\s/var/www/$~Directory ${WEB_ROOT_DIR}/~" $APACHE_CONF_FILE;

    sed -i "s~OPENXPKI_SCEP_CLIENT_CONF_SOCKET.*$~OPENXPKI_SCEP_CLIENT_CONF_SOCKET ${SOCKET_FILE}/~" $APACHE_CONF_FILE;

    sed -i "s~OPENXPKI_RPC_CLIENT_CONF_SOCKET.*$~OPENXPKI_RPC_CLIENT_CONF_SOCKET ${SOCKET_FILE}/~" $APACHE_CONF_FILE;

    sed -i "s~OPENXPKI_EST_CLIENT_CONF_SOCKET.*$~OPENXPKI_EST_CLIENT_CONF_SOCKET ${SOCKET_FILE}/~" $APACHE_CONF_FILE;

fi

# Copy Apache .conf to APACHE_CONF_DIR
cp $APACHE_CONF_FILE $APACHE_CONF_DST;

# Set permissions on Apache .conf
chown -f root:$APACHE_USER $APACHE_CONF_DST;
chmod -f 644 $APACHE_CONF_DST;



# Add apache user to openxpki user
usermod -G $OPENXPKI_USR $APACHE_USER;



# Make www root directory
mkdir -p $WEB_OPENXPKI_DIR;
chown -f root:root $WEB_OPENXPKI_DIR;
chmod -f 755 $WEB_OPENXPKI_DIR;


# Install Website
cp -r $OPENXPKI_SRC_DIR/core/server/htdocs/* $WEB_OPENXPKI_DIR/;


# Set Permissions On Website
chown -f root:root $WEB_OPENXPKI_DIR/assets;
chmod -f 755 $WEB_OPENXPKI_DIR/assets;

chown -f -R root:root $WEB_OPENXPKI_DIR/assets/*;
chmod -f 644 -R $WEB_OPENXPKI_DIR/assets/*;

chown -f root:root $WEB_OPENXPKI_DIR/fonts;
chmod -f 755 $WEB_OPENXPKI_DIR/fonts;

chown -f -R root:root $WEB_OPENXPKI_DIR/fonts/*;
chmod -f 644 -R $WEB_OPENXPKI_DIR/fonts/*;

chown -f root:root $WEB_OPENXPKI_DIR/img;
chmod -f 755 $WEB_OPENXPKI_DIR/img;

chown -f -R root:root $WEB_OPENXPKI_DIR/img/*;
chmod -f 644 -R $WEB_OPENXPKI_DIR/img/*;

chown -f root:root $WEB_OPENXPKI_DIR/index.html;
chmod -f 644 $WEB_OPENXPKI_DIR/index.html;

chown -f root:root $WEB_OPENXPKI_DIR/localconfig.yaml.template;
chmod -f 644 $WEB_OPENXPKI_DIR/localconfig.yaml.template;

chown -f root:root $WEB_OPENXPKI_DIR/default.html;
chmod -f 644 $WEB_OPENXPKI_DIR/default.html;

chown -f root:root $WEB_OPENXPKI_DIR/favicon.png;
chmod -f 644 $WEB_OPENXPKI_DIR/favicon.png;



# Static Directory
# The default configuration has a static HTML page set as the home for the `User` role.
# The code for this page must be manually placed to `/var/www/static/<realm>/home.html`,
# an example can be found in the `contrib` directory. If you don't want a static page,
# remove the `welcome` and `home` items from the `uicontrol/_default.yaml`

# Create Static Directory
mkdir -p $WEB_STATIC_DIR;
chown -f root:root $WEB_STATIC_DIR;
chmod -f 755 $WEB_STATIC_DIR;

# Create Realm Directory
mkdir -p $WEB_STATIC_DIR/$REALM;
chown -f $APACHE_USER:$APACHE_USER $WEB_STATIC_DIR/$REALM;
chmod -f 755 $WEB_STATIC_DIR/$REALM;

# Download home.html if WEB_STATIC_INDEX is NOT provided
if [ ! -f $WEB_STATIC_INDEX ] ; then
    echo "Downloading home.html to ${WEB_STATIC_INDEX}";
    curl $WEB_STATIC_URL > $WEB_STATIC_INDEX;
fi

# Copy home.html into the realm static directory
cp $WEB_STATIC_INDEX $WEB_STATIC_DIR/$REALM/home.html;
chown -f root:root $WEB_STATIC_DIR/$REALM/home.html;
chmod -f 644 $WEB_STATIC_DIR/$REALM/home.html;



# HTML Templating
# This is where you add your branding
# Download localconfig.yaml if WEB_TEMPLATE_FILE is NOT provided
if [ ! -f $WEB_TEMPLATE_FILE ] ; then
    echo "Downloading localconfig.yaml to ${WEB_TEMPLATE_FILE}";
    curl $WEB_TEMPLATE_URL > $WEB_TEMPLATE_FILE;
fi

# Copy localconfig.yaml into the openxpki web directory
cp $WEB_TEMPLATE_FILE $WEB_OPENXPKI_DIR/localconfig.yaml;
chown -f root:root $WEB_OPENXPKI_DIR/localconfig.yaml;
chmod -f 644 $WEB_OPENXPKI_DIR/localconfig.yaml;

# Remove localconfig.yaml.template if exists
if [ -f $WEB_TEMPLATE_FILE ] ; then
    rm $WEB_OPENXPKI_DIR/localconfig.yaml.template;
fi


# Copy custom.css into the openxpki web directory
if [ -f $CUSTOM_CSS_FILE ] ; then
    cp $CUSTOM_CSS_FILE $WEB_OPENXPKI_DIR/custom.css;
else
    # Have to create this file or else errors
    touch $WEB_OPENXPKI_DIR/custom.css;
    # Edit localconfig.yaml to point to the custom.css file
    # another option would be to comment it out with this:
    #   sed -i "s/^customCssPath/#customCssPath/" $WEB_OPENXPKI_DIR/localconfig.yaml;
    sed -i "s~^customCssPath\:.*$~customCssPath: ${WEB_OPENXPKI_DIR}/custom.css~" $WEB_OPENXPKI_DIR/localconfig.yaml;
fi
chown -f root:root $WEB_OPENXPKI_DIR/custom.css;
chmod -f 644 $WEB_OPENXPKI_DIR/custom.css;



# Open Firewalld ports
firewall-cmd --permanent --zone=public --add-service=http;
firewall-cmd --permanent --zone=public --add-service=https;
firewall-cmd --reload;




# Exiting
echo "Finished setting up web server..";
exit 0;
