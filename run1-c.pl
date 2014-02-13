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

# Run the C tests
my $dh;
opendir($dh, "$c_npb_dir/bin") || die "Can't open C NPB bin dir";
my @cbins = sort(grep { ! /^\./ && -x "$c_npb_dir/bin/$_" } readdir($dh));;
closedir($dh);
chdir("$c_npb_dir/bin");
foreach my $bin (@cbins) {
    my ($benchmark, $class, $size) = split(/\./, $bin);
    print "### Running $bin at " . localtime() . "\n";
    system("mpirun --mca btl sm,self --bind-to core -np 16 $bin |& tee $results_dir/$benchmark.$class.$size.c.sm.out");
    print "### Completed $bin at " . localtime() . "\n";
}

system("$pushover C NPB shmem done");
