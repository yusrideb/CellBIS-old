package CellBIS::Controller;
use strict;
use warnings;

# Use Module :
use Data::Dumper;
use Hash::Merge qw( merge );
use CellBIS::Utils::Char;

# Version :
our $VERSION = '0.1000';

# declare which will be use :
our $_auth = {};
our $_setting = {};
our $_config = {};
our $_route = {};
our $_route_size = {};
sub _add;

# Subroutine for setting controller :
# ------------------------------------------------------------------------
sub _setting {
    # Define parameter subroutine :
    my ($self, $sett) = @_;
    Carp::croak(q{$sett is required})
        unless defined $sett && ref($sett) eq 'HASH';
    my %set_setting = %{ merge($_setting, $sett) };
    $_setting = \%set_setting;
}
# End of Subroutine for setting controller.
# ===========================================================================================================

# Subroutine for check auth in route :
# ------------------------------------------------------------------------
sub check_auth {
    my ($self, $route, $auth) = @_;

}
# End of Subroutine for check auth in route.
# ===========================================================================================================

# Subroutine for add routes :
# ------------------------------------------------------------------------
sub _add {
    my $self = shift;
    my $param_len = scalar @_;

    # For Method Request :
    my %cfg = ();
    if (exists $_[2]) {
        $cfg{$_[0]} = $_[2];
        my %set_config = %{ merge($_config, \%cfg) };
        $_config = \%set_config;
    } else {
        $cfg{$_[0]} = 'get';
    }

    # For Authentication :
    my %auth = ();
    if (exists $_[3]) {
        $cfg{$_[0]} = '0';
        my %set_config = %{ merge($_config, \%auth) };
        $_config = \%set_config;
    }
    my %data = ();
    $data{$_[0]} = $_[1];

    my %add_controller = %{ merge($_route, \%data) };
    $_route = \%add_controller;

    # Size each route :
    my $route = $_[0];
    $route =~ s/^\///g;
    $route =~ s/\/$//g;
    my @_route = CellBIS::Utils::Char->split_bchar($route, '/');
    $_route_size = scalar @_route;
}
# End of Subroutine for add controller.
# ===========================================================================================================

# Subroutine for Contoller Utils :
# ------------------------------------------------------------------------
sub get_list { return $_route }
sub get_size { return $_route_size }
sub get_cfg { return $_config }
sub get_auth { return $_auth }
sub get_setting { return $_setting }
# End of Subroutine for Contoller Utils.
# ===========================================================================================================

1;