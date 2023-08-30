
!**********************************************************************
!   System:                     N3
!   Functional form:            permutation-invariant polynomials
!   Common name:                N3 4App (quartet A" state)
!   Number of derivatives:      1
!   Number of bodies:           3
!   Number of electronic surfaces: 1
!   Interface: Section-2
!
!   References:: Z. Varga and D. G. Truhlar, to be published in PCCP
!
!   Notes:    -Mixed-exponential-Gaussian (MEG)
!              variables are applied
!             -Diatomic potential contains
!              dispersion correction
!             -The following PESs (including this one) have 
!              a unified set of N2, O2, and NO pairwise potentials:
!                 N4_1A_MB-PIP-MEG3
!                 N2O2_3A_MB-PIP-MEG2
!                 N2O_3Ap_MB-PIP-MEG2
!                 N2O_3App_MB-PIP-MEG2
!                 PES_O3_1_1Ap_umn_v1
!                 PES_O3_1_1App_umn_v1
!                 PES_O3_1_3Ap_umn_v1
!                 PES_O3_1_3App_umn_v1
!                 PES_O3_1_5Ap_umn_v1
!                 PES_O3_1_5App_umn_v1
!                 PES_O3_2_1Ap_umn_v1
!                 PES_O3_2_3Ap_umn_v1
!                 PES_O3_2_5Ap_umn_v1
!                 PES_O4_quintet_umn_v1
!                 PES_O4_singlet_umn_v1
!                 PES_O4_triplet_umn_v2
!                 NO2_2Ap_MB-PIP-MEG
!                 NO2_4Ap_MB-PIP-MEG
!                 N3_4App_MB-PIP-MEG
!             
!
!   Input: X(3),Y(3),Z(3)               in unit of bohr
!   Output: E                           in unit of hartree
!   Output: dEdX(3),dEdY(3),dEdZ(3)     hartree/bohr
!**********************************************************************

      module N3_4App_ZV_par

! Conversion factors
! Cconv: bohr to Angstrom 
!        1 bohr = 0.52917721092 angstrom
! Econv: kcal/mol to hartree 
!        1 kcal/mol = 0.159360144 * 10^-2 hartree
! Gconv: kcal/(mol*Angstrom) to hartree/bohr
!        1 kcal mol^-1 angstrom^-1 = 0.843297564 * 10^-3 hartree/bohr

      double precision,parameter :: Cconv = 0.52917721092d0
      double precision,parameter :: Econv = 0.159360144d-2
      double precision,parameter :: Gconv = 0.843297564d-3

! Common variables
! R(3):         Interatomic bond distance
! rMs(6)		Array to store base terms
! rM(0:7) 		Array to store monomials
! P(0:66) 		Array to store polynomials
! B(1:56)     	Array to store basis functions
! dMsdR(3,3):   The derivative of base terms w.r.t. R
! dMdR(3,8):    The derivative of monomials w.r.t. R
! dPdR(3,67):   The derivative of basis functions w.r.t. R
! dVdR(3):      The derivative of V w.r.t. R
! dRdX(3,9):    The derivative of R w.r.t. X
! dBdR(3,56)	The derivative of B w.r.t. R 
  
      double precision :: R(3)
      double precision :: rMs(3),rM(0:7),P(0:66),B(56)
      double precision :: dMsdR(3,3),dMdR(3,0:7),dPdR(3,0:66)
      double precision :: dVdR(3),dRdX(3,9),dBdR(3,56)
  
! Nonlinear parameters:
! a(in Ang)
! ab (in Ang^2)
! ra (in Ang)
! and rb (in Ang)

      double precision,parameter :: a  = 1.280d0
      double precision,parameter :: ab = 2.100d0 
      double precision,parameter :: ra = 1.098d0  
      double precision,parameter :: rb = 1.098d0

! Reference energy of infinitely separated N2 + N in hartree (taken
! from CASPT2 calculations)
      double precision,parameter :: Eref = -163.65202806

! For N2 + N2 framework total diss. energy is 2*228.4 kcal/mol 
      double precision,parameter :: totdiss = 456.8d0

! Linear parameters optimized by the weighted-least square fitting
      double precision,parameter :: C(56) = (/ &
          -0.350120274856D+03  &
       ,   0.281093379749D+03  &
       ,   0.504222011875D+04  &
       ,   0.774595390008D+04  &
       ,  -0.153977000048D+05  &
       ,  -0.341980773453D+05  &
       ,   0.421291716912D+05  &
       ,  -0.118457148928D+06  &
       ,   0.485872504516D+05  &
       ,   0.126542076928D+06  &
       ,   0.479715536807D+05  &
       ,  -0.430825904195D+05  &
       ,   0.351123766345D+06  &
       ,  -0.393715206114D+05  &
       ,  -0.124625021693D+06  &
       ,  -0.263800314496D+06  &
       ,  -0.839917151081D+04  &
       ,   0.153566935802D+05  &
       ,  -0.167551509503D+05  &
       ,  -0.510531730539D+06  &
       ,   0.642719554456D+05  &
       ,   0.176493066952D+06  &
       ,   0.325900189079D+06  &
       ,  -0.808274097880D+05  &
       ,   0.929658499777D+05  &
       ,   0.922980021155D+05  &
       ,  -0.522086545864D+05  &
       ,   0.470098466709D+06  &
       ,  -0.704531576918D+05  &
       ,  -0.569186006731D+05  &
       ,  -0.133918206304D+06  &
       ,  -0.241532954576D+06  &
       ,  -0.767179058281D+06  &
       ,   0.322616894753D+06  &
       ,  -0.179596800582D+06  &
       ,  -0.428279161417D+06  &
       ,  -0.701871514181D+05  &
       ,   0.167945612096D+06  &
       ,  -0.281749185916D+06  &
       ,   0.490556308761D+05  &
       ,   0.959017744649D+04  &
       ,   0.518488791569D+05  &
       ,   0.101035720167D+06  &
       ,   0.842133667245D+05  &
       ,   0.656068569063D+05  &
       ,  -0.184873054675D+06  &
       ,   0.391252917892D+05  &
       ,   0.263542187638D+06  &
       ,   0.209985542260D+05  &
       ,  -0.891093615300D+05  &
       ,   0.789434896598D+05  &
       ,  -0.247967448188D+05  &
       ,  -0.242734300770D+04  &
       ,   0.154198371772D+04  &
       ,  -0.744339642914D+04  &
       ,  -0.185997161122D+05  &
      /)

      end module N3_4App_ZV_par

      subroutine pes(x,igrad,potential,gradient,dvec)

      use N3_4App_ZV_par
      implicit none
      ! number of electronic state
      integer, parameter :: nstates=1
      integer, parameter :: natoms=3
      integer, intent(in) :: igrad
      double precision, intent(in) :: x(natoms,3)
      double precision, intent(out) :: potential(nstates)
      double precision, intent(out) :: gradient(nstates,natoms,3)
      double precision, intent(out) :: dvec(nstates,nstates,natoms,3)

      double precision :: v, tx(9), tg(9)
      integer :: iatom, idir, j, istate
      !initialize 
      potential=0.d0
      gradient=0.d0
      dvec=0.d0

      do iatom=1,natoms
        do idir=1,3
          j=3*(iatom-1)+idir
          tx(j)=x(iatom, idir)
        enddo
      enddo
      tg=0.d0

      ! n3pes reads in angstrom for coordinates
      ! n3pes outputs in kcal/mol for energy
      call n3pes(tx,v,tg,igrad)

      ! add a reference energy, which is in hartree
      v=v/23.0609 ! +Eref*27.211386d0
      tg=tg/23.0609

      do istate=1,nstates
        potential(istate)=v
      enddo

      do istate=1,nstates
        do iatom=1,natoms
          do idir=1,3
            j=3*(iatom-1)+idir
            gradient(istate,iatom,idir)=tg(j)
          enddo
        enddo
      enddo

      dvec=0.d0

      endsubroutine

!**********************************************************************
! Local variables used in the N3 PES subroutine
! input coordinate matrix: X(9)in Ang
!                          N1: X(1),X(2),X(3)
!                          N2: X(4),X(5),X(6)
!                          N3: X(7),X(8),X(9)
! input flag: igrad     igrad=0 energy-only calculation
!                       igrad=1 energy + gradient
! output potential energy:      v    in kcal/mol
! output gradient:              dVdX in kcal/(mol*Ang)
!**********************************************************************
      subroutine n3pes(X,v,dVdX,igrad)
      use N3_4App_ZV_par
!**********************************************************************
! Subroutine to calculate the potential energy V and gradient dVdX
! for given Cartesian coordinates X(9)  
! R:            Interatomic bond distance (3)
! V:            Calculated potential energy
! dVdX:         The derivative of V w.r.t. X, dim(9)
! dVdR:         The derivative of V w.r.t. R, dim(3) 
! dPdR:         The derivative of basis functions w.r.t. R
!               dim(3*67)
! dMdR:         The derivative of monomials w.r.t. R
!               dim(3*8)
! dRdX:         The derivative of R w.r.t. X, dim(3*9)
!**********************************************************************

      integer i,igrad,j,nob,k
      double precision V
      double precision dVdX(9),X(9) 

! Read Cartesian coordinate from input file
      call coord_convt(X)

      if (igrad .le. 1) then
! Call subroutine Evv to evaluate potential energy V
        call evv(V)

        if (igrad .eq. 1) then
! Call EvdVdX to evaluate the derivatives of V w.r.t. X
          call evdvdx(X,dVdX)
        endif
      else
        write (*,*) 'Only energy and gradient are available'
      endif

      end subroutine n3pes

      subroutine coord_convt(X)
      use N3_4App_ZV_par
!**********************************************************************
!  Program to calculate the six interatomic distance 
!  by reading XYZ coordinate
!**********************************************************************

      integer i
      double precision X(9)
      
!**********************************************************************
!  Now, calculate the inter-atomic distance
!  r1 = r(N1N2)
!  r2 = r(N1N3)
!  r3 = r(N2N3)       
!**********************************************************************

      R(1)=Sqrt((X(4)-X(1))**2 + (X(5)-X(2))**2 + (X(6)-X(3))**2)
      R(2)=Sqrt((X(7)-X(1))**2 + (X(8)-X(2))**2 + (X(9)-X(3))**2)
      R(3)=Sqrt((X(4)-X(7))**2 + (X(5)-X(8))**2 + (X(6)-X(9))**2)

      return

      end subroutine coord_convt

      subroutine EvV(V)
      use N3_4App_ZV_par
!**********************************************************************
! Subroutine to evaluate V for given R 
! V(R) = C*P
! C:            Coefficients, stored in 'dim.inc' 
! P:            Basis functions evaluated for given R
! rMs:          rMs(3), six mixed exponential-Gaussian terms (MEG)
! a:            Nonlinear parameters in Morse terms(Angstrom)
! ab:           Nonlinear parameters in Gauss terms(Angstrom^2)
! re:           Equilibrium bond length(Angstrom)
! nop:          number of points
! nom:          number of monomials
! nob:          number of basis functions(polynomials)
! rM(0:7):      Array to store monomials
! P(0:66):      Array to store polynomials
! B(1:56):      Array to store basis functions
!**********************************************************************

      integer i,j,k
      double precision dist,dv2dr,V,V2
      double precision Vpf,dVpfdR(3)

! Calculate the six MEG terms for each point
      call evmorse

! Calculate the monomials for each point by using six MEG terms
      call evmono

! Calculate the polynomials (basis functions) by using monomials
      call evpoly

! Calculate the basis functions by removing unconnected and 2-body terms
      call evbas

! Initialized v to be totdiss
      v=totdiss
! Evaluate 2-body interactions
      do i=1,3
        dist=r(i)
        call ev2gm2(dist,v2,dv2dr,1,0)
        v=v+v2
      enddo

!! D3 dispersion correction is called inside the ev2gm2 !!
! Add D3 dispersion correction
!        call d3disp(r,disp,dispdr,0)
!        v=v+disp

! Evaluate V by taken the product of C and Basis function array
      do i=1,56
        v=v + c(i)*b(i)
      enddo
! Add a patch function to get the D3h structure
        call patchfunc(Vpf,dVpfdR,0)
        v=v - Vpf 


!      Write(*,9999) V 
! 9999 Format('The potential energy is ',F20.14,' kcal/mol')

      return

      end subroutine EvV

      subroutine EvdVdX(X,dVdX)
      use N3_4App_ZV_par
!**********************************************************************
! Subroutine to evaluate dRdX for given R and X 
! R:            R(3), 3 bond lengths
! X:            X(9), 9 Cartesian coordinates
! rM(0:7):      Array to store monomials
! P(0:66):      Array to store polynomials
! dVdX:         dVdX(9), derivatives of V w.r.t. Cartesian coordinates 
! dVdR:         dVdR(3), derivatives of V w.r.t. 3 bond lengths
! dRdX:         dRdX(3,9), derivatives of R(3) w.r.t. 9  
!               Cartesian coordinates
!**********************************************************************

      integer i,j
      double precision dVdX(9),X(9)

! Initialize dVdX
      do i=1,9
        dVdX(i)=0.0d0
      enddo

! Call EvdVdR to evaluate dVdR(3)
      Call evdvdr

! Call EvdRdX to evaluate dRdX(3,9)
      Call evdrdx(X)  

! Calculate dVdX by using chain rule: dV/dXi=(dV/dRj)*(dRj/dXi), 
! j = 1 to 3
      do i=1,9
        do j=1,3
          dVdX(i)=dVdX(i) + dVdR(j)*dRdX(j,i)
        enddo
      enddo

!      write(*,*) 'The 9 dVdX are:'
!      Write(*,9999) (dVdX(i),i=1,9) 
! 9999 Format(1x,3F15.8)

      return
      end subroutine EvdVdX

      subroutine EvMorse
      use N3_4App_ZV_par
!**********************************************************************
! mixed exponential-Gaussian terms = exp(-(r-ra)/a-(r-rb)^2/ab)
! ra:   reference bond length
! rb:   reference bond length
! a:    nonlinear parameter, unit Anstrom
! ab:   nonlinear parameter, unit Anstrom^2
!**********************************************************************      

      integer i
   
      do i=1,3
         rms(i)=Exp(-(r(i)-ra)/a-((r(i)-rb)**2.0d0)/ab)
      enddo

      end subroutine EvMorse

      subroutine EvMono
      use N3_4App_ZV_par
!**********************************************************************
!  The subroutine reads six MEG variables(X) and calculates the
!  monomials(M) that do not have usable decomposition.
!  For A4 with max. degree 10, the number of monomials is nom.
!**********************************************************************

      rm(0) = 1.0d0
      rm(1) = rms(3)
      rm(2) = rms(2)
      rm(3) = rms(1)
      rm(4) = rm(1)*rm(2)
      rm(5) = rm(1)*rm(3)
      rm(6) = rm(2)*rm(3)
      rm(7) = rm(1)*rm(6)

      return

      end subroutine EvMono

      subroutine EvPoly
      use N3_4App_ZV_par
!**********************************************************************
!  The subroutine reads monomials(m) and calculates the
!  permutation invariant polynomials(p)
!  For A4 with max. degree 10, the number of polynomials is nob.
!**********************************************************************

      p( 0) = rm(0)
      p( 1) = rm(1) + rm(2) + rm(3)
      p( 2) = rm(4) + rm(5) + rm(6)
      p( 3) = p( 1)*p( 1) - p( 2) - p( 2)
      p( 4) = rm(7)
      p( 5) = p( 1)*p( 2) - p( 4) - p( 4) - p( 4)
      p( 6) = p( 1)*p( 3) - p( 5)
      p( 7) = p( 1)*p( 4)
      p( 8) = p( 2)*p( 2) - p( 7) - p( 7)
      p( 9) = p( 2)*p( 3) - p( 7)
      p(10) = p( 1)*p( 6) - p( 9)
      p(11) = p( 2)*p( 4)
      p(12) = p( 3)*p( 4)
      p(13) = p( 1)*p( 8) - p(11)
      p(14) = p( 2)*p( 6) - p(12)
      p(15) = p( 1)*p(10) - p(14)
      p(16) = p( 4)*p( 4)
      p(17) = p( 4)*p( 5)
      p(18) = p( 4)*p( 6)
      p(19) = p( 2)*p( 8) - p(17)
      p(20) = p( 1)*p(13) - p(17) - p(19) - p(19)
      p(21) = p( 2)*p(10) - p(18)
      p(22) = p( 1)*p(15) - p(21)
      p(23) = p( 1)*p(16)
      p(24) = p( 4)*p( 8)
      p(25) = p( 3)*p(11) - p(23)
      p(26) = p( 4)*p(10)
      p(27) = p( 1)*p(19) - p(24)
      p(28) = p( 6)*p( 8) - p(23)
      p(29) = p( 2)*p(15) - p(26)
      p(30) = p( 1)*p(22) - p(29)
      p(31) = p( 2)*p(16)
      p(32) = p( 3)*p(16)
      p(33) = p( 1)*p(24) - p(31)
      p(34) = p( 4)*p(14)
      p(35) = p( 4)*p(15)
      p(36) = p( 2)*p(19) - p(33)
      p(37) = p( 3)*p(19) - p(31)
      p(38) = p( 8)*p(10) - p(32)
      p(39) = p( 2)*p(22) - p(35)
      p(40) = p( 1)*p(30) - p(39)
      p(41) = p( 4)*p(16)
      p(42) = p( 4)*p(17)
      p(43) = p( 4)*p(19)
      p(44) = p( 6)*p(16)
      p(45) = p( 4)*p(20)
      p(46) = p( 4)*p(21)
      p(47) = p( 4)*p(22)
      p(48) = p( 1)*p(36) - p(43)
      p(49) = p( 1)*p(37) - p(45) - p(48)
      p(50) = p( 8)*p(15) - p(44)
      p(51) = p( 2)*p(30) - p(47)
      p(52) = p( 1)*p(40) - p(51)
      p(53) = p( 1)*p(41)
      p(54) = p( 4)*p(24)
      p(55) = p( 3)*p(31) - p(53)
      p(56) = p( 1)*p(43) - p(54)
      p(57) = p(10)*p(16)
      p(58) = p( 4)*p(28)
      p(59) = p( 4)*p(29)
      p(60) = p( 4)*p(30)
      p(61) = p( 2)*p(36) - p(56)
      p(62) = p( 3)*p(36) - p(54)
      p(63) = p(10)*p(19) - p(53)
      p(64) = p( 8)*p(22) - p(57)
      p(65) = p( 2)*p(40) - p(60)
      p(66) = p( 1)*p(52) - p(65)

      return

      end subroutine EvPoly

      subroutine evbas
      use N3_4App_ZV_par
!**********************************************************************
!  The subroutine eliminate the 2-body terms in Bowman's approach
!**********************************************************************
    
      integer i
      double precision b1(67) 

! Pass P(0:66) to BM1(1:67)
      do i=1,67
        b1(i)=p(i-1)
      enddo

! Remove unconnected terms and 2-body terms and pass to B(1:430)
      b(1)=b1(3)

      do i=2,3
        b(i)=b1(i+3)
      enddo

      do i=4,6
        b(i)=b1(i+4)
      enddo

      do i=7,10
        b(i)=b1(i+5)
      enddo

      do i=11,16
        b(i)=b1(i+6)
      enddo

      do i=17,23
        b(i)=b1(i+7)
      enddo

      do i=24,32
        b(i)=b1(i+8)
      enddo

      do i=33,43
        b(i)=b1(i+9)
      enddo

      do i=44,56
        b(i)=b1(i+10)
      enddo

      return

      end subroutine evbas

      subroutine ev2gm2(r,v,grad,imol,igrad)
!**********************************************************************
!
! Compute the diatomic potential of ground-state N2 (singlet)
!
! Input:  r      interatomic distance in Angstrom
!         imol   1 - stands for N2 for N4 PES
!         igrad  1 - gradient is calculated
!                0 - gradient is not calculated
! Output: V      potential in kcal/mol
!         grad   gradient (kcal/mol)/Angstrom
!
!**********************************************************************
      implicit none

      integer,intent(in) :: imol, igrad
      double precision :: r
      double precision :: v, grad
      double precision :: re, de, as(0:6)
      double precision :: y, fy, u
      double precision :: dfdy,rr,dydr,dfdr
      integer :: k
! Dispersion variables
      double precision :: dist(1),disp,dispdr(1)

! Modified parameters for D3(BJ)
        re=1.098d0
        de=  224.9157d0 ! 228.4d0 
        as(0) =  2.7599278840949d0  ! 2.71405774451d0
        as(1) =  0.2318898277373d0  ! 1.32757649829d-1
        as(2) =  0.1908422945648d0  ! 2.66756890408d-1
        as(3) = -0.2727504034613d0  ! 1.95350725241d-1
        as(4) = -0.5345112219335d0  !-4.08663480982d-1
        as(5) =  1.0857331617073d0  ! 3.92451705557d-1
        as(6) =  1.6339897930305d0  ! 1.13006674877d0

      v=0.d0

      y=(r*r*r*r - re*re*re*re)/(r*r*r*r + re*re*re*re)

      fy = as(0) + as(1)*y + as(2)*y*y + as(3)*y*y*y + as(4)*y*y*y*y &
         + as(5)*y*y*y*y*y + as(6)*y*y*y*y*y*y

      u=exp(-fy*(r-re))

      v=de*(1.0d0-u)*(1.0d0-u)-de


! Add D3 dispersion correction
        dist(1)=r
        call d3disp(dist,disp,dispdr,0,imol)
        v=v+disp

! Compute the gradient if needed
      if (igrad.eq.1) then
       grad=0.d0

       dfdy = as(1) + 2.0d0*as(2)*y + 3.0d0*as(3)*y*y &
            + 4.0d0*as(4)*y*y*y + 5.0d0*as(5)*y*y*y*y &
            + 6.0d0*as(6)*y*y*y*y*y
        rr = r*r*r*r + re*re*re*re
        dydr = 8.0d0*r*r*r*re*re*re*re/(rr*rr)
        dfdr = dfdy*dydr
        grad = 2.0d0*de*(1-u)*u*(dfdr*(r-re)+fy)

! Add analytical gradient of D3 dispersion correction
        call d3disp(dist,disp,dispdr,1,imol)
        grad= grad + dispdr(1)

      endif
      return
      end subroutine ev2gm2

       subroutine patchfunc(Vpf,dVpfdR,igrad)
       use N3_4App_ZV_par
!**********************************************************************
!      A patch function to correct the barrier between 2A1 and 2B1
!      minima of the doublet surface
!**********************************************************************
       integer igrad
       integer i,j
       double precision Vpf
       double precision tmp1,tmp2,tmp3
       double precision tmp(3,3)
       double precision dVpfdR(3)
       double precision rfx,afx,v0,b1,b2
       double precision a1(3),aa(3)

       v0 = 17.0d0  ! in kcal/mol
       b1 = 3.4d0 ! in Ang^-1
       b2 = 6.8d0 ! in rad^-1
! rfx is the bond length of D3h geometry
       rfx = 1.532d0  ! in Ang
! afx is 60 deg
       afx = 1.047197551d0  ! in rad

       aa(1)= (( r(1)**2 - r(2)**2 - r(3)**2 )/(-2.0d0*r(2)*r(3)))
       aa(2)= (( r(2)**2 - r(1)**2 - r(3)**2 )/(-2.0d0*r(1)*r(3)))
       aa(3)= (( r(3)**2 - r(1)**2 - r(2)**2 )/(-2.0d0*r(1)*r(2)))

       do i=1,3
        if(aa(i).gt.(1.0d0-1.0d-10)) then
         aa(i)=(1.0d0-1.0d-10)
        else if (aa(i).lt.-(1.0d0-1.0d-10)) then
         aa(i)=-(1.0d0-1.0d-10)
        endif
       enddo

       a1(1)= acos(aa(1))
       a1(2)= acos(aa(2))
       a1(3)= acos(aa(3))

       tmp1=-(b1*(r(1)-rfx))**2 -(b1*(r(2)-rfx))**2 -(b2*(a1(3)-afx))**2
       tmp2=-(b1*(r(1)-rfx))**2 -(b1*(r(3)-rfx))**2 -(b2*(a1(2)-afx))**2
       tmp3=-(b1*(r(2)-rfx))**2 -(b1*(r(3)-rfx))**2 -(b2*(a1(1)-afx))**2

       Vpf = v0*( Exp(tmp1) + Exp(tmp2) + Exp(tmp3) )

       if (igrad .eq. 1) then

       tmp=0.0d0

       tmp(1,1) = 2.0d0*b2**2*(1.0d0/r(2)-cos(a1(3))/r(1))*(a1(3)-afx)
       tmp(1,1) = tmp(1,1)/sqrt(1.0d0-(cos(a1(3)))**2)
       tmp(1,1) = tmp(1,1) -2.0d0*b1**2*(r(1)-rfx)

       tmp(1,2) = 2.0d0*b2**2*(1.0d0/r(3)-cos(a1(2))/r(1))*(a1(2)-afx)
       tmp(1,2) = tmp(1,2)/sqrt(1.0d0-(cos(a1(2)))**2)
       tmp(1,2) = tmp(1,2) -2.0d0*b1**2*(r(1)-rfx)

       tmp(1,3) = -(2.0d0*b2**2*r(1)*(a1(1)-afx))
       tmp(1,3) = tmp(1,3)/(r(2)*r(3)*sqrt(1.0d0-(cos(a1(1)))**2))

       tmp(2,1) = 2.0d0*b2**2*(1.0d0/r(1)-cos(a1(3))/r(2))*(a1(3)-afx)
       tmp(2,1) = tmp(2,1)/sqrt(1.0d0-(cos(a1(3)))**2)
       tmp(2,1) = tmp(2,1) -2.0d0*b1**2*(r(2)-rfx)

       tmp(2,2) = -(2.0d0*b2**2*r(2)*(a1(2)-afx))
       tmp(2,2) = tmp(2,2)/(r(1)*r(3)*sqrt(1.0d0-(cos(a1(2)))**2))

       tmp(2,3) = 2.0d0*b2**2*(1.0d0/r(3)-cos(a1(1))/r(2))*(a1(1)-afx)
       tmp(2,3) = tmp(2,3)/sqrt(1.0d0-(cos(a1(1)))**2)
       tmp(2,3) = tmp(2,3) -2.0d0*b1**2*(r(2)-rfx)

       tmp(3,1) = -(2.0d0*b2**2*r(3)*(a1(3)-afx))
       tmp(3,1) = tmp(3,1)/(r(1)*r(2)*sqrt(1.0d0-(cos(a1(3)))**2))

       tmp(3,2) = 2.0d0*b2**2*(1.0d0/r(1)-cos(a1(2))/r(3))*(a1(2)-afx)
       tmp(3,2) = tmp(3,2)/sqrt(1.0d0-(cos(a1(2)))**2)
       tmp(3,2) = tmp(3,2) -2.0d0*b1**2*(r(3)-rfx)

       tmp(3,3) = 2.0d0*b2**2*(1.0d0/r(2)-cos(a1(1))/r(3))*(a1(1)-afx)
       tmp(3,3) = tmp(3,3)/sqrt(1.0d0-(cos(a1(1)))**2)
       tmp(3,3) = tmp(3,3) -2.0d0*b1**2*(r(3)-rfx)

       do i=1,3
        do j=1,3
         if(abs(tmp(i,j)).gt.10d20) then
          if(tmp(i,j).gt.10d20) then
           tmp(i,j)=10d10
          else if (tmp(i,j).lt.-10d20) then
           tmp(i,j)=-10d10
          endif
         endif
         if(isnan(tmp(i,j))) then
         tmp(i,j) = 0.0d0
         endif
        enddo
       enddo

       dVpfdR(1) = v0*(tmp(1,1)*Exp(tmp1) + tmp(1,2)*Exp(tmp2) + &
                   tmp(1,3)*Exp(tmp3))
       dVpfdR(2) = v0*(tmp(2,1)*Exp(tmp1) + tmp(2,2)*Exp(tmp2) + &
                   tmp(2,3)*Exp(tmp3))
       dVpfdR(3) = v0*(tmp(3,1)*Exp(tmp1) + tmp(3,2)*Exp(tmp2) + &
                   tmp(3,3)*Exp(tmp3))
!      do i=1,3
!       if(isnan(dVpfdR(i))) then
!        dVpfdR(i) = 0.0d0
!       endif
!      enddo

!      write(*,*) "dVpfdR(1) ",dVpfdR(1)
!      write(*,*) "dVpfdR(2) ",dVpfdR(2)
!      write(*,*) "dVpfdR(3) ",dVpfdR(3)


       endif

       end subroutine patchfunc

      subroutine EvdVdR
      use N3_4App_ZV_par
!**********************************************************************
! Subroutine to evaluate dVdR for given R 
! dVdR = dV2dR + C*dBdR
! C:            Coefficients, stored in 'dim.inc' 
! P:            Basis functions evaluated for given R
! M:            Monomials evaluated for given R
! dV2dR:        Gradient of 2-body interactions
! dMsdR:        dMsdR(3,3), 3 MEG terms w.r.t. 3 bond lengths
! dMdR:         dMdR(3,nom), nom monomials w.r.t.3 bond length
! dPdR:         dPdR(3,nob), nop polynomial basis functions 
!               w.r.t. 3 bond lengths
! nom:          number of monomials
! nob:          number of basis functions(polynomials)
! M(nom):       Array to store monomials
! P(nob):       Array to store polynomials
!**********************************************************************
     
      integer i,j
      double precision dist,v2,dv2dr
      double precision Vpf,dVpfdR(3)

! Initialize dVdR(3)
      do i=1,3
        dVdR(i)=0.0d0
      enddo

! Add dV2dR(i) to dVdR
      do i=1,3
        dist=R(i)
        call ev2gm2(dist,v2,dv2dr,1,1)
        dVdR(i)=dv2dr
      enddo

!! D3 dispersion correction is called inside the ev2gm2 !!
! Add numerical gradient of D3 dispersion correction
!     do i=1,3
!       call d3disp(R,disp,dispdr,1)
!       dVdR(i)= dVdR(i) + dispdr(i)
!     enddo

! Calculate dMEG/dr(3,3) for given R(3)
      call evdmsdr

! Calculate the monomials for each point by using six MEG terms
      call evdmdr

! Calculate the polynomials by using monomials
      call evdpdr 

! Remove 2-body interactions and unconnected terms from polynomials
      call evdbdr

! Evaluate dVdR(3) by taken the product of C(j) and dPdR(i,j)
      do i=1,3      
        do j=1,56
         dVdR(i)=dVdR(i) + c(j)*dBdR(i,j)
        enddo
      enddo

! Subtract the derivative of patch function to get the D3h correction
       call patchfunc(Vpf,dVpfdR,1)

       do i=1,3 
       dVdR(i) = dVdR(i) - dVpfdR(i)
       enddo

      return
      end subroutine EvdVdR

      subroutine EvdRdX(X)
      use N3_4App_ZV_par
!**********************************************************************
! Subroutine to evaluate dRdX for given R and X 
! R:            R(3), 3 bond lengths
! X:            X(9), 9 Cartesian coordinates
! 
! dMdR:         dMdR(3,nom), nom monomials w.r.t.3 bond length
! dPdR:         dPdR(3,nob), nop polynomial basis functions 
!               w.r.t. 3 bond lengths
! M(nom):       Array to store monomials
! P(nob):       Array to store polynomials
!**********************************************************************

      integer i,j
      double precision X(9)

! Initialize dRdX(3,9)
      do i=1,3
        do j=1,9
          dRdX(i,j)=0.0d0
        enddo
      enddo

! Start to calculate the non-zero dRdX
! dr1dx
      dRdX(1,1)=(x(1)-x(4))/r(1)
      dRdX(1,2)=(x(2)-x(5))/r(1)
      dRdX(1,3)=(x(3)-x(6))/r(1)
      dRdX(1,4)=-dRdX(1,1)
      dRdX(1,5)=-dRdX(1,2)
      dRdX(1,6)=-dRdX(1,3)

! dr2dx
      dRdX(2,1)=(x(1)-x(7))/r(2)
      dRdX(2,2)=(x(2)-x(8))/r(2)
      dRdX(2,3)=(x(3)-x(9))/r(2)
      dRdX(2,7)=-dRdX(2,1)
      dRdX(2,8)=-dRdX(2,2)
      dRdX(2,9)=-dRdX(2,3)

! dr3dx
      dRdX(3,4)=(x(4)-x(7))/r(3)
      dRdX(3,5)=(x(5)-x(8))/r(3)
      dRdX(3,6)=(x(6)-x(9))/r(3)
      dRdX(3,7)=-dRdX(3,4)
      dRdX(3,8)=-dRdX(3,5)
      dRdX(3,9)=-dRdX(3,6)
! Finish the calculation of non-zero dRdX

      return

      end subroutine EvdRdX

      subroutine EvdMsdR
      use N3_4App_ZV_par
!**********************************************************************
! Subroutine to evaluate the derivatives of MEG term X
! w.r.t. interatomic distance R(3)
! dmsdR:        Local variables, dirm(3,3)
! a:            Nonlinear pamameter(Angstrom)
! ab:           Nonlinear pamameter(Angstrom^2)
! ra:           reference bond length(Angstrom)
! rb:           reference bond length(Angstrom)
!**********************************************************************

      integer i,j

! Initialize dmsdr
      do i=1,3
        do j=1,3
          dmsdr(i,j)=0.0d0
        enddo
      enddo

! MEG term dmsdr = exp(-(r-re)/a-(r-re)^2/ab)
! dmsdr(i,j)=0  i!=j

      do i=1,3
         dmsdr(i,i)=(-2.0d0*(r(i)-rb)/ab-1/a) &
      * Exp(-(r(i)-ra)/a-((r(i)-rb)**2.0d0)/ab)
      enddo 

      return

      end subroutine EvdMsdR

      subroutine EvdMdR
      use N3_4App_ZV_par
!**********************************************************************
!  The subroutine reads M(nom) and dMSdR(3,3) and calculates the
!  dMdR(3,nom) that do not have usable decomposition.
!  For A4 with max. degree 10, the number of monomials is nom.
!**********************************************************************

      integer i

      do i=1,3
      dmdr(i,0) = 0.0d0
      dmdr(i,1) = dmsdr(i,3)
      dmdr(i,2) = dmsdr(i,2)
      dmdr(i,3) = dmsdr(i,1)
      dmdr(i,4) = dmdr(i,1)*rm(2) + rm(1)*dmdr(i,2)
      dmdr(i,5) = dmdr(i,1)*rm(3) + rm(1)*dmdr(i,3)
      dmdr(i,6) = dmdr(i,2)*rm(3) + rm(2)*dmdr(i,3)
      dmdr(i,7) = dmdr(i,1)*rm(6) + rm(1)*dmdr(i,6)
      enddo

      return

      end subroutine EvdMdR

      subroutine EvdPdr
      use N3_4App_ZV_par
!**********************************************************************
!  The subroutine reads monomials(m) and calculates the
!  permutation invariant polynomials(p)
!  For A4 with max. degree 10, the number of polynomials is nob.
!**********************************************************************

      integer i

      do i=1,3
      dpdr(i, 0) = dmdr(i,0)
      dpdr(i, 1) = dmdr(i,1) + dmdr(i,2) + dmdr(i,3)
      dpdr(i, 2) = dmdr(i,4) + dmdr(i,5) + dmdr(i,6)
      dpdr(i, 3) = dpdr(i, 1)*p( 1) + p( 1)*dpdr(i, 1) - dpdr(i, 2) &
       - dpdr(i, 2)
      dpdr(i, 4) = dmdr(i,7)
      dpdr(i, 5) = dpdr(i, 1)*p( 2) + p( 1)*dpdr(i, 2) - dpdr(i, 4) &
       - dpdr(i, 4) - dpdr(i, 4)
      dpdr(i, 6) = dpdr(i, 1)*p( 3) + p( 1)*dpdr(i, 3) - dpdr(i, 5)
      dpdr(i, 7) = dpdr(i, 1)*p( 4) + p( 1)*dpdr(i, 4)
      dpdr(i, 8) = dpdr(i, 2)*p( 2) + p( 2)*dpdr(i, 2) - dpdr(i, 7) &
       - dpdr(i, 7)
      dpdr(i, 9) = dpdr(i, 2)*p( 3) + p( 2)*dpdr(i, 3) - dpdr(i, 7)
      dpdr(i,10) = dpdr(i, 1)*p( 6) + p( 1)*dpdr(i, 6) - dpdr(i, 9)
      dpdr(i,11) = dpdr(i, 2)*p( 4) + p( 2)*dpdr(i, 4)
      dpdr(i,12) = dpdr(i, 3)*p( 4) + p( 3)*dpdr(i, 4)
      dpdr(i,13) = dpdr(i, 1)*p( 8) + p( 1)*dpdr(i, 8) - dpdr(i,11)
      dpdr(i,14) = dpdr(i, 2)*p( 6) + p( 2)*dpdr(i, 6) - dpdr(i,12)
      dpdr(i,15) = dpdr(i, 1)*p(10) + p( 1)*dpdr(i,10) - dpdr(i,14)
      dpdr(i,16) = dpdr(i, 4)*p( 4) + p( 4)*dpdr(i, 4)
      dpdr(i,17) = dpdr(i, 4)*p( 5) + p( 4)*dpdr(i, 5)
      dpdr(i,18) = dpdr(i, 4)*p( 6) + p( 4)*dpdr(i, 6)
      dpdr(i,19) = dpdr(i, 2)*p( 8) + p( 2)*dpdr(i, 8) - dpdr(i,17)
      dpdr(i,20) = dpdr(i, 1)*p(13) + p( 1)*dpdr(i,13) - dpdr(i,17) &
       - dpdr(i,19) - dpdr(i,19)
      dpdr(i,21) = dpdr(i, 2)*p(10) + p( 2)*dpdr(i,10) - dpdr(i,18)
      dpdr(i,22) = dpdr(i, 1)*p(15) + p( 1)*dpdr(i,15) - dpdr(i,21)
      dpdr(i,23) = dpdr(i, 1)*p(16) + p( 1)*dpdr(i,16)
      dpdr(i,24) = dpdr(i, 4)*p( 8) + p( 4)*dpdr(i, 8)
      dpdr(i,25) = dpdr(i, 3)*p(11) + p( 3)*dpdr(i,11) - dpdr(i,23)
      dpdr(i,26) = dpdr(i, 4)*p(10) + p( 4)*dpdr(i,10)
      dpdr(i,27) = dpdr(i, 1)*p(19) + p( 1)*dpdr(i,19) - dpdr(i,24)
      dpdr(i,28) = dpdr(i, 6)*p( 8) + p( 6)*dpdr(i, 8) - dpdr(i,23)
      dpdr(i,29) = dpdr(i, 2)*p(15) + p( 2)*dpdr(i,15) - dpdr(i,26)
      dpdr(i,30) = dpdr(i, 1)*p(22) + p( 1)*dpdr(i,22) - dpdr(i,29)
      dpdr(i,31) = dpdr(i, 2)*p(16) + p( 2)*dpdr(i,16)
      dpdr(i,32) = dpdr(i, 3)*p(16) + p( 3)*dpdr(i,16)
      dpdr(i,33) = dpdr(i, 1)*p(24) + p( 1)*dpdr(i,24) - dpdr(i,31)
      dpdr(i,34) = dpdr(i, 4)*p(14) + p( 4)*dpdr(i,14)
      dpdr(i,35) = dpdr(i, 4)*p(15) + p( 4)*dpdr(i,15)
      dpdr(i,36) = dpdr(i, 2)*p(19) + p( 2)*dpdr(i,19) - dpdr(i,33)
      dpdr(i,37) = dpdr(i, 3)*p(19) + p( 3)*dpdr(i,19) - dpdr(i,31)
      dpdr(i,38) = dpdr(i, 8)*p(10) + p( 8)*dpdr(i,10) - dpdr(i,32)
      dpdr(i,39) = dpdr(i, 2)*p(22) + p( 2)*dpdr(i,22) - dpdr(i,35)
      dpdr(i,40) = dpdr(i, 1)*p(30) + p( 1)*dpdr(i,30) - dpdr(i,39)
      dpdr(i,41) = dpdr(i, 4)*p(16) + p( 4)*dpdr(i,16)
      dpdr(i,42) = dpdr(i, 4)*p(17) + p( 4)*dpdr(i,17)
      dpdr(i,43) = dpdr(i, 4)*p(19) + p( 4)*dpdr(i,19)
      dpdr(i,44) = dpdr(i, 6)*p(16) + p( 6)*dpdr(i,16)
      dpdr(i,45) = dpdr(i, 4)*p(20) + p( 4)*dpdr(i,20)
      dpdr(i,46) = dpdr(i, 4)*p(21) + p( 4)*dpdr(i,21)
      dpdr(i,47) = dpdr(i, 4)*p(22) + p( 4)*dpdr(i,22)
      dpdr(i,48) = dpdr(i, 1)*p(36) + p( 1)*dpdr(i,36) - dpdr(i,43)
      dpdr(i,49) = dpdr(i, 1)*p(37) + p( 1)*dpdr(i,37) - dpdr(i,45) &
       - dpdr(i,48)
      dpdr(i,50) = dpdr(i, 8)*p(15) + p( 8)*dpdr(i,15) - dpdr(i,44)
      dpdr(i,51) = dpdr(i, 2)*p(30) + p( 2)*dpdr(i,30) - dpdr(i,47)
      dpdr(i,52) = dpdr(i, 1)*p(40) + p( 1)*dpdr(i,40) - dpdr(i,51)
      dpdr(i,53) = dpdr(i, 1)*p(41) + p( 1)*dpdr(i,41)
      dpdr(i,54) = dpdr(i, 4)*p(24) + p( 4)*dpdr(i,24)
      dpdr(i,55) = dpdr(i, 3)*p(31) + p( 3)*dpdr(i,31) - dpdr(i,53)
      dpdr(i,56) = dpdr(i, 1)*p(43) + p( 1)*dpdr(i,43) - dpdr(i,54)
      dpdr(i,57) = dpdr(i,10)*p(16) + p(10)*dpdr(i,16)
      dpdr(i,58) = dpdr(i, 4)*p(28) + p( 4)*dpdr(i,28)
      dpdr(i,59) = dpdr(i, 4)*p(29) + p( 4)*dpdr(i,29)
      dpdr(i,60) = dpdr(i, 4)*p(30) + p( 4)*dpdr(i,30)
      dpdr(i,61) = dpdr(i, 2)*p(36) + p( 2)*dpdr(i,36) - dpdr(i,56)
      dpdr(i,62) = dpdr(i, 3)*p(36) + p( 3)*dpdr(i,36) - dpdr(i,54)
      dpdr(i,63) = dpdr(i,10)*p(19) + p(10)*dpdr(i,19) - dpdr(i,53)
      dpdr(i,64) = dpdr(i, 8)*p(22) + p( 8)*dpdr(i,22) - dpdr(i,57)
      dpdr(i,65) = dpdr(i, 2)*p(40) + p( 2)*dpdr(i,40) - dpdr(i,60)
      dpdr(i,66) = dpdr(i, 1)*p(52) + p( 1)*dpdr(i,52) - dpdr(i,65)
      enddo

      return

      end subroutine EvdPdR

      subroutine evdbdr
      use N3_4App_ZV_par
!**********************************************************************
!  The subroutine eliminate the 2-body terms in Bowman's approach
!**********************************************************************

      integer i,j
      double precision db1dr(3,67) 

! Pass P(3,0:66) to BM1(3,1:67)
      do j=1,3
      do i=1,67
        db1dr(j,i)=dpdr(j,i-1)
      enddo
      enddo

! Remove unconnected terms and 2-body terms and pass to B(1:56)
      do j=1,3

        dbdr(j,1)=db1dr(j,3)

      do i=2,3
        dbdr(j,i)=db1dr(j,i+3)
      enddo

      do i=4,6
        dbdr(j,i)=db1dr(j,i+4)
      enddo

      do i=7,10
        dbdr(j,i)=db1dr(j,i+5)
      enddo

      do i=11,16
        dbdr(j,i)=db1dr(j,i+6)
      enddo

      do i=17,23
        dbdr(j,i)=db1dr(j,i+7)
      enddo

      do i=24,32
        dbdr(j,i)=db1dr(j,i+8)
      enddo

      do i=33,43
        dbdr(j,i)=db1dr(j,i+9)
      enddo

      do i=44,56
        dbdr(j,i)=db1dr(j,i+10)
      enddo

      enddo

      return

      end subroutine evdbdr

      subroutine d3disp(dist,disp,dispdr,igrad,imol)
!**********************************************************************
! Dispersion correction based on Grimme's D3(BJ) calculation for
! diatomic pairs
!
! Several subroutines of DFTD3 V3.1 Rev 1 by Grimme were merged into 
! subroutine edisp and they have been heavily modified to calculate
! only dispersion energy corrections that are needed.
!
! S. Grimme, J. Antony, S. Ehrlich and H. Krieg
! J. Chem. Phys, 132 (2010), 154104
! and 
! S. Grimme, S. Ehrlich and L. Goerigk, J. Comput. Chem, 32 (2011),
! 1456-1465
!
! The C6 values are fixed.
!
!**********************************************************************

      double precision cn(2),s6,s8,rs6,rs8
      double precision dist(1), e6(1), e8(1), disp, dispdr(1), c6(2)
      double precision e6dr(1),e8dr(1)
      integer iz(2), mxc(94), i, j, igrad
      double precision c6ab(94,94,5,5,3)
      double precision r2r4(94)
      double precision autoang,autokcal
      integer imol

      autoang =0.52917726d0
      autokcal=627.509541d0

! Generalized parameters for BJ damping from P. Verma, B. Wang, 
! L. E. Fernandez, and D. G. Truhlar, J. Phys. Chem. A 121, 2855 (2017)
      s6= 1.0d0
      s8= 2.0d0
      rs6= 0.5299d0
      rs8= 2.20d0

      do i=1,1
      dist(i)=dist(i)/autoang
      enddo

      if (imol.eq.1) then
! iz for N2 system
      iz(1)=7
      iz(2)=7

! C6 for N2 system
      c6(1)=19.7d0
      c6(2)=19.7d0
      else
! currently imol = 1 is used
      stop
      endif

! Calculate dispersion correction
      call edisp(94,5,2,dist,iz,mxc, &
           rs6,rs8,e6,e8,e6dr,e8dr,c6,0)

      disp = 0.0d0

      do i=1,1
      disp =disp + (-s6*e6(i)-s8*e8(i))*autokcal
      enddo

      if (igrad .eq. 1) then
      call edisp(94,5,2,dist,iz,mxc, &
           rs6,rs8,e6,e8,e6dr,e8dr,c6,1)

      dispdr(:) = 0.0d0

      do i=1,1
      dispdr(i) =dispdr(i) + (-s6*e6dr(i)-s8*e8dr(i))*autokcal/autoang
      enddo
      endif

      do i=1,1
      dist(i)=dist(i)*autoang
      enddo

      end subroutine d3disp

!**********************************************************************
! compute energy
!**********************************************************************
      subroutine edisp(max_elem,maxc,n,dist,iz,mxc, &
                 rs6,rs8,e6,e8,e6dr,e8dr,c6a,igrad)

      integer n,iz(2),max_elem,maxc,mxc(max_elem) 
      double precision dist(1),r2r4(max_elem),r0ab(max_elem,max_elem)
      double precision rs6,rs8,rcov(max_elem)
      double precision c6ab(max_elem,max_elem,maxc,maxc,3)
      double precision e6(1), e8(1), c6a(2), e6dr(1), e8dr(1)
       
      integer iat,jat,igrad
      double precision r,tmp,c6,c8,a1,a2
      double precision damp6,damp8
      double precision cn(n)
      double precision r2ab(n*n),cc6ab(n*n),dmp(n*n)
      integer step

      e6(:) =0.0d0
      e8(:) =0.0d0

      e6dr(:) =0.0d0
      e8dr(:) =0.0d0

      a1=rs6
      a2=rs8 

!  r2r4 =sqrt(0.5*r2r4(i)*dfloat(i)**0.5 ) with i=elementnumber
!  the large number of digits is just to keep the results consistent
!  with older versions. They should not imply any higher accuracy than
!  the old values
      r2r4(1:94)=(/ &
      2.00734898d0,  1.56637132d0,  5.01986934d0,  3.85379032d0, &
      3.64446594d0,  3.10492822d0,  2.71175247d0,  2.59361680d0, &
      2.38825250d0,  2.21522516d0,  6.58585536d0,  5.46295967d0, &
      5.65216669d0,  4.88284902d0,  4.29727576d0,  4.04108902d0, &
      3.72932356d0,  3.44677275d0,  7.97762753d0,  7.07623947d0, &
      6.60844053d0,  6.28791364d0,  6.07728703d0,  5.54643096d0, &
      5.80491167d0,  5.58415602d0,  5.41374528d0,  5.28497229d0, &
      5.22592821d0,  5.09817141d0,  6.12149689d0,  5.54083734d0, &
      5.06696878d0,  4.87005108d0,  4.59089647d0,  4.31176304d0, &
      9.55461698d0,  8.67396077d0,  7.97210197d0,  7.43439917d0, &
      6.58711862d0,  6.19536215d0,  6.01517290d0,  5.81623410d0, &
      5.65710424d0,  5.52640661d0,  5.44263305d0,  5.58285373d0, &
      7.02081898d0,  6.46815523d0,  5.98089120d0,  5.81686657d0, &
      5.53321815d0,  5.25477007d0, 11.02204549d0,  0.15679528d0, &
      9.35167836d0,  9.06926079d0,  8.97241155d0,  8.90092807d0, &
      8.85984840d0,  8.81736827d0,  8.79317710d0,  7.89969626d0, &
      8.80588454d0,  8.42439218d0,  8.54289262d0,  8.47583370d0, &
      8.45090888d0,  8.47339339d0,  7.83525634d0,  8.20702843d0, &
      7.70559063d0,  7.32755997d0,  7.03887381d0,  6.68978720d0, &
      6.05450052d0,  5.88752022d0,  5.70661499d0,  5.78450695d0, &
      7.79780729d0,  7.26443867d0,  6.78151984d0,  6.67883169d0, &
      6.39024318d0,  6.09527958d0, 11.79156076d0, 11.10997644d0, &
      9.51377795d0,  8.67197068d0,  8.77140725d0,  8.65402716d0, &
      8.53923501d0,  8.85024712d0 /)

! these new data are scaled with k2=4./3. and converted to a_0 via
! autoang=0.52917726d0
      rcov(1:94)=(/ &
       0.80628308d0, 1.15903197d0, 3.02356173d0, 2.36845659d0, &
       1.94011865d0, 1.88972601d0, 1.78894056d0, 1.58736983d0, &
       1.61256616d0, 1.68815527d0, 3.52748848d0, 3.14954334d0, &
       2.84718717d0, 2.62041997d0, 2.77159820d0, 2.57002732d0, &
       2.49443835d0, 2.41884923d0, 4.43455700d0, 3.88023730d0, &
       3.35111422d0, 3.07395437d0, 3.04875805d0, 2.77159820d0, &
       2.69600923d0, 2.62041997d0, 2.51963467d0, 2.49443835d0, &
       2.54483100d0, 2.74640188d0, 2.82199085d0, 2.74640188d0, &
       2.89757982d0, 2.77159820d0, 2.87238349d0, 2.94797246d0, &
       4.76210950d0, 4.20778980d0, 3.70386304d0, 3.50229216d0, &
       3.32591790d0, 3.12434702d0, 2.89757982d0, 2.84718717d0, &
       2.84718717d0, 2.72120556d0, 2.89757982d0, 3.09915070d0, &
       3.22513231d0, 3.17473967d0, 3.17473967d0, 3.09915070d0, &
       3.32591790d0, 3.30072128d0, 5.26603625d0, 4.43455700d0, &
       4.08180818d0, 3.70386304d0, 3.98102289d0, 3.95582657d0, &
       3.93062995d0, 3.90543362d0, 3.80464833d0, 3.82984466d0, &
       3.80464833d0, 3.77945201d0, 3.75425569d0, 3.75425569d0, &
       3.72905937d0, 3.85504098d0, 3.67866672d0, 3.45189952d0, &
       3.30072128d0, 3.09915070d0, 2.97316878d0, 2.92277614d0, &
       2.79679452d0, 2.82199085d0, 2.84718717d0, 3.32591790d0, &
       3.27552496d0, 3.27552496d0, 3.42670319d0, 3.30072128d0, &
       3.47709584d0, 3.57788113d0, 5.06446567d0, 4.56053862d0, &
       4.20778980d0, 3.98102289d0, 3.82984466d0, 3.85504098d0, &
       3.88023730d0, 3.90543362d0 /)

! DFT-D3
      step=0
      do iat=1,n-1
         do jat=iat+1,n
         step=step+1
         r=dist(step)
         c6=c6a(step)
! r2r4 stored in main as sqrt
         c8 =3.0d0*c6*r2r4(iz(iat))*r2r4(iz(jat))

! energy for BJ damping
          tmp=sqrt(c8/c6)
          e6(step)= c6/(r**6+(a1*tmp+a2)**6)
          e8(step)= c8/(r**8+(a1*tmp+a2)**8)
! calculate gradients
         if (igrad .eq. 1) then
! grad for BJ damping
          e6dr(step)=c6*(-6*r**5)/(r**6+(a1*tmp+a2)**6)**2
          e8dr(step)=c8*(-8*r**7)/(r**8+(a1*tmp+a2)**8)**2
         endif
         enddo
      enddo

      end subroutine edisp

