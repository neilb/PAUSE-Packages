package PAUSE::Packages::EntryIterator;

use Moo;
use PAUSE::Packages;
use PAUSE::Packages::Entry;
use autodie;
use feature 'state';

has 'packages' =>
    (
        is      => 'ro',
        default => sub { return PAUSE::Packages->new(); },
    );

sub next
{
    my $self = shift;
    state $fh;

    if (not defined $fh) {
        open($fh, '<', $self->packages->path());

        # Skip the header block at the top of the file
        while (<$fh>) {
            last if /^$/;
        }
    }

    my $line = <$fh>;

    if (defined($line)) {
        chomp($line);
        my ($module, $version, $release) = split(/\s+/, $line);
        return PAUSE::Packages::Entry->new(module => $module, version => $version, release => $release);
    } else {
        return undef;
    }
}

1;
