#!/bin/bash
set -e

CONTAINER_INITIALIZED="CONTAINER_INITIALIZED"

if [ ! -e $CONTAINER_INITIALIZED ]; then

 #    echo "INSTALLING SEMORG SEMANTIC MEDIAWIKI..."

 #    if [ ! -d /var/www/html/skins/Tweeki ]; then
	#     echo "DOWNLOAD TWEEKI SKIN..."
	#     cd /var/www/html/skins/
	#     git clone https://github.com/thaider/Tweeki
	# else
	# 	echo "TWEEKI SKIN EXISTS, SKIPPING..."
 #    fi

 #    if [ ! -d /var/www/html/extensions/PageForms ]; then
	#     echo "DOWNLOAD EXTENSIONS..."
	#     cd /var/www/html/extensions 
	#     git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/PageForms.git
	#     git clone https://github.com/thaider/SemanticOrganization.git
	# else
	# 	echo "EXTENSIONS EXIST, SKIPPING..."
 #    fi

 #    echo "INSTALL SEMANTIC MEDIAWIKI..."
 #    cd /var/www/html
 #    php composer.phar require mediawiki/semantic-media-wiki "~2.5" --update-no-dev
 #    php composer.phar require mediawiki/semantic-result-formats "~2.5" --update-no-dev

    cd /var/www/html

    echo "SETUP (SEMANTIC-)MEDIAWIKI..."
    php maintenance/install.php --dbserver=$MYSQL_HOST --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --scriptpath="" --lang=de --pass=$MEDIAWIKI_ADMIN_PASSWORD "$MEDIAWIKI_NAME" "$MEDIAWIKI_ADMIN_USERNAME"
    php maintenance/update.php --skip-external-dependencies


    echo "UPDATE LOCALSETTINGS.PHP..."
    envsubst '$HABIDAT_LDAP_HOST $HABIDAT_LDAP_PORT $HABIDAT_LDAP_BINDDN $HABIDAT_LDAP_ADMIN_PASSWORD $HABIDAT_LDAP_BASE' < LocalSettings.php.additional.template > LocalSettings.php.additional
    envsubst '$HABIDAT_LOGO' < additonal-pages.xml.template > additonal-pages.xml
    cp LocalSettings.php LocalSettings.php.bak
    echo " " >> LocalSettings.php
    cat LocalSettings.php.additional >> LocalSettings.php

    if [ $HABIDAT_SSO == "true" ]
    then
        export HABIDAT_SSO_CERTIFICATE=$(echo $HABIDAT_SSO_CERTIFICATE | sed --expression='s/\\n/\n/g')
        envsubst '$HABIDAT_MEDIAWIKI_SUBDOMAIN $HABIDAT_DOMAIN $HABIDAT_SSO_CERTIFICATE' < LocalSettings.php.sso.template > LocalSettings.php.sso
        echo " " >> LocalSettings.php
        cat LocalSettings.php.sso >> LocalSettings.php        
    fi
    #sed -i 's/wgDefaultSkin = ".*"/wgDefaultSkin = "tweeki"/g' LocalSettings.php
    #sed -i 's/wgLanguageCode = ".*"/wgLanguageCode = "de"/g' LocalSettings.php
    #sed -i `s/wgSitename = ".*"/wgSitename = "$HABIDAT_TITLE"/g` LocalSettings.php

    echo "IMPORTING SEMORG PAGES..."
    php maintenance/importDump.php < extensions/SemanticOrganization/import/semorg_pages.xml
    php maintenance/importDump.php < additonal-pages.xml

    echo "CLEANUP..."
    php maintenance/rebuildrecentchanges.php
    php maintenance/runJobs.php

    touch $CONTAINER_INITIALIZED
fi

echo "STARTUP WEB SERVER..."
exec "apache2-foreground"
