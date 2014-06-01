#!/bin/sh

benchmark=$1
btl=$2
np=$3

nservers=$SLURM_NNODES

cmd="mpirun --mca btl_usnic_if_include 10.1.0.0/16,10.2.0.0/16 --mca btl_tcp_if_exclude 127.0.0.0/8,10.4.0.0/16 --mca btl $btl --bind-to core --map-by node -np $np $benchmark"

cat <<EOF
Running C benchmark $benchmark, class $2, on $nservers servers (np=$np), $btl

SLURM job ID: $SLURM_JOB_ID

Servers:
`mpirun -np $np --map-by node hostname`

$cmd

Start: `date`
===============================================================================
EOF

eval $cmd

status=$?

cat <<EOF
===============================================================================
End: `date`
EOF
