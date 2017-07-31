package CellBIS::Controller;
use strict;
use warnings;

# Use Module :
use Data::Dumper;
use Hash::Merge qw( merge );

# Version :
our $VERSION = '0.1000';

# declare which will be use :
our $_config = {};
our $_route = {};
sub _add;

# Subroutine for config controller :
# ------------------------------------------------------------------------
sub _config {
    # Define parameter subroutine :
    my ($self, $config) = @_;
    Carp::croak(q{$config is required})
        unless defined $config && ref($config) eq 'HASH';
    my %set_config = %{ merge($_config, $config) };
    $_config = \%set_config;
}
# End of Subroutine for config controller.
# ===========================================================================================================

# Subroutine for add routes :
# ------------------------------------------------------------------------
sub _add {
    my $self = shift;
    my %data = ();
    $data{$_[0]} = $_[1];
    my %add_controller = %{ merge($_route, \%data) };
    $_route = \%add_controller;
}
# End of Subroutine for add controller.
# ===========================================================================================================

# Subroutine for get route :
# ------------------------------------------------------------------------
sub get_route {
    return $_route;
}
# End of Subroutine for get route.
# ===========================================================================================================

1;