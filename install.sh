#!/bin/sh

## Run As:  ./install.sh > install.log 2>&1 &

# Requires restart root
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root." ; exit 1 ; fi


# Import installation variables
source ./install.config;



./00_prep_system.sh;

./01_rhel_perl-deps.sh;

./02_cpan_perl-deps.sh;

./03_openxpki-core.sh;

./04_openxpki-config.sh;

./05_cgi-bin.sh;

./06_mariadb.sh;

./07_apache.sh;

./08_logging.sh;

./09_openxpki-cgi-session-driver.sh;

./10_libscep.sh

./11_publishing.sh;

systemctl enable --now openxpkid

./12_import-certs.sh;

systemctl enable --now httpd



exit 0;
