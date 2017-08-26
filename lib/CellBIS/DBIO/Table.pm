package # hide from PAUSE
    CellBIS::DBIO::Table;

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

# Subroutine for Constructor :
# ------------------------------------------------------------------------
sub new {
	my $class = shift;
    my $self = {
        _type_query => shift,
    };
    $self->{query} = $class->type_query($self->{_type_query});
    $self->{db_schema} = {
        'query' => $self->{query},
    };
    $self->{'temp.table'} = {};
    $self->{'temp.schema'} = {};
    bless $self, $class;
    return $self;
}

# Subroutine for add table :
# ------------------------------------------------------------------------
sub add_table_new {
    my $self = shift;
    my ($table_name) = @_;
    my $type_q = $self->{query};
    my $_schema = $self->{db_schema};
    my $temp_tbl = $self->{'temp.table'};
    my $temp_schm = $self->{'temp.schema'};

    # For Single Query :
    if ($type_q eq 'sQuery') {
        unless (exists $temp_tbl->{table_name}) {
            my $new_data = Hash::MultiValue->new();
            $new_data->add('table_name' => $table_name);
            $self->{'temp.table'} = $new_data->as_hashref;
        } else {
            my $new_data = Hash::MultiValue->new();
            $new_data->set('table_name' => $table_name);
            $self->{'temp.table'} = $new_data->as_hashref;
        }
    }

    # For Group Query :
    if ($type_q eq 'gQuery') {
        unless (exists $temp_tbl->{table_list}) {

            my %arrtbl_list = ('table1' => $table_name);
            my $new_dataTbl_list = Hash::MultiValue->new(%{$temp_tbl});
            $new_dataTbl_list->add('table_list' => \%arrtbl_list);
            my $dataTbl_list = $new_dataTbl_list->as_hashref;

            my $new_tblList_name = Hash::MultiValue->new(%{$dataTbl_list});
            $new_tblList_name->add('table_list_name' => {
                    $table_name => $table_name
                });
            $dataTbl_list = $new_tblList_name->as_hashref;

            my $new_tblList_rev = Hash::MultiValue->new(%{$dataTbl_list});
            $new_tblList_rev->add('table_list_rev' => {
                    $table_name => 'table1',
                });
            $self->{'temp.table'} = $new_tblList_rev->as_hashref;

            my $new_data = Hash::MultiValue->new(%{$temp_schm});
            $new_data->add('table1' => {
                    'table_name' => $table_name
                });
            $self->{'temp.schema'} = $new_data->as_hashref;
            $self->{active_table} = 'table1';

        } else {

            # For Table list :
            my $table_list = $temp_tbl->{table_list};
            my $last_data = CellBIS::Utils::ArrHash->HashKey_numToArr($table_list);
            $last_data = CellBIS::Utils::ArrHash->Arr_minMax_val($last_data, 'max');
            my $new_tblID = $last_data + 1;
            $new_tblID = 'table'.$new_tblID;
            my $forPush_tbl = Hash::MultiValue->new(%{$table_list});
            $forPush_tbl->add($new_tblID => $table_name);
            my $push_tbl = $forPush_tbl->as_hashref;

            # For Table List Name :
            my $table_list_name = $temp_tbl->{'table_list_name'};
            my $forPush_tbl_name = Hash::MultiValue->new(%{$table_list_name});
            $forPush_tbl_name->add($table_name => $table_name);
            my $push_tblName = $forPush_tbl_name->as_hashref;

            # For Table List Reverse :
            my $table_list_rev = $temp_tbl->{'table_list_rev'};
            my $forPush_tbl_rev = Hash::MultiValue->new(%{$table_list_rev});
            $forPush_tbl_rev->add($table_name => $new_tblID);
            my $push_tblRev = $forPush_tbl_rev->as_hashref;

            # For Data Temp Table :
            my $AddNew_data = Hash::MultiValue->new(%{$temp_tbl});
            $AddNew_data->set('table_list' => $push_tbl);
            $AddNew_data->set('table_list_name' => $push_tblName);
            $AddNew_data->set('table_list_rev' => $push_tblRev);
            $self->{'temp.table'} = $AddNew_data->as_hashref;

            # For Table Schema :
            my $addNew_schema = Hash::MultiValue->new(%{$temp_schm});
            $addNew_schema->set($new_tblID => {
                    'table_name' => $table_name
                });
            $self->{'temp.schema'} = $addNew_schema->as_hashref;
            $self->{active_table} = $new_tblID;
        }
    }
    return $self;
}

# Subroutine for add column :
# ------------------------------------------------------------------------
sub add_col_new {
	my $self = shift;
    my ($name, $attr) = @_;
    my $table_name = $self->{active_table};
    my $type_q = $self->{query};
    my $temp_tbl = $self->{'temp.table'};
    my $temp_schm = $self->{'temp.schema'};

    # For Single Query :
    if ($type_q eq 'sQuery') {
        if (exists $temp_schm->{column}) {
            my $col_list = $temp_schm->{column_list};
            my $last_col = CellBIS::Utils::ArrHash->HashKey_numToArr($col_list);
            $last_col = CellBIS::Utils::ArrHash->Arr_minMax_val($last_col, 'max');
            my $new_colID = $last_col + 1;
            $new_colID = 'col'.$new_colID;

            my $curr_col = $temp_schm->{'column'};
            my $add_column = Hash::MultiValue->new(%{$curr_col});
            if (exists $curr_col->{$name}) {
                $add_column->set($name => $attr);
            } else {
                $add_column->add($name => $attr);
            }
            my $new_data_col = $add_column->as_hashref;

            my $curr_collist = $temp_schm->{column_list};
            my $add_colList = Hash::MultiValue->new(%{$curr_collist});
            $add_colList->add($new_colID => $name);
            my $new_listCol = $add_colList->as_hashref;

            my $curr_collistName = $temp_schm->{column_list_name};
            my $add_colList_name = Hash::MultiValue->new(%{$curr_collistName});
            $add_colList_name->add($name => $name);
            my $new_listCol_Name = $add_colList_name->as_hashref;

            my $union_data = Hash::MultiValue->new(%{$temp_schm});
            $union_data->set(column => $new_data_col);
            $union_data->set(column_list => $new_listCol);
            $union_data->set(column_list_name => $new_listCol_Name);
            $self->{'temp.schema'} = $union_data->as_hashref;
        } else {
            my $new_data_col = Hash::MultiValue->new(%{$temp_schm});
            $new_data_col->add('column' => {
                    $name => $attr
                });
            $new_data_col->add(column_rev => {
                    'col1' => $name
                });
            $new_data_col->add(column_list_name => {
                    $name => $name
                });
            $self->{'temp.schema'} = $new_data_col->as_hashref;
        }
    }

    # For Group Query :
    if ($type_q eq 'gQuery') {

        # For get last table :
        my $table_list = $temp_tbl->{table_list};
        my $last_data = CellBIS::Utils::ArrHash->HashKey_numToArr($table_list);
        $last_data = CellBIS::Utils::ArrHash->Arr_minMax_val($last_data, 'max');
        my $last_table = $last_data + 1;
        $last_table = 'table'.$last_table;

        # For Add Data Column :
        my $curr_tblSchema = $temp_schm->{$table_name};
        my $data_table;
        my $new_listCol;
        my $new_listCol_name;
        if (exists $curr_tblSchema->{column}) {
            my $list_col = $curr_tblSchema->{column_rev};
            my $last_col = CellBIS::Utils::ArrHash->HashKey_numToArr($list_col);
            $last_col = CellBIS::Utils::ArrHash->Arr_minMax_val($last_col, 'max');
            my $new_colID = $last_col + 1;
            $new_colID = 'col'.$new_colID;

            my $forAdd_col = Hash::MultiValue->new(%{$curr_tblSchema->{column}});
            $forAdd_col->add($name => $attr);
            $data_table = $forAdd_col->as_hashref;

            my $forAdd_listCol = Hash::MultiValue->new(%{$curr_tblSchema->{column_rev}});
            $forAdd_listCol->add($new_colID => $name);
            $new_listCol = $forAdd_listCol->as_hashref;

            my $forAdd_listCol_name = Hash::MultiValue->new(%{$curr_tblSchema->{column_name}});
            $forAdd_listCol_name->add($name => $name);
            $new_listCol_name = $forAdd_listCol_name->as_hashref;
        } else {
            my $forAdd_col = Hash::MultiValue->new();
            $forAdd_col->add($name => $attr);
            $data_table = $forAdd_col->as_hashref;

            my $forAdd_listCol = Hash::MultiValue->new();
            $forAdd_listCol->add('col1' => $name);
            $new_listCol = $forAdd_listCol->as_hashref;

            my $forAdd_listCol_name = Hash::MultiValue->new();
            $forAdd_listCol_name->add($name => $name);
            $new_listCol_name = $forAdd_listCol_name->as_hashref;
        }

        # For Add New Data Table Schema :
        my $addData_tbl = Hash::MultiValue->new(%{$curr_tblSchema});
        $addData_tbl->add(column => $data_table);
        $addData_tbl->add(column_rev => $new_listCol);
        $addData_tbl->add(column_name => $new_listCol_name);
        my $new_tbl_schema = $addData_tbl->as_hashref;

        # For Add New Data Schema :
        my $forNewData_schema = Hash::MultiValue->new(%{$temp_schm});
        $forNewData_schema->set($table_name => $new_tbl_schema);
        $self->{'temp.schema'} = $forNewData_schema->as_hashref;
    }
    return $self;
}

# Subroutine for get result schema :
# ------------------------------------------------------------------------
sub result_new {
	my $self = shift;
    my $type_q = $self->{query};
    my $temp_tbl = $self->{'temp.table'};
    my $temp_schm = $self->{'temp.schema'};
    my $_schema = $self->{db_schema};

    # For Single Query :
    if ($type_q eq 'sQuery') {
        my $table_name = $temp_tbl->{'table_name'};
        my $col_list = $temp_schm->{'column'};
        my $col_list_rev = $temp_schm->{'column_rev'};
        my $col_list_name = $temp_schm->{'column_name'};

        my $new_schema = Hash::MultiValue->new(%{$_schema});
        $new_schema->add('table_name' => $table_name);
        $new_schema->add('column' => $col_list);
        $new_schema->add('column_rev' => $col_list_rev);
        $new_schema->add('column_name' => $col_list_name);
        $self->{db_schema} = $new_schema->as_hashref;
    }

    # For Group Query :
    if ($type_q eq 'gQuery') {
        my $table_list = $temp_tbl->{'table_list'};
        my $table_list_name = $temp_tbl->{'table_list_name'};
        my $table_list_rev = $temp_tbl->{'table_list_rev'};

        my $new_schema = Hash::MultiValue->new(%{$_schema});
        $new_schema->add('table_list' => $table_list);
        $new_schema->add('table_list_name' => $table_list_name);
        $new_schema->add('table_list_rev' => $table_list_rev);
        $new_schema->add('schema' => $temp_schm);
        $self->{db_schema} = $new_schema->as_hashref;
    }
    return $self->{db_schema};
}

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
            $new_data->add('query' => $type_q);
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

            my $new_tblList_name = Hash::MultiValue->new(%{$dataTbl_list});
            $new_tblList_name->add('table_list_name' => {
                    $table_name => $table_name
                });
            $dataTbl_list = $new_tblList_name->as_hashref;

            my $new_tblList_rev = Hash::MultiValue->new(%{$dataTbl_list});
            $new_tblList_rev->add('table_list_rev' => {
                    $table_name => 'table1',
                });
            $dataTbl_list = $new_tblList_rev->as_hashref;

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

            # For Table List Name :
            my $table_list_name = $_schema->{'table_list_name'};
            my $forPush_tbl_name = Hash::MultiValue->new(%{$table_list_name});
            $forPush_tbl_name->add($table_name => $table_name);
            my $push_tblName = $forPush_tbl_name->as_hashref;

            # For Table List Reverse :
            my $table_list_rev = $_schema->{'table_list_rev'};
            my $forPush_tbl_rev = Hash::MultiValue->new(%{$table_list_rev});
            $forPush_tbl_rev->add($table_name => $new_tblID);
            my $push_tblRev = $forPush_tbl_rev->as_hashref;

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
            $AddNew_data->set('table_list_name' => $push_tblName);
            $AddNew_data->set('table_list_rev' => $push_tblRev);
            $AddNew_data->set('schema' => $new_table);
            $self->{db_schema} = $AddNew_data->as_hashref;
            $self->{active_table} = $new_tblID;
        }
    }
    return $self;
}

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
            my $col_list = $_schema->{column_list};
            my $last_col = CellBIS::Utils::ArrHash->HashKey_numToArr($col_list);
            $last_col = CellBIS::Utils::ArrHash->Arr_minMax_val($last_col, 'max');
            my $new_colID = $last_col + 1;
            $new_colID = 'col'.$new_colID;

            my $curr_col = $_schema->{'column'};
            my $add_column = Hash::MultiValue->new(%{$curr_col});
            if (exists $curr_col->{$name}) {
                $add_column->set($name => $attr);
            } else {
                $add_column->add($name => $attr);
            }
            my $new_data_col = $add_column->as_hashref;

            my $curr_collist = $_schema->{column_list};
            my $add_colList = Hash::MultiValue->new(%{$curr_collist});
            $add_colList->add($new_colID => $name);
            my $new_listCol = $add_colList->as_hashref;

            my $curr_collistName = $_schema->{column_list_name};
            my $add_colList_name = Hash::MultiValue->new(%{$curr_collistName});
            $add_colList_name->add($name => $name);
            my $new_listCol_Name = $add_colList_name->as_hashref;

            my $union_data = Hash::MultiValue->new(%{$_schema});
            $union_data->set(column => $new_data_col);
            $union_data->set(column_list => $new_listCol);
            $union_data->set(column_list_name => $new_listCol_Name);
            $self->{db_schema} = $union_data->as_hashref;

        } else {

            my $new_data_col = Hash::MultiValue->new(%{$_schema});
            $new_data_col->add('column' => {
                    $name => $attr
                });
            $new_data_col->add(column_list => {
                    'col1' => $name
                });
            $new_data_col->add(column_list_name => {
                    $name => $name
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
        my $new_listCol;
        my $new_listCol_name;
        if (exists $curr_tblSchema->{column}) {
            my $list_col = $curr_tblSchema->{column_list};
            my $last_col = CellBIS::Utils::ArrHash->HashKey_numToArr($list_col);
            $last_col = CellBIS::Utils::ArrHash->Arr_minMax_val($last_col, 'max');
            my $new_colID = $last_col + 1;
            $new_colID = 'col'.$new_colID;

            my $forAdd_col = Hash::MultiValue->new(%{$curr_tblSchema->{column}});
            $forAdd_col->add($name => $attr);
            $data_table = $forAdd_col->as_hashref;

            my $forAdd_listCol = Hash::MultiValue->new(%{$curr_tblSchema->{column_list}});
            $forAdd_listCol->add($new_colID => $name);
            $new_listCol = $forAdd_listCol->as_hashref;

            my $forAdd_listCol_name = Hash::MultiValue->new(%{$curr_tblSchema->{column_list_name}});
            $forAdd_listCol_name->add($name => $name);
            $new_listCol_name = $forAdd_listCol_name->as_hashref;

        } else {
            my $forAdd_col = Hash::MultiValue->new();
            $forAdd_col->add($name => $attr);
            $data_table = $forAdd_col->as_hashref;

            my $forAdd_listCol = Hash::MultiValue->new();
            $forAdd_listCol->add('col1' => $name);
            $new_listCol = $forAdd_listCol->as_hashref;

            my $forAdd_listCol_name = Hash::MultiValue->new();
            $forAdd_listCol_name->add($name => $name);
            $new_listCol_name = $forAdd_listCol_name->as_hashref;
        }

        # For Add New Data Table Schema :
        my $addData_tbl = Hash::MultiValue->new(%{$curr_tblSchema});
        $addData_tbl->add(column => $data_table);
        $addData_tbl->add(column_list => $new_listCol);
        $addData_tbl->add(column_list_name => $new_listCol_name);
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

# Subroutine for set primary key :
# ------------------------------------------------------------------------
sub set_primary_key {
	my $self = shift;
    my ($field_tbl) = @_;
    my $table_name = $self->{active_table};
    my $type_q = $self->{query};
    my $_schema = $self->{db_schema};

    my $data_column;
    my $rev_DataCol;
    my $newData_schema_cfg;

    $field_tbl = $self->_tbl_col($field_tbl);

    # For Single Query :
    if ($type_q eq 'sQuery') {
        my $tbl_cfg = $_schema->{column}->{$field_tbl};
        my $forAdd_tblCfg = Hash::MultiValue->new(%{$tbl_cfg});
        $forAdd_tblCfg->add('is_primary_key' => 1);
        my $rCfg_colTbl = $forAdd_tblCfg->as_hashref;

        # For Data Column Table :
        $data_column = $_schema->{column};
        my $newData_col = Hash::MultiValue->new(%{$data_column});
        $newData_col->set($field_tbl => $rCfg_colTbl);
        $rev_DataCol = $newData_col->as_hashref;

        # For Data Config Schema :
        $newData_schema_cfg = Hash::MultiValue->new(%{$_schema});
        $newData_schema_cfg->set('column' => $rev_DataCol);
        $self->{db_schema} = $newData_schema_cfg->as_hashref;
    }

    # For Group Query :
    if ($type_q eq 'gQuery') {
        my $tbl_cfg = $_schema->{schema}->{$table_name}->{column}->{$field_tbl};
        my $forAdd_tblCfg = Hash::MultiValue->new(%{$tbl_cfg});
        $forAdd_tblCfg->add('is_primary_key' => 1);
        my $rCfg_colTbl = $forAdd_tblCfg->as_hashref;

        # For Data Column Table :
        $data_column = $_schema->{schema}->{$table_name}->{column};
        my $newData_Col = Hash::MultiValue->new(%{$data_column});
        $newData_Col->set($field_tbl => $rCfg_colTbl);
        $rev_DataCol = $newData_Col->as_hashref;

        # For data Table :
        my $data_table = $_schema->{schema}->{$table_name};
        my $newData_table = Hash::MultiValue->new(%{$data_table});
        $newData_table->set('column' => $rev_DataCol);
        my $rev_DataTable = $newData_table->as_hashref;

        # For Data Schema :
        my $data_schema = $_schema->{schema};
        my $newData_schema = Hash::MultiValue->new(%{$data_schema});
        $newData_schema->set($table_name => $rev_DataTable);
        my $rev_DataSchema = $newData_schema->as_hashref;

        # For Data Config Schema :
        $newData_schema_cfg = Hash::MultiValue->new(%{$_schema});
        $newData_schema_cfg->set('schema' => $rev_DataSchema);
        $self->{db_schema} = $newData_schema_cfg->as_hashref;
    }
    return $self;
}

# Subroutine for get table or column name :
# ------------------------------------------------------------------------
sub _tbl_col {
	my $self = shift;
    my $arg_len = scalar @_;
    my $table_name = $self->{active_table};
    my $type_q = $self->{query};
    my $dataSchema = $self->{db_schema};
    my $field_tbl = 'c1';
    my $list_col;
    my $r_col;

    if ($arg_len >= 1) {
        $field_tbl = $_[0];
    }

    # For Single Query :
    if ($type_q eq 'sQuery') {
        $list_col = $dataSchema->{column_list};
        $field_tbl = convert_abbrCol($field_tbl);
        $r_col = $list_col->{$field_tbl} if exists $list_col->{$field_tbl};
        $r_col = $list_col->{'col1'} unless exists $list_col->{$field_tbl};
    }

    # For Group Query
    if ($type_q eq 'gQuery') {
        $list_col = $dataSchema->{schema}->{$table_name}->{column_list};
        $field_tbl = convert_abbrCol($field_tbl);
        $r_col = $list_col->{$field_tbl} if exists $list_col->{$field_tbl};
        $r_col = $list_col->{'col1'} unless exists $list_col->{$field_tbl};
    }
    return $r_col;
}

# Subroutine for translate abbreviation column name :
# ------------------------------------------------------------------------
sub convert_abbrCol {
	my ($abbr) = @_;
    my $result = '';
    if ($abbr =~ m/^c([0-9]+)/) {
        $result = 'col'.$1;
    } else {
        $result = 'col1';
    }
    return $result;
}

# Subroutine for get result schema :
# ------------------------------------------------------------------------
sub result {
	my $self = shift;
    return $self->{db_schema};
}

1;