#!/bin/sh



# Starting
source ./install.config;
echo "Setting up cpan perl deps..";


# Crypt::OpenSSL::AES needs openssl-devel
dnf -y install openssl-devel;



# Install CPANM
dnf -y module enable perl perl-App-cpanminus;
dnf -y install perl perl-App-cpanminus;
# Some of the CPANM perl deps might be take care of in the perl-deps-dnf script



### Install Perl Deps from CPANM ###
# We try to only install perl modules via cpan when we cant find them in RHEL/EPEL repos
# thats a decision I made to easily update them all at once and to minimize compatibility issues
# I was having with cpan modules.
#
# The order of installation matters because cpanm sucks at putting deps first
# Cross your fingers and hope everything installs without issue.

cpanm -q -i Crypt::X509;

cpanm -q -i Env;

cpanm -q -i CGI::Session;

cpanm -q -i Proc::SafeExec;

cpanm -q -i Test::utf8 IO::Digest;

cpanm -q -i Git::PurePerl;

cpanm -q -i Config::Merge Config::Versioned;

cpanm -q -i Connector;

cpanm -q -i CryptX;

cpanm -q -i Crypt::Argon2 Crypt::Cipher::AES Crypt::JWT Crypt::OpenSSL::AES Crypt::PKCS10;

cpanm -q -i DBIx::Handler;

cpanm -q -i Devel::NYTProf;

cpanm -q -i IO::Prompt;

cpanm -q -i Log::Log4perl::Layout::JSON;

cpanm -q -i Hash::Util::FieldHash::Compat;

cpanm -q -i MooseX::InsideOut;

cpanm -q -i MooseX::Params::Validate;

cpanm -q -i SQL::Abstract::More;

cpanm -q -i Mock::MonkeyPatch Class::Factory;

cpanm -q -i Workflow;



# Exiting
echo "Finished setting up cpan perl deps..";
exit 0;
