#!/bin/sh



# Starting
source ./install.config;
echo "Starting to generate certificates..";




### Gerate Certifiactes (Optional) - Testing Purposes Only ###
# Skip this step to just import cert you provide
# Will only generate missing certs.



COUNTRY="US";
STATE="EX";
CITY="Example Town";
ORG="OpenXPKI";
EMAIL="test@example.com";



# Root CA
ROOT_CA_CN="OpenXPKI Root CA";
ROOT_CA_SUBJECT="/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/CN=${ROOT_CA_CN}/emailAddress=${EMAIL}";

# Issuer CA
ISSUER_CA_CN="OpenXPKI Demo Issuing CA";
ISSUER_CA_SUBJECT="/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/CN=${ISSUER_CA_CN}/emailAddress=${EMAIL}";

# Datavault
DATAVAULT_CN="OpenXPKI DataVault";
DATAVAULT_SUBJECT="/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/CN=${DATAVAULT_CN}";

# SCEP RA
SCEP_RA_CN="OpenXPKI SCEP RA";
SCEP_RA_SUBJECT="/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/CN=${SCEP_RA_CN}";

# Web Server
WEB_CN=$FQDN;
WEB_SUBJECT="/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/CN=${WEB_CN}";



# OpenXPKI default min for the endentity certificates is 6 months
# if you set the CA lower than that it will error
#   "ERROR Could not find token alias by group; __group__ => ca-signer"
EXPIRE_DAYS=183;



## Optional - By default off, will need uncomment the openssl.cnf settings
# ROOT_CA_CERT_URI="http://localhost/root-ca.pem";
# ROOT_CA_CRL_URI="http://localhost/root-ca.crl";
# ROOT_CA_OCSP_URI="http://ocsp.localhost";
# ISSUER_CA_CERT_URI="http://localhost/issuer-ca.pem";
# ISSUER_CA_CRL_URI="http://localhost/issuer-ca.crl";
# ISSUER_CA_OCSP_URI="http://ocsp.localhost";



mkdir -p $WORK_DIR/ca
chown root:root $WORK_DIR/ca
chmod 500 $WORK_DIR/ca

# serial
echo 1000 > $WORK_DIR/ca/serial;



make_cnf () {
    # index.txt
    touch $WORK_DIR/ca/$1-index.txt;
    # randfile
    touch $WORK_DIR/ca/$1.rnd;
    # crlnumber
    echo 1000 > $WORK_DIR/ca/$1-crlnumber;

    # openssl.cnf
    cat > $WORK_DIR/ca/$1-openssl.cnf << EOL
    [ openssl_conf_section ]
    # Configuration module list
    alg_section = evp_sect

    [ evp_sect ]
    # Set to “yes” to enter FIPS mode if supported
    fips_mode = yes

    [ ca ]
    default_ca = CA_default

    [ CA_default ]
    # Directory and file locations.
    dir               = ${WORK_DIR}/
    certs             = ${WORK_DIR}/ca/
    crl_dir           = ${WORK_DIR}/ca/
    new_certs_dir     = ${WORK_DIR}/ca/
    database          = ${WORK_DIR}/ca/$1-index.txt
    serial            = ${WORK_DIR}/ca/serial
    RANDFILE          = ${WORK_DIR}/ca/$1.rnd

    # The root key and root certificate.
    private_key       = $2
    certificate       = $3

    # For certificate revocation lists.
    crlnumber         = ${WORK_DIR}/ca/$1-crlnumber
    crl               = ${WORK_DIR}/ca/$1-crl.pem
    crl_extensions    = crl_ext
    default_crl_days  = 30

    # SHA-1 is deprecated, so use SHA-2 instead.
    default_md        = sha512
    name_opt          = ca_default
    cert_opt          = ca_default
    default_days      = ${EXPIRE_DAYS}
    preserve          = no
    policy            = policy_strict

    [ policy_strict ]
    # The root CA should only sign intermediate certificates that match.
    # See the POLICY FORMAT section of man ca.
    countryName             = match
    stateOrProvinceName     = match
    localityName            = match
    organizationName        = match
    organizationalUnitName  = optional
    commonName              = supplied
    emailAddress            = optional

    [ req ]
    default_bits        = 4098
    distinguished_name  = req_distinguished_name
    string_mask         = utf8only

    # SHA-1 is deprecated, so use SHA-2 instead.
    default_md          = sha512

    # Extension to add when the -x509 option is used.
    x509_extensions     = v3_ca

    [ req_distinguished_name ]
    countryName                     = Country Name (2 letter code)
    stateOrProvinceName             = State or Province Name
    localityName                    = Locality Name
    0.organizationName              = Organization Name
    organizationalUnitName          = Organizational Unit Name
    commonName                      = Common Name
    emailAddress                    = Email Address

    # Optionally, specify some defaults.
    countryName_default             = ${COUNTRY}
    stateOrProvinceName_default     = ${STATE}
    localityName_default            = ${CITY}
    0.organizationName_default      = ${ORG}
    emailAddress_default            = ${EMAIL}

    [ v3_ca ]
    # Extensions for a typical CA (man x509v3_config).
    subjectKeyIdentifier    = hash
    authorityKeyIdentifier  = keyid:always,issuer
    basicConstraints        = critical, CA:true
    keyUsage                = critical, digitalSignature, cRLSign, keyCertSign
    #crlDistributionPoints  = ${ROOT_CA_CRL_URI}
    #authorityInfoAccess    = caIssuers;${ROOT_CA_CERT_URI}
    #authorityInfoAccess    = OCSP;URI:${ROOT_CA_OCSP_URI}

    [ v3_ca_reqexts ]
    subjectKeyIdentifier    = hash
    keyUsage                = digitalSignature, keyCertSign, cRLSign

    [ v3_datavault_reqexts ]
    subjectKeyIdentifier    = hash
    keyUsage                = keyEncipherment
    extendedKeyUsage        = emailProtection

    [ v3_scep_reqexts ]
    subjectKeyIdentifier    = hash

    [ v3_web_reqexts ]
    subjectKeyIdentifier    = hash
    keyUsage                = critical, digitalSignature, keyEncipherment
    extendedKeyUsage        = serverAuth, clientAuth


    [ v3_ca_extensions ]
    subjectKeyIdentifier    = hash
    keyUsage                = digitalSignature, keyCertSign, cRLSign
    basicConstraints        = critical,CA:TRUE
    authorityKeyIdentifier  = keyid:always,issuer
    #crlDistributionPoints  = ${ROOT_CA_CRL_URI}
    #authorityInfoAccess    = caIssuers;${ROOT_CA_CERT_URI}
    #authorityInfoAccess    = OCSP;URI:${ROOT_CA_OCSP_URI}

    [ v3_issuing_extensions ]
    subjectKeyIdentifier    = hash
    keyUsage                = digitalSignature, keyCertSign, cRLSign
    basicConstraints        = critical,CA:TRUE
    authorityKeyIdentifier  = keyid:always,issuer:always
    #crlDistributionPoints  = ${ISSUER_CA_CRL_URI}
    #authorityInfoAccess    = caIssuers;${ISSUER_CA_CERT_URI}
    #authorityInfoAccess    = OCSP;URI:${ISSUER_CA_OCSP_URI}

    [ v3_datavault_extensions ]
    subjectKeyIdentifier    = hash
    keyUsage                = keyEncipherment
    extendedKeyUsage        = emailProtection
    basicConstraints        = CA:FALSE
    authorityKeyIdentifier  = keyid:always,issuer

    [ v3_scep_extensions ]
    subjectKeyIdentifier    = hash
    keyUsage                = digitalSignature, keyEncipherment
    basicConstraints        = CA:FALSE
    authorityKeyIdentifier  = keyid,issuer

    [ v3_web_extensions ]
    subjectKeyIdentifier    = hash
    keyUsage                = critical, digitalSignature, keyEncipherment
    extendedKeyUsage        = serverAuth, clientAuth
    basicConstraints        = critical,CA:FALSE
    subjectAltName          = IP:${IP_ADDR}
    #crlDistributionPoints  = ${ISSUER_CA_CRL_URI}
    #authorityInfoAccess    = caIssuers;${ISSUER_CA_CERT_URI}
    #authorityInfoAccess    = OCSP;URI:${ISSUER_CA_OCSP_URI}

EOL
}

make_cnf ${ROOT_CA_CERT%.*} $(readlink -f $ROOT_CA_KEY) $(readlink -f $ROOT_CA_CERT);
make_cnf ${ISSUER_CA_CERT%.*} $(readlink -f $ISSUER_CA_KEY) $(readlink -f $ISSUER_CA_CERT);



# Root CA
if [[ ! -f $ROOT_CA_CERT ]] ; then
    echo "Root CA certificate was not provided, will generate.."

    # Private Key
    echo "Generating ${ROOT_CA_CN} private key: ${ROOT_CA_KEY}";
    # /bin/openssl ecparam -name secp521r1 -genkey -noout -outform PEM -out "${ROOT_CA_KEY}";
    /bin/openssl genrsa -rand "${WORK_DIR}/ca/${ROOT_CA_CERT%.*}.rnd" -out $ROOT_CA_KEY 4096;
    chown root:root $ROOT_CA_KEY;
    chmod 400 $ROOT_CA_KEY;

    # Self Signed Certificate
    echo "Generating ${ROOT_CA_CN} certificate key: ${ROOT_CA_CERT}";
    /bin/openssl req -new -x509 \
        -config "${WORK_DIR}/ca/${ROOT_CA_CERT%.*}-openssl.cnf" \
        -subj "${ROOT_CA_SUBJECT}" \
        -key "${ROOT_CA_KEY}" \
        -extensions "v3_ca_extensions" \
        -out "${ROOT_CA_CERT}";
    chown root:root $ROOT_CA_CERT;
    chmod 400 $ROOT_CA_CERT;
else
    echo "Importing Root CA: ${ROOT_CA_CERT}";
fi



# Issuer CA
if [[ ! -f $ISSUER_CA_KEY || ! -f $ISSUER_CA_CERT ]] ; then
    echo "${ISSUER_CA_CN} certificate or key was not provided, will generate.."

    # Private Key
    echo "Generating ${ISSUER_CA_CN} private key: ${ISSUER_CA_KEY}";
    # /bin/openssl ecparam -name secp521r1 -genkey -noout -outform PEM -out "${ISSUER_CA_KEY}";
    /bin/openssl genrsa -rand "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}.rnd" -out "${ISSUER_CA_KEY}" 4096;
    chown root:root $ISSUER_CA_KEY;
    chmod 400 $ISSUER_CA_KEY;

    # Certificate Signing Request
    echo "Generating ${ISSUER_CA_CN} certificate signing request: ${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}.csr";
    /bin/openssl req -new \
        -config "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}-openssl.cnf" \
        -subj "${ISSUER_CA_SUBJECT}" \
        -key "${ISSUER_CA_KEY}" \
        -reqexts "v3_ca_reqexts" \
        -out "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}.csr";
    chown root:root "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}.csr";
    chmod 400 "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}.csr";

    # Sign Issuer CA CSR with the Root CA ###
    if [[ -f $ROOT_CA_KEY  ||  -f $ROOT_CA_CERT ]] ; then
        echo "Signing ${ISSUER_CA_CERT%.*}.csr with ${ROOT_CA_CN}.";
        /bin/openssl ca -batch \
            -create_serial \
            -config "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}-openssl.cnf" \
            -subj "${ISSUER_CA_SUBJECT}" \
            -keyfile "${ROOT_CA_KEY}" \
            -cert  "${ROOT_CA_CERT}" \
            -extensions "v3_issuing_extensions" \
            -in "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}.csr" \
            -out "${ISSUER_CA_CERT}";
        chown root:root $ISSUER_CA_CERT;
        chmod 400 $ISSUER_CA_CERT;
    else
        echo "Can't sign ${ISSUER_CA_CERT%.*}.csr because ${ROOT_CA_CN} certificate or key is missing: ${ROOT_CA_CERT} ${ROOT_CA_KEY}";
    fi
else
    echo "Importing Issuer CA: ${ISSUER_CA_CERT} ${ISSUER_CA_KEY}";
fi



# Datavault
if [[ ! -f $DATAVAULT_KEY || ! -f $DATAVAULT_CERT ]] ; then
    echo "${DATAVAULT_CN} certificate or key was not provided, will generate.."

    # Private Key
    echo "Generating ${DATAVAULT_CN} private key: ${DATAVAULT_KEY}";
    /bin/openssl genrsa -rand "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}.rnd" -out "${DATAVAULT_KEY}" 4096;
    chown root:root $DATAVAULT_KEY;
    chmod 400 $DATAVAULT_KEY;

    # Certificate Signing Request
    echo "Generating ${DATAVAULT_CN} certificate signing request: ${WORK_DIR}/ca/${DATAVAULT_CERT%.*}.csr";
    /bin/openssl req -new \
        -config "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}-openssl.cnf" \
        -subj "${DATAVAULT_SUBJECT}" \
        -key "${DATAVAULT_KEY}" \
        -reqexts "v3_datavault_reqexts" \
        -out "${WORK_DIR}/ca/${DATAVAULT_CERT%.*}.csr";
    chown root:root "${WORK_DIR}/ca/${DATAVAULT_CERT%.*}.csr";
    chmod 400 "${WORK_DIR}/ca/${DATAVAULT_CERT%.*}.csr";

    # Sign CSR with the Issuer CA ###
    if [[ -f $ISSUER_CA_KEY  ||  -f $ISSUER_CA_CERT ]] ; then
        echo "Signing ${DATAVAULT_CERT%.*}.csr with ${ISSUER_CA_CN}.";
        /bin/openssl ca -batch \
            -create_serial \
            -config "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}-openssl.cnf" \
            -subj "${DATAVAULT_SUBJECT}" \
            -keyfile "${ISSUER_CA_KEY}" \
            -cert  "${ISSUER_CA_CERT}" \
            -extensions "v3_datavault_extensions" \
            -in "${WORK_DIR}/ca/${DATAVAULT_CERT%.*}.csr" \
            -out "${DATAVAULT_CERT}";
        chown root:root $DATAVAULT_CERT;
        chmod 400 $DATAVAULT_CERT;
    else
        echo "Can't sign ${DATAVAULT_CERT%.*}.csr because ${ISSUER_CA_CN} certificate or key is missing: ${ISSUER_CA_CERT} ${ISSUER_CA_KEY}";
    fi
else
    echo "Importing Datavault: ${DATAVAULT_CERT} ${DATAVAULT_KEY}";
fi



# SCEP RA
if [[ ! -f $SCEP_RA_KEY || ! -f $SCEP_RA_CERT ]] ; then
    echo "${SCEP_RA_CN} certificate or key was not provided, will generate.."

    # Private Key
    echo "Generating ${SCEP_RA_CN} private key: ${SCEP_RA_KEY}";
    /bin/openssl genrsa -rand "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}.rnd" -out "${SCEP_RA_KEY}" 4096;
    chown root:root $SCEP_RA_KEY;
    chmod 400 $SCEP_RA_KEY;

    # Certificate Signing Request
    echo "Generating ${SCEP_RA_CN} certificate signing request: ${WORK_DIR}/ca/${SCEP_RA_CERT%.*}.csr";
    /bin/openssl req -new \
        -config "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}-openssl.cnf" \
        -subj "${SCEP_RA_SUBJECT}" \
        -key "${SCEP_RA_KEY}" \
        -reqexts "v3_scep_reqexts" \
        -out "${WORK_DIR}/ca/${SCEP_RA_CERT%.*}.csr";
    chown root:root "${WORK_DIR}/ca/${SCEP_RA_CERT%.*}.csr";
    chmod 400 "${WORK_DIR}/ca/${SCEP_RA_CERT%.*}.csr";

    # Sign CSR with the Issuer CA
    if [[ -f $ISSUER_CA_KEY  ||  -f $ISSUER_CA_CERT ]] ; then
        echo "Signing ${SCEP_RA_CERT%.*}.csr with ${ISSUER_CA_CN}.";
        /bin/openssl ca -batch \
            -create_serial \
            -config "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}-openssl.cnf" \
            -subj "${SCEP_RA_SUBJECT}" \
            -keyfile "${ISSUER_CA_KEY}" \
            -cert  "${ISSUER_CA_CERT}" \
            -extensions "v3_scep_extensions" \
            -in "${WORK_DIR}/ca/${SCEP_RA_CERT%.*}.csr" \
            -out "${SCEP_RA_CERT}";
        chown root:root $SCEP_RA_CERT;
        chmod 400 $SCEP_RA_CERT;
    else
        echo "Can't sign ${SCEP_RA_CERT%.*}.csr because ${ISSUER_CA_CN} certificate or key is missing: ${ISSUER_CA_CERT} ${ISSUER_CA_KEY}";
    fi
else
    echo "Importing SCEP RA: ${SCEP_RA_CERT} ${SCEP_RA_KEY}";
fi



# Web Server Cert
if [[ ! -f $WEB_KEY || ! -f $WEB_CERT ]] ; then
    echo "${WEB_CN} certificate or key was not provided, will generate..";

    # Private Key
    echo "Generating ${WEB_CN} private key: ${WEB_KEY}";
    # /bin/openssl ecparam -name secp521r1 -genkey -noout -outform PEM -out "${WEB_KEY}";
    /bin/openssl genrsa -rand "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}.rnd" -out "${WEB_KEY}" 4096;
    chown root:root $WEB_KEY;
    chmod 400 $WEB_KEY;

    # Certificate Signing Request
    echo "Generating ${WEB_CN} certificate signing request: ${WORK_DIR}/ca/${WEB_CERT%.*}.csr";
    /bin/openssl req -new \
        -config "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}-openssl.cnf" \
        -subj "${WEB_SUBJECT}" \
        -key "${WEB_KEY}" \
        -reqexts "v3_web_reqexts" \
        -out "${WORK_DIR}/ca/${WEB_CERT%.*}.csr";
    chown root:root "${WORK_DIR}/ca/${WEB_CERT%.*}.csr";
    chmod 400 "${WORK_DIR}/ca/${WEB_CERT%.*}.csr";

    # Sign CSR with the Issuer CA
    if [[ -f $ISSUER_CA_KEY  ||  -f $ISSUER_CA_CERT ]] ; then
        echo "Signing ${WEB_CERT%.*}.csr with ${ISSUER_CA_CN}.";
        /bin/openssl ca -batch \
            -create_serial \
            -config "${WORK_DIR}/ca/${ISSUER_CA_CERT%.*}-openssl.cnf" \
            -subj "${WEB_SUBJECT}" \
            -keyfile "${ISSUER_CA_KEY}" \
            -cert  "${ISSUER_CA_CERT}" \
            -extensions "v3_web_extensions" \
            -in "${WORK_DIR}/ca/${WEB_CERT%.*}.csr" \
            -out "${WEB_CERT}";
        chown root:root $WEB_CERT;
        chmod 400 $WEB_CERT;
    else
        echo "Can't sign ${WEB_CERT%.*}.csr because ${ISSUER_CA_CN} certificate or key is missing: ${ISSUER_CA_CERT} ${ISSUER_CA_KEY}";
    fi
else
    echo "Importing Web Server Cert: ${WEB_CERT} ${WEB_KEY}";
fi



chown root:root $WORK_DIR/ca/*;
chmod 400 $WORK_DIR/ca/*;



# Exiting
echo "Finished generating certificates..";
exit 0;
