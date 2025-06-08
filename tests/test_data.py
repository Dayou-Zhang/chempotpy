import numpy as np
import chempotpy
import json
import os
import pytest
import faulthandler
import multiprocessing

faulthandler.enable()

with open(os.path.join(os.path.dirname(__file__), 'data.json')) as f:
    data = json.load(f)

def run_in_subprocess(func, *args):
    def target(*args):
        return_dict, *args = args
        result = func(*args)
        return_dict[tuple(args[:2])] = result
    process = multiprocessing.Process(target=target, args=args)
    process.start()
    process.join()
    exitcode = process.exitcode
    process.close()
    assert exitcode == 0
    return_dict = args[0]
    result = return_dict[tuple(args[1:3])]
    return_dict.clear()
    return result

@pytest.mark.parametrize("d", data)
def test(d):
    manager = multiprocessing.Manager()
    return_dict = manager.dict()
    system = d['system']
    surface = d['surface']
    geom = d['geom']
    for api in ['p', 'u']:
        ref = d.get(api)
        if ref is None:
            continue
        result = run_in_subprocess(getattr(chempotpy, api), return_dict, system, surface, geom)
        assert np.allclose(ref, result), f'{api} not agree for {system} {surface}\nref:\n{ref}\ncalculated:\n{result}'

