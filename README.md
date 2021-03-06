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
Took as many [deps from RHEL/EPEL](01_rhel_perl-deps.sh) rpms as possible and the [rest from CPAN](02_cpan_perl-deps.sh). Struggled with this, but the list provided works.
  

#### Security Policies
The default umask 027 causes some of the Perl modules installed via CPAN or along with openxpki-core [to have incorrect permissions](03_openxpki-core.sh#L57).


#### FIPS mode
LibSCEP and the Crypt::LibSCEP [do not pass tests](10_libscep.sh) due to FIPS mode:

`digital envelope routines:EVP_DigestInit_ex:disabled for FIPS:crypto/evp/digest.c`

However scep is completely functional with 3DES & SHA256.


#### SELinux
Allow [HTTP/S](00_prep_system.sh#L78): `setsebool -P httpd_can_network_connect on`.

Keep SELinux enabled but configure to permit http & fcgi [to write to log file](08_logging.sh#L44) and [socket](03_openxpki-core.sh#L94).
|type|file|
| :------------ | :------------ |
|httpd_sys_script_ra_t|webui.log|
|httpd_sys_ra_content_t|rpc.log|
|httpd_sys_ra_content_t|scep.log|
|httpd_sys_ra_content_t|soap.log|
|httpd_sys_rw_content_t|openxpki.socket|

The openxpki backend daemon deletes/creates the openxpki.socket on start/stop causing the SELinux permission to break (requiring `restorecon`). Apply the SELinux permissions to the directory instead so that the new socket file inherits the SELinux settings.
