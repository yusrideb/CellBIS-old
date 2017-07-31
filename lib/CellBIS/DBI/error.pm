package CellBIS::DBI::error;
use strict;
use warnings FATAL => 'all';

# Import Module :
use JSON::XS;

# Version :
our $VERSION = '0.1000';

# Subroutine for Error Handling MySQL Connection :
# ------------------------------------------------------------------------
#
#    Deskripsi subroutine errcon() :
#    ----------------------------------------
#    Subroutine yang berfungsi untuk Handel Error Connection MySQL.
#
#    Parameter subroutine errcon() :
#    ----------------------------------------
#    No Parameter Subroutine.
#
sub errconn {

    # Define parameter subroutine :
    my $self = shift;

    # Define array for place error DBMS Connection :
    my @data = ();

    # Check IF defined $DBI::err;
    if (defined $DBI::err) {
        $data[0] = $DBI::err;
    } else {
        $data[0] = 00000;
    }

    # Check IF defined $DBI::state :
    if (defined $DBI::state) {
        $data[1] = $DBI::state;
    } else {
        $data[1] = 0;
    }

    # Check IF defined $DBI::errstr :
    if (defined $DBI::errstr) {
        $data[2] = $DBI::errstr;
    } else {
        $data[2] = 'none';
    }

    # Return Result :
    return \@data;
}
# End of Subroutine for Error Handling MySQL Connection.
# ===========================================================================================================

# Subroutine for Error Handling data MySQL Connection :
# ------------------------------------------------------------------------
#
#    Deskripsi subroutine errdata() :
#    ----------------------------------------
#    Subroutine yang berfungsi untuk menampilkan error saat proses koneksi Data MySQL.
#
#    Parameter subroutine errdata() :
#    ----------------------------------------
#    $sth		=>	Berisi scalar $sth.
#
sub errdata {

    # Define parameter Subroutine :
    my ($self, $sth) = @_;

    # Define array for place result :
    my @data = ();

    # Place result :
    $data[0] = $sth->err;
    $data[1] = $sth->state;
    $data[2] = $sth->errstr;

    # Return Result :
    return \@data;
}
# End of Subroutine for Error Handling data MySQL Connection.
# ===========================================================================================================

1;
__END__
#
