#!/bin/bash
set -e

cd /var/www/html

CONTAINER_UPDATED="UPDATED"
CONTAINER_INSTALLED="config/INSTALLED"
CONTAINER_1_35="config/1_35"

if [ ! -e $CONTAINER_INSTALLED ]; then

    echo "SETUP (SEMANTIC-)MEDIAWIKI..."
    php maintenance/install.php --dbserver=$MYSQL_HOST --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --scriptpath="" --lang=de --pass=$MEDIAWIKI_ADMIN_PASSWORD "$MEDIAWIKI_NAME" "$MEDIAWIKI_ADMIN_USERNAME"

    cp -a LocalSettings.php config/

    touch $CONTAINER_1_35
    touch $CONTAINER_INSTALLED

fi

if [ ! -e $CONTAINER_1_35 ]; then

    cp -a config/LocalSettings.php ./

    envsubst '$HABIDAT_LDAP_HOST $HABIDAT_LDAP_PORT $HABIDAT_LDAP_BINDDN $HABIDAT_LDAP_ADMIN_PASSWORD $HABIDAT_LDAP_BASE' < templates/config/LocalSettings.additional.template.php > LocalSettings.additional.php

    echo " " >> LocalSettings.php
    echo "\$wgServer = \"$MEDIAWIKI_SERVER\";" >> LocalSettings.php
    echo "require_once('LocalSettings.additional.php');" >> LocalSettings.php

    php maintenance/populateContentTables.php
    php maintenance/update.php --quick
    php extensions/SemanticMediaWiki/maintenance/updateEntityCountMap.php
    php extensions/SemanticMediaWiki/maintenance/rebuildData.php -v --with-maintenance-log

    echo "CHANGED BEHAVIOUR OF NAMED ARGS AND USERPARAM"
    set +e # replaceAll.php throws an error if there is nothing to replace
    php extensions/ReplaceText/maintenance/replaceAll.php "{{{?" "{{{" --yes --nsall
    php extensions/ReplaceText/maintenance/replaceAll.php "{{{userparam" "{{{#userparam" --yes --nsall
    set -e

    php maintenance/runJobs.php

    touch $CONTAINER_1_35
fi

if [ ! -e $CONTAINER_UPDATED ]; then

    cp -a config/LocalSettings.php ./
    envsubst '$HABIDAT_LDAP_HOST $HABIDAT_LDAP_PORT $HABIDAT_LDAP_BINDDN $HABIDAT_LDAP_ADMIN_PASSWORD $HABIDAT_LDAP_BASE' < templates/config/LocalSettings.additional.template.php > LocalSettings.additional.php

    echo " " >> LocalSettings.php
    echo "\$wgServer = \"https://$VIRTUAL_HOST\";" >> LocalSettings.php
    echo "require_once('LocalSettings.additional.php');" >> LocalSettings.php

    php maintenance/update.php --quick

    echo "UPDATE LOCALSETTINGS.PHP..."
    envsubst '$HABIDAT_LOGO' < templates/config/additional-pages.template.xml > additional-pages.xml

    if [ $HABIDAT_SSO == "true" ]
    then
        export HABIDAT_SSO_CERTIFICATE=$(echo $HABIDAT_SSO_CERTIFICATE | sed --expression='s/\\n/\n/g')
        envsubst '$HABIDAT_MEDIAWIKI_SUBDOMAIN $HABIDAT_DOMAIN $MEDIAWIKI_ADMIN_PASSWORD' < templates/sso/config.template.php > /var/simplesamlphp/config/config.php
        envsubst '$HABIDAT_MEDIAWIKI_SUBDOMAIN $HABIDAT_DOMAIN' < templates/sso/authsources.template.php > /var/simplesamlphp/config/authsources.php
        envsubst '$HABIDAT_SSO_CERTIFICATE $HABIDAT_DOMAIN' < templates/sso/saml20-idp-remote.template.php > /var/simplesamlphp/metadata/saml20-idp-remote.php
        envsubst '$HABIDAT_MEDIAWIKI_SUBDOMAIN $HABIDAT_DOMAIN $HABIDAT_SSO_CERTIFICATE' < templates/sso/LocalSettings.sso.template.php > LocalSettings.sso.php
        echo "require_once('LocalSettings.sso.php');" >> LocalSettings.php
    fi

    echo "require_once('config/LocalSettings.override.php');" >> LocalSettings.php

    echo "IMPORTING SEMORG PAGES..."
    php maintenance/importDump.php < extensions/SemanticOrganization/import/semorg_pages.xml
    php maintenance/importDump.php < additional-pages.xml

    echo "CLEANUP..."
    php maintenance/rebuildrecentchanges.php
    php maintenance/runJobs.php

    touch $CONTAINER_UPDATED
fi

echo "STARTUP WEB SERVER..."
exec "$@"
