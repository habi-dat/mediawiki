<?php

$metadata['https://sso.$HABIDAT_DOMAIN'] = array (
  'entityid' => 'https://$HABIDAT_DOMAIN',
  'metadata-set' => 'saml20-idp-remote',
  'SingleSignOnService' => array (0 => array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'https://user.$HABIDAT_DOMAIN/sso/login/$HABIDAT_MEDIAWIKI_SUBDOMAIN',
    ),
  ),
  'SingleLogoutService' => 
    array ( 0 =>  array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'https://user.$HABIDAT_DOMAIN/sso/logout/$HABIDAT_MEDIAWIKI_SUBDOMAIN',
    ),
  ),
  'ArtifactResolutionService' =>  array (),
  'certData' => '$HABIDAT_SSO_CERTIFICATE',
)

?>
