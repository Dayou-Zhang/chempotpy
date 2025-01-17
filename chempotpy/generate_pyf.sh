#!/bin/bash

# Generate a .pyf signature file for the F2PY build system
# Only create wrappers for function pes() and dpem()
# Dayou Zhang, Jan 17, 2025

for i in $@
do
    dir=`dirname $i`
    name=`basename $i`
    (
        cd $dir
        python -m numpy.f2py $name only: pes dpem : -m ${name%.*} -h ${name%.*}.pyf
    )
done
