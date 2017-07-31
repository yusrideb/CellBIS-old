package CellBIS::Model;
use strict;
use warnings FATAL => 'all';

# Import Module :
use Hash::Merge qw( merge );
use CellBIS::Utils::Char;
use CellBIS::Devel::QC;

# Version :
our $VERSION = '0.1000';

# Declare :
our $_config = {};
our $_models = {};
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

# Subroutine for add model :
# ------------------------------------------------------------------------
sub _add {
    my $self = shift;
    my %data = ();
    $data{$_[0]} = $_[1];
    my %add_models = %{ merge($_models, \%data) };
    $_models = \%add_models;
}
# End of Subroutine for add model.
# ===========================================================================================================

# Subroutine for get list models :
# ------------------------------------------------------------------------
sub get_list {
    return $_models;
}
# End of Subroutine for get list models.
# ===========================================================================================================
1;
__END__
#