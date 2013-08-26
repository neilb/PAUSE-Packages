package PAUSE::Packages::ReleaseIterator;

use Moo;
use PAUSE::Packages;
use PAUSE::Packages::Release;
use PAUSE::Packages::Module;
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
    state $current_path;
    state @modules;
    state $eof = 0;

    return undef if $eof;

    if (not defined $fh) {
        open($fh, '<', $self->packages->path());
        my $inheader = 1;

        # Skip the header block at the top of the file
        while (<$fh>) {
            last if /^$/;
        }
    }

    do {
        my $line = <$fh>;

        if (defined($line)) {
            chomp($line);

            my ($module_name, $version, $path) = split(/\s+/, $line);

            my $module = PAUSE::Packages::Module->new(
                                name => $module_name,
                                version => $version,
                                );

            if (defined($current_path) && $path ne $current_path) {
                my $release = PAUSE::Packages::Release->new(
                                    modules => [@modules],
                                    path => $current_path,
                                    );
                @modules = ($module);
                $current_path = $path;
                return $release;
            } elsif (!defined($current_path)) {
                $current_path = $path;
            }
            push(@modules, $module);
        } else {
            $eof = 1;
            if (defined($current_path) && @modules > 0) {
                return PAUSE::Packages::Release->new(
                            modules => [@modules],
                            path => $current_path,
                            );
            }
            return undef;
        }

    } while (not $eof);

    return undef;
}

1;
