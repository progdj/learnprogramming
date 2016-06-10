#!/usr/bin/perl

use strict;
use warnings;

open my $fh, "/hostconfig/domains" or die $!;
open my $hostfh, ">> /hostconfig/hosts.tmp" or die $!;

my $ipAddress = `hostname --ip-address`;
chomp $ipAddress;

my $hosts;

while (<$fh>)
{     
		print $ipAddress . "\t" . $_ . "\n";
	   chomp;
	   next if /^#/;
       $hosts .= $ipAddress . "\t" . $_ . "\n";
}

print $hostfh $hosts;


close $hostfh;
close $fh;
