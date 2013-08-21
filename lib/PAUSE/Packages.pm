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
