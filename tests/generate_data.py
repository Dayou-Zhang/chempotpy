import numpy as np
import sys
import chempotpy
import json

'''
This script generates reference values for automated testing.
Users will provide a file in the following format (pass the file name in the first command line argument):
    <system> <surface> <atom1> <atom2> <atom3> ...
    ...

For example:
    ALC ALC5m0_LEPS_ModelSurface A L C

The script will randomly sample one geometry in the 3D space, and evaluate
the energy (chempotpy.p) or the DPEM (chempotpy.u). The results will be saved
in data.json in the current directory. If data.json exists, the new record(s)
will be appended.
'''

def sample_points(n, r_min=1.0, r_max=2.5, max_attempts=10000):
    """
    Sample n points in ℝ³ such that:
      - p₀ = (0,0,0)
      - For i ≥ 1, each pᵢ is ≥ r_min from all previous points
        and ≤ r_max from at least one previous point.
    """
    points = [np.zeros(3)]
    for _ in range(1, n):
        for attempt in range(max_attempts):
            base = points[np.random.randint(len(points))]
            # random direction
            v = np.random.normal(size=3)
            v /= np.linalg.norm(v)
            d = np.random.uniform(r_min, r_max)
            candidate = base + d * v
            dists = np.linalg.norm(np.stack(points) - candidate, axis=1)
            if np.all(dists >= r_min):
                points.append(candidate)
                break
        else:
            raise RuntimeError(f"Failed to place point {_} after {max_attempts} attempts")
    return np.vstack(points)


try:
    with open('data.json') as f:
        data = json.load(f)
except FileNotFoundError:
    data = []

with open(sys.argv[1]) as f:
    for line in f:
        system, surface, *atoms = line.split()
        print('processing', system, surface, flush=True)
        coords = sample_points(len(atoms))
        geom = [[a, *xyz] for a, xyz in zip(atoms, coords)]
        try:
            result = chempotpy.p(system, surface, geom).tolist()
            data.append(dict(system=system, surface=surface, geom=geom, p=result))
        except AttributeError:
            result = chempotpy.u(system, surface, geom).tolist()
            data.append(dict(system=system, surface=surface, geom=geom, u=result))
with open('data.json', 'w') as f:
    json.dump(data, f, indent=2)
