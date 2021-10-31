# OpenXPKI Installer for RHEL
##### Whiterabbit Security the founders and maintainers of OpenXPKI offers a [RHEL package for enterprise](https://www.whiterabbitsecurity.com/produkte/openxpki/ "OpenXPKI offers a RHEL package for enterprise"), consider supporting them.
------------
This script aims to install [OpenXPKI](https://github.com/openxpki/openxpki "OpenXPKI") on RHEL with the built-in Security Policy configured for NIST 800-171, CMMC L3, or DISA STIG compliance, providing a FIPS 140-2 validated PKI solution.

Built and tested on:
- RHEL 8.4
- NIST 800-171 Security Policy
- FIPS Mode
- OpenXPKI 3.14
------------


#### Perl Dependenices
As many deps from RHEL/EPEL rpms as possible with what I couldnt find from CPAN. I struggled with this but the list I've compiled works.


#### Security Policies
Default umask 027 causes some of the perl modules installed via CPAN or along with openxpki-core to have incorrect permissions.


#### FIPS mode
[LibSCEP](https://github.com/Javex/libscep.git "LibSCEP") and the [Crypt::LibSCEP](https://metacpan.org/pod/Crypt::LibSCEP "Crypt::LibSCEP") does not pass tests, due to FIPS mode:

`digital envelope routines:EVP_DigestInit_ex:disabled for FIPS:crypto/evp/digest.c`


#### SELinux
|type|file|
| :------------ | :------------ |
|httpd_sys_script_ra_t|webui.log|
|httpd_sys_ra_content_t|rpc.log|
|httpd_sys_ra_content_t|scep.log|
|httpd_sys_ra_content_t|soap.log|
|httpd_sys_rw_content_t|openxpki.socket|
