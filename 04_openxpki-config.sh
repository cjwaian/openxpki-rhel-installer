#!/bin/sh



# Starting
source ./install.config;
echo "Starting to set up openxpki-config..";



dnf -y install git-core;
# git-core should already be installed



# If config dir supplied move it into place as is, will only apply permissions
if [ -d $IMPORT_OPENXPKI_CONFIG_DIR ] ; then
    echo "Importing supplied openxpki-config to $OPENXPKI_CONFIG_DIR";
    # copy openxpki-config to /etc/openxpki
    cp -R $IMPORT_OPENXPKI_CONFIG_DIR $OPENXPKI_CONFIG_DIR;
else
    echo "Downloading openxpki-config...";
    git clone https://github.com/openxpki/openxpki-config.git --branch=community $IMPORT_OPENXPKI_CONFIG_DIR;
    # Insert version info and configure some I18N stuff
    cd $WORK_DIR/$IMPORT_OPENXPKI_CONFIG_DIR;
    make;
    cd ..;


    # /etc/openxpki
    mkdir -p $OPENXPKI_CONFIG_DIR;

    # openxpki/config.d
    mkdir -p $OPENXPKI_CONFIG_DIR/config.d;

    # openxpki/system
    cp -R $IMPORT_OPENXPKI_CONFIG_DIR/config.d/system $OPENXPKI_CONFIG_DIR/config.d/system/;

    # system/database.yaml
    sed -i "s/name\:.*$/name\: ${DB_NAME}/" $OPENXPKI_CONFIG_DIR/config.d/system/database.yaml;
    sed -i "s/user\:.*$/user\: ${DB_USER_NAME}/" $OPENXPKI_CONFIG_DIR/config.d/system/database.yaml;
    sed -i "s/passwd\:.*$/passwd\: ${DB_USER_PASS}/" $OPENXPKI_CONFIG_DIR/config.d/system/database.yaml;

    # system/server.yaml
    sed -i "s~log4perl\:.*$~log4perl: ${OPENXPKI_CONFIG_DIR}/log.conf~" $OPENXPKI_CONFIG_DIR/config.d/system/server.yaml;
    sed -i "s~group\:.*$~group: ${OPENXPKI_USR}~" $OPENXPKI_CONFIG_DIR/config.d/system/server.yaml;
    sed -i "s~socket_file\:.*$~socket_file: ${SOCKET_FILE}~" $OPENXPKI_CONFIG_DIR/config.d/system/server.yaml;
    sed -i "s~pid_file\:.*$~pid_file: ${OPENXPKI_PID}~" $OPENXPKI_CONFIG_DIR/config.d/system/server.yaml;
    sed -i "s~stderr\:.*$~stderr: ${OPENXPKI_LOG_DIR}/stderr.log~" $OPENXPKI_CONFIG_DIR/config.d/system/server.yaml;
    sed -i "s~directory\:.*$~directory: ${SESSION_DIR}~" $OPENXPKI_CONFIG_DIR/config.d/system/server.yaml;

    # Update openxpki/system/realms.yaml to reference our realm
    sed -i "s/^democa/$REALM/" $OPENXPKI_CONFIG_DIR/config.d/system/realms.yaml;
    sed -i "s/label\:.*$/label: ${REALM_LONG_NAME}/" $OPENXPKI_CONFIG_DIR/config.d/system/realms.yaml;
    sed -i "s~baseurl:.*$~baseurl: ${REALM_URL}~" $OPENXPKI_CONFIG_DIR/config.d/system/realms.yaml;


    # openxpki/config.d/realm
    mkdir -p $OPENXPKI_CONFIG_DIR/config.d/realm;

    # Move the sample realm to our realm
    cp -R $IMPORT_OPENXPKI_CONFIG_DIR/config.d/realm.tpl $OPENXPKI_CONFIG_DIR/config.d/realm/$REALM/;

    # Update openxpki/config.d/realm/$REALM/auth/handler.yaml to reference our realm
    sed -i "s/democa/$REALM/" $OPENXPKI_CONFIG_DIR/config.d/realm/$REALM/auth/handler.yaml;

    # Change password for test accounts in auth/handler.yaml
    SALT=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16);
    CRYPT_ARGS="'${TEST_ACCT_PASSWD}','\$6\$${SALT}\$'";
    HASH=$(perl -e "print crypt(${CRYPT_ARGS})");
    sed -i "s~digest:.*$~digest: \"${HASH}\"~" $OPENXPKI_CONFIG_DIR/config.d/realm/$REALM/auth/handler.yaml;

    # Update openxpki/config.d/realm/$REALM/publishing.yaml
    sed -i 's/ldap\@/#ldap@/' $OPENXPKI_CONFIG_DIR/config.d/realm/$REALM/publishing.yaml;
    sed -i "s~LOCATION\:.*$~LOCATION\: ${OPENXPKI_PUBLISH_DIR}~" $OPENXPKI_CONFIG_DIR/config.d/realm/$REALM/publishing.yaml;

    # openxpki/local/keys - this is where datavault keys go
    mkdir -p $OPENXPKI_CONFIG_DIR/local/keys;

    # openxpki/log.conf
    cp $IMPORT_OPENXPKI_CONFIG_DIR/log.conf $OPENXPKI_CONFIG_DIR/log.conf;
    sed -i "s~log4perl\.appender\.Logfile\.filename\s=.*$~log4perl.appender.Logfile.filename = ${OPENXPKI_LOG_DIR}/openxpki.log~" $OPENXPKI_CONFIG_DIR/log.conf;
    sed -i "s~log4perl\.appender\.CatchAll\.filename\s=.*$~log4perl.appender.CatchAll.filename = ${OPENXPKI_LOG_DIR}/catchall.log~" $OPENXPKI_CONFIG_DIR/log.conf;
    sed -i "s~log4perl\.appender\.ApplicationFile\.filename\s=.*$~log4perl.appender.ApplicationFile.filename = ${OPENXPKI_LOG_DIR}/workflows.log~" $OPENXPKI_CONFIG_DIR/log.conf;
    sed -i "s~log4perl\.appender\.AuditFile\.filename\s=.*$~log4perl.appender.AuditFile.filename = ${OPENXPKI_LOG_DIR}/audit.log~" $OPENXPKI_CONFIG_DIR/log.conf;
    sed -i "s~log4perl\.appender\.Deprecated\.filename\s=.*$~log4perl.appender.Deprecated.filename = ${OPENXPKI_LOG_DIR}/deprecated.log~" $OPENXPKI_CONFIG_DIR/log.conf;

    # openxpki/template
    cp -R $IMPORT_OPENXPKI_CONFIG_DIR/template $OPENXPKI_CONFIG_DIR/template/;

    # Sym link openxpki/notification  to  openxpki/template
    ln -s $OPENXPKI_CONFIG_DIR/template $OPENXPKI_CONFIG_DIR/notification;

    # openxpki/est
    cp -R $IMPORT_OPENXPKI_CONFIG_DIR/est $OPENXPKI_CONFIG_DIR/est/;

    # openxpki/rpc
    cp -R $IMPORT_OPENXPKI_CONFIG_DIR/rpc $OPENXPKI_CONFIG_DIR/rpc/;

    # openxpki/scep
    cp -R $IMPORT_OPENXPKI_CONFIG_DIR/scep $OPENXPKI_CONFIG_DIR/scep/;
    sed -i "s/^realm=.*$/realm=${REALM}/" $OPENXPKI_CONFIG_DIR/scep/default.conf;
    sed -i "s/value\:\sSecretChallenge.*$/value: ${SCEP_CHALLENGE}/" $OPENXPKI_CONFIG_DIR/config.d/realm/$REALM/scep/generic.yaml;
    sed -i "s/^hmac\:.*$/hmac: ${HMAC_SECRET}/" $OPENXPKI_CONFIG_DIR/config.d/realm/$REALM/scep/generic.yaml;

    # openxpki/soap
    cp -R $IMPORT_OPENXPKI_CONFIG_DIR/soap $OPENXPKI_CONFIG_DIR/soap/;

    # openxpki/webui
    cp -R $IMPORT_OPENXPKI_CONFIG_DIR/webui $OPENXPKI_CONFIG_DIR/webui/;
    sed -i "s/^NameSpace\s\=\s.*$/NameSpace = ${DB_NAME}/" $OPENXPKI_CONFIG_DIR/webui/default.conf;
    sed -i "s/^User\s\=\s.*$/User = ${DB_SESSION_USER_NAME}/" $OPENXPKI_CONFIG_DIR/webui/default.conf;
    sed -i "s/^Password\s\=\s.*$/Password = ${DB_SESSION_USER_PASS}/" $OPENXPKI_CONFIG_DIR/webui/default.conf;
    sed -i "s~^Directory\s\=\s.*$~Directory = ${SESSION_DIR}~" ${OPENXPKI_CONFIG_DIR}/webui/default.conf;
    # TODO: Add other session settings here


    # openxpki/tls
    mkdir -p $OPENXPKI_CONFIG_DIR/tls;

    # openxpki/tls/chain
    mkdir -p $OPENXPKI_CONFIG_DIR/tls/chain;

    # openxpki/tls/endentity
    mkdir -p $OPENXPKI_CONFIG_DIR/tls/endentity

    # openxpki/tls/private
    mkdir -p $OPENXPKI_CONFIG_DIR/tls/private

fi



# Setting Permissions
chown -f $OPENXPKI_USR:root $OPENXPKI_CONFIG_DIR;
chmod -f 755 $OPENXPKI_CONFIG_DIR;

# openxpki/config.d
chown -f $OPENXPKI_USR:root $OPENXPKI_CONFIG_DIR/config.d;
chmod -f 750 $OPENXPKI_CONFIG_DIR/config.d;

# openxpki/config.d/realm
chown -f -R $OPENXPKI_USR:root $OPENXPKI_CONFIG_DIR/config.d/realm/$REALM;
# These dont work because there is two files inside config.d/realm.tpl/uicontrol
# which have special characters in the file name, breaking the commands:
#   'CA Operator.yaml'
#   'RA Operator.yaml'
chmod -f 750 $(find $OPENXPKI_CONFIG_DIR/config.d/realm/$REALM -type d);
chmod -f 640 $(find $OPENXPKI_CONFIG_DIR/config.d/realm/$REALM -type f);
# TODO: Fix 'CA Operator.yaml' & 'RA Operator.yaml'

# openxpki/config.d/system
chown -f -R $OPENXPKI_USR:root $OPENXPKI_CONFIG_DIR/config.d/system
chmod -f 750 $(find $OPENXPKI_CONFIG_DIR/config.d/system -type d);
chmod -f 640 $(find $OPENXPKI_CONFIG_DIR/config.d/system -type f);

# openxpki/local
chown -f root:$OPENXPKI_USR $OPENXPKI_CONFIG_DIR/local;
chmod -f 750 $OPENXPKI_CONFIG_DIR/local;
# openxpki/local/keys
chown -f root:$OPENXPKI_USR $OPENXPKI_CONFIG_DIR/local/keys;
chmod -f 750 $OPENXPKI_CONFIG_DIR/local/keys;
# We'll run this one again when we import the datavault key
chown -f -R $OPENXPKI_USR:root $OPENXPKI_CONFIG_DIR/local/keys;
chmod -f 640 $(find $OPENXPKI_CONFIG_DIR/local/keys -type f)

# openxpki/log.conf
chown -f $OPENXPKI_USR:root $OPENXPKI_CONFIG_DIR/log.conf;
chmod -f 644 $OPENXPKI_CONFIG_DIR/log.conf;

# openxpki/template
chown -f -R $OPENXPKI_USR:root
chmod -f 755 $(find $OPENXPKI_CONFIG_DIR/template -type d);
chmod -f 644 $(find $OPENXPKI_CONFIG_DIR/template -type f);
# openxpki/notification     (sym linked to openxpki/template)

# openxpki/config.d/est
chown -f -R $OPENXPKI_USR:root $OPENXPKI_CONFIG_DIR/est;
chmod -f 755 $(find $OPENXPKI_CONFIG_DIR/est -type d);
chmod -f 644 $(find $OPENXPKI_CONFIG_DIR/est -type f);

# openxpki/config.d/rpc
chown -f -R $OPENXPKI_USR:root $OPENXPKI_CONFIG_DIR/rpc;
chmod -f 755 $(find $OPENXPKI_CONFIG_DIR/rpc -type d);
chmod -f 644 $(find $OPENXPKI_CONFIG_DIR/rpc -type f);

# openxpki/config.d/scep
chown -f -R $OPENXPKI_USR:root $OPENXPKI_CONFIG_DIR/scep;
chmod -f 755 $(find $OPENXPKI_CONFIG_DIR/scep -type d);
chmod -f 644 $(find $OPENXPKI_CONFIG_DIR/scep -type f);

# openxpki/config.d/soap
chown -f -R $OPENXPKI_USR:root $OPENXPKI_CONFIG_DIR/soap;
chmod -f 755 $(find $OPENXPKI_CONFIG_DIR/soap -type d);
chmod -f 644 $(find $OPENXPKI_CONFIG_DIR/soap -type f);

# openxpki/config.d/webui
chown -f -R $OPENXPKI_USR:root $OPENXPKI_CONFIG_DIR/webui;
chmod -f 755 $(find $OPENXPKI_CONFIG_DIR/webui -type d);
chmod -f 644 $(find $OPENXPKI_CONFIG_DIR/webui -type f);


# openxpki/tls
chown -f -R root:root $OPENXPKI_CONFIG_DIR/tls;
chmod -f 750 $(find $OPENXPKI_CONFIG_DIR/tls -type d);
chmod -f 600 $(find $OPENXPKI_CONFIG_DIR/tls -type f);

# openxpki/tls/chain
chown -f -R root:root $OPENXPKI_CONFIG_DIR/tls/chain;
chmod -f 750 $(find $OPENXPKI_CONFIG_DIR/tls/chain -type d);
chmod -f 600 $(find $OPENXPKI_CONFIG_DIR/tls/chain -type f);

# openxpki/tls/endentity
chown -f -R root:root $OPENXPKI_CONFIG_DIR/tls/endentity;
chmod -f 750 $(find $OPENXPKI_CONFIG_DIR/tls/endentity -type d);
chmod -f 640 $(find $OPENXPKI_CONFIG_DIR/tls/endentity -type f)

# openxpki/tls/private
chown -f -R root:root $OPENXPKI_CONFIG_DIR/tls/private;
chmod -f 750 $(find $OPENXPKI_CONFIG_DIR/tls/private -type d);
chmod -f 600 $(find $OPENXPKI_CONFIG_DIR/tls/private -type f)



# Exiting
echo "Finished setting up openxpki-config..";
exit 0;
