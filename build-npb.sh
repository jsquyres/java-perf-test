#!/bin/sh

# C NPB
cd ~/svn/ompi-tests/NPB3.3.1/NPB3.3-MPI

echo Removing old binaries...
rm -rf bin
mkdir bin

banner_clean() {
    NPROCS=$1
    CLASS=$2

    cat <<EOF
******************************************************************************
** Cleaning
** NPROCS=$NPROCS
** CLASS=$CLASS
******************************************************************************
EOF
    MAKE="make -k clean NPROCS=$NPROCS"
    $MAKE CLASS=$CLASS
}

banner_build() {
    NPROCS=$1
    CLASS=$2

    cat <<EOF
==============================================================================
== Building
== NPROCS=$NPROCS
== CLASS=$CLASS
==============================================================================
EOF
    MAKE="make -k cg ep ft is mg sp NPROCS=$NPROCS"
    $MAKE CLASS=$CLASS
}

do_make() {
    NPROCS=$1
    banner_clean $NPROCS C
    banner_build $NPROCS C
    banner_clean $NPROCS D
    banner_build $NPROCS D
    banner_clean $NPROCS E
    banner_build $NPROCS E
}

echo Building...
do_make 1
do_make 2
do_make 4
do_make 8
do_make 9 # this is just for SP, which requires nprocs to be a square
do_make 16

# Java NPB
cd ~/svn/ompi-tests/NPB_MPJ
make clean
make

