package PAUSE::Packages;

use Moo;
use File::HomeDir;
use File::Spec::Functions 'catfile';
use HTTP::Tiny;

my $DISTNAME = '{{ $dist->name }}';
my $BASENAME = '02packages.details.txt';

has 'url' =>
    (
     is      => 'ro',
     default => sub { return 'http://www.cpan.org/modules/02packages.details.txt' },
    );

has 'path' =>
    (
     is      => 'rw',
    );

sub BUILD
{
    my $self = shift;

    # If constructor didn't specify a local file, then mirror the file from CPAN
    if (not $self->path) {
        $self->path( catfile(File::HomeDir->my_dist_data( $DISTNAME, { create => 1 } ), $BASENAME) );
        HTTP::Tiny->new()->mirror($self->url, $self->path);
    }
}

sub entry_iterator
{
    my $self = shift;

    require PAUSE::Packages::EntryIterator;
    return PAUSE::Packages::EntryIterator->new( packages => $self );
}

sub release_iterator
{
    my $self = shift;

    require PAUSE::Packages::ReleaseIterator;
    return PAUSE::Packages::ReleaseIterator->new( packages => $self );
}

1;

=head1 NAME

PAUSE::Packages - interface to PAUSE's packages file (02packages.details.txt)

=head1 SYNOPSIS

  use PAUSE::Packages;

  my $pp       = PAUSE::Packages->new;
  my $iterator = $pp->release_iterator();

  foreach my $release ($iterator->next) {
    print 'path = ', $release->path, "\n";
    print '   modules = ', join(', ', @{ $release->modules }), "\n";
  }

=head1 DESCRIPTION

PAUSE::Packages provides an interface to the C<02packages.details.txt>
file produced by the Perl Authors Upload Server (PAUSE).
The file records what version of what modules are included in the
most recent release of each distribution on CPAN.

The interface for this distribution is very much still in flux,
as is the documentation. More of the latter will be coming soon.

=head1 REPOSITORY

L<https://github.com/neilbowers/PAUSE-Packages>

=head1 AUTHOR

Neil Bowers E<lt>neilb@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Neil Bowers <neilb@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

