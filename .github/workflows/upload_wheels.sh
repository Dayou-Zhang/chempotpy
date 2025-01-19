#!/usr/bin/env bash

set -e

version=$(grep -oP '__version__ = "\K([^"]+)' chempotpy/_version.py)
gh release create $version wheelhouse/*/* --target $GITHUB_REF_NAME
