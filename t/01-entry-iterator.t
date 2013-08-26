#!perl

use strict;
use warnings;

use Test::More 0.88 tests => 3;
use PAUSE::Packages;

#-----------------------------------------------------------------------
# construct PAUSE::Packages
#-----------------------------------------------------------------------

my $pp = PAUSE::Packages->new(path => 't/02packages-mini.txt');

ok(defined($pp), "instantiate PAUSE::Packages");

#-----------------------------------------------------------------------
# construct the iterator
#-----------------------------------------------------------------------
my $iterator = $pp->entry_iterator();

ok(defined($iterator), 'create release iterator');

#-----------------------------------------------------------------------
# Construct a string with info
#-----------------------------------------------------------------------
my $expected = <<"END_EXPECTED";
Module::Path|0.09|N/NE/NEILB/Module-Path-0.09.tar.gz
PAUSE::Permissions|0.04|N/NE/NEILB/PAUSE-Permissions-0.04.tar.gz
PAUSE::Permissions::Module|0.04|N/NE/NEILB/PAUSE-Permissions-0.04.tar.gz
END_EXPECTED

my $string = '';

while (my $entry = $iterator->next) {
    $string .= $entry->module
               .'|'
               .$entry->version
               .'|'
               .$entry->release
               ."\n";
}

is($string, $expected, "rendered entry details");

