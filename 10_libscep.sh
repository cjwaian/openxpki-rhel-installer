
#!/bin/sh



# Starting
source ./install.config;
echo "Starting to set up libscep..";



# Install Dependencies
dnf -y install cmake pkgconf-pkg-config check check-devel uriparser uriparser-devel libcurl-devel;



# Install LibSCEP
# git clone https://github.com/Javex/libscep.git --branch=develop $LIBSCEP_SRC;
git clone https://github.com/openxpki/libscep.git  $LIBSCEP_SRC;
mkdir $LIBSCEP_SRC/build;
cd $LIBSCEP_SRC/build;
cmake -D LIB64=1 -D CMAKE_INSTALL_PREFIX=/usr ..;
make && make install;


# Set Perms
chown -f root:root /usr/lib64/libscep.so;
chmod -f 755 /usr/lib64/libscep.so;

chown -f root:root /usr/include/scep.h;
chmod -f 644 /usr/include/scep.h;

chown -f root:root /usr/bin/scep-client;
chmod -f 755 /usr/bin/scep-client;



# Install LibSCEP Perl Binding
cpanm -q -n -i Crypt::LibSCEP;
# Have to skip tests because they will error due to FIPS mode
# https://access.redhat.com/solutions/176633

chown -f -R root:root /usr/local/lib64/perl5/auto/Crypt/;
chmod -f 755 /usr/local/lib64/perl5/auto/Crypt/;
chmod -f 755 /usr/local/lib64/perl5/auto/Crypt/LibSCEP;
chmod -f 755 /usr/local/lib64/perl5/auto/Crypt/LibSCEP/LibSCEP.so;

chown -f root:root /usr/local/lib64/perl5/Crypt/LibSCEP.pm;
chmod -f 644 /usr/local/lib64/perl5/Crypt/LibSCEP.pm;

chown -f root:root /usr/local/share/man/man3/Crypt::LibSCEP.3pm;
chmod -f 444 /usr/local/share/man/man3/Crypt::LibSCEP.3pm;



# SSCEP is broken for RHEL, will seg fault. Install on debian system for testing
#       dnf -y install automake autoconf libtool
#       git clone https://github.com/certnanny/sscep.git $SSCEP_SRC;
#       cd $SSCEP_SRC;
#       ./bootstrap.sh;
#       ./configure;
#       make && make install;



# Instead test SCEP with the following:
# openssl req -new -keyout tmp/scep-test.key -out tmp/scep-test.csr -newkey rsa:4096 -nodes
# scep-client getca -c tmp/cacert -u http://localhost/scep/scep
# scep-client enroll -u http://localhost/scep/scep -k tmp/scep-test.key -r tmp/scep-test.csr -c tmp/cacert0 -l tmp/scep-test.crt -S sha256 -E 3des



# Exiting
echo "Finished setting up libscep..";
exit 0;
