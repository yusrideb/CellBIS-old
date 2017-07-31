package CellBIS::DBI::config;
use strict;
use warnings FATAL => 'all';

# Import Module :
require CellBIS::Version;
use JSON::XS;
use Crypt::JWT;
use CellBIS::enkripsi;
use CellBIS::DBI;

# Version :
our $VERSION = '0.1000';

# Subroutine for read database config :
# ------------------------------------------------------------------------
=head1 SUBROUTINE read()

	Deskripsi subroutine read() :
	----------------------------------------
	Subroutine yang berfungsi untuk membaca database config.

	Parameter subroutine read() :
	----------------------------------------
	$loc_file       =>  Berisi lokasi file database config.
	$db_secret      =>  Berisi Secret database.

	Output Parameter :
	----------------------------------------
	#

=cut
sub read {
	# Define parameter subroutine :
    my ($self, $loc_file, $db_secret) = @_;


}
# End of Subroutine for read database config
# ===========================================================================================================

# Subroutine for create secret database config :
# ------------------------------------------------------------------------
=head1 SUBROUTINE secret()
				
	Deskripsi subrotuine secret() :
	----------------------------------------
	Subroutine yang berfungsi untuk membuat secret database config.
	
	Parameter subrotuine secret() :
	----------------------------------------
	$self
	
	Output Parameter :
	----------------------------------------
	#

=cut
sub secret {
    # Define scalar :
    my $db_secret;

    # Create Cookies Name :
    my $pre_pattern_enc0 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    my $pattern_enc = CellBIS::enkripsi->loop_odoe2eood($pre_pattern_enc0, 11, 5, 2);
    my $plankey = CellBIS::enkripsi->getKey_enc($pattern_enc);
    $db_secret = CellBIS::enkripsi->Encoder('ThE_Token', $plankey);

    # Return :
    return $db_secret;
}
# End of Subroutine for create secret database config
# ===========================================================================================================

1;