package PAUSE::Packages::Module;

use 5.8.1;
use Moo 1.006;

has 'name'    => (is => 'ro');
has 'version' => (is => 'ro');

=head1 NAME

PAUSE::Packages::Module - Captures the name and version of a module

=head1 SYNOPSIS

 my $pp = PAUSE::Packages->new;
 my $release = $pp->('Amazon-S3');  # gets information about the Amazone-S3 release
 my $modules = $release->modules;   # Returns an array of PAUSE::Packages::Module
 my @names = map {$_->name} @$modules; # Extracts the module names of the release
 my @versions = map {$_->version} @$modules; # Extracts the module versions of the release

=head1 METHODS

=head2 name()

Returns the module name

=head2 version()

Returns the module version

=cut

1;
