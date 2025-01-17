'''
NH3OH
'''
import numpy as np
import sys

def intro():

    print("""
    SHORT List of potential energy surfaces for NH3OH:
    P: potential energy, G: Gradient, D: Nonadiabatic coupling vector 
    This is listed at the end of description to show the availability.
    For example: P/G means both potential energy and gradient are available. 

    Single-State Surfaces:
    1.  NH3OH_VBMM:           single-state surface of NH3OH, ground state,      P/G

    ==VERY IMPORTANT NOTICE==
    the automatic ordering of input coordinates follows the folloiwng rule:
    The H atom closest to O will be considered as the last H atom, i.e. the H in OH.


        """)

    return

def intro_detail():

    print("""
    DETAILED List of potential energy surfaces for NH3OH:
    LEP: London–Eyring–Polanyi function
    VBMM: valence bond molecular mechanics
    PIP: permutationally invariant polynomials
    PIP-NN: permutationally invariant polynomials followed by neural network 
    DDNN: diabatization by deep neural network 

    Single-State Surfaces:
    1.  NH3OH_VBMM:          single-state surface of NH3OH, ground state,
                              availability: potential energy
                              functional form: VBMM
                              corresponding surface in POTLIB: nh3oh-2013.f
                              special emphsize on: OH + NH3 reaction 
                              ref: M. Monge-Palacios, C. Rangel, and J. Espinosa-Garcia,
                                   "Ab initio based potential energy surface and kinetics 
                                   study of the OH + NH3 hydrogen abstraction reaction"
                                   J.Chem.Phys. 138, 084305 (2013).

    ==VERY IMPORTANT NOTICE==
    the automatic ordering of input coordinates follows the folloiwng rule:
    The H atom closest to O will be considered as the last H atom, i.e. the H in OH.

        """)

    return

def check(system, surface, geom):

    n_hydrogen=0
    n_oxygen=0
    n_nitrogen=0
    natoms=len(geom)

    if natoms!=6:
        print("number of atoms not equal 6 for NH3OH system")
        sys.exit()
    else:
        for iatom in range(natoms):
            if (geom[iatom][0]=='O'):
                 n_oxygen=n_oxygen+1
            elif (geom[iatom][0]=='H'):
                 n_hydrogen=n_hydrogen+1
            elif (geom[iatom][0]=='N'):
                 n_nitrogen=n_nitrogen+1
        if n_oxygen!=1:
            print("number of Oxygen atoms not equal 1 for NH3OH system")
            sys.exit()
        if n_hydrogen!=4:
            print("number of Hydrogen atoms not equal 4 for NH3OH system")
            sys.exit()
        if n_nitrogen!=1:
            print("number of Nitrogen atoms not equal 1 for NH3OH system")
            sys.exit()

    xyz=np.zeros((natoms,3))

    rank=np.copy(geom)
    for iatom in range(natoms):
        rank[iatom][1]=int(iatom)

    #for NH3OH_VBMM: input Cartesian should in order of HNHHOH
    if surface=='NH3OH_VBMM':
        geom_ordered=sorted(geom, key=lambda x: ("N", "H", "O").index(x[0]))
        rank_ordered=sorted(rank, key=lambda x: ("N", "H", "O").index(x[0]))
        for iatom in range(natoms):
            for idir in range(3):
                xyz[iatom][idir]=geom_ordered[iatom][idir+1]
        #now do re-ordering. 
        r=np.zeros((4))
        for i in range(4):
            r[i]=np.linalg.norm(xyz[i+1]-xyz[5])
        min_idx=np.argmin(r)
        #first, move the H attached to O to xyz[4]
        tmp_row=np.copy(xyz[4])
        xyz[4]=xyz[min_idx+1]
        xyz[min_idx+1]=tmp_row
        tmp_row=np.copy(rank_ordered[4])
        rank_ordered[4]=rank_ordered[min_idx+1]
        rank_ordered[min_idx+1]=tmp_row
        #next, switch the N and H position. 
        tmp_row=np.copy(xyz[1])
        xyz[1]=xyz[0]
        xyz[0]=tmp_row
        tmp_row=np.copy(rank_ordered[1])
        rank_ordered[1]=rank_ordered[0]
        rank_ordered[0]=tmp_row
        #next, switch the O and xyz[4] position. 
        tmp_row=np.copy(xyz[5])
        xyz[5]=xyz[4]
        xyz[4]=tmp_row
        tmp_row=np.copy(rank_ordered[5])
        rank_ordered[5]=rank_ordered[4]
        rank_ordered[4]=tmp_row

    return xyz, rank_ordered

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
