#!/usr/bin/env bash

set -e

sudo apt -qq install \
    libopenblas-dev \
    gfortran

python -m pip install -U pip
python -m pip install .
