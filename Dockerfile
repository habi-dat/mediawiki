FROM mediawiki:1.31

RUN apt-get update && \
    apt-get install -y libldap2-dev nano gettext-base wget zip unzip libzip-dev zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap && \
    docker-php-ext-install zip

WORKDIR /var/www/html

RUN git clone https://github.com/thaider/Tweeki /var/www/html/skins/Tweeki \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/PageForms.git /var/www/html/extensions/PageForms \
    && git clone https://github.com/thaider/SemanticOrganization.git /var/www/html/extensions/SemanticOrganization \
    && git clone -b REL1_31 https://gerrit.wikimedia.org/r/mediawiki/extensions/PluggableAuth.git extensions/PluggableAuth \
    && git clone -b REL1_31 https://github.com/wikimedia/mediawiki-extensions-SimpleSAMLphp extensions/SimpleSAMLphp \
    && git clone -b REL1_31 https://github.com/wikimedia/mediawiki-extensions-Auth_remoteuser.git extensions/Auth_remoteuser \ 
    && git clone -b REL1_31 https://github.com/wikimedia/mediawiki-extensions-LdapAuthentication extensions/LdapAuthentication \
    && git clone -b REL1_31 https://gerrit.wikimedia.org/r/mediawiki/extensions/CreateUserPage.git extensions/CreateUserPage \
    && git clone -b REL1_31 https://gerrit.wikimedia.org/r/mediawiki/extensions/UserMerge.git extensions/UserMerge 

WORKDIR /var/www/html/extensions/PageForms
RUN git checkout 397dfbb

WORKDIR /var/www/html

RUN wget https://github.com/simplesamlphp/simplesamlphp/releases/download/v1.18.8/simplesamlphp-1.18.8.tar.gz \
    && tar xzf simplesamlphp-1.18.8.tar.gz \
    && rm simplesamlphp-1.18.8.tar.gz \
    && mv simplesamlphp-1.18.8 /var/simplesamlphp \
    && chown -R www-data:www-data /var/simplesamlphp

COPY sso/000-default.conf /etc/apache2/sites-available

ADD composer.local.json ./

RUN wget https://getcomposer.org/composer-1.phar
RUN php composer-1.phar update --no-dev

RUN mkdir ./templates

ADD sso ./templates/sso
ADD config ./templates/config

RUN mkdir config
ADD LocalSettings.override.php config
RUN chown -R www-data:www-data config

# set x-frame options to ALLOWALL to enable being shown in an iframe (inside nextcloud)
RUN a2enmod headers
COPY apache2-security.conf /etc/apache2/conf-enabled/security.conf

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80

CMD ["apache2-foreground"]

