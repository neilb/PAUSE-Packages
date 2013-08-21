package PAUSE::Packages;
use strict;
use warnings;

use Moo;

with('File::CachedURL');

has '+uri' =>
    (
     default    => sub { return 'http://www.cpan.org/modules/02packages.details.txt' },
    );

has '+basename' =>
    (
     default => sub { return '02packages.txt'; },
    );

#
# I'm currently calling these as class methods:
#
#   my $iterator = PAUSE::Packages->release_iterator();
#
# But that results in the class being instantiated twice. I was trying to avoid:
#
#   my $packages = PAUSE::Packages->new();
#   my $iterator = $packages->entry_iterator();
#
# I guess the first example could then be written:
#
#   my $iterator = PAUSE::Packages->new()->entry_iterator();
#
# ?

sub entry_iterator
{
    require PAUSE::Packages::EntryIterator;
    return PAUSE::Packages::EntryIterator->new( permissions => PAUSE::Packages->new() );
}

sub release_iterator
{
    require PAUSE::Packages::ReleaseIterator;
    return PAUSE::Packages::ReleaseIterator->new( permissions => PAUSE::Packages->new() );
}

1;
