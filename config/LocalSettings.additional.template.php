<?php

$wgDefaultSkin = "tweeki";
$wgLanguageCode = "de";

$wgEnableUploads = true; 

# Show Tweeki's advanced features by default
$wgDefaultUserOptions['tweeki-advanced'] = 1;

# Load Parser Functions extension
wfLoadExtension( 'ParserFunctions' );
# Enable String Functions
$wgPFEnableStringFunctions = true;

# Enable Semantic MediaWiki
enableSemantics('localhost');
$smwgEnabledEditPageHelp = false;
$smwgLinksInValues = true;

# Load Page Forms and Semantic Organization extensions
wfLoadExtension('PageForms');
$wgPageFormsAutocompleteOnAllChars = true;
wfLoadExtension('SemanticOrganization');

# Disable caching
$wgEnableParserCache = false;
$wgCachePages = false;

# Allow display titles for automatically created page names
$wgRestrictDisplayTitle = false;

# Make Wiki private
$wgGroupPermissions['*']['createaccount'] = false;
$wgGroupPermissions['*']['read'] = false;
$wgGroupPermissions['*']['edit'] = false;

# Load auto user page creation extension
wfLoadExtension( 'CreateUserPage' );
$wgCreateUserPage_PageContent = '{{semorg-person-user-custom}}';

# Load extension to get current user name
#wfLoadExtension( 'MyVariables' );

wfLoadExtension('UserMerge');
$wgGroupPermissions['bureaucrat']['usermerge'] = true;

$wgTweekiSkinHideAnon['navbar'] = true; 
$wgTweekiSkinHideAnon['footer'] = true; 
$wgTweekiSkinHideAll['footer-info'] = false; 
$wgTweekiSkinHideAll['footer-places'] = true; 
$wgTweekiSkinHideAll['footer-info-copyright'] = true; 
$wgTweekiSkinHideAll['footer-icons'] = true;
$wgTweekiSkinUseTooltips = true;
$wgTweekiSkinUseRealnames = true;
$wgJobRunRate = 100;

$wgMaxCredits = 1;

# LDAP
/*require_once ('extensions/LdapAuthentication/LdapAuthentication.php');

$wgAuthManagerAutoConfig['primaryauth'] += [
  LdapPrimaryAuthenticationProvider::class => [
    'class' => LdapPrimaryAuthenticationProvider::class,
    'args' => [['authoritative' => false]], // don't allow local non-LDAP accounts
    'sort' => 50, // must be smaller than local pw provider
  ],
];

$wgLDAPDomainNames = array( 'habidat-ldap' );
$wgLDAPServerNames = array( 'habidat-ldap' => '$HABIDAT_LDAP_HOST' );
$wgLDAPUseLocal = false;
$wgLDAPEncryptionType = array( 'habidat-ldap' => 'clear' );
$wgLDAPPort = array( 'habidat-ldap' => $HABIDAT_LDAP_PORT );
$wgLDAPProxyAgent = array( 'habidat-ldap' => '$HABIDAT_LDAP_BINDDN' );
$wgLDAPProxyAgentPassword = array( 'habidat-ldap' => '$HABIDAT_LDAP_ADMIN_PASSWORD' );
$wgLDAPSearchAttributes = array( 'habidat-ldap' => 'cn' );
$wgLDAPBaseDNs = array( 'habidat-ldap' => '$HABIDAT_LDAP_BASE' );
$wgLDAPUserBaseDNs = array( 'habidat-ldap' => 'ou=users,$HABIDAT_LDAP_BASE' );
$wgLDAPGroupBaseDNs = array( 'habidat-ldap' => 'ou=groups,$HABIDAT_LDAP_BASE' );

# Map specific LDAP attributes like e-mail addresses
$wgLDAPPreferences = array( 'habidat-ldap' => array('email' => 'mail', 'realname' => 'cn', 'nickname' => 'givenName' ) );

# Group based restriction:
$wgLDAPGroupUseFullDN = array( 'habidat-ldap' => true );
$wgLDAPGroupObjectclass = array( 'habidat-ldap' => 'groupOfNames' );
$wgLDAPGroupAttribute = array( 'habidat-ldap' => 'member' );
$wgLDAPGroupSearchNestedGroups = array( 'habidat-ldap' => false );
$wgLDAPGroupNameAttribute = array( 'habidat-ldap' => 'cn' );
$wgLDAPLowerCaseUsername = array( 'habidat-ldap' => true );
$wgLDAPRequiredGroups = array(
  'habidat-ldap' => array(
    'cn=$HABIDAT_MEDIAWIKI_LDAP_GROUP,ou=groups,$HABIDAT_LDAP_BASE',
  ),
);

// This hook is called by the LdapAuthentication plugin. It is a configuration hook. Here we
// are specifying what attibute we want to use for a username in the wiki.
// Note that this hook is NOT called on a straight bind.
// The hook calls the function defined below.
$wgHooks['SetUsernameAttributeFromLDAP'][] = 'SetUsernameAttribute';

// This function allows you to get the username from LDAP however you need to do it.
// This is the username MediaWiki will use.
function SetUsernameAttribute(&$LDAPUsername, $info) {
        $LDAPUsername = ucwords($info[0]['cn'][0]);
        return true;
}

$wgLDAPDebug = 3;
$wgDebugLogGroups['ldap'] = "/tmp/debug.log" ;
*/

error_reporting(E_ERROR | E_PARSE);
