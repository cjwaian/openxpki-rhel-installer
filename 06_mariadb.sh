#!/bin/sh

# Starting
source ./install.config;
echo "Starting to set up database.";


# Install Mariadb
echo "Downloading MariaDB.";
dnf -y install mariadb-server;
# client libraries should be already downloaded

# Start & Enable MariaDB
echo "Starting MariaDB daemon.";
systemctl enable --now mariadb;



## Setup OpenXPKI Database
# Do mysql_secure_installation stuff manually. Might error if this is unncessiary, just ignore
echo "Doing mysql_secure_installation stuff, safe to ignore errors.."
mysql -e "UPDATE mysql.user SET Password = PASSWORD('${DB_ROOT_PASS}') WHERE User = 'root'";
mysql -e "DROP USER ''@'localhost'";
mysql -e "DROP USER ''@'$(hostname)'";
mysql -e "DROP DATABASE test";
mysql -e "FLUSH PRIVILEGES";


# Create Database
echo "Creating database ${DB_NAME}";
mysql -u root -p$DB_ROOT_PASS -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARSET utf8;";


# Create OpenXPKI db user
echo "Creating openxpki database user: ${DB_USER_NAME}";
mysql -u root -p$DB_ROOT_PASS -e "CREATE USER '${DB_USER_NAME}'@'localhost' IDENTIFIED BY '${DB_USER_PASS}'";
mysql -u root -p$DB_ROOT_PASS -e "GRANT ALL ON ${DB_NAME}.* TO '${DB_USER_NAME}'@'localhost'";
mysql -u root -p$DB_ROOT_PASS -e "FLUSH PRIVILEGES";


# Download the database schema if DB_SCHEMA_FILE is not provided
if [ ! -f $DB_SCHEMA_FILE ] ; then
    echo "Downloading database schema to ${DB_SCHEMA_FILE}";
    curl $DB_SCHEMA_URL > $DB_SCHEMA_FILE;
fi


# Import the database schema
echo "Importing ${DB_SCHEMA_FILE} into database ${DB_NAME}";
mysql -u root -p$DB_ROOT_PASS $DB_NAME < $DB_SCHEMA_FILE;



## Setup OpenXPKI Session Driver Table (openxpki.frontend_session)
# Create the session handler account
echo "Creating session driver database user: ${DB_SESSION_USER_NAME}";
mysql -u root -p$DB_ROOT_PASS -e "CREATE USER '${DB_SESSION_USER_NAME}'@'localhost' IDENTIFIED BY '${DB_SESSION_USER_PASS}'";
mysql -u root -p$DB_ROOT_PASS -e "GRANT SELECT, INSERT, UPDATE, DELETE ON ${DB_NAME}.frontend_session TO '${DB_SESSION_USER_NAME}'@'localhost'";



# Exiting
echo "Finished setting up database..";
exit 0;