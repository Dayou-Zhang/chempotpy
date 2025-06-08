#!/bin/bash

# Generate a .pyf signature file for the F2PY build system
# Only create wrappers for function pes() and dpem()
# Remove wrappers for block data and module
# Dayou Zhang, June 7, 2025

for i in $@
do
    dir=`dirname $i`
    name=`basename $i`
    (
        cd $dir
        python -m numpy.f2py $name only: pes dpem : -m ${name%.*} -h ${name%.*}.pyf
        sed -i '/^  *block data/,/^  *end block data/d;/^  *module/,/^  *end module/d' ${name%.*}.pyf
    )
done
