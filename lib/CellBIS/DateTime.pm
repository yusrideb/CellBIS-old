package CellBIS::DateTime;

use strict;
use warnings;

# Import Module :
use DateTime;
#use NKTIweb::DateTime::lang;
use base 'CellBIS::DateTime::lang';
#use vars qw($language $date_lang);
use Data::Dumper;

# Version :
require CellBIS::Version;
our $VERSION = $CellBIS::Version::VERSION;

# scalar global :
our ($language, $date_lang);

# Subroutine for set languages :
# ------------------------------------------------------------------------
#=head1 SUBROUTINE set_lang()
#
#	Deskripsi subroutine set_lang() :
#	----------------------------------------
#	Subroutine yang berfungsi untuk mengeset languages
#	untuk bulan dan hari. Languages standard in Indonesian.
#
#	Format parameter $hashdate :
#	----------------------------------------
#	$hashdate = {
#		'month' => [
#			0 => '',
#			1 => 'Januari',
#			2 => 'Februari',
#			3 => 'Maret',
#			4 => 'April',
#			5 => 'Mei',
#			6 => 'Juni',
#			7 => 'Juli',
#			8 => 'Agustus',
#			9 => 'September',
#			10 => 'Oktober',
#			11 => 'November',
#			12 => 'Desember'
#		],
#		'month_short' => [
#			0 => '',
#			1 => 'Jan',
#			2 => 'Feb',
#			3 => 'Mar',
#			4 => 'Apr',
#			5 => 'Mei',
#			6 => 'Jun',
#			7 => 'Jul',
#			8 => 'Agu',
#			9 => 'Sep',
#			10 => 'Okt',
#			11 => 'Nov',
#			12 => 'Des'
#		],
#		'day' => [
#			0 => '',
#			1 => 'Senin',       # Monday
#			2 => 'Selasa',      # Tuesday
#			3 => 'Rabu',        # Wednesday
#			4 => 'Kamis',       # Thursday
#			5 => 'Jum\'at',     # Friday
#			6 => 'Sabtu',       # Saturday
#			7 => 'Minggu'       # Sunday
#		]
#		'day_short' => [
#			0 => '',
#			1 => 'Sen',         # Mon
#			2 => 'Sel',         # Tue
#			3 => 'Rab',         # Wed
#			4 => 'Kam',         # Thu
#			5 => 'Jum',         # Fri
#			6 => 'Sab',         # Sat
#			7 => 'Min'          # Sun
#		]
#	}
#
#	Format scalar $lang :
#	----------------------------------------
#	$lang       => Available :
#						- 'id_ID' # Indonesia
#						- 'en_US' # Engish US.
#
#	Parameter subroutine set_lang() :
#	----------------------------------------
#	$hashdate       =>  Berisi Hashref language untuk Bulan dan Hari.
#
#	Output Parameter :
#	----------------------------------------
#	#
#
#=cut
sub set_lang {
	# Define parameter subroutine :
	my $self = shift;
	my $key_param = scalar keys(@_);
	my $lang = 'id_ID';
	my $hashdate = undef;
	
	# IF one parameter input :
	if ($key_param eq 1) {
		if ($_[0] =~ m/^[A-Za-z_]+/ and ref($_[0]) ne 'HASH') {
			$lang = $_[0];
			$language = $_[0];
		}
		elsif (ref($_[0]) eq 'HASH') {
			$hashdate = $_[0];
			$date_lang = $_[0];
		}
	}
	
	# IF two parameters input :
	if ($key_param eq 2) {
		if ($_[0] =~ m/^[A-Za-z_]+/ and ref($_[0]) ne 'HASH') {
			$lang = $_[0];
			$language = $_[0];
		} elsif (ref($_[0]) eq 'HASH') {
			$lang = $_[0];
			$language = $_[0];
		}
		if (ref($_[1]) eq 'HASH') {
			$hashdate = $_[1];
			$date_lang = $_[1];
		} elsif ($_[1] =~ m/^[A-Za-z_]+/ and ref($_[1]) ne 'HASH') {
			$lang = $_[1];
			$language = $_[1];
		}
	}
}
# End of Subroutine for set languages
# ===========================================================================================================

# Subroutine for get languages :
# ------------------------------------------------------------------------
#=head1 SUBROUTINE get_lang()
#
#	Deskripsi subroutine get_lang() :
#	----------------------------------------
#	Subroutine yang berfungsi untuk mengambil data language.
#
#	Parameter subroutine get_lang() :
#	----------------------------------------
#	$lang           =>  language identify.
#
#	Output Parameter :
#	----------------------------------------
#	#
#
#=cut
sub get_lang {
	# Define parameter subroutine :
	my ($self, $lang) = @_;
	
	# Define scalar for place result :
	my $data = undef;
	
	# Get language :
	my $get_lang = $self->$lang();
	$date_lang = $get_lang;
	
	return $get_lang;
}
# End of Subroutine for get languages
# ===========================================================================================================

# Subroutine for Add or Subtract Duration :
# ------------------------------------------------------------------------
#=head1 SUBROUTINE add_or_subtract()
#
#	Deskripsi subroutine add_or_subtract() :
#	----------------------------------------
#	Subroutine yang berfungsi untuk menambahkan durasi datetime.
#
#	Parameter subroutine add_or_subtract() :
#	----------------------------------------
#	$dt             =>  [ Berisi DateTime module initialized ],
#	$minplus        =>  [ Berisi Identification Time Add/Subtract ].
#						Ex :
#								+1D || +D == add 1 day, -1D || -D == subtract 1 day.
#								+1W || +W == add 1 week, -1W || -W == subtract 1 week.
#								+1M || +M == add 1 month, -1M || -M == subtract 1 month.
#								+1Y || +Y == add 1 year, -1Y || -Y == subtract 1 year.
#								+1h || +h == add 1 hour, -1h || -h == subtract 1 hour.
#								+1m || +m == add 1 minute, -1m || -m == subtract 1 minute.
#								+1s || +s == add 1 second, -1s || -s == subtract 1 second.
#
#	Output Parameter :
#	----------------------------------------
#	#
#
#=cut
sub add_or_subtract {
	# Define parameter subroutine :
	my ($self, $dt, $minplus) = @_;
	
	# Define scalar for use in this function :
	my $action = undef;
	my $number = undef;
	
	# Check IF $minplus == "HASH" :
	if ($minplus ne '') {
		#		print "HASH type \n";
		
		# Parse Action :
		$action = $minplus =~ m/\+/ ? 'add' : 'subtract';
		
		# Parse Time for add or subtract :
		if ($minplus =~ m/D/) {
			$minplus =~ s/\D//g;
			$number = $minplus;
			$number = $number eq '' ? 1 : $number;
			if ($action eq 'add') {
				$dt->add(days => $number);
			} else {
				$dt->subtract(days => $number);
			}
		}
		if ($minplus =~ m/W/) {
			$minplus =~ s/\D//g;
			$number = $minplus;
			$number = $number eq '' ? 1 : $number;
			if ($action eq 'add') {
				$dt->add(weeks => $number);
			} else {
				$dt->subtract(weeks => $number);
			}
		}
		if ($minplus =~ m/M/) {
			$minplus =~ s/\D//g;
			$number = $minplus;
			$number = $number eq '' ? 1 : $number;
			if ($action eq 'add') {
				$dt->add(months => $number);
			} else {
				$dt->subtract(months => $number);
			}
		}
		if ($minplus =~ m/Y/) {
			$minplus =~ s/\D//g;
			$number = $minplus;
			$number = $number eq '' ? 1 : $number;
			if ($action eq 'add') {
				$dt->add(years => $number);
			} else {
				$dt->subtract(years => $number);
			}
		}
		if ($minplus =~ m/h/) {
			$minplus =~ s/\D//g;
			$number = $minplus;
			$number = $number eq '' ? 1 : $number;
			if ($action eq 'add') {
				$dt->add(hours => $number);
			} else {
				$dt->subtract(hours => $number);
			}
		}
		if ($minplus =~ m/m/) {
			$minplus =~ s/\D//g;
			$number = $minplus;
			$number = $number eq '' ? 1 : $number;
			if ($action eq 'add') {
				$dt->add(minutes => $number);
			} else {
				$dt->subtract(minutes => $number);
			}
		}
		if ($minplus =~ m/s/) {
			$minplus =~ s/\D//g;
			$number = $minplus;
			$number = $number eq '' ? 1 : $number;
			if ($action eq 'add') {
				$dt->add(seconds => $number);
			} else {
				$dt->subtract(seconds => $number);
			}
		}
	}
	return(0);
}
# End of Subroutine for Add or Subtract Duration
# ===========================================================================================================


# Subroutine for Get Date Time :
# ------------------------------------------------------------------------
#=head1 SUBROUTINE get()
#
#	Deskripsi subroutine get() :
#	----------------------------------------
#	Subroutine yang berfungsi untuk mengambil data DateTime.
#
#	Format Delimiter in $config :
#	--------------------------------------------------
#	$attribute = {
#		date => '/',
#		time => ':',
#		datetime => [ Delimiter between date and time ],
#		format => [ Format DateTime. Ex: "DD-MM-YYYY hms" ],
#		minplus => [ For Add and Subtract Duration time ],
#	}
#
#	Format Key "format" in hashref $config :
#	--------------------------------------------------
#	format      =   DD      =>  Date of Calender
#					MM      =>  Mount Number of Calender
#					YYYY    =>  Years of Calender
#					Dn      =>  Day Name of Week
#					dn      =>  Day name sort of Week
#					Di      =>  Day number of Week
#					Mn      =>  Month Name of Calendar
#					h       =>  Hour of clock.
#					m       =>  Minue of clock.
#					s       =>  Second of clock.
#
#	Format Key "minplus" in hashref $config :
#	--------------------------------------------------
#	minplus     =   +       =>  Add Duration. --> if example current years in 2017 and +1 equals 2018.
#					-       =>  Subtract Duration. --> if example current years in 2017 and -1 equals 2016.
#					D       =>  add/subtract Day.
#					M       =>  add/subtract Month.
#					Y       =>  add/subtract Year.
#					h       =>  add/subtract Hour.
#					m       =>  add/subtract Minutes.
#					s       =>  add/subtract Second.
#
#	Parameter subroutine get() :
#	--------------------------------------------------
#	$timestamp      =>  Berisi UNIX TimeStamp Format.
#	$timezone       =>  Berisi name TimeZone. Ex: "Asia/Makassar".
#	$attribute      =>  Berisi delimiter yang dinginkan.
#
#	Output Parameter :
#	--------------------------------------------------
#	$hash_ref = {
#		'custom' => $DateNow_custom,
#		'datetime' => $DateNow,
#		'calender' => {
#			'day_num' => $dayNum,
#			'day_name' => $dayName,
#			'date' => $date_num,
#			'month' => $monthNum,
#			'month_name' => $monthName,
#			'year' => $years
#		},
#		'time' => {
#			'hour' => $hours,
#			'minute' => $minutes,
#			'second' => $second,
#		},
#	}
#
#=cut
sub get {
	# Define parameter subroutine :
	my $self = shift;
	my $timestamp = undef;
	my $timezone = undef;
	my $attribute = undef;
	
	# Define hash for place result :
	my %data = ();
	
	# IF no input parameter :
	my $keys_param = scalar keys(@_);
	if ($keys_param eq 0) {
		$timestamp = time();
		$timezone = 'Asia/Makassar';
	}
	# IF just one of input parameter :
	elsif ($keys_param eq 1) {
		if ($_[0] =~ m/^[0-9,.E]+$/) {
			$timestamp = $_[0];
			$timezone = 'Asia/Makassar';
			$attribute = undef;
		}
		if ($_[0] =~ m/^[A-Za-z\/]+/ and ref($_[0]) ne 'HASH') {
			$timestamp = time();
			$timezone = $_[0];
			$attribute = undef;
		}
		if (ref($_[0]) eq "HASH") {
			$timestamp = time();
			$timezone = 'Asia/Makassar';
			$attribute = $_[0];
		}
	}
	# IF just two of input parameter :
	elsif ($keys_param == 2) {
		# For $_[0] :
		if ($_[0] =~ m/^[0-9,.E]+$/) {
			$timestamp = $_[0];
		}
		elsif ($_[0] =~ m/^[A-Za-z\/\w]+/ and ref($_[0]) ne 'HASH') {
			$timestamp = time();
			$timezone = $_[0];
		}
		# For $_[1] :
		if ($_[1] =~ m/^[A-Za-z\/]+/ and ref($_[1]) ne 'HASH') {
			$timezone = $_[1];
		}
		elsif ($_[1] =~ m/^[0-9,.E]+$/ and ref($_[1]) ne 'HASH') {
			$timestamp = $_[1];
			$timezone = 'Asia/Makassar';
		}
		elsif (ref($_[1]) eq "HASH") {
			$timezone = 'Asia/Makassar';
			$attribute = $_[1];
		}
	}
	# IF three of input parameter :
	elsif ($keys_param eq 3) {
		# For $_[0] :
		if ($_[0] =~ m/^[0-9,.E]+$/) {
			$timestamp = $_[0];
		} else {
			$timestamp = time();
		}
		# For $_[1] :
		if ($_[1] =~ m/^[A-Za-z\/]+/ and ref($_[1]) ne 'HASH') {
			$timezone = $_[1];
		} else {
			$timezone = 'Asia/Makassar';
			$attribute = undef;
		}
		# For $_[2] :
		if (ref($_[2]) eq "HASH") {
			$attribute = $_[2];
#			print "param3 - ada\n";
#			print Dumper $_[2];
		} else {
			$attribute = undef;
#			print "param3 - tidak ada\n";
		}
	} else {
		$timestamp = time();
		$timezone = 'Asia/Makassar';
	}
#	print "Data $keys_param\n";
#	print "-----START------\n\n\n";
#	print Dumper \@_;
#	print "-----END----\n\n\n";
	
	# Get Language :
	if ($language) {
		$self->set_lang($language);
	} else {
		$self->set_lang('id_ID');
	}
	my $lang_date = $self->get_lang($language);
	my @Mname = @{$lang_date->{'month'}};
	my @Mname_short = @{$lang_date->{'month_short'}};
	my @Dname = @{$lang_date->{'day'}};
	my @Dname_short = @{$lang_date->{'day_short'}};
	
	# Get date time ;
	my $dt = DateTime->from_epoch(epoch => $timestamp);
	$dt->set_time_zone( $timezone );
	my $dayNum = $dt->day_of_week();
	my $dayName = $Dname[$dayNum];
	my $dayName_short = $Dname_short[$dayNum];
	my $date_num = $dt->day();
	my $monthNum = $dt->month();
	my $monthName = $Mname[$monthNum];
	my $years = $dt->year();
	
	my $hours = $dt->hour();
	my $minutes = $dt->minute();
	my $second = $dt->second();
	
	my $ymd = undef;
	my $dmy = undef;
	my $hms = undef;
	my $DateNow = undef;
	my $DateNow_custom = undef;
	my $DateNow_custom_instring = undef;
	my $add_or_subtract = undef;
	my $epoch_time = undef;
#	my $epoch_time = $dt->epoch();
	
	# Check $attribute ;
	if (ref($attribute) eq 'HASH') {
		
		# For Config :
		my $delim_date = $attribute->{'date'} ? $attribute->{'date'} : '-';
		my $delim_time = $attribute->{'time'} ? $attribute->{'time'} : ':';
		my $delim_datetime = $attribute->{'datetime'} ? $attribute->{'datetime'} : ' ';
		my $minplus_datetime = $attribute->{'minplus'} ? $attribute->{'minplus'} : '';
		$add_or_subtract = $self->add_or_subtract($dt, $minplus_datetime);
#		print "MIN-PLUS $minplus_datetime\n";
		
		# get Date Format :
		$dayNum = $dt->day_of_week();
		$dayName = $Dname[$dayNum];
		$dayName_short = $Dname_short[$dayNum];
		$date_num = $dt->day();
		$monthNum = $dt->month();
		$monthName = $Mname[$monthNum];
		$years = $dt->year();
		$epoch_time = $dt->epoch();
		
		$hours = $dt->hour();
		$minutes = $dt->minute();
		$second = $dt->second();
		
		$ymd = $dt->ymd($delim_date);
		$dmy = $dt->dmy($delim_date);
		$hms = $dt->hms($delim_time);
		
		# For Action Custom :
		my $format_datetime = $attribute->{'format'} ? $attribute->{'format'} : '';
		$format_datetime =~ s/DD/$date_num/g;
		$format_datetime =~ s/Dn/$dayName_short/g;
		$format_datetime =~ s/Di/$dayNum/g;
		$format_datetime =~ s/MM/$monthNum/g;
		$format_datetime =~ s/YYYY/$years/g;
		$format_datetime =~ s/h/$hours/g;
		$format_datetime =~ s/m/$minutes/g;
		$format_datetime =~ s/s/$second/g;
		$DateNow_custom_instring = $format_datetime;
		
		# For Action
		$DateNow = $ymd.' '.$hms;
		$DateNow_custom = $ymd.$delim_datetime.$hms;
		
	} else {
		# get Date Format :
		$ymd = $dt->ymd();
		$dmy = $dt->dmy();
		$hms = $dt->hms();
		$DateNow = $ymd.' '.$hms;
		$DateNow_custom = $ymd.' '.$hms;
		$epoch_time = $dt->epoch();
	}
	
	# Place result :
	$data{'custom_in_string'} = $DateNow_custom_instring;
	$data{'custom'} = $DateNow_custom;
	$data{'datetime'} = $DateNow;
	$data{'timestamp'} = $epoch_time;
	$data{'calender'} = {
		'day_num' => $dayNum,
		'day_name' => $dayName,
		'day_short' => $dayName_short,
		'date' => $date_num,
		'month' => $monthNum,
		'month_name' => $monthName,
		'year' => $years,
		'ymd' => $ymd,
		'dmy' => $dmy,
	};
	$data{'time'} = {
		'hour' => $hours,
		'minute' => $minutes,
		'second' => $second,
		'hms' => $hms
	};
	
#	$data{'timestamp'} = $timestamp;
#	$data{'timezone'} = $timezone;
#	$data{'test'} = 'data-test';
#	$data{'param'} = \@_;
#	$data{'param1'} = $_[0];
#	$data{'param2'} = $_[1];
#	$data{'param1_ref'} = ref($_[0]);
#	$data{'config'} = $attribute;
#	$data{'keys_param'} = $keys_param;
#	$data{'self'} = $self;
#	$data{'attribute'} = ref($attribute);
#	$data{'add-substr'} = $add_or_subtract;
	
	# Return result :
	return \%data;
}
# End of Subroutine for Get Date Time
# ===========================================================================================================

# Subroutine for Get Date Time based datetime :
# ------------------------------------------------------------------------
#=head1 SUBROUTINE get_dt_mysql()
#
#	Deskripsi subroutine get_dt_mysql() :
#	--------------------------------------------------
#	Subroutine yang berfungsi untk mengambil data time
#	berdasarkan datetime MySQL.
#
#	Parameter subroutine get_dt_mysql() :
#	--------------------------------------------------
#	my $dt_mysql            =>  Berisi DataTime MySQL.
#	my $timezone            =>  Berisi TimeZone. Ex: "Asia/Makassar".
#
#	Output Parameter :
#	--------------------------------------------------
#	#
#
#=cut
sub get_dt_mysql {
	# Define parameter subroutine :
	my ($self, $dt_mysql, $timezone) = @_;
	
	# Define scalar for place result :
	my %data = ();
	
	# Parse DateTime MySQL :
	if ($dt_mysql =~ /^(\d+)\-(\d+)\-(\d+)\s(\d+)\:(\d+)\:(\d+)$/) {
		# Result Parse :
		my $year_mysql = $1;
		my $month_mysql = $2;
		my $day_mysql = $3;
		my $hour_mysql = $4;
		my $minues_mysql = $5;
		my $second_mysql = $6;
		
		# Initialization DateTime Module :
		my $dt = DateTime->new(
			year       => $year_mysql,
			month      => $month_mysql,
			day        => $day_mysql,
			hour       => $hour_mysql,
			minute     => $minues_mysql,
			second     => $second_mysql,
			nanosecond => 500000000,
			time_zone  => $timezone,
		);
		
		# Get Language :
		if ($language) {
			$self->set_lang($language);
		} else {
			$self->set_lang('id_ID');
		}
		my $lang_date = $self->get_lang($language);
		my @Mname = @{$lang_date->{'month'}};
		my @Mname_short = @{$lang_date->{'month_short'}};
		my @Dname = @{$lang_date->{'day'}};
		my @Dname_short = @{$lang_date->{'day_short'}};
		
		# Get data DateTime :
		my $dayNum = $dt->day_of_week();
		my $dayName = $Dname[$dayNum];
		my $dayName_short = $Dname_short[$dayNum];
		my $date_num = $dt->day();
		my $monthNum = $dt->month();
		my $monthName = $Mname[$monthNum];
		my $years = $dt->year();
		my $epoch_time = $dt->epoch();
		
		my $hours = $dt->hour();
		my $minutes = $dt->minute();
		my $second = $dt->second();
		my $ymd = $dt->ymd();
		my $dmy = $dt->dmy();
		my $hms = $dt->hms();
		my $DateNow = $ymd.' '.$hms;
		
		# Place result :
		$data{'datetime'} = $DateNow;
		$data{'timestamp'} = $epoch_time;
		$data{'calender'} = {
			'day_num' => $dayNum,
			'day_name' => $dayName,
			'day_short' => $dayName_short,
			'date' => $date_num,
			'month' => $monthNum,
			'month_name' => $monthName,
			'year' => $years,
			'ymd' => $ymd,
			'dmy' => $dmy,
		};
		$data{'time'} = {
			'hour' => $hours,
			'minute' => $minutes,
			'second' => $second,
			'hms' => $hms
		};
	}
	return(0);
}
# End of Subroutine for Get Date Time based datetime
# ===========================================================================================================

# Subroutine for Test Module NKTIweb::DateTime :
# ------------------------------------------------------------------------
sub test {
	# Define parameter subroutine :
	my $self = shift;
	my $timestamp = undef;
	my $timezone = undef;
	my $attribute = undef;
	
	# Define hash for place result :
	my %data = ();
	
	# IF no input parameter :
	my $keys_param = scalar keys(@_);
	if ($keys_param eq 0) {
		$timestamp = time();
		$timezone = 'Asia/Makassar';
	}
	# IF just one of input parameter :
	elsif ($keys_param eq 1) {
		if ($_[0] =~ m/^[0-9,.E]+$/) {
			$timestamp = $_[0];
			$timezone = 'Asia/Makassar';
			$attribute = undef;
		}
		if ($_[0] =~ m/^[A-Za-z\/]+/ and ref($_[0]) ne 'HASH') {
			$timestamp = time();
			$timezone = $_[0];
			$attribute = undef;
		}
		if (ref($_[0]) eq "HASH") {
			$timestamp = time();
			$timezone = 'Asia/Makassar';
			$attribute = $_[0];
		}
	}
	# IF just two of input parameter :
	elsif ($keys_param == 2) {
		# For $_[0] :
		if ($_[0] =~ m/^[0-9,.E]+$/) {
			$timestamp = $_[0];
		}
		elsif ($_[0] =~ m/^[A-Za-z\/\w]+/ and ref($_[0]) ne 'HASH') {
			$timestamp = time();
			$timezone = $_[0];
		}
		# For $_[1] :
		if ($_[1] =~ m/^[A-Za-z\/]+/ and ref($_[1]) ne 'HASH') {
			$timezone = $_[1];
		}
		elsif ($_[1] =~ m/^[0-9,.E]+$/ and ref($_[1]) ne 'HASH') {
			$timestamp = $_[1];
			$timezone = 'Asia/Makassar';
		}
		elsif (ref($_[1]) eq "HASH") {
			$timezone = 'Asia/Makassar';
			$attribute = $_[1];
		}
	}
	# IF three of input parameter :
	elsif ($keys_param eq 3) {
		# For $_[0] :
		if ($_[0] =~ m/^[0-9,.E]+$/) {
			$timestamp = $_[0];
		} else {
			$timestamp = time();
		}
		# For $_[1] :
		if ($_[1] =~ m/^[A-Za-z\/]+/ and ref($_[1]) ne 'HASH') {
			$timezone = $_[1];
		} else {
			$timezone = 'Asia/Makassar';
			$attribute = undef;
		}
		# For $_[2] :
		if (ref($_[2]) eq "HASH") {
			$attribute = $_[2];
		} else {
			$attribute = undef;
		}
	} else {
		$timestamp = time();
		$timezone = 'Asia/Makassar';
	}
	
	
	# Print Result :
	print "TimeStamp : $timestamp <br>";
	print "TimeZone : $timezone <br>";
	print "index 0 : <br>";
	print Dumper $_[0];
	print "<br>";
	print "index 1  : <br>";
	print Dumper $_[1];
	print "<br>";
	print "index 2  : <br>";
	print Dumper $_[2];
	print "<br>";
	print "Attribute <br>";
	print Dumper $attribute;
	print "<pre>";
	print Dumper \@_;
	print "</pre>";
	print "<br>";
	print "<hr>";
}
# End of Subroutine for Test Module NKTIweb::DateTime
# ===========================================================================================================

1;
__END__

=head1 NAME

NKTIweb::DateTime - Perl extension for NKTIweb::apps::website

=head1 SYNOPSIS

  use NKTIweb::DateTime;
  

=head1 DESCRIPTION


=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Achmad Yusri Afandi, E<lt>yusrideb@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Achmad Yusri Afandi

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.20.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
