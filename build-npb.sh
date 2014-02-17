#!/bin/sh

# C NPB
cd ~/svn/ompi-tests/NPB3.3.1/NPB3.3-MPI

echo Removing old binaries...
rm -rf bin
mkdir bin

do_make() {
    NPROCS=$1
    MAKE="make clean -k cg ep ft is mg sp NPROCS=$NPROCS"
    $MAKE CLASS=C
    $MAKE CLASS=D
    $MAKE CLASS=E
}

echo Building...
do_make 1
do_make 2
do_make 4
do_make 8
do_make 16

# Java NPB
cd ~/svn/ompi-tests/NPB_MPJ
make clean
make

