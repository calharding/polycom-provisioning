#!/usr/bin/perl

####################################
# Convert Excel spreadsheet to CSV
####################################

use strict;
use warnings;
use Spreadsheet::XLSX;
 
#my $first_name=$ARGV[0];
#my $xlsx_file = Spreadsheet::XLSX -> new ('polycom.xlsx');
my $xlsx_file = Spreadsheet::XLSX -> new ("$ARGV[0]");
my $line;

foreach my $sheet (@{$xlsx_file -> {Worksheet}}) {
    printf("Sheet: %s\n", $sheet->{Name});
    $sheet -> {MaxRow} ||= $sheet -> {MinRow};
    foreach my $row ($sheet -> {MinRow} .. $sheet -> {MaxRow}) {
        $sheet -> {MaxCol} ||= $sheet -> {MinCol};
        foreach my $col ($sheet -> {MinCol} ..  $sheet -> {MaxCol}) {
            my $cell = $sheet -> {Cells} [$row] [$col];
            if ($cell) {
                $line .= "".$cell -> {Val}.",";
            }
        }
		chomp($line);
		print "$line\n";
		$line = '';
    }
}
