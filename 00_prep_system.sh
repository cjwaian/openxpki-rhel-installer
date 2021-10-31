#!/bin/sh



# Starting
source ./install.config;
echo "Starting system prep..";



# Completely optional but I was reverting my VM for testing and this fixed any rhel repo issues
# Refresh RHEL repo subscription
subscription-manager refresh;
# Clean up and update packages
dnf clean all;
rm -r /var/cache/dnf;
dnf -y upgrade;



# Before we do anything ensure FIPS is on
if [[ $(update-crypto-policies --show) != 'FIPS' ]] ; then
    echo "FIPS Mode is not enabled..";
    fips-mode-setup --enable
    update-crypto-policies --set FIPS
    echo "Setting FIPS mode. Requires reboot to continue."
    exit 1;
fi
if [[ $(fips-mode-setup --check) != 'FIPS mode is enabled.' ]] ; then
    echo "FIPS Mode is not enabled..";
    fips-mode-setup --enable
    update-crypto-policies --set FIPS
    echo "Setting FIPS mode. Requires reboot to continue."
    exit 1;
fi



# Install RHEL codeready-builder repo (needed for EPEL)
CODEREADY_REPO="codeready-builder-for-rhel-8-$(/bin/arch)-rpms"
if [[ $(dnf repolist --enabled | awk '{print $1}' | grep codeready-builder) != $CODEREADY_REPO ]] ; then
    echo "Codeready-builder repo missing. Installing..";
    subscription-manager repos --enable "${CODEREADY_REPO}";
fi




# Install EPEL repo
if [[ $(dnf repolist --enabled | awk '{print $1}' | grep '^epel$') != "epel" ]] ; then
    echo "EPEL repo missing. Installing..";
    # Import Fedora gpg keys
    rpm --import https://getfedora.org/static/fedora.gpg;
    # Add EPEL repo
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm;
fi



# Haveged gives VM's extra entropy when generating crypto keys
if [[ $(which haveged) != 'haveged' ]] ; then
    echo "Haveged is not installed. Exiting.";
    # Requires EPEL repo
    dnf -y install haveged;
fi
if [[ $(systemctl is-enabled haveged) != 'enabled' ]] ; then
    echo "Enabling haveged daemon.";
    systemctl enable --now haveged;
fi
if [[ $(systemctl is-active haveged) != 'active' ]] ; then
    echo "Starting haveged daemon.";
    systemctl start haveged;
fi



# Disable SELINUX
setsebool -P httpd_can_network_connect on;


semanage fcontext -a -t httpd_sys_content_t "${WEB_ROOT_DIR}(/.*)?";
restorecon $WEB_ROOT_DIR;

semanage fcontext -a -t httpd_sys_content_t "${WEB_OPENXPKI_DIR}(/.*)?";
restorecon $WEB_OPENXPKI_DIR;

semanage fcontext -a -t httpd_sys_content_t "${WEB_STATIC_DIR}(/.*)?";
restorecon $WEB_STATIC_DIR;

semanage fcontext -a -t httpd_sys_content_t "${OPENXPKI_PUBLISH_DIR}(/.*)?";
restorecon $OPENXPKI_PUBLISH_DIR;

semanage fcontext -a -t httpd_sys_script_exec_t "${CGI_BIN_DIR}(/.*)?";
restorecon $CGI_BIN_DIR;


# semanage fcontext -a -t httpd_sys_script_ra_t $OPENXPKI_LOG_DIR/webui.log;
semanage fcontext -a -t httpd_sys_ra_content_t $OPENXPKI_LOG_DIR/webui.log;
restorecon $OPENXPKI_LOG_DIR/webui.log;

semanage fcontext -a -t httpd_sys_ra_content_t $OPENXPKI_LOG_DIR/rpc.log;
restorecon $OPENXPKI_LOG_DIR/rpc.log;

semanage fcontext -a -t httpd_sys_ra_content_t $OPENXPKI_LOG_DIR/scep.log;
restorecon $OPENXPKI_LOG_DIR/scep.log;

semanage fcontext -a -t httpd_sys_ra_content_t $OPENXPKI_LOG_DIR/soap.log;
restorecon $OPENXPKI_LOG_DIR/soap.log;


semanage fcontext -a -t httpd_sys_rw_content_t $SOCKET_FILE
restorecon $SOCKET_FILE;



## For Debugging SELinux issues
# semanage fcontext -l

# https://access.redhat.com/articles/2191331
# https://fedoraproject.org/wiki/SELinux/apache

# yum -y install setroubleshoot-server
# ausearch -m AVC,USER_AVC -ts recent
# sealert -a /var/log/audit/audit.log



# Exiting
echo "Finished system prep..";
exit 0;
