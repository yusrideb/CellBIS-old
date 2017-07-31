package CellBIS::enkripsi::jwt;
use strict;
use warnings FATAL => 'all';

# Use require Module :
require CellBIS::Version;
use Crypt::JWT qw(decode_jwt encode_jwt);
use CellBIS::enkripsi;

# Version :
our $VERSION = $CellBIS::Version::VERSION;

# Subroutine for Encode JWS :
# ------------------------------------------------------------------------
#
#	Deskripsi subroutine jws() :
#	----------------------------------------
#	Subroutine yang berfungsi untuk meng-encode JWS
#
#	Parameter subroutine jws() :
#	----------------------------------------
#	$type       =>  Your Type algorithm.
#	$data       =>  Berisi data yang akan di "encode".
#	$secret     =>  Berisi Secret JWT.
#
#	Output Parameter :
#	----------------------------------------
#	#
#
sub jws {
    # Define parameter subroutine :
    my ($self, $type, $data, $secret) = @_;

    # Define scalar :
    my $enc_jws;

    my $alg_type = 'HS256' if $type eq '';
    $alg_type = 'HS256' if $type eq 'alg1';
    $alg_type = 'HS384' if $type eq 'alg2';
    $alg_type = 'HS512' if $type eq 'alg3';

    # Action Encode :
    $enc_jws = encode_jwt(payload=>$data, alg=>$alg_type, key=>$secret);

    # Return :
    return $enc_jws;
}
# End of Subroutine for Encode JWS.
# ===========================================================================================================

# Subroutine for Encode JWE :
# ------------------------------------------------------------------------
#
#	Deskripsi subroutine jwe() :
#	----------------------------------------
#	Subroutine yang berfungsi untuk meng-encode JWE.
#
#	Parameter subroutine jwe() :
#	----------------------------------------
#	$type
#	$enc
#	$data
#	$secret
#
#	Output Parameter :
#	----------------------------------------
#	#
#
sub jwe {
	# Define parameter subroutine :
    my ($self, $type, $enc, $data, $secret) = @_;

    # Define scalar :
    my $enc_jwe;

    # For Type :
    my $type_alg = 'PBES2-HS256+A128KW' if $type eq '';
    $type_alg = 'PBES2-HS256+A128KW' if $type eq 'alg1';
    $type_alg = 'PBES2-HS384+A192KW' if $type eq 'alg2';
    $type_alg = 'PBES2-HS512+A256KW' if $type eq 'alg3';

    # For Enc :
    my $type_enc = 'A128CBC-HS256' if $enc eq '';
    $type_enc = 'A128CBC-HS256' if $enc eq 'enc1';
    $type_enc = 'A192CBC-HS384' if $enc eq 'enc2';
    $type_enc = 'A256CBC-HS512' if $enc eq 'enc3';

    # Action Encode :
    $enc_jwe = my $jwe_encode = encode_jwt(payload=>$data, alg=>$type_alg, enc=>$type_enc, key=>$secret);

    # Return :
    return $enc_jwe;
}
# End of Subroutine for Encode JWE
# ===========================================================================================================

# Subroutine for Decode JWS or JWE :
# ------------------------------------------------------------------------
#
#	Deskripsi subroutine decode() :
#	----------------------------------------
#	Subroutine yang berfungsi untuk meng-encode JWS atau JWE.
#
#	Parameter subroutine decode() :
#	----------------------------------------
#	$data_token
#	$secret
#
#	Output Parameter :
#	----------------------------------------
#	#
#
sub decode {
	# Define parameter subroutine :
    my ($self, $data_token, $secret) = @_;

    # For Decode :
    my $decode = decode_jwt(token=>$data_token, key=>$secret);

    # Return :
    return $decode;
}
# End of Subroutine for Decode JWS or JWE
# ===========================================================================================================

# Subroutine for create Secret JWT/JWE/JWS :
# ------------------------------------------------------------------------
#
#	Deskripsi subroutine secret() :
#	----------------------------------------
#	Subroutine yang berfungsi untuk membuat secret JSON Web Token (JWT)
#
#	Parameter subroutine secret() :
#	----------------------------------------
#	No parameter subroutine.
#
#	Output Parameter :
#	----------------------------------------
#	#
#
sub secret {
    # Define parameter subroutine :
    my $self = shift;

    # Define hash for place result :
    my %data = ();

    # Make Screet :
    my $pre_secret = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    my $secret = CellBIS::enkripsi->loop_odoe2eood($pre_secret, 5, 8, 2);

    # Return :
    return $secret;
}
# End of Subroutine for create Secret JWT/JWE/JWS.
# ===========================================================================================================
1;