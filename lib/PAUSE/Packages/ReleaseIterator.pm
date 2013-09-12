package PAUSE::Packages::ReleaseIterator;

use Moo;
use PAUSE::Packages;
use PAUSE::Packages::Release;
use PAUSE::Packages::Module;
use JSON;
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
    my @modules;
    state $fh;

    if (not defined $fh) {
        open($fh, '<', $self->packages->path());
        my $inheader = 1;

        # Skip the header block at the top of the file
        while (<$fh>) {
            last if /^$/;
        }
    }

    my $line = <$fh>;

    if (defined($line)) {
        chomp($line);
        my ($path, $json) = split(/\s+/, $line, 2);
        foreach my $entry (@{ decode_json($json) }) {
            my $module = PAUSE::Packages::Module->new(
                            name    => $entry->[0],
                            version => $entry->[1],
                         );
            push(@modules, $module);
        }
        return PAUSE::Packages::Release->new(
                            modules => [@modules],
                            path => $path,
                            );
    } else {
        return undef;
    }

    return undef;
}

1;
