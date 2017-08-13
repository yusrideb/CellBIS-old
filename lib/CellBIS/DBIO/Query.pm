package CellBIS::DBIO::Query;
use strict;
use warnings FATAL => 'all';

# Import Module :
use Data::Dumper;
use Carp ();
use JSON::XS;
use Hash::MultiValue;
use Hash::Merge qw( merge );
use CellBIS::Utils::ArrHash;

# Version :
our $VERSION = '0.1000';

# Subroutine for type query :
# ------------------------------------------------------------------------
sub type_query {
    my ($self, $type) = @_;
    my %data = ();
    my $result = '';

    $data{'single'} = 'sQuery';
    $data{'group'} = 'gQuery';

    $result = $data{$type} if defined $data{$type};
    $result = $data{'single'} unless exists $data{$type};
    return $result;
}
# End of Subroutine for type query.
# ===========================================================================================================

# Subroutine for Constructor :
# ------------------------------------------------------------------------
sub new {
	my $class = shift;
    my $self = {
        _type_query => shift,
    };
    $self->{query} = $class->type_query($self->{_type_query});
    $self->{db_schema} = {
        'query' => $self->{query}
    };
    bless $self, $class;
    return $self;
}
# End of Subroutine for Constructor.
# ===========================================================================================================

# Subroutine for add table :
# ------------------------------------------------------------------------
sub add_table {
    my $self = shift;
    my ($table_name) = @_;
    my $type_q = $self->{query};
    my $_schema = $self->{db_schema};

    # For Single Query :
    if ($type_q eq 'sQuery') {
        unless (exists $_schema->{table_name}) {
            my $new_data = Hash::MultiValue->new();
            $new_data->add('table_name' => $table_name);
            $self->{db_schema} = $new_data->as_hashref;
        } else {
            my $new_data = Hash::MultiValue->new(%{$_schema});
            $new_data->set('table_name' => $table_name);
            $self->{db_schema} = $new_data->as_hashref;
        }
    }

    # For Group Query :
    else {

        unless (exists $_schema->{'table_list'}) {

            my %arrtbl_list = ('table1' => $table_name);
            my $new_dataTbl_list = Hash::MultiValue->new(%{$_schema});
            $new_dataTbl_list->add('table_list' => \%arrtbl_list);
            my $dataTbl_list = $new_dataTbl_list->as_hashref;
            my $new_data = Hash::MultiValue->new(%{$dataTbl_list});
            $new_data->add('schema' => {
                    'table1' => {
                        'table_name' => $table_name
                    }
                });
            $self->{db_schema} = $new_data->as_hashref;
            $self->{active_table} = 'table1';
        } else {

            # For Table List :
            my $table_list = $_schema->{'table_list'};
            my $last_data = CellBIS::Utils::ArrHash->HashKey_numToArr($table_list);
            $last_data = CellBIS::Utils::ArrHash->Arr_minMax_val($last_data, 'max');
            my $new_tblID = $last_data + 1;
            $new_tblID = 'table'.$new_tblID;
            my $forPush_tbl = Hash::MultiValue->new(%{$table_list});
            $forPush_tbl->add($new_tblID => $table_name);
            my $push_tbl = $forPush_tbl->as_hashref;

            # For Table Schema :
            my $schema_list = $self->{db_schema}->{'schema'};
            my $addNew_table = Hash::MultiValue->new(%{$schema_list});
            $addNew_table->set($new_tblID => {
                    'table_name' => $table_name
                });
            my $new_table = $addNew_table->as_hashref;

            # For Finishing :
            my $AddNew_data = Hash::MultiValue->new(%{$_schema});
            $AddNew_data->set('table_list' => $push_tbl);
            $AddNew_data->set('schema' => $new_table);
            $self->{db_schema} = $AddNew_data->as_hashref;
            $self->{active_table} = $new_tblID;
        }
    }
    return $self;
}
# End of Subroutine for add table.
# ===========================================================================================================

# Subroutine for add column :
# ------------------------------------------------------------------------
sub add_col {
	my $self = shift;
    my ($name, $attr) = @_;
    my $table_name = $self->{active_table};
    my $type_q = $self->{query};
    my $_schema = $self->{db_schema};

    # For Single Querqy :
    if ($type_q eq 'sQuery') {

        if (exists $_schema->{'column'}) {
            my $curr_col = $_schema->{'column'};
            my $add_column = Hash::MultiValue->new(%{$curr_col});
            if (exists $curr_col->{$name}) {
                $add_column->set($name => $attr);
            } else {
                $add_column->add($name => $attr);
            }
            my $new_data_col = $add_column->as_hashref;
            my $union_data = Hash::MultiValue->new(%{$_schema});
            $union_data->set('column' => $new_data_col);
            $self->{db_schema} = $union_data->as_hashref;
        } else {
            my $new_data_col = Hash::MultiValue->new(%{$_schema});
            $new_data_col->add('column' => {
                    $name => $attr
                });
            $self->{db_schema} = $new_data_col->as_hashref;
        }
    }

    # For Group Query :
    else {
        my $curr_schema = $_schema->{schema};

        # For get last table :
        my $table_list = $_schema->{'table_list'};
        my $last_data = CellBIS::Utils::ArrHash->HashKey_numToArr($table_list);
        $last_data = CellBIS::Utils::ArrHash->Arr_minMax_val($last_data, 'max');
        my $last_table = $last_data + 1;
        $last_table = 'table'.$last_table;

        # For Add data column :
        my $curr_tblSchema = $curr_schema->{$table_name};
        my $data_table;
        if (exists $curr_tblSchema->{column}) {
            my $forAdd_col = Hash::MultiValue->new(%{$curr_tblSchema->{column}});
            $forAdd_col->add($name => $attr);
            $data_table = $forAdd_col->as_hashref;
        } else {
            my $forAdd_col = Hash::MultiValue->new();
            $forAdd_col->add($name => $attr);
            $data_table = $forAdd_col->as_hashref;
        }

        # For Add New Data Table Schema :
        my $addData_tbl = Hash::MultiValue->new(%{$curr_tblSchema});
        $addData_tbl->add(column => $data_table);
        my $new_tbl_schema = $addData_tbl->as_hashref;

        # For Add New Data Schema :
        my $forNewData_schema = Hash::MultiValue->new(%{$curr_schema});
        $forNewData_schema->set($table_name => $new_tbl_schema);
        my $newData_schema = $forNewData_schema->as_hashref;

        # For Add New Data Schema :
        my $addData_schema = Hash::MultiValue->new(%{$_schema});
        $addData_schema->set(schema => $newData_schema);
        $self->{db_schema} = $addData_schema->as_hashref;
    }
    return $self;
}
# End of Subroutine for add column.
# ===========================================================================================================

# Subroutine for get result schema :
# ------------------------------------------------------------------------
sub result {
	my $self = shift;
    return $self->{db_schema};
}
# End of Subroutine for get result schema.
# ===========================================================================================================

1;