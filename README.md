# OpenXPKI Installer for RHEL
##### White Rabbit Security GmbH, the founders and maintainers of OpenXPKI, offers a [RHEL package for enterprise](https://www.whiterabbitsecurity.com/produkte/openxpki/); consider supporting them.
------------
This script aims to install [OpenXPKI](https://github.com/openxpki/openxpki "OpenXPKI") on RHEL with the built-in Security Policy configured for NIST 800-171, CMMC L3, or DISA STIG compliance, providing a FIPS 140-2 validated PKI solution.

Built and tested on:
- RHEL 8.4
- NIST 800-171 Security Policy
- FIPS Mode
- OpenXPKI 3.14
------------


#### Perl Dependenices
Took as many deps from RHEL/EPEL rpms as possible and the rest from CPAN. Struggled with this, but the list provided works.
  

#### Security Policies
The default umask 027 causes some of the Perl modules installed via CPAN or along with openxpki-core to have incorrect permissions.


#### FIPS mode
[LibSCEP](https://github.com/Javex/libscep.git) and the [Crypt::LibSCEP](https://metacpan.org/pod/Crypt::LibSCEP) do not pass tests due to FIPS mode:

`digital envelope routines:EVP_DigestInit_ex:disabled for FIPS:crypto/evp/digest.c`


#### SELinux
|type|file|
| :------------ | :------------ |
|httpd_sys_script_ra_t|webui.log|
|httpd_sys_ra_content_t|rpc.log|
|httpd_sys_ra_content_t|scep.log|
|httpd_sys_ra_content_t|soap.log|
|httpd_sys_rw_content_t|openxpki.socket|
