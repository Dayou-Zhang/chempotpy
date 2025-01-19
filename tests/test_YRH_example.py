import numpy as np
import chempotpy

def test_YRH():
    geom = [['Y', 0.8, 2.0, 1.0],
            ['H', 1.5, 1.0, 0.5],
            ['R', 2.6, 2.0, 2.0]]
    system = 'YRH'
    
    # Test p method
    name = 'YRH_LEPS_ModelSurface'
    v = chempotpy.p(system, name, geom)
    assert np.allclose(v, [0.52403335, 4.35878037])
    
    # Test pn method
    v, n = chempotpy.pn(system, name, geom)
    assert np.allclose(v, [0.52403335, 4.35878037])
    assert np.allclose(n[0], [[-1.8381639,  2.60747547,  1.29655704],
                              [ 1.88113227, -2.55665947, -1.22751572],
                              [-0.04296868, -0.0508161, -0.06904132]])
    
    # Test pg method
    v, g = chempotpy.pg(system, name, geom)
    assert np.allclose(v, [0.52403335, 4.35878037])
    assert np.allclose(g[0], [[-1.83816485,  2.60747969,  1.29655703],
                              [ 1.88113351, -2.55666357, -1.22751566],
                              [-0.04296867, -0.05081612, -0.06904137]])
    
    # Test pgd method
    v, g, d = chempotpy.pgd(system, name, geom)
    assert np.allclose(v, [0.52403335, 4.35878037])
    assert np.allclose(d[0][1], [[0.00047888, -0.00068238, -0.00034052],
                                 [-0.00091055,  0.00028886, -0.0002491 ],
                                 [0.00043167,  0.00039353,  0.00058962]])
    
    # Test u methods
    name = 'YRH_LEPS_ModelSurface_DPEM'
    u = chempotpy.u(system, name, geom)
    assert np.allclose(u, [[5.24033396e-01, 4.39128619e-04],
                           [4.39128619e-04, 4.35878032e+00]])
    
    u, ug = chempotpy.ug(system, name, geom)
    assert np.allclose(ug[0][0], [[-1.83816523,  2.60748023,  1.2965573 ],
                                  [ 1.88113426, -2.55666378, -1.22751544],
                                  [-0.04296903, -0.05081645, -0.06904187]])
    
    u, un = chempotpy.un(system, name, geom)
    assert np.allclose(un[0][0], [[-1.83816428,  2.60747602,  1.29655731],
                                  [ 1.88113302, -2.55665969, -1.22751549],
                                  [-0.04296904, -0.05081643, -0.06904182]])

