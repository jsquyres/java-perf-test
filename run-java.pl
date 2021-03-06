#!/usr/bin/env perl

use strict;

use Cwd;
use POSIX qw/strftime/;

my $script_dir = "$ENV{HOME}/git/java-perf-test";
my $results_dir = "$script_dir/results-" . strftime("%Y-%m-%d", localtime);

my $ompitests = "$ENV{HOME}/svn/ompi-tests";
my $java_npb_dir = "$ompitests/NPB_MPJ";
my $c_npb_dir = "$ompitests/NPB3.3.1/NPB3.3-MPI";

my $expected_ompi_ver = "Open MPI v1.8.1";

my $pushover = "$ENV{HOME}/dotfiles/pushover";

my $slurm_queue = "mtt-usnic-198";

#######################################################################

mkdir($results_dir)
    if (! -d $results_dir);

# Sanity check version
open(VERSION, "ompi_info --version|") || die "Can't open ompi_info";
my $ver = <VERSION>;
close(VERSION);
chomp($ver);
die "Wrong version of OMPI: $ver"
    if ($ver ne $expected_ompi_ver);

# Sanity check that it's not a debugging build
open(DEBUG, "ompi_info --parsable|") || die "Can't open ompi_info";
while (<DEBUG>) {
    chomp;
    if (/debug/) {
        die "This is a debugging version: $_"
            if (! /:no$/);
    }
}
close(DEBUG);

# Run the Java tests
my @nprocs = qw/
1:1
1:2
1:4
1:8
1:16
2:2
4:4
8:8
16:16
/;
my @benchmarks = qw/
CG:C
CG:D
CGbuf:C
CGbuf:D
EP:C
EP:D
FT:C
IS:C
MG:C
MGopt:C
MG:D
MGopt:D
/;

chdir($java_npb_dir);
foreach my $nprocs (@nprocs) {
    my ($nservers, $np) = split(/:/, $nprocs);
    my @transports;
    if ($nservers == 1) {
        @transports = qw/shmem:sm,self/;
    } else {
        @transports = qw/tcp:tcp,self usnic:usnic,self/;
    }

    # If we are running with np=16, use mpi001..mpi016
    my $hosts;
    if (16 == $nservers) {
        $hosts = "-w mpi[001-016]";
    }

    foreach my $benchmark (@benchmarks) {
        my ($benchmark_name, $class) = split(/:/, $benchmark);
        my $np_save = $np;
        # The SP benchmarks require np to be a square
        if (substr($benchmark_name, 0, 2) eq "SP" && $np == 8) {
            $np = 9;
        }

        foreach my $transport (@transports) {
            my ($transport_name, $btl) = split(/:/, $transport);

            my $outfile = "$results_dir/java.$benchmark_name.$class.nservers=$nservers.np=$np.transport=$transport_name.slurm=%j.out";

            print "### Submitting $benchmark_name / $class / $transport_name / ns=$nservers / np=$np at " . localtime() . "\n";
            my $executable = "$java_npb_dir/NPB_MPJ/$benchmark_name.class";
            if (-r $executable) {
                system("sbatch -p $slurm_queue -N $nservers $hosts -J 'Java $benchmark_name $class $transport_name $nservers:$np' -o $outfile $script_dir/sbatch-java-runner.sh $benchmark_name $class $btl $np");
                print "+++ Submitted $executable\n";
            } else {
                print "--- SKIPPED: no executable $executable\n";
            }
        }

        $np = $np_save;
    }
}
