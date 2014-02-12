#!/usr/bin/env perl

use strict;

use Cwd;
use POSIX qw/strftime/;

my $day = strftime("%Y-%m-%d", localtime);

my $ompitests = "$ENV{HOME}/svn/ompi-tests";
my $java_npb_dir = "$ompitests/NPB_MPJ";
my $c_npb_dir = "$ompitests/NPB3.3.1/NPB3.3-MPI";
my $results_dir = getcwd() . "/results-$day";
my $pushover = "$ENV{HOME}/dotfiles/pushover";

mkdir($results_dir)
    if (! -d $results_dir);

# Sanity check version
open(VERSION, "ompi_info --version|") || die "Can't open ompi_info";
my $ver = <VERSION>;
close(VERSION);
chomp($ver);
die "Wrong version of OMPI: $ver"
    if ($ver ne "Open MPI v1.7.4");

# Sanity check that it's not a debugging build
open(DEBUG, "ompi_info --parsable|") || die "Can't open ompi_info";
while (<DEBUG>) {
    chomp;
    if (/debug/) {
        die "This is not a debugging version: $_"
            if (! /:no$/);
    }
}
close(DEBUG);

# Run the Java tests
my @benchmarks = qw/BT CG EP FT IS LU MG SP/;
my @classes = qw/A B C D E/;
chdir($java_npb_dir);
foreach my $class (@classes) {
    foreach my $benchmark (@benchmarks) {
        system("mpirun --mca btl tcp,self --bind-to core --map-by node -np 16 java NPB_MPJ.$benchmark class=$class |& tee $results_dir/" . lc($benchmark) . ".$class.16.java.tcp.out");
        system("mpirun --mca btl usnic,self --bind-to core --map-by node -np 16 java NPB_MPJ.$benchmark class=$class |& tee $results_dir/" . lc($benchmark) . ".$class.16.java.usnic.out");
    }
}

system("$pushover java NPB shmem done");
