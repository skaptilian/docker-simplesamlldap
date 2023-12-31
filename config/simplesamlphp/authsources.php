<?php

$config = array(
    'admin' => array(
        'core:AdminPassword',
    ),

    'ldap' => [
        'ldap:LDAP',
        'hostname' => 'ldap.movieking.com',
        'enable_tls' => false,
        'timeout' => 10,
        'dnpattern' => 'cn=%username%,dc=movieking,dc=com',
        'search.enable' => false,
    ],
);