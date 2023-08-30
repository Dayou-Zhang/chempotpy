'''
C6H5SH
'''
import numpy as np
import sys

def intro():

    print("""
    SHORT List of potential energy surfaces for C6H5SH:
    P: potential energy, G: Gradient, D: Nonadiabatic coupling vector 
    U: diabatic potential energy matrix 
    UG: gradient of diabatic potential energy matrix
    This is listed at the end of description to show the availability.
    For example: P/G means both potential energy and gradient are available.

    Multi-State Surfaces:
    1.  C6H5SH_APRP:       multi-state surface of C6H5SH, 1-3 state,     P/G/D
    2.  C6H5SH_APRP_DPEM:  multi-state surface of C6H5SH, 1-3 state,     U/UG

    ==VERY IMPORTANT NOTICE==
    The atomic ordering specified in geom is required for C6H5SH_APRP
    Internal numbering of atoms:
         H11      H12
          \      /
           C5---C6
          /      \ 
    H10--C4       C1---S7
          \      /      \ 
           C3---C2       H13
          /      \ 
         H9       H8 

        """)

    return

def intro_detail():

    print("""
    DETAILED List of potential energy surfaces for C6H5SH:
    LEP: London–Eyring–Polanyi function
    VBMM: valence bond molecular mechanics
    PIP: permutationally invariant polynomials
    PIP-NN: permutationally invariant polynomials followed by neural network 
    DDNN: diabatization by deep neural network 
    APRP: anchor points reactive potential

    Multi-State Surfaces:
    1.  C6H5SH_APRP:       multi-state surface of C6H5SH, 1-3 state,
                           availability: potential energy, gradient, nonadiabatic coupling vector 
                           functional form: APRP + PIP
                           corresponding surface in POTLIB: phsh_aprp.f90
                           special emphsize on: C6H5SH → C6H5S + H
                           ref: L. Zhang, D. G. Truhlar, and S. Sun,
                                "Full-dimensional three-state potential energy
                                surfaces and state couplings for photodissociation
                                of thiophenol",
                                J. Chem. Phys. 151, 154306 (2019).

    ==VERY IMPORTANT NOTICE==
    The atomic ordering specified in geom is required for C6H5SH_APRP
    Internal numbering of atoms:
         H11      H12
          \      /
           C5---C6
          /      \ 
    H10--C4       C1---S7
          \      /      \ 
           C3---C2       H13
          /      \ 
         H9       H8 

        """)

    return


def check(system, surface, geom):

    n_carbon=0
    n_hydrogen=0
    n_sulfer=0
    natoms=len(geom)

    if natoms!=13:
        print("number of atoms not equal 13 for C6H5SH system")
        sys.exit()
    else:
        for iatom in range(natoms):
            if (geom[iatom][0]=='S'):
                n_sulfer=n_sulfer+1
            elif (geom[iatom][0]=='H'):
                 n_hydrogen=n_hydrogen+1
            elif (geom[iatom][0]=='C'):
                 n_carbon=n_carbon+1
        if n_sulfer!=1:
            print("number of Sulfer atoms not equal 1 for C6H5SH system")
            sys.exit()
        if n_hydrogen!=6:
            print("number of Hydrogen atoms not equal 6 for C6H5SH system")
            sys.exit()
        if n_carbon!=6:
            print("number of Carbon atoms not equal 6 for C6H5SH system")
            sys.exit()

    xyz=np.zeros((natoms,3))

    rank=np.copy(geom)
    for iatom in range(natoms):
        rank[iatom][1]=int(iatom)

    #for C6H5SH_APRP: input Cartesian should in order of CCCCCCSHHHHHHHH
    if surface=='C6H5SH_APRP' or surface=='C6H5SH_APRP_DPEM':
        for iatom in range(natoms):
            for idir in range(3):
                xyz[iatom][idir]=geom[iatom][idir+1]

    return xyz, rank


def reverse_order(v, g, d, geom, rank_ordered):

    natoms=len(geom)
    nstates=len(v)
    v_ro=np.zeros((nstates))
    g_ro=np.zeros((nstates,natoms,3))
    d_ro=np.zeros((nstates,nstates,natoms,3))

    v_ro = v
    for istate in range(nstates):
        for iatom in range(natoms):
            for idir in range(3):
                g_ro[istate][int(rank_ordered[iatom][1])][idir]=g[istate][iatom][idir]

    for istate in range(nstates):
        for jstate in range(nstates):
            for iatom in range(natoms):
                for idir in range(3):
                    d_ro[istate][jstate][int(rank_ordered[iatom][1])][idir]=d[istate][jstate][iatom][idir]


    return v_ro, g_ro, d_ro

def reverse_order_dpem(u, ug, geom, rank_ordered):

    natoms=len(geom)
    nstates=len(u)
    u_ro=np.zeros((nstates,nstates))
    ug_ro=np.zeros((nstates,nstates,natoms,3))

    u_ro = u

    for istate in range(nstates):
        for jstate in range(nstates):
            for iatom in range(natoms):
                for idir in range(3):
                    ug_ro[istate][jstate][int(rank_ordered[iatom][1])][idir]=ug[istate][jstate][iatom][idir]


    return u_ro, ug_ro
