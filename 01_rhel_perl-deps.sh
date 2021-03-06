#!/bin/sh



# Starting
source ./install.config;
echo "Setting up rhel perl deps..";


# Enable modular perl
# https://developers.redhat.com/blog/2019/05/16/modular-perl-in-red-hat-enterprise-linux-8#
dnf -y module enable \
    perl \
    perl-DBD-SQLite  \
    perl-DBD-MySQL \
    perl-DBI \
    perl-FCGI \
    perl-IO-Socket-SSL \
    perl-libwww-perl;





# Perl Modules available via RHEL/EPEL Repos
# some of this might be excessive, I really struggled getting the minimal amount of packages
# installed from CPAN, which gave me tons of dependencies errors. I made dep tree's for each and
# managed to resolve them here. Some modules might be extranious but I can be bothered to clean
# them up, I've spend too much time already on this and it works.

# TODO: Clean up unncessary modules

dnf -y install \
    perl \
    perl-Archive-Extract \
    perl-Archive-Zip \
    perl-CGI \
    perl-CGI-Fast \
    perl-CPAN-Meta \
    perl-CPAN-Meta-Requirements \
    perl-CPAN-Meta-YAML \
    perl-Cache-LRU \
    perl-Capture-Tiny \
    perl-Carp \
    perl-Class-Accessor \
    perl-Compress-Raw-Zlib \
    perl-Config-Any \
    perl-Config-GitLike \
    perl-Config-Std \
    perl-Convert-ASN1 \
    perl-Crypt-Rijndael \
    perl-Crypt-X509 \
    perl-DBD-Mock \
    perl-DBD-SQLite \
    perl-DBI \
    perl-Data-Dumper \
    perl-Data-Serializer \
    perl-Data-Stream-Bulk \
    perl-Data-UUID \
    perl-DateTime \
    perl-DateTime-Format-DateParse \
    perl-DateTime-Format-Strptime \
    perl-Devel-Caller \
    perl-Digest-MD5 \
    perl-Encode \
    perl-Encode-Locale \
    perl-Exception-Class \
    perl-Exporter \
    perl-ExtUtils-CBuilder \
    perl-ExtUtils-Command \
    perl-ExtUtils-Install \
    perl-ExtUtils-MakeMaker \
    perl-ExtUtils-Manifest \
    perl-ExtUtils-ParseXS \
    perl-File-Find-Rule \
    perl-File-Slurp \
    perl-File-Which \
    perl-Getopt-Long \
    perl-HTML-Parser \
    perl-IO \
    perl-IO-Compress \
    perl-IO-Socket-SSL \
    perl-JSON \
    perl-JSON-MaybeXS \
    perl-JSON-PP \
    perl-LDAP \
    perl-LWP-Protocol-https \
    perl-List-MoreUtils \
    perl-Log-Log4perl \
    perl-MIME-Base64 \
    perl-MIME-tools \
    perl-MRO-Compat \
    perl-Math-BigInt \
    perl-Math-Complex \
    perl-Module-Build \
    perl-Module-Build-Tiny \
    perl-Module-Load \
    perl-Moose \
    perl-MooseX-NonMoose \
    perl-MooseX-StrictConstructor \
    perl-MooseX-Types-Path-Class \
    perl-Net-DNS \
    perl-Net-Server \
    perl-NetAddr-IP \
    perl-Params-Validate \
    perl-Path-Class \
    perl-PathTools \
    perl-Pod-Coverage-TrustPod \
    perl-Pod-POM \
    perl-Proc-Daemon \
    perl-Proc-ProcessTable \
    perl-Regexp-Common \
    perl-SOAP-Lite \
    perl-SQL-Abstract \
    perl-Scalar-List-Utils \
    perl-Storable \
    perl-Sub-Exporter \
    perl-Sys-SigAction \
    perl-Template-Toolkit \
    perl-TermReadKey \
    perl-Test-Differences \
    perl-Test-Exception \
    perl-Test-Fatal \
    perl-Test-Harness \
    perl-Test-Kwalitee \
    perl-Test-Most \
    perl-Test-Pod \
    perl-Test-Pod-Coverage \
    perl-Test-Requires \
    perl-Test-SharedFork \
    perl-Test-Simple \
    perl-Test-Warnings \
    perl-Text-CSV_XS \
    perl-Time-HiRes \
    perl-TimeDate \
    perl-Try-Tiny \
    perl-Want \
    perl-XML-Simple \
    perl-YAML \
    perl-YAML-Tiny \
    perl-constant \
    perl-devel \
    perl-interpreter \
    perl-libintl-perl \
    perl-libs \
    perl-libwww-perl \
    perl-namespace-autoclean \
    perl-parent \
    perl-srpm-macros \
    perl-version \
    perl-Algorithm-Diff \
    perl-AppConfig \
    perl-Archive-Any-Lite \
    perl-Archive-Extract-Z-Compress-Zlib \
    perl-Archive-Extract-bz2-IO-Uncompress-Bunzip2 \
    perl-Archive-Extract-gz-Compress-Zlib \
    perl-Archive-Extract-lzma-unlzma \
    perl-Archive-Extract-tar-Archive-Tar \
    perl-Archive-Extract-tbz-Archive-Tar-IO-Uncompress-Bunzip2 \
    perl-Archive-Extract-tgz-Archive-Tar-Compress-Zlib \
    perl-Archive-Extract-txz-tar-unxz \
    perl-Archive-Extract-xz-unxz \
    perl-Archive-Extract-zip-Archive-Zip \
    perl-Archive-Tar \
    perl-Array-Diff \
    perl-Authen-SASL \
    perl-B-Hooks-EndOfScope \
    perl-Bencode \
    perl-CPAN-DistnameInfo \
    perl-Carp-Clan \
    perl-Class-Data-Inheritable \
    perl-Class-Inspector \
    perl-Class-Load \
    perl-Class-Load-XS \
    perl-Class-Method-Modifiers \
    perl-Class-Singleton \
    perl-Class-Std \
    perl-Class-Tiny \
    perl-Class-XSAccessor \
    perl-Clone \
    perl-Clone-Choose \
    perl-Compress-Raw-Bzip2 \
    perl-Config-General \
    perl-Config-Tiny \
    perl-Convert-Bencode \
    perl-Convert-Bencode_XS \
    perl-Convert-BinHex \
    perl-Cpanel-JSON-XS \
    perl-Crypt-Blowfish \
    perl-Crypt-CBC \
    perl-Data-Binary \
    perl-Data-Denter \
    perl-Data-Dump \
    perl-Data-Dumper-Names \
    perl-Data-OptList \
    perl-Data-Section \
    perl-Data-Taxi \
    perl-Date-ISO8601 \
    perl-Date-Manip \
    perl-DateTime-Locale \
    perl-DateTime-TimeZone \
    perl-DateTime-TimeZone-SystemV \
    perl-DateTime-TimeZone-Tzfile \
    perl-Devel-CallChecker \
    perl-Devel-GlobalDestruction \
    perl-Devel-LexAlias \
    perl-Devel-OverloadInfo \
    perl-Devel-PartialDump \
    perl-Devel-StackTrace \
    perl-Devel-Symdump \
    perl-Digest \
    perl-Digest-HMAC \
    perl-Digest-SHA \
    perl-Dist-CheckConflicts \
    perl-DynaLoader-Functions \
    perl-Email-Date-Format \
    perl-Errno \
    perl-Eval-Closure \
    perl-Exporter-Tidy \
    perl-Exporter-Tiny \
    perl-ExtUtils-Config \
    perl-ExtUtils-Helpers \
    perl-ExtUtils-InstallPaths \
    perl-ExtUtils-MM-Utils \
    perl-FCGI \
    perl-File-Find-Object \
    perl-File-Listing \
    perl-File-Path \
    perl-File-ShareDir \
    perl-File-Temp \
    perl-Filter \
    perl-Filter-Simple \
    perl-FreezeThaw \
    perl-GSSAPI \
    perl-HTML-Tagset \
    perl-HTTP-Cookies \
    perl-HTTP-Date \
    perl-HTTP-Message \
    perl-HTTP-Negotiate \
    perl-HTTP-Tiny \
    perl-Hash-Merge \
    perl-IO-HTML \
    perl-IO-Multiplex \
    perl-IO-SessionData \
    perl-IO-Socket-INET6 \
    perl-IO-Socket-IP \
    perl-IO-Zlib \
    perl-IO-stringy \
    perl-IPC-Cmd \
    perl-IPC-SysV \
    perl-Image-Base \
    perl-Image-Info \
    perl-Image-Xbm \
    perl-Image-Xpm \
    perl-Import-Into \
    perl-LWP-MediaTypes \
    perl-List-MoreUtils-XS \
    perl-Locale-Maketext \
    perl-Locale-Maketext-Simple \
    perl-Log-Dispatch \
    perl-Log-Dispatch-FileRotate \
    perl-MIME-Lite \
    perl-MIME-Types \
    perl-Mail-Sender \
    perl-Mail-Sendmail \
    perl-MailTools \
    perl-Mixin-Linewise \
    perl-Module-CPANTS-Analyse \
    perl-Module-CPANfile \
    perl-Module-CoreList \
    perl-Module-ExtractUse \
    perl-Module-Find \
    perl-Module-Implementation \
    perl-Module-Load-Conditional \
    perl-Module-Metadata \
    perl-Module-Pluggable \
    perl-Module-Runtime \
    perl-Module-Runtime-Conflicts \
    perl-Moo \
    perl-MooX-Types-MooseLike \
    perl-MooseX-Types \
    perl-Mozilla-CA \
    perl-NTLM \
    perl-Net-HTTP \
    perl-Net-SMTP-SSL \
    perl-Net-SSLeay \
    perl-Number-Compare \
    perl-PHP-Serialization \
    perl-Package-DeprecationManager \
    perl-Package-Generator \
    perl-Package-Stash \
    perl-Package-Stash-XS \
    perl-PadWalker \
    perl-Params-Check \
    perl-Params-Classify \
    perl-Params-Util \
    perl-Params-ValidationCompiler \
    perl-Parse-RecDescent \
    perl-Perl-OSType \
    perl-PerlIO-utf8_strict \
    perl-Pod-Coverage \
    perl-Pod-Escapes \
    perl-Pod-Eventual \
    perl-Pod-Html \
    perl-Pod-Parser \
    perl-Pod-Perldoc \
    perl-Pod-Simple \
    perl-Pod-Strip \
    perl-Pod-Usage \
    perl-Ref-Util \
    perl-Ref-Util-XS \
    perl-Role-Tiny \
    perl-SelfLoader \
    perl-Socket \
    perl-Socket6 \
    perl-Software-License \
    perl-Specio \
    perl-Sub-Exporter-ForMethods \
    perl-Sub-Exporter-Progressive \
    perl-Sub-Identify \
    perl-Sub-Install \
    perl-Sub-Name \
    perl-Sub-Quote \
    perl-Sub-Uplevel \
    perl-Sys-Syslog \
    perl-Term-ANSIColor \
    perl-Term-Cap \
    perl-Test \
    perl-Test-Deep \
    perl-Test-Warn \
    perl-Text-Balanced \
    perl-Text-Diff \
    perl-Text-Glob \
    perl-Text-ParseWords \
    perl-Text-Soundex \
    perl-Text-Tabs+Wrap \
    perl-Text-Template \
    perl-Text-Unidecode \
    perl-Time-Local \
    perl-UNIVERSAL-isa \
    perl-URI \
    perl-Unicode-Normalize \
    perl-Variable-Magic \
    perl-WWW-RobotRules \
    perl-XML-Dumper \
    perl-XML-LibXML \
    perl-XML-NamespaceSupport \
    perl-XML-Parser \
    perl-XML-SAX \
    perl-XML-SAX-Base \
    perl-YAML-LibYAML \
    perl-YAML-Syck \
    perl-inc-latest \
    perl-libnet \
    perl-macros \
    perl-namespace-clean \
    perl-podlators \
    perl-threads \
    perl-threads-shared \
    perltidy \
    perl-Attribute-Handlers \
    perl-B-Debug \
    perl-CPAN \
    perl-CPAN-Meta-Check \
    perl-Compress-Bzip2 \
    perl-Config-Perl-V \
    perl-DB_File \
    perl-Devel-PPPort \
    perl-Devel-Peek \
    perl-Devel-SelfStubber \
    perl-Devel-Size \
    perl-Encode-devel \
    perl-Env \
    perl-ExtUtils-Embed \
    perl-ExtUtils-Miniperl \
    perl-File-Fetch \
    perl-File-HomeDir \
    perl-File-pushd \
    perl-IPC-System-Simple \
    perl-Locale-Codes \
    perl-Math-BigInt-FastCalc \
    perl-Math-BigRat \
    perl-Memoize \
    perl-Module-CoreList-tools \
    perl-Module-Loaded \
    perl-Net-Ping \
    perl-Parse-PMFile \
    perl-PerlIO-via-QuotedPrint \
    perl-Pod-Checker \
    perl-String-ShellQuote \
    perl-Thread-Queue \
    perl-Time-Piece \
    perl-Unicode-Collate \
    perl-autodie \
    perl-bignum \
    perl-encoding \
    perl-experimental \
    perl-libnetcfg \
    perl-local-lib \
    perl-open \
    perl-perlfaq \
    perl-utils \
    perl-DBD-MySQL \
    perl-CGI-Fast;

# Exiting
echo "Finished setting up rhel perl deps..";
exit 0;
