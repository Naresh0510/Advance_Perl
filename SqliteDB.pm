package SqliteDB;

use strict;
use DBI;
use File::Touch;
use LogDisp;

sub new {
    my ( $class, $sqlite_db,$FHL ) = @_ ;

    my $self = {
        'sqlite_db'     =>  $sqlite_db,
        'logFHL'        => $FHL,
    };

    bless $self ,$class;
    $self->checkNcreateDB();
    return $self;
}

sub checkNcreateDB {
    my $self = shift;
    my $checkOnly = shift;

    my $sqlite_db  = $self->{sqlite_db};

    if ( ! -e "$sqlite_db" ) {
            logInfo ($self->{logFHL},"Creating sqlite DB: $sqlite_db");
            my $ok = touch("$sqlite_db");

            if ( $ok ) {
                logInfo ($self->{logFHL},"Created sqlite DB first time : $sqlite_db");
                return 1;
            } else {

                logDie ($self->{logFHL},"Failed to create sqlite DB : $sqlite_db \n");
            }
        }
    else {
        logInfo ($self->{logFHL},"Sqlite DB : $sqlite_db, already exists");
        return 1;
    }
}

sub get_DBConn {
    my $self = shift;

    my $driver = "SQLite";
    my $database = "$self->{sqlite_db}";
    my $dsn = "DBI:$driver:dbname=$database";
    my $userid = "";
    my $password = "";
    my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1, AutoInactiveDestroy => 1, sqlite_use_immediate_transaction => 0 }) or logDie ($self->{logFHL},"Unable to connect to $self->{sqlite_db} , $DBI::errstr");

    $dbh->sqlite_busy_timeout( 10000 );

    return $dbh;
}

sub create_table {
    my $self = shift;
    my $table_nm = "empDetails";
    my $table_def = "emp.tab";

    my $create_sql;


    if ($self->check_table_exists($table_nm )){
        logInfo ($self->{logFHL},"Table already exists, Skipping table creation process");
        return -1;
    }

    $create_sql = "CREATE TABLE empDetails ( empId INTEGER (5) NOT NULL, firstName CHAR(20), lastName  CHAR(20), age INTEGER (3), PRIMARY KEY (empId))";

    my $dbh = $self->get_DBConn();


    my  $drop_sql = "DROP TABLE IF EXISTS $table_nm";
    $dbh->do($drop_sql) || die "Failed to execute $drop_sql, $DBI::errstr \n" ;


    $dbh->do($create_sql) || die "Failed to execute : $create_sql, $DBI::errstr \n";

    $dbh->disconnect();
    logInfo ($self->{logFHL},"Created Sqlite Table : $table_nm ");
    return 1;
}

sub check_table_exists {
    my ($self, $table ) = @_;
    my $dbh = $self->get_DBConn();

    logInfo ($self->{logFHL},"checking table '$table' already exists or not");
    my $sql = "select 1 FROM sqlite_master WHERE type='table' AND name='$table'";

    my $retVal = $dbh->selectrow_array($sql);
    $dbh->disconnect();
    $retVal = (defined($retVal))?$retVal:0;

    return $retVal;
}


sub load_data {
    my $self = shift;
    my ($Table_NM, $input_file, $delim ) = @_;

    my $sqlite_db  = $self->{sqlite_db};

    if ( -s "$input_file" )
    {
        open(W_FH,"> import.sql") || die "Can't write to import.sql, $! \n";
        print W_FH ".separator '$delim'\n";
        print W_FH ".import $input_file $Table_NM";
        close W_FH;

        my $cmd = "sqlite3 $sqlite_db < import.sql 2> ${Table_NM}_load.err";
        logInfo ($self->{logFHL}, "$cmd");

        my $ok = system($cmd);
        if ($ok)
        {
            logDie ($self->{logFHL},"Failed to Load $input_file to $Table_NM, check file : ${Table_NM}_load.err");
        }
        else
        {
            logInfo ($self->{logFHL},"Loaded $input_file to $Table_NM ");
            if ( -s "${Table_NM}_load.err" )
            {
                logInfo ($self->{logFHL},"Warning/Error while loading $input_file to $Table_NM, check file : ${Table_NM}_load.err");
            }
        }
    }

}

sub get_table_record_count {
    my $self = shift;
    my $tablName = shift;

    my $dbh = $self->get_DBConn();
    my $asOfDateCountSql = "select count(1) from $tablName";
    my $retVal = $dbh->selectrow_array($asOfDateCountSql);
    $dbh->disconnect();

    $retVal = (defined($retVal))?$retVal:0;

    return $retVal;
}

1;