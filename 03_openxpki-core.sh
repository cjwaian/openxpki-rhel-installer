#!/bin/sh



# Starting
source ./install.config;
echo "Setting up openxpki-core..";


# Compiler requirements
dnf -y install git-core gcc openssl-devel perl perl-Config-Std;


# Clone OpenXPKI git repo
git clone https://github.com/openxpki/openxpki.git --branch=master $OPENXPKI_SRC_DIR;


# Install Openxpki Core
cd $WORK_DIR/$OPENXPKI_SRC_DIR/core/server;
perl -w ./Makefile.PL INSTALLSITESCRIPT=$INSTALLSITESCRIPT;
make;
make install;

# Install Openxpki I18N (localization)
cd $WORK_DIR/$OPENXPKI_SRC_DIR/core/i18n
perl -w ./Makefile.PL;
make scan;
make;
make install;



# Create Openxpki User
useradd --system --no-create-home $OPENXPKI_USR;


cd $WORK_DIR;
### Create Systemd Unit File openxpkid
if [ ! -f $SYSTEMD_SERVICE_FILE ] ; then
    echo "Downloading Systemd openxpkid.service..";
    curl $SYSTEMD_SERVICE_URL > $SYSTEMD_SERVICE_FILE;

    sed -i "s~apache2.service~httpd.service~" $SYSTEMD_SERVICE_FILE
    sed -i "s~^PIDFile=.*$~PIDFile=${OPENXPKI_PID}~" $SYSTEMD_SERVICE_FILE
    sed -i "s~^ExecStart=.*$~ExecStart=${INSTALLSITESCRIPT}/openxpkictl start --nd~" $SYSTEMD_SERVICE_FILE
    sed -i "s~^ExecStop=.*$~ExecStop=${INSTALLSITESCRIPT}/openxpkictl stop~" $SYSTEMD_SERVICE_FILE
fi

cp $SYSTEMD_SERVICE_FILE /usr/lib/systemd/system/openxpkid.service;
chown -f root:root /usr/lib/systemd/system/openxpkid.service;
chmod -f 644 /usr/lib/systemd/system/openxpkid.service;

systemctl daemon-reload;



### Set Permission for Perl Modules ###
# RHEL w/ security settings changes the umask so that the modules dont come
# with the execute priv, this is a sledge hammer fix

# RHEL Default INSTALLPRIVLIB
chown -f -R root:root /usr/share/perl5/;
chmod -f 755 $(find /usr/share/perl5 -type d);
chmod -f 644 $(find /usr/share/perl5 -type f);

# RHEL Default INSTALLARCHLIB
chown -f -R root:root /usr/lib64/perl5;
chmod -f 755 $(find /usr/lib64/perl5 -type d);
chmod -f 644 $(find /usr/lib64/perl5 -type f);

# CPAN Default INSTALLSITELIB
chown -f -R root:root /usr/local/share/perl5;
chmod -f 755 $(find /usr/local/share/perl5 -type d);
chmod -f 644 $(find /usr/local/share/perl5 -type f);

# CPAN Default INSTALLSITEARCH
chown -f -R root:root /usr/local/lib64/perl5;
chmod -f 755 $(find /usr/local/lib64/perl5 -type d);
chmod -f 644 $(find /usr/local/lib64/perl5 -type f);



# PID File
touch $OPENXPKI_PID;
chown -f root:root $OPENXPKI_PID;
chmod -f 644 $OPENXPKI_PID;

# Socket
mkdir -p $SOCKET_DIR;
chown -f $OPENXPKI_USR:$OPENXPKI_USR $SOCKET_DIR;
chmod -f 750 $SOCKET_DIR;
# Apply the SELinux permissions to the directory, the openxpki.socket file itself is deleted/created on
# openxpkictl start/stop so we have to apply it here so that the contents inherit the SELinux Settings
semanage fcontext -a -t httpd_sys_rw_content_t $SOCKET_DIR;
restorecon $SOCKET_DIR;

touch $SOCKET_FILE;
chown -f $OPENXPKI_USR:$OPENXPKI_USR $SOCKET_FILE;
chmod -f 770 $SOCKET_FILE;
# Apply the SELinux permissions to the directory, the openxpki.socket file itself is deleted/created on
# openxpkictl start/stop so we have to apply it here so that the contents inherit the SELinux Settings
# semanage fcontext -a -t httpd_sys_rw_content_t $SOCKET_FILE;
# restorecon $SOCKET_FILE;


# Exiting
echo "Finished setting up openxpki-core..";
exit 0;
