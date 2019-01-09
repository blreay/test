#!/usr/bin/perl

use strict; # ALWAYS!

#use HTML::FromText;
use Net::SMTP; # Yes, this will work on windows.
# You need to fill in the variables.
# Read the perldoc for more info on using SMTP.
#use Mail::Mailer;
use Encode;
use Config;

use Time::Local;
use IPC::Open3;
use File::Temp qw/ tempdir /;
use File::Path;
use Fatal qw / open close waitpid /;
use MIME::QuotedPrint qw(encode_qp);
use Net::SMTP;
use MIME::Base64;
use Sys::Hostname;
use Encode qw(encode);

my $from_address = "perlmonk";
my $to_address = "user\@localhost";
my $subject = "hi";
my $body = "hello"; 
my $message = <<EOF;
Topic "test14"=zzy
Author: zhaoyong.zhang\@oracle.com
reviewers: zhaoyong.zhang\@oracle.com
URL: http://bej301159:9080/codestriker/codestriker.pl?action=view&topic=9674224
--------------------------------------------------------------
Description:
Reviewer: Wade, Minhui, Pin

This is a test.

*** ZHAOZHAN  12/11/14 02:38 am ***
Requirement from HHS:
1.Enhance BatchRT to support one job file includes multiple jobs.
including
sibling jobs and parent-children jobs and mix of them, Make this
kind
of job
Rootcause
file can be submitted.
Solution
file can be submitted.
2.Enhance BatchRT/WorkBench to support following JCL statements:
/*AFTER <jobname>
*** ZHAOZHAN  12/11/14 02:39 am *** (CHG: Desirability-> NULL -> 3)
*** ZHAOZHAN  12/11/14 02:39 am *** (CHG: Sta->15 Asg->ZHAOZHAN)
*** ZHAOZHAN  12/11/14 02:42 am REQUEST TEXT ***
@ Attachment:HHS_Special_JCL_Solution_Multiplejobs_v0.2.doc:Solution
and Design
@ for this feature.

--------------------------------------------------------------

The topic was created with the following files:

batchrt/COMMON/mi_ConvertScript.pl {+14,-2}

Total line count: {+14,-2}

EOF
############################################################
sub zzyformat {
    (my $txt)=@_;
    my $newtxt="";
    my $part_begin=<<EOF;
<html>
  <head>
    <style>
  .reviewer {
        color:red;
        background-color:yellow;
        font-family:Times New Roman;
        font-weight: bold;
        font-size:200%;
      }
  .rootcause {
        color:white;
        background-color:red;
        font-family:Times New Roman;
        font-weight: bold;
        font-size:140%;
      }
  .solution {
        color:white;
        background-color:green;
        font-family:Times New Roman;
        font-weight: bold;
        font-size:140%;
      }
  .description {
        color:white;
        background-color:blue;
        font-family:Times New Roman;
        font-weight: bold;
        font-size:140%;
      }
</style>
  </head> <body>
EOF

    my $part_end=<<EOF;
</body></html>
EOF
    $txt=~ s/\n(\s*reviewer:)(.*)\n/\n<div class=\"reviewer\">\1\2<\/div>\n/ig;
    $txt=~ s/\n(\s*rootcause:*\s*)\n/\n<span class=\"rootcause\">\1<\/span>\n/ig;
    $txt=~ s/\n(\s*solution:*\s*)\n/\n<span class=\"solution\">\1<\/span>\n/ig;
    #$txt=~ s/\n(\s*description:\s*)\n/\n<span class=\"description\">\1<\/span>\n/ig;
    $txt=~ s/\n/<BR>/g;
    $newtxt="$part_begin\n".$txt."\n$part_end";
    return $newtxt;
}

#my $smtp = Net::SMTP->new('stbeehive.oracle.com') or die $!;
my $smtp = Net::SMTP->new('localhost') or die $!;
#my $from="zhaoyong.zhang\@oracle.com";
my $from="oracle zzy";
my $to="zhaoyong.zhang\@oracle.com";

$smtp->mail( $from );
$smtp->to( $to );
$smtp->data();
$smtp->datasend("To: $to\n");
$smtp->datasend("From: $from\n");
#$smtp->datasend("Subject: $subject\n");
$smtp->datasend("Subject: =?UTF-8?Q?${subject}?=\n"); 

# Set the content type to be text/plain with UTF8 encoding, to handle
# unicode characters.
#$smtp->datasend("Content-Type: text/plain; charset=\"utf-8\"\n");
$smtp->datasend("Content-Type: text/html; charset=\"utf-8\"\n");
#$smtp->datasend("Content-Type: text/html\n");
#$smtp->datasend("Content-Type: text/html; charset=\"ISO-8859-1\"\n");
$smtp->datasend("Content-Transfer-Encoding: quoted-printable\n");
#$smtp->datasend("Content-Transfer-Encoding: base64\n");
#$smtp->datasend("Content-Transfer-Encoding: 7bit\n");
#$smtp->datasend("Content-Transfer-Encoding: binary\n");
$smtp->datasend("MIME-Version: 1.0\n"); 
$smtp->datasend("\n"); # done with header

$message = zzyformat($message);
#$message = encode_base64(encode("UTF-8", $message, ""));
$message = encode_qp(encode("UTF-8", $message));
$smtp->datasend($message);

$smtp->dataend();
$smtp->quit(); # all done. message sent.
