#!/usr/bin/env perl
##
###########################
## Server Info CGI v1.08 ##
###########################
##
##  ######################################
##  ##   Server Info CGI v1.08 � 2000   ##
##  ##      http://www.widexl.com       ##
##  ##      Made by Henk Boonstra       ##
##  ######################################
##
## This script gives information about your (web)server.
## Software, Modules, libraries, env, network...
##
## Install:
## Change the path to perl (The first line in this script).
## Upload the script in ASCII mode to your cgi-bin directory.
## chmod script to 755.
## Open the script in a browser.
##
##############################
##############################

use strict;
use warnings FATAL => 'all';
no warnings 'redefine'; # to be remove in production
use Carp;

our %info  = ();
my $output = undef;
my $ver    = 'v1.8';

find_prog();

print "Content-type: text/html\n\n";

my $header = qq|
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
        <title>Server Info script</title>
<meta name="robots" content="noindex,nofollow">

<style type="text/css"><!--
BODY {
        background-color : #FFFFFF;
        font-family: verdana, arial, helvetica, sans-serif;
        color : #484848;
        font-size : 12px;

        scrollbar-face-color: #FFFFFF;
        scrollbar-shadow-color: #000000;
        scrollbar-highlight-color: #484848;
        scrollbar-3dlight-color: #FFFFFF;
        scrollbar-darkshadow-color:     #000000;
        scrollbar-track-color: #8E929D;
        scrollbar-arrow-color: #484848;
}

TD {
        font-family: verdana, arial, helvetica, sans-serif;
        color : #484848;
        font-size : 12px;
}

PRE {
        color : #484848;
        margin-bottom: 0px;
        margin-top: 0px;
}

I {
        font-family: verdana, arial, helvetica, sans-serif;
        color : Red;
        font-size : 12px;
}

STRONG {
        background-color : transparent;
        font-family: verdana, arial, helvetica, sans-serif;
        color : #484848;
        font-size : 12px;
        font-weight : bold;
}

--></style>
</head>
<body>
|;

$output .= "$header\n";
$output .= "<table border=\"0\" cellspacing=\"0\" cellpadding=\"32\" align=\"left\" width=\"760\"><tr><td align=\"left\">\n\n";

if ($^O eq 'MSWin32') {
  $info{'OS_VERSION'} = `ver`;
  $info{'HOST_NAME'}  = `hostname`;
  if ($info{'OS_VERSION'}) {$info{'EXEC'} = 'Enabled'}
}

else {
  $info{'PROC_RELEASE'} = `uname -r`;
  $info{'MACHINE'}      = `uname -m`;
  $info{'PROCESSOR'}    = `uname -p`;
  $info{'NODE_NAME'}    = `uname -n`;
  $info{'SYS_NAME'}     = `uname -s`;
  $info{'WHOAMI'}       = `whoami`;

  my $ex                = `which perl`;
  $info{'TAR'}          = `which tar`             || $info{'TAR'};
  $info{'GZIP'}         = `which gzip`            || $info{'GZIP'};
  $info{'COMPRESS'}     = `which compress`        || $info{'COMPRESS'};
  $info{'WHOIS'}        = `which whois`           || $info{'WHOIS'};
  $info{'CONVERT'}      = `which convert`         || $info{'CONVERT'};
  $info{'MAIL_PROGRAM'} = `which sendmail`        || $info{'MAIL_PROGRAM'};
  $info{'MAIL_PROGRAM'} = "Found no mail program" if (!$info{'MAIL_PROGRAM'});

  $info{'UPTIME'}       = `uptime`;
  $info{'QUOTA'}        = `quota`;
  $info{'QUOTA'}        =~ s/\n/<br>/isg if ($info{'QUOTA'});

  if ($ex) {$info{'EXEC'} = 'Enabled'}
}

$info{'OS'}           = $^O;
$info{'SERVER_NAME'}  = $ENV{'SERVER_NAME'};
$info{'SERVER_ADDR'}  = $ENV{'SERVER_ADDR'};

$info{'PERL_EXE'}     = $^X;
$info{'PERL_VER'}     = $];
$info{'PERL_LIB'}     = "@INC";

$info{'HTTP_HOST'}    = $ENV{'HTTP_HOST'};
$info{'APACHE_LIB'}   = $info{'APACHE_LIB'};
$info{'DOCU_ROOT'}    = $ENV{'DOCUMENT_ROOT'};
$info{'SERVER_ADMIN'} = $ENV{'SERVER_ADMIN'};
$info{'SERVER_SOFT'}  = $ENV{'SERVER_SOFTWARE'};
$info{'HTTP_ACCEPT'}  = $ENV{'HTTP_ACCEPT'};

$info{'REMOTE_ADDR'}  = $ENV{'REMOTE_ADDR'};
$info{'REMOTE_HOST'}  = $ENV{'REMOTE_HOST'};
$info{'ACCEPT_LANG'}  = $ENV{'HTTP_ACCEPT_LANGUAGE'};
$info{'USER_AGENT'}   = $ENV{'HTTP_USER_AGENT'};

$info{'SERVER_VER'}   = server('version');
$info{'SERVER_CPU'}   = server('cpuinfo');
$info{'SERVER_MEM'}   = server('meminfo');

# The Output.
$output .= "<strong>Server info</strong><br>\n";
$output .= "Operating system = <%OS%><br>\n";

if (("$^O" eq "MSWin32") and ($info{'EXEC'})) {
  $output .= "Version        = <%OS_VERSION%><br>\n";
  $output .= "Host name      = <%HOST_NAME%><br>\n";
}

if (("$^O" ne "MSWin32") and ($info{'EXEC'})) {
  $output .= "Kernel         = <%PROC_RELEASE%><br>\n";
  $output .= "Machine        = <%MACHINE%><br>\n";
  $output .= "Processor type = <%PROCESSOR%><br>\n";
  $output .= "Whoami         = <%WHOAMI%><br>\n";
  $output .= "Host name      = <%NODE_NAME%><br>\n";
}

$output .= "Server name      = <%SERVER_NAME%><br>\n";
$output .= "Server IP        = <%SERVER_ADDR%><br>\n";
$output .= "<br>\n\n";

$output .= "<strong>Web server info</strong><br>\n";
$output .= "HTTP address     = <%HTTP_HOST%><br>\n";
$output .= "Document root    = <%DOCU_ROOT%><br>\n";
$output .= "Apache lib       = <%APACHE_LIB%><br>\n";
$output .= "Administrator    = <%SERVER_ADMIN%><br>\n";
$output .= "Server software  = <%SERVER_SOFT%><br>\n";
$output .= "HTTP accept      = <%HTTP_ACCEPT%><br>\n";
$output .= "<br>\n\n";

$output .= "<strong>Server programs</strong><br>\n";
$output .= "Mail program        = <%MAIL_PROGRAM%><br>\n";
$output .= "Tar program         = <%TAR%><br>\n";
$output .= "Gzip program        = <%GZIP%><br>\n";
$output .= "Compress program    = <%COMPRESS%><br>\n";
$output .= "Whois program       = <%WHOIS%><br>\n";
$output .= "ImageMagick convert = <%CONVERT%><br>\n";
$output .= "<br>\n\n";

$output .= "<strong>Perl info</strong><br>\n";
$output .= "Perl location               = <%PERL_EXE%><br>\n";
$output .= "Perl version                = <%PERL_VER%><br>\n";
$output .= "Locations of Perl libraries = <%PERL_LIB%><br>\n";
$output .= "<br>\n\n";

$output .= "<strong>Remote user info</strong><br>\n";
$output .= "Remote IP       = <%REMOTE_ADDR%><br>\n";
$output .= "Remote hostname = <%REMOTE_HOST%><br>\n";
$output .= "Language        = <%ACCEPT_LANG%><br>\n";
$output .= "User agent      = <%USER_AGENT%><br>\n";
$output .= "<br>\n\n";

$output .= "<strong>Extra info</strong><br>\n";
$output .= "Executing of system commands = Enabled<br>\n" if ($info{'EXEC'});
$output .= "Executing of system commands = Not enabled<br>\n" if (!$info{'EXEC'});
$output .= "Server uptime                = <%UPTIME%><br>\n";
$output .= "<br>\n\n";

if ("$^O" ne "MSWin32") {

  $output .= "<strong>Server version</strong><br>\n";
  $output .= "<%SERVER_VER%><br>\n";
  $output .= "<br>\n\n";

  if ($info{'QUOTA'}) {
    $output .= "<strong>Disk Quota</strong><br>\n";
    $output .= "<%QUOTA%>\n";
    $output .= "<br>\n\n";
  }

  $output .= "<strong>CPU info</strong><br>\n";
  $output .= "<%SERVER_CPU%><br>\n";
  $output .= "<br>\n\n";

  $output .= "<strong>Memory info</strong><br>\n";
  $output .= "<%SERVER_MEM%><br>\n";
  $output .= "<br>\n\n";
}

$output .= "<strong>Perl libraries installed</strong><br>\n";
eval {require CGI};
if ($@) {$output .= "<i>The library CGI is not installed</i><br>\n"}
else {$output .= "Library CGI v$CGI::VERSION installed<br>\n"}

eval {require mod_perl};
if ($@) {$output .= "<i>The library mod_perl is not installed</i><br>\n"}
else {$output .= "Library mod_perl v$mod_perl::VERSION installed<br>\n"}

eval {require LWP};
if ($@) {$output .= "<i>The library www-perl is not installed</i><br>\n"}
else {$output .= "Library www-perl v$LWP::VERSION installed<br>\n"}

eval {require LWP::Parallel};
if ($@) {$output .= "<i>The library LWP::Parallel is not installed</i><br>\n"}
else {$output .= "Library LWP::Parallel v$LWP::Parallel::VERSION installed<br>\n"}

eval {require SOAP::Lite};
if ($@) {$output .= "<i>The library SOAP::Lite is not installed</i><br>\n"}
else {$output .= "Library SOAP::Lite v$SOAP::Lite::VERSION installed<br>\n"}

eval {require DBI};
if ($@) {$output .= "<i>The library DBI is not installed</i><br>\n"}
else {$output .= "Library DBI v$DBI::VERSION installed<br>\n"}

eval {require DBD::mysql};
if ($@) {$output .= "<i>The library DBD::mysql is not installed</i><br>\n"}
else {$output .= "Library DBD::mysql v$DBD::mysql::VERSION installed<br>\n"}

eval {require URI};
if ($@) {$output .= "<i>The library URI is not installed</i><br>\n"}
else {$output .= "Library URI v$URI::VERSION installed<br>\n"}

eval {require Digest::MD5};
if ($@) {$output .= "<i>The library Digest::MD5 is not installed</i><br>\n"}
else {$output .= "Library Digest::MD5 v$Digest::MD5::VERSION installed<br>\n"}

eval {require Crypt::SSLeay};
if ($@) {$output .= "<i>The library Crypt::SSLeay is not installed</i><br>\n"}
else {$output .= "Library Crypt::SSLeay v$Crypt::SSLeay::VERSION installed<br>\n"}

eval {require Net::SSLeay};
if ($@) {$output .= "<i>The library Net::SSLeay is not installed</i><br><br>\n\n"}
else {$output .= "Library Net::SSLeay.pm v$Net::SSLeay::VERSION installed<br><br>\n\n"}



if ($info{'APACHE_LIB'}) {
  my @standard_mod = ('mod_rewrite.so', 'mod_cgi.so', 'mod_perl.so', 'mod_env.so', 'mod_include.so', 'mod_alias.so', 'mod_python.so');
  my @auth_mod     = ('mod_auth_digest.so', 'mod_auth_mysql.so');
  my @ext_mod      = ('mod_expires.so', 'mod_headers.so', 'libphp5.so', 'mod_proxy.so', 'mod_speling.so', 'mod_status.so',  'mod_usertrack.so', 'mod_vhost_alias.so');

  $output .= "<strong>Apache modules installed</strong><br>\n";

  foreach my $item(@standard_mod) {
    if (-e "$info{'APACHE_LIB'}/$item") {$output .= "Module '$item' installed<br>\n"}
    else {$output .= "<i>Module '$item' is not installed</i><br>\n"}
  }

  $output .= "<br>\n\n";

  foreach my $item (@auth_mod) {
    if (-e "$info{'APACHE_LIB'}/$item") {$output .= "Module '$item' installed<br>\n"}
    else {$output .= "<i>Module '$item' is not installed</i><br>\n"}
  }

  $output .= "<br>\n\n";

  foreach my $item(@ext_mod) {
    if (-e "$info{'APACHE_LIB'}/$item") {$output .= "Module '$item' installed<br>\n"}
    else {$output .= "<i>Module '$item' is not installed</i><br>\n"}
  }

  $output .= "<br>\n\n";
}

eval {
  $info{'GET_USER'}  = getpwent();
  $info{'GET_GROUP'} = getgrent();
  $info{'GET_HOST'}  = gethostent();
  $info{'GET_NET'}   = getnetent();
  $info{'GET_PROTO'} = getprotoent();
  $info{'GET_SERV'}  = getservent();

  $output .= "<strong>Special info</strong><br>\n";
  $output .= "user     = <%GET_USER%><br>\n";
  $output .= "group    = <%GET_GROUP%><br>\n";
  $output .= "host     = <%GET_HOST%><br>\n";
  $output .= "network  = <%GET_NET%><br>\n";
  $output .= "protocol = <%GET_PROTO%><br>\n";
  $output .= "service  = <%GET_SERV%><br>\n";
  $output .= "<br>\n\n";
};

$output .= "<strong>Web server Env</strong><br>\n";

my @keys   = keys %ENV;
my @values = values %ENV;
foreach my $key (sort(@keys)) {
  $output .= "$key = $ENV{$key}<br>\n";
}

$output .= "</td></tr></table>\n";
$output .= "</body></html>\n";

$output =~ s/<%\s*(.*?)\s*%>/if ($info{$1}) {$info{$1}} else {"<i>undefined<\/i>"}/oesg;

print $output;

return 'OK';

########################
## Find Programs
########################
sub find_prog {

if (-e "/usr/local/bin/tar") {$info{'TAR'} = "/usr/local/bin/tar"}
elsif (-e "/usr/bin/tar") {$info{'TAR'} = "/usr/bin/tar"}
elsif (-e "/usr/local/tar") {$info{'TAR'} = "/usr/local/tar"}

if (-e "/usr/local/bin/gzip") {$info{'GZIP'} = "/usr/local/bin/gzip"}
elsif (-e "/usr/bin/gzip") {$info{'GZIP'} = "/usr/bin/gzip"}
elsif (-e "/usr/local/gzip") {$info{'GZIP'} = "/usr/local/gzip"}

if (-e "/usr/local/bin/compress") {$info{'COMPRESS'} = "/usr/local/bin/compress"}
elsif (-e "/usr/bin/compress") {$info{'COMPRESS'} = "/usr/bin/compress"}
elsif (-e "/usr/local/compress") {$info{'COMPRESS'} = "/usr/local/compress"}

if (-e "/usr/local/bin/whois") {$info{'WHOIS'} = "/usr/local/bin/whois"}
elsif (-e "/usr/bin/whois") {$info{'WHOIS'} = "/usr/bin/whois"}
elsif (-e "/usr/local/whois") {$info{'WHOIS'} = "/usr/local/whois"}

if (-e "/usr/local/bin/convert") {$info{'CONVERT'} = "/usr/local/bin/convert"}
elsif (-e "/usr/bin/convert") {$info{'CONVERT'} = "/usr/bin/convert"}
elsif (-e "/usr/local/convert") {$info{'CONVERT'} = "/usr/local/convert"}

########################
## Find Mail
########################
if (-e "/var/qmail/bin/qmail-inject") {$info{'MAIL_PROGRAM'} = "/var/qmail/bin/qmail-inject"}
elsif (-e "/usr/sbin/sendmail") {$info{'MAIL_PROGRAM'} = "/usr/sbin/sendmail"}
elsif (-e "/usr/lib/sendmail") {$info{'MAIL_PROGRAM'} = "/usr/lib/sendmail"}
elsif (-e "/usr/bin/sendmail") {$info{'MAIL_PROGRAM'} = "/usr/bin/sendmail"}

########################
## Find Apache
########################
if (-e "/usr/lib/httpd/modules/mod_env.so") {$info{'APACHE_LIB'} = "/usr/lib/httpd/modules"}
elsif (-e "/opt/lib/apache2/mod_env.so") {$info{'APACHE_LIB'} = "/opt/lib/apache2"}
if (-e "/usr/lib64/httpd/modules/mod_env.so") {$info{'APACHE_LIB'} = "/usr/lib64/httpd/modules"}
#elsif (-e "/System/Library/Apache/Modules/mod_env.so") {$info{'APACHE_LIB'} = "/System/Library/Apache/Modules"}# Mac
#elsif (-e "/System/Library/Apache2/Modules/mod_env.so") {$info{'APACHE_LIB'} = "/System/Library/Apache2/Modules"}# Mac
#elsif (-e "/usr/local/apache/modules/mod_env.so") {$info{'APACHE_LIB'} = "/usr/local/apache/modules"}# MachTen/WebTen
#elsif (-e "/usr/local/apache2/modules/mod_env.so") {$info{'APACHE_LIB'} = "/usr/local/apache2/modules"}# MachTen/WebTen
#elsif (-e "/usr/lib/apache/modules/mod_env.so") {$info{'APACHE_LIB'} = "/usr/lib/apache/modules"}# OpenBSD
#elsif (-e "/usr/lib/apache2/modules/mod_env.so") {$info{'APACHE_LIB'} = "/usr/lib/apache2/modules"}# OpenBSD
#elsif (-e "/usr/lib/apache/mod_env.so") {$info{'APACHE_LIB'} = "/usr/lib/apache"}
#elsif (-e "/usr/lib/httpd/mod_env.so") {$info{'APACHE_LIB'} = "/usr/lib/httpd"}
#elsif (-e "C:/Apache/modules") {$info{'APACHE_LIB'} = "C:/Apache/modules"}# windows
#elsif (-e "C:/Apache2/modules") {$info{'APACHE_LIB'} = "C:/Apache2/modules"}# windows
}

##############
## Server Info
##############
sub server {
  my $serv_info   = shift;
  my $server_info = undef;

  if (-e "/proc/$serv_info") {
    open SERVER, "</proc/$serv_info";
      $server_info .= join("<br>", <SERVER>);
    close SERVER;
  }
  return $server_info;
}
