package CellBIS::DBIO;
use strict;
use warnings FATAL => 'all';

# Import Module :
use Carp ();
use JSON::XS;
use Hash::MultiValue;
use Hash::Merge qw( merge );
use CellBIS::Utils::ArrHash;
use base 'CellBIS::DBIO::Query';

# Version :
our $VERSION = '0.1000';

# Declare :
our $_dbh = {};
our $_schema = {};
sub _table;
sub _add_col;

# Subroutine for Set DBH :
# ------------------------------------------------------------------------
sub set_dbh {
	my $self = shift;
    my ($r_dbh) = @_;
    $_dbh = $r_dbh;
}

# Subroutine for get dbh :
# ------------------------------------------------------------------------
sub def_dbh {
	my $self = shift;
    return $_dbh;
}

# Subroutine for setup data table schema :
# ------------------------------------------------------------------------
sub set_schema {
	my ($self, $schema) = @_;
    $_schema = $schema;
}

# Subroutine for get data schema :
# ------------------------------------------------------------------------
sub get_schema {
    my ($self) = @_;
    return $_schema;
}

# Subroutine for get result of table schema :
# ------------------------------------------------------------------------
sub schema_result {
    my $self = shift;
    return $self->{'db_schema'};
}
# End of Subroutine for get result of table schema.
# ===========================================================================================================

# Subroutine for get table :
# ------------------------------------------------------------------------
sub _table {
	my $self = shift;
    my $data = '';
    my $type_q = $_schema->{query};

    if ($type_q eq 'sQuery') {
        $data = $_schema->{'table_name'};
    }

    if ($type_q eq 'gQuery') {
        my $arg_len = scalar @_;
        if ($arg_len == 0) {
            $data = $_schema->{table_list}->{table1};
        } else {
            my $tableID = $_[0];
            $tableID =~ s/^\w+([0-9])/table$1/g;
            $data = $_schema->{table_list}->{$tableID};
        }
    }

    if ($type_q eq 'mgQuery') {
    }
    return $data;
}
# End of Subroutine for get table.
# ===========================================================================================================

1;
__END__
#