#!/bin/sh

mpicc bandwidth.c -O3 -o bandwidth
mpijavac BandwidthArray.java
mpijavac BandwidthDirectBuffer.java
