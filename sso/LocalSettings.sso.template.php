<?php

wfLoadExtension( 'PluggableAuth' );

$wgPluggableAuth_EnableAutoLogin = true;
$wgPluggableAuth_EnableLocalLogin = false;
$wgGroupPermissions['*']['autocreateaccount'] = true;


wfLoadExtension( 'SimpleSAMLphp' );

$wgSimpleSAMLphp_InstallDir = '/var/simplesamlphp';

$wgPluggableAuth_Config['Log in using my SAML'] = [
	'plugin' => 'SimpleSAMLphp',
	'data' => [
		'authSourceId' => 'habidat',
		'usernameAttribute' => 'uid',
		'realNameAttribute' => 'cn',
		'emailAttribute' => 'mail'
	]
];