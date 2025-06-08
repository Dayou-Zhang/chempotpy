import numpy as np
import chempotpy
import json
import os
import pytest

with open(os.path.join(os.path.dirname(__file__), 'data.json')) as f:
    data = json.load(f)

@pytest.mark.parametrize("d", data)
def test(d):
    system = d['system']
    surface = d['surface']
    geom = d['geom']
    for api in ['p', 'u']:
        ref = d.get(api)
        if ref is None:
            continue
        result = getattr(chempotpy, api)(system, surface, geom)
        assert np.allclose(ref, result), f'{api} not agree for {system} {surface}\nref:\n{ref}\ncalculated:\n{result}'

