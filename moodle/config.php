<?php
unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mysqli';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'db';
$CFG->dbname    = 'moodle';
$CFG->dbuser    = 'moodleuser';
$CFG->dbpass    = 'MoodlePass@123';
$CFG->prefix    = 'mdl_';

$CFG->wwwroot   = 'http://192.168.0.103';
$CFG->dataroot  = '/var/www/moodledata';
$CFG->admin     = 'admin';

$CFG->debug = E_ALL;
$CFG->debugdisplay = 1;

$CFG->sessioncookie = 'MoodleSession';
$CFG->sessiontimeout = 7200;

$CFG->directorypermissions = 0777;

require_once(__DIR__ . '/lib/setup.php'); 