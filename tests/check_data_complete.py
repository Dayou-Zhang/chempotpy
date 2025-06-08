import chempotpy
import os
import sys
import glob
import json

'''
This script checks if data.json contains test data for all surfaces.
It also reports test data that does not belong to any existing surface.
'''

root = os.path.dirname(chempotpy.__file__)
so_names = glob.glob(os.path.join(root, '*', '*.so'))
all_surfaces = set()
for path in so_names:
    path, surface = os.path.split(path)
    path, system = os.path.split(path)
    surface = surface[:surface.index('.')]
    all_surfaces.add((system, surface))

if sys.argv[1:]:
    datafile = sys.argv[1]
else:
    datafile = 'data.json'

with open(datafile) as f:
    data = json.load(f)
all_tests = set()
for d in data:
    all_tests.add((d['system'], d['surface']))

missing = all_surfaces.difference(all_tests)
extra = all_tests.difference(all_surfaces)

if missing:
    print('Missing surfaces in', datafile)
    for i in missing:
        print(*i, sep='\t')
    print()

if extra:
    print('Extra surfaces in', datafile)
    for i in extra:
        print(*i, sep='\t')
    print()
