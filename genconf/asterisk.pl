#!/usr/bin/perl
use strict;
use warnings;
use UUID::Tiny ':std';
use Sys::Hostname;
use Asterisk::AMI;
no warnings qw(Asterisk::AMI);
use File::Path qw(make_path remove_tree);

# XXX: These need moved to config!
my $ast_user = "asterisk";
my $fcgi_perl_group = "fcgi-perl";
my $radio = 'radio0';
my $ami_file = "/opt/netrig/etc/asterisk/manager.d/logout-cgi.conf";
my $ari_file = "/opt/netrig/etc/asterisk/netrig/ari.$radio.conf";
my $ari_passfile = "/opt/netrig/run/ari.$radio.pass";
my $ari_user = "netrig_$radio";
my $ari_pass = join'', map +(0..9,'a'..'z','A'..'Z')[rand(10+26*2)], 1..16;


# Sort out permissions on /opt/netrig/etc/asterisk/netrig for dynamic configs by perl cgi
system("chown $ast_user:$fcgi_perl_group /opt/netrig/etc/asterisk/netrig");
system("chmod 0770 /opt/netrig/etc/asterisk/netrig");

# Generate an ari user configuration for the backends
open (our $ari_fh, '>', $ari_file) or die("Can't open $ari_file for writing");
print $ari_fh "[$ari_user]\n";
print $ari_fh "type = user\n";
print $ari_fh "read_only = no\n";
print $ari_fh "password = $ari_pass\n";
close $ari_fh;
chmod 0700, $ari_file;

open (our $ami_fh, '>', $ami_file) or die("Can't open $ami_file for writing");
print $ami_fh "[logout-cgi]\n";
print $ami_fh "secret = tShCawPy2EY0iLtB\n";
print $ami_fh "deny=0.0.0.0/0.0.0.0\n";
print $ami_fh "permit=127.0.0.1/32\n";
print $ami_fh "read = system,command,user,config,dialplan\n";
print $ami_fh "write = system,command,user,config,dialplan\n";
close $ami_fh;
chmod 0700, $ami_file;

# Save to a password file
open (our $aripass_fh, '>', $ari_passfile) or die("Can't open $ari_passfile for writing");
print $aripass_fh "$ari_user:$ari_pass\n";
close $aripass_fh;
chmod 0700, $ari_passfile;

# Is asterisk running?
if (-e "/opt/netrig/var/run/asterisk/asterisk.pid") {
   # reload pjsip module in asterisk
   my $astman = Asterisk::AMI->new(PeerAddr => '127.0.0.1',
                                   PeerPort => '5038',
                                   Username => 'logout-cgi',
                                   Secret => 'tShCawPy2EY0iLtB');
   die "Unable to connect to asterisk" unless ($astman);
   $astman->send_action({ Action => 'Command', Command => 'module reload res_pjsip.so' });
   $astman->send_action({ Action => 'Command', Command => 'dialplan reload' });
}
