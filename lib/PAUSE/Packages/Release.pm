package PAUSE::Packages::Release;

use Moo;
use CPAN::DistnameInfo;

has 'modules' => (is => 'ro');
has 'path' => (is => 'ro');
has 'distinfo' => (is => 'lazy');

sub _build_distinfo
{
    my $self = shift;

    return CPAN::DistnameInfo->new($self->path);
}

1;
