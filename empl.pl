#!/usr/bin/perl
## Sample prg by NKS on perl oops

use strict;
use warnings;

use Getopt::Long;
use Emp;
use SqliteDB;
use LogDisp;
use LogDisp qw (logDesign);

my ($empId,$firstName, $lastName, $age, $help);
my   $status = GetOptions (
    'eId=i'              => \$empId,
    'fName=s'            => \$firstName,
    'lName=s'            => \$lastName,
    'Age=i'              => \$age,
    'help!'              => \$help,
);

if ($help or !($status)) {
    usage();
}

if ((!defined($empId) or $empId eq "") or (!defined($firstName) or $firstName eq "") or (!defined($lastName) or $lastName eq "") or (!defined($age) or $age eq "") )
{
    usage("Empl Id, firstName, lastName and age are mandatory parameters");
}
logDesign ("Starting the Perl program for Emp Details. This include Perl oops concept and use of DBI module");

my $emp_obj = Emp->new($empId,$firstName, $lastName, $age);
my $logFile = "$0.log";

open (my $FHL,'>',$logFile);

logInfo ($FHL,"Provided Input parameters are as below : \n\t\tEmployee ID:\t\t$empId \n\t\tFirst Name:\t\t$firstName \n\t\tLast Name:\t\t$lastName \n\t\tEmployee Age:\t\t$age \n");

logDesign ("Please enter new first name for the employee.");
my $newFName = <STDIN>;
chomp ($newFName);
logDesign ("Setting new first name for the employee.");
$emp_obj -> setFirstName($newFName);

my $modfName = $emp_obj -> getFirstName;
logInfo ($FHL,"After modification first name of employee:$modfName");

logDesign ("Creating employee data file for mySQL DB loading.");
my $dataFile = "empData.txt";

my $latsName = $emp_obj -> getLastName;
open (my $FH,'>',$dataFile) || die "Error in opening $dataFile $! \n";
my $empDet = join ('|',$empId,$modfName,$latsName,$age);

print $FH $empDet;
close ($FH);

logInfo ($FHL,"Created employee data file $dataFile");

my $mySql_obj = SqliteDB->new('EmpDB.db',$FHL);
logDesign ("mySQL DB EmpDB.db created.");
$mySql_obj ->create_table;
logDesign ("Table created in DB EmpDB.db");

my $rowCount= $mySql_obj -> get_table_record_count('empDetails');
logInfo ($FHL,"Table row count for table empDetails :$rowCount");

logDesign ("Loading data into DB EmpDB.db");
$mySql_obj -> load_data ('empDetails',$dataFile,'|');

logDesign ("Data loaded into DB EmpDB.db");
my $rowCountA= $mySql_obj -> get_table_record_count('empDetails');
logInfo ($FHL,"Table row count after data load into table empDetails :$rowCountA");

logDesign ("Sample program on Perl oops with database completed");
close ($FHL);


sub usage {
    my $msg = $_[0] if defined(@_);
    print "\n\t\t*** Reason: $msg .... *** \n " if defined($msg);
    print <<EOF;
    Usage:perl $0 --eId=<EmpId> --fName=<First Name> --lName=<Last Name>  --age=<Age> [--help]
    eId:             [Mandatory]   Employee ID
    fName:           [Mandatory]   First Name
    lName:           [Mandatory]   Last Name
    age:             [Mandatory]   Age
EOF
    exit(1);
}