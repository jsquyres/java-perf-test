#!/bin/sh

# C NPB
cd ~/svn/ompi-tests/NPB3.3.1/NPB3.3-MPI

echo Removing old binaries...
rm -rf bin
mkdir bin

echo Building...
NPROCS=16
MAKE="make clean -k bt cg ep ft is lu mg sp NPROCS=$NPROCS"
$MAKE CLASS=A
$MAKE CLASS=B
$MAKE CLASS=C
$MAKE CLASS=D
$MAKE CLASS=E

# Java NPB
cd ~/svn/ompi-tests/NPB_MPJ
make clean
make

