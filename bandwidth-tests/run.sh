#!/bin/sh

date=`date '+%Y-%m-%d'`
if test ! -d $date; then
    mkdir $date
fi

networks="10.10.0.0/16,10.2.0.0/16"
cmd_base="mpirun -np 2 --mca btl_usnic_if_include $networks --mca btl_tcp_if_include $networks --bind-to core"

map_by="--map-by node"

java="java -Xmx64g"

doit() {
    echo === CMD: $*
    $*
}

# C bandwidth
doit $cmd_base $map_by \
    --mca btl usnic,self bandwidth \
    |& tee $date/bandwidth-c-usnic.txt
doit $cmd_base $map_by \
    --mca btl tcp,self bandwidth \
    |& tee $date/bandwidth-c-tcp.txt
doit $cmd_base --mca btl sm,self bandwidth \
    |& tee $date/bandwidth-c-sm.txt

# BandwidthArray
doit $cmd_base $map_by \
    --mca btl usnic,self $java BandwidthArray \
    |& tee $date/BandwidthArray-usnic.txt
doit $cmd_base $map_by \
    --mca btl tcp,self $java BandwidthArray \
    |& tee $date/BandwidthArray-tcp.txt
doit $cmd_base --mca btl sm,self $java BandwidthArray \
    |& tee $date/BandwidthArray-sm.txt

# BandwidthDirectBuffer
doit $cmd_base $map_by \
    --mca btl usnic,self $java BandwidthDirectBuffer \
    |& tee $date/BandwidthDirectBuffer-usnic.txt
doit $cmd_base $map_by \
    --mca btl tcp,self $java BandwidthDirectBuffer \
    |& tee $date/BandwidthDirectBuffer-tcp.txt
doit $cmd_base --mca btl sm,self $java BandwidthDirectBuffer \
    |& tee $date/BandwidthDirectBuffer-sm.txt

$DOTFILES/pushover java bandwidth tests done
