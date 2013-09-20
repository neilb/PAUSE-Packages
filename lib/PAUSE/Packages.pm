package PAUSE::Packages;

use Moo;
use File::HomeDir;
use File::Spec::Functions 'catfile';
use HTTP::Date qw(time2str);
use HTTP::Tiny;
use CPAN::DistnameInfo;
use Carp;
use autodie qw(open);

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

sub BUILD
{
    my $self = shift;

    # If constructor didn't specify a local file, then mirror the file from CPAN
    if (not $self->path) {
        $self->path( catfile(File::HomeDir->my_dist_data( $DISTNAME, { create => 1 } ), $BASENAME) );
        # HTTP::Tiny->new()->mirror($self->url, $self->path);
        $self->_cache_file_if_needed();
    }
}

sub _cache_file_if_needed
{
    my $self    = shift;
    my $options = {};
    my $ua      = HTTP::Tiny->new();

    if (-f $self->path) {
        $options->{'If-Modified-Since'} = time2str( (stat($self->path))[9]);
    }
    my $response = $ua->get($self->url, $options);

    return if $response->{status} == 304; # Not Modified

    if ($response->{status} == 200) {
        $self->_transform_and_cache($response);
        return;
    }

    croak("request for 02packages failed: $response->{status} $response->{reason}");
}

sub _transform_and_cache
{
    my ($self, $response) = @_;
    my $inheader = 1;
    my (%release, %other, $module, $version, $path, $distname);

    LINE:
    while ($response->{content} =~ m!^(.*)$!gm) {
        my $line = $1;
        if ($line =~ /^$/ && $inheader) {
            $inheader = 0;
            next;
        }
        next LINE if $inheader;
        ($module, $version, $path) = split(/\s+/, $line);

        my $di = CPAN::DistnameInfo->new($path);

        if (defined($di) && defined($distname = $di->dist) && defined($di->version)) {
            if (!exists($release{$distname}) || $release{$distname}->{version} lt $di->version) {
                $release{$distname} = {
                                    version => $di->version,
                                    modules => [ { name => $module, version => $version } ],
                                    path    => $path,
                                   };
            } elsif ($di->version lt $release{$distname}->{version}) {
                next LINE;
            } else {
                push(@{ $release{$distname}->{modules} },
                     { name => $module, version => $version }
                    );
            }
        } else {
            push(@{ $other{$path} }, { name => $module, version => $version });
        }
    }

    open(my $fh, '>', $self->path);

    print $fh <<"END_HEADER";
File: PAUSE Packages data
Format: 2
Source: CPAN/modules/02packages.details.txt

END_HEADER

    foreach $distname (sort keys %release) {
        print $fh $release{$distname}->{path}, ' ';
        print $fh "[", join(",", map { '["'.$_->{name}.'","'.$_->{version}.'"]' } @{ $release{$distname}->{modules} }), "]\n";
    }

    foreach my $release (sort keys %other) {
        print $fh $release, ' ';
        print $fh "[", join(",", map { '["'.$_->{name}.'","'.$_->{version}.'"]' } @{ $other{$release} }), "]\n";
    }

    close($fh);
}

1;

=head1 NAME

PAUSE::Packages - interface to PAUSE's packages file (02packages.details.txt)

=head1 SYNOPSIS

  use PAUSE::Packages 0.02;

  my $pp       = PAUSE::Packages->new;
  my $iterator = $pp->release_iterator();

  foreach my $release ($iterator->next) {
    print 'path = ', $release->path, "\n";
    print '   modules = ', join(', ', @{ $release->modules }), "\n";
  }

=head1 DESCRIPTION

B<NOTE>: this is very much an alpha release. any and all feedback appreciated.

PAUSE::Packages provides an interface to the C<02packages.details.txt>
file produced by the Perl Authors Upload Server (PAUSE).
The file records what version of what modules are included in each
release of a distribution that is on CPAN.

PAUSE::Packages processes 02packages.details.txt and caches a transformed
version of the data, with the following characteristics:

=over 4

=item *

Only the highest numbered version of a module is included.

=item *

All modules in a release are written together, to make it efficient to
iterate over the file release by release.
02packages is sorted by module name, not by release, which means it can't
be efficiently processed by an iterator.

=back

The interface for this distribution is very much still in flux,
as is the documentation. More of the latter will be coming soon.

B<Note>: the behaviour of this module changed between version 0.01 and 0.02,
so you should make sure you're using 0.02 or later:

  use PAUSE::Packages 0.02;

=head1 REPOSITORY

L<https://github.com/neilbowers/PAUSE-Packages>

=head1 AUTHOR

Neil Bowers E<lt>neilb@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Neil Bowers <neilb@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

