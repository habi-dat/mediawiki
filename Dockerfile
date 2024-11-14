FROM mediawiki:1.39

# run setup as root user
USER root
# allow running composer as superuser
ENV COMPOSER_ALLOW_SUPERUSER=1 

RUN apt-get update && \
    apt-get install -y libldap2-dev nano gettext-base wget zip unzip libzip-dev zlib1g-dev vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap && \
    docker-php-ext-install zip

COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

RUN git clone -b 5.39 https://github.com/thaider/Tweeki /var/www/html/skins/Tweeki \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/PageForms.git /var/www/html/extensions/PageForms \
    && git clone -b REL1_39 https://github.com/thaider/SemanticOrganization.git /var/www/html/extensions/SemanticOrganization \
    && git clone https://github.com/thaider/Habidat.git /var/www/html/extensions/Habidat \
    && git clone -b REL1_39 https://gerrit.wikimedia.org/r/mediawiki/extensions/PluggableAuth.git extensions/PluggableAuth \
    && git clone -b REL1_39 https://github.com/wikimedia/mediawiki-extensions-SimpleSAMLphp extensions/SimpleSAMLphp \
    && git clone -b REL1_39 https://github.com/wikimedia/mediawiki-extensions-Auth_remoteuser.git extensions/Auth_remoteuser \
    && git clone -b REL1_39 https://github.com/wikimedia/mediawiki-extensions-LdapAuthentication extensions/LdapAuthentication \
    && git clone -b REL1_39 https://gerrit.wikimedia.org/r/mediawiki/extensions/CreateUserPage.git extensions/CreateUserPage \
    && git clone -b REL1_39 https://gerrit.wikimedia.org/r/mediawiki/extensions/UserMerge.git extensions/UserMerge \
    && git clone -b REL1_39 https://gerrit.wikimedia.org/r/mediawiki/extensions/VEForAll.git extensions/VEForAll

WORKDIR /var/www/html/extensions/PageForms
RUN git checkout a171657

WORKDIR /var/www/html

RUN wget https://github.com/simplesamlphp/simplesamlphp/releases/download/v2.1.6/simplesamlphp-2.1.6.tar.gz \
    && tar xzf simplesamlphp-2.1.6.tar.gz \
    && rm simplesamlphp-2.1.6.tar.gz \
    && mv simplesamlphp-2.1.6 /var/simplesamlphp \
    && chown -R www-data:www-data /var/simplesamlphp

COPY sso/000-default.conf /etc/apache2/sites-available

ADD composer.local.json ./

RUN chown root:root composer.json
RUN composer config --no-interaction allow-plugins.composer/installers true
RUN composer update --no-dev -o

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

COPY update.sh /update.sh
RUN chmod +x /update.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80

CMD ["apache2-foreground"]

