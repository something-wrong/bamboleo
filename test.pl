#! /usr/bin/perl -w

use strict;
use warnings;

my @person = ("Hans" , "Meier" , "Dr" , 42, 4622, "Irgendwo" );
my @personKopie = @person;
my $lo = @person;
my $lk = @personKopie;

print $lo . "\n";
print $lk . "\n";


$person[9] = 1; # obwohl dem original array ein neuer wert zugewiesen wird hat es keinen einfluss auf die kopierten arrays
$lo = @person;
$lk = @personKopie;

print $lo . "\n";
print $lk . "\n";


my @personAusschnitt = @person[1,2];
my $l1 = @personKopie;
my $l2 = @personAusschnitt;

print $l1 . "\n";
print $l2 . "\n";




