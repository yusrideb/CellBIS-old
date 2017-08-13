package CellBIS::DBIO::Query;
use strict;
use warnings FATAL => 'all';

# Version :
our $VERSION = '0.1000';

# Custom Query :
# ------------------------------------------------------------------------
sub query {
	my $self = shift;
	my $data = {};

	my ($query, $execute) = @_;
	my $dbh = $self->def_dbh();
	my $sth = $dbh->prepare($query);
	$sth->execute(@{$execute});
	return $sth;
}
# End of Custom Query.
# ===========================================================================================================

1;