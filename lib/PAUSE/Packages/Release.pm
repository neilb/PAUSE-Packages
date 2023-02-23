package PAUSE::Packages::Release;

use 5.8.1;
use Moo 1.006;
use CPAN::DistnameInfo;

has 'modules' => (is => 'ro');
has 'path' => (is => 'ro');
has 'distinfo' => (is => 'lazy');

sub _build_distinfo
{
    my $self = shift;

    return CPAN::DistnameInfo->new($self->path);
}

=head1 NAME

PAUSE::Packages::Release - Captures information about a CPAN release

=head1 SYNOPSIS

 use PAUSE::Packages;

 my $pp = PAUSE::Packages->new;
 my $release = $pp->('Amazon-S3');  # gets information about the Amazone-S3 release
 my $path = $release->path;         # B/BI/BIGFOOT/Amazon-S3-0.60.tar.gz
 my $distinfo = $release->distinfo; # returns a CPAN::DistnameInfo object
 my $version = $distinfo->version   # 0.60
 my $modules = $release->modules;   # Returns an array of PAUSE::Packages::Module
 my @names = map {$_->name} @$modules; # Extracts the module names of the release:
                                       #  Amazon::S3, Amazon::S3::Bucket,
                                       #  Amazon::S3::Constants, Amazon::S3::Logger,
                                       #  Amazon::S3::Signature::V4

=head1 METHODS

=head2 path()

Returns the full path to the distribution, e.g. C<B/BI/BIGFOOT/Amazon-S3-0.60.tar.gz>.

(The same is also returned by C<distinfo()-E<gt>pathname()>)

=head2 distinfo()

Returns a L<CPAN::DistnameInfo> object for the distribution

=head2 modules()

Returns an array of L<PAUSE::Packages::Module> of modules for the release

=head1 SEE ALSO

=over 4

=item *

L<CPAN::DistnameInfo>

=item *

L<PAUSE::Packages::Module>

=back

=cut

1;
