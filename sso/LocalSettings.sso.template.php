<?php

wfLoadExtension( 'PluggableAuth' );

$wgPluggableAuth_EnableAutoLogin = true;
$wgPluggableAuth_EnableLocalLogin = false;
$wgGroupPermissions['*']['autocreateaccount'] = true;


wfLoadExtension( 'SimpleSAMLphp' );

$wgSimpleSAMLphp_InstallDir = '/var/simplesamlphp';
$wgSimpleSAMLphp_AuthSourceId = 'habidat';
$wgSimpleSAMLphp_RealNameAttribute = 'cn';
$wgSimpleSAMLphp_EmailAttribute = 'mail';
$wgSimpleSAMLphp_UsernameAttribute = 'uid';

