package CellBIS::Controller;
use strict;
use warnings;

# Use Module :
use Data::Dumper;
use Carp ();
use Hash::Merge qw( merge );
use CellBIS::Utils::Char;

# Version :
our $VERSION = '0.1000';

# declare which will be use :
our $_setting = {};
our $_route_auth = {};
our $_config = {};
our $_route = {};
our $_route_size = {};
our $_route_attr = {};
sub _setting;
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

# Subroutine for type route :
# ------------------------------------------------------------------------
sub type_route {
    my ($self, $r_type) = @_;
	my %data = ();

    $data{'type1'} = 'mod1'; # name subroutine in routing Matching
    $data{'type2'} = 'mod2'; # name subroutine in routing Matching
    $data{'type3'} = 'mod3'; # name subroutine in routing Matching

    if (exists $data{$r_type}) {
        my $result = $data{$r_type};
        return $result;
    } else {
        return $data{'type1'};
    }
}
# End of Subroutine for type route.
# ===========================================================================================================

# Subroutine for check type routes :
# ------------------------------------------------------------------------
sub check_type {
	my ($self, $data_route) = @_;
    my $data = '';

    unless ($data_route eq '') {
        $data_route =~ s/^\///g;
        $data_route =~ s/\/$//g;
        my @arr_route = CellBIS::Utils::Char->split_bchar($data_route, '/');
        my $ori_size_rt = scalar @arr_route;
        @arr_route = grep { $_ =~ m/(.*)\:(.*)/} @arr_route;
        my $size_rt = scalar @arr_route;

        $data = 'type1' if $size_rt == 1;
        $data = 'type2' if $size_rt > 1 && $size_rt < $ori_size_rt;
        $data = 'type3' if $ori_size_rt == $size_rt;
    } else {
        $data = 'type1';
    }

    return $data;
}
# End of Subroutine for check type routes.
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
        $cfg{$_[0]} = $_[3];
        my %set_config = %{ merge($_route_auth, \%auth) };
        $_route_auth = \%set_config;
    } else {
        $cfg{$_[0]} = 0;
        my %set_config = %{ merge($_route_auth, \%auth) };
        $_route_auth = \%set_config;
    }

    # For Add new Route :
    my %data = ();
    $data{$_[0]} = $_[1];
    my %add_controller = %{ merge($_route, \%data) };
    $_route = \%add_controller;

    # Size each route :
    my %data_route = ();
    my $route = $_[0];
    $route =~ s/^\///g;
    $route =~ s/\/$//g;
    my @_route = CellBIS::Utils::Char->split_bchar($route, '/');
    my $rt_size = scalar @_route;
    $data_route{$_[0]} = $rt_size;
    my %_size_route = %{ merge($_route_size, \%data_route) };
    $_route_size = \%_size_route;

    # Router Attributes :
    my %new_attr_route = ();
    my $r_check_type = $self->check_type($_[0]);
    $new_attr_route{$_[0]} = $self->type_route($r_check_type);
    my %_fix_route_attr = %{ merge($_route_attr, \%new_attr_route) };
    $_route_attr = \%_fix_route_attr;
}
# End of Subroutine for add controller.
# ===========================================================================================================

# Subroutine for Contoller Utils :
# ------------------------------------------------------------------------
sub get_list { return $_route }
sub get_size { return $_route_size }
sub get_cfg { return $_config }
sub get_attr { return $_route_attr }
sub get_auth { return $_route_auth }
sub get_setting { return $_setting }
# End of Subroutine for Contoller Utils.
# ===========================================================================================================

1;