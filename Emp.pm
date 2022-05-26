#!/usr/bin/perl
## Sample prg by NKS on perl oops

package Emp;
use strict;
use Data::Dumper;

sub new {
    my $class = shift;
    my $self = {
        'EmpId'  => shift,
        'FirstName' => shift,
        'LastName' => shift,
        'Age' => shift,
    };
    bless $self,$class;
    return $self;
}

sub setFirstName
{
    my $self = shift;
    my $newFname = shift;
    $self->{'FirstName'} = $newFname;

    return ($self->{'FirstName'});
}
sub getFirstName {
    my $self = shift;
    return ($self->{'FirstName'});
}

sub setLastName
{
    my $self = shift;
    my $newLname = shift;
    $self->{'LastName'} = $newLname;

    return ($self->{'LastName'});

}
sub getLastName {
    my $self = shift;
    return ($self->{'LastName'});
}

1;