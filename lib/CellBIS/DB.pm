package CellBIS::DBI;
use strict;
use warnings FATAL => 'all';

# Import Module :
use JSON::XS;
use parent 'DBI';
use CellBIS::DB::error;

# Version :
our $VERSION = '0.1000';

# Subroutine for database MySQL :
# ------------------------------------------------------------------------
sub mysql {
	# Define parameter subroutine :
    my ($self, $db_cfg) = @_;

    # Define scalar :
    my $dbh;

    # Define scalar for Database config.
    my $db_user = $db_cfg->{'db_user'};
    my $db_pass = $db_cfg->{'db_pass'};
    my $db_name = $db_cfg->{'db_name'};
    my $db_host = $db_cfg->{'db_host'};

    # For Database connection :
    my $dsn;
    if (exists $db_cfg->{'db_port'}) {
        my $db_port = $db_cfg->{'db_port'};
        $dsn = 'DBI:mysql:database='.$db_name.';host='.$db_host.';port='.$db_port;
    } else {
        $dsn = 'DBI:mysql:database='.$db_name.';host='.$db_host;
    }

    # Initialize Database Connection :
    $dbh = $self->connect($dsn, $db_user, $db_pass, {
            RaiseError => 0,
            PrintError => 0,
        });

    # Return Result :
    return $dbh;
}
# End of Subroutine for database MySQL
# ===========================================================================================================

# Subroutine for database ProgreSQL :
# ------------------------------------------------------------------------
sub pgsql {
	# Define parameter Subroutine :
    my ($self, $db_cfg) = @_;

    # Define scalar :
    my $dbh;

    # Define scalar for Database config.
    my $db_user = $db_cfg->{'db_user'};
    my $db_pass = $db_cfg->{'db_pass'};
    my $db_name = $db_cfg->{'db_name'};
    my $db_host = $db_cfg->{'db_host'};

    # Define database conection :
    my $dsn = 'DBI:Pg:database='.$db_name.';host='.$db_host.';port=5432';
    $dbh = $self->connect($dsn, $db_user, $db_pass, {RaiseError => 1});

    # Return Result :
    return $dbh;
}
# End of Subroutine for database ProgreSQL
# ===========================================================================================================

# Subroutine for database SQLite :
# ------------------------------------------------------------------------
sub sqlite {
	# Define parameter subroutine :
    my ($self, $fileloc_db) = @_;

    # Define scalar for Database config.
    my $driver = "SQLite";
    my $dsn = "DBI:$driver:dbname=$fileloc_db";
    my $userid = "";
    my $password = "";
    my $dbh = $self->connect($dsn, $userid, $password, { RaiseError => 1 })
        or die $DBI::errstr;

    # Return Result :
    # ----------------------------------------------------------------
    return $dbh;
}
# End of Subroutine for database SQLite
# ===========================================================================================================

1;
__END__
#