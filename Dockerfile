FROM mediawiki:lts

RUN apt update && apt install -y zip unzip zlib1g-dev

RUN docker-php-ext-install zip

RUN apt-get update && \
    apt-get install -y libldap2-dev nano gettext-base wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

WORKDIR /var/www/html

RUN git clone https://github.com/thaider/Tweeki /var/www/html/skins/Tweeki \
    && git clone -b REL1_32 https://gerrit.wikimedia.org/r/p/mediawiki/extensions/PageForms.git /var/www/html/extensions/PageForms \
    && git clone https://github.com/oteloegen/SemanticOrganization.git /var/www/html/extensions/SemanticOrganization \
    && git clone -b REL1_32 https://github.com/wikimedia/mediawiki-extensions-LdapAuthentication extensions/LdapAuthentication \
    && git clone -b REL1_32 https://gerrit.wikimedia.org/r/p/mediawiki/extensions/CreateUserPage.git extensions/CreateUserPage \
    && git clone -b REL1_32 https://gerrit.wikimedia.org/r/p/mediawiki/extensions/MyVariables.git extensions/MyVariables \
    && wget https://www.miniorange.com/downloads/mediawiki_saml_1.1.2.zip -P extensions \
    && unzip extensions/mediawiki_saml_1.1.2.zip -d extensions \
    && rm extensions/mediawiki_saml_1.1.2.zip


RUN curl --silent --show-error https://getcomposer.org/installer | php

RUN php composer.phar require mediawiki/semantic-media-wiki "~2.5" --update-no-dev \
    && php composer.phar require mediawiki/semantic-result-formats "~2.5" --update-no-dev

ADD LocalSettings.php.additional.template ./
ADD LocalSettings.php.sso.template ./
ADD additonal-pages.xml.template ./

# set x-frame options to ALLOWALL to enable being shown in an iframe (inside nextcloud)
RUN a2enmod headers
COPY apache2-security.conf /etc/apache2/conf-enabled/security.conf

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80

CMD ["apache2-foreground"]

