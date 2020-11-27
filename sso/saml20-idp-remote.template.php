<?php

$metadata['https://sso.$HABIDAT_DOMAIN'] = array (
  'entityid' => 'https://$HABIDAT_DOMAIN',
  'metadata-set' => 'saml20-idp-remote',
  'SingleSignOnService' => array (0 => array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'https://sso.$HABIDAT_DOMAIN/simplesaml/saml2/idp/SSOService.php',
    ),
  ),
  'SingleLogoutService' => 
    array ( 0 =>  array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'https://sso.$HABIDAT_DOMAIN/simplesaml/saml2/idp/SingleLogoutService.php',
    ),
  ),
  'ArtifactResolutionService' =>  array (),
  'certData' => '$HABIDAT_SSO_CERTIFICATE',
)

?>
