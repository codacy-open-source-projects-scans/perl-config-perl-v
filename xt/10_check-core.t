#!/pro/bin/perl

use strict;
use warnings;
use Test::More;
use Cwd;

my $here = getcwd;

chdir "/pro/3gl/CPAN/perl-git" or plan skip_all => "This is not the developer environment";
qx{git pull --all};

my @pc;
if (open my $fh, "<", "perl.c") {
    while (<$fh>) {
	(/^S_Internals_V/ .. /^}/) or next;
	m/^\s+"\s*(\S.*)"/ and push @pc, $1;
	}
    }

my @ph;
if (open my $fh, "<", "perl.h") {
    while (<$fh>) {
	(/^\w.*PL_bincompat/../^\w}/) or next;
	m/^\s*$/ and last;
	m/^\s+"\s*(\S.*)"/ and push @ph, $1;
	}
    }

chdir $here;
open my $fh, "V.pm" or die "Cannot open V.pm: $!\n";
my (%C, %H, $v);
while (<$fh>) {
    if (m/ qw\($/) {
	$v = \%C;
	next;
	}
    $v or next;
    m/^\s+\);$/ and last;
    if (%C && m/^\s*$/) {
	$v = \%H;
	next;
	}
    m/^\s+(\S+)/ and $v->{$1}++;
    }

ok ($C{$_}, "perl.c - $_") for @pc;
ok ($H{$_}, "perl.h - $_") for @ph;

done_testing;
