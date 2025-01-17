      subroutine pes(x,igrad,p,g,d)

      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      ! number of electronic state
      integer, parameter :: nstates=1
      integer, parameter :: natoms=3
      integer, intent(in) :: igrad
      double precision, intent(in) :: x(natoms,3)
      double precision, intent(out) :: p(nstates), g(nstates,natoms,3)
      double precision, intent(out) :: d(nstates,nstates,natoms,3)

      PARAMETER (NATOM=25)
      PARAMETER (ISURF=5)
      PARAMETER (JSURF=INT(ISURF*(ISURF+1)/2))

      COMMON/USROCM/ PENGYGS,PENGYES(ISURF),
     +               PENGYIJ(JSURF),
     +               DGSCART(NATOM,3),DESCART(NATOM,3,ISURF),
     +               DIJCART(NATOM,3,JSURF)
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,
     +               NULBL(NATOM),NFLAG(20),
     +               NASURF(ISURF+1,ISURF+1),NDER
      logical, save :: first_time_data=.true.

      !initialize 
      v=0.d0
      g=0.d0
      d=0.d0

      NDER=igrad
      NASURF=1
      CART=0.d0
      do iatom=1,natoms
      do idir=1,3
        CART(iatom,idir)=x(iatom,idir)/0.529177211
      enddo
      enddo

      if(first_time_data) then
      call prepot
      first_time_data=.false.
      endif

      call pot


      if (igrad==0) then
        do istate=1,nstates
          p(istate)=PENGYGS*27.211386
        enddo
      else if (igrad==1) then
        do istate=1,nstates
          p(istate)=PENGYGS*27.211386
        enddo
        do iatom=1,natoms
        do idir=1,3
          g(1,iatom,idir)=DGSCART(iatom,idir)*51.422067
        enddo
        enddo
      else if (igrad==2) then
        write (*,*) 'Only energy and gradient are available'
      endif

      endsubroutine


C                                                                               
      SUBROUTINE PREPOT                                                         
C
C                                                                               
C   System:          OH2                                                        
C   Functional form: Anti-Morse Bends plus Bowman's collinear spline            
C   Common name:     OH2DIM                                                     
C   Interface:       potlib2001
C   Reference:                                                                  
C                                                                               
C   Number of bodies: 3
C   Number of derivatives: 1
C   Number of electronic surfaces: 1
C
C   PREPOT must be called once before any calls to POT.                         
C   The control flags for the potential, such as IPRT, are                      
C   initialized in the block data subprogram PTPACM.                            
C   Coordinates, potential energy, and derivatives are passed                   
C   The potential energy in the three asymptotic valleys are                    
C   stored in the common block ASYCM:                                           
C                  COMMON /ASYCM/ EASYAB, EASYBC, EASYAC                        
C   The potential energy in the AB valley, EASYAB, is equal to the potential    
C   energy of the H "infinitely" far from the OH diatomic, with the             
C   OH diatomic at its equilibrium configuration.  Similarly, the terms         
C   EASYBC and EASYAC represent the H2 and the OH asymptotic valleys,           
C   respectively.                                                               
C   All the information passed through the common blocks PT1CM and ASYCM        
C   is in Hartree atomic units.                                                 
C                                                                               
C   This potential is written such that:                                        
C                  R(1) = R(O-H)                                                
C                  R(2) = R(H-H)                                                
C                  R(3) = R(H-O)                                                
C   The zero of energy is defined at O "infinitely" far from the H2 diatomic.   
C                                                                               
C   The flags that indicate what calculations should be carried out in          
C   the potential routine are passed through the common block PT2CM:            
C   where:                                                                      
C        NASURF - which electronic states availalble                            
C                 (1,1) = 1 as only gs state available                          
C        NDER  = 0 => no derivatives should be calculated                       
C        NDER  = 1 => calculate first derivatives                               
C        NFLAG - these integer values can be used to flag options               
C                within the potential;                                          
C                                                                               
C                                                                               
C   Potential parameters' default settings                                      
C                  Variable            Default value                            
C                  NDER                1                                        
C                  NFLAG(18)           6                                        
C                                                                               
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                                  
C          GENERAL INFORMATION                                                  
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                                  
C                                                                               
C   POTA.FOR HAS ANTI-MORSE BEND PLUS BOWMAN'S COLLINEAR SPLINE ROUTINE.        
C   ANTI-MORSE BENDING POTENTIAL IS ADDED TO COLLINEAR POTENTIAL.               
C   THIS SUBROUTINE CAN BE USED TO ADD A BENDING CORRECTION TO                  
C   ANY COLLINEAR POTENTIAL SUBROUTINE.                                         
C                                                                               
CCCCCCCCCCCCCCCCCCCCCCCCCCC                                                     
C          DEFINE VARIABLES                                                     
CCCCCCCCCCCCCCCCCCCCCCCCCCC                                                     
C                                                                               
      IMPLICIT REAL*8 (A-H,O-Z)                                                 
C                                                                               
      REAL*8 NAB,NAB1,NBC,NBC1,JUNK,HRTREE,BOHR                                 
      DIMENSION JUNK(4)                                                         
C                                                                               
      CHARACTER*75 REF(5)                                                       
C                                                                               
      PARAMETER (N3ATOM = 75)                                                   
      PARAMETER (ISURF = 5)                                                     
      PARAMETER (JSURF = ISURF*(ISURF+1)/2)                             
      PARAMETER (PI = 3.141592653589793D0)                                      
      PARAMETER (NATOM = 25)                                                    
C                                                                               
      COMMON /PT1CM/ R(N3ATOM),ENGYGS,DEGSDR(N3ATOM)                            
      COMMON /PT3CM/ EZERO(ISURF+1)                                             
      COMMON /PT4CM/ ENGYES(ISURF),DEESDR(N3ATOM,ISURF)                         
      COMMON /PT5CM/ ENGYIJ(JSURF),DEIJDR(N3ATOM,JSURF)                         
C                                                                               
      COMMON/INFOCM/ CARTNU(NATOM,3),INDEXES(NATOM),                            
     +               IRCTNT,NATOMS,ICARTR,MDER,MSURF,REF                        
C                                                                               
      COMMON/USROCM/ PENGYGS,PENGYES(ISURF),                                    
     +               PENGYIJ(JSURF),                                            
     +               DGSCART(NATOM,3),DESCART(NATOM,3,ISURF),                   
     +               DIJCART(NATOM,3,JSURF)                                     
C                                                                               
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,                                     
     +               NULBL(NATOM),NFLAG(20),                                    
     +               NASURF(ISURF+1,ISURF+1),NDER                               
C                                                                               
      COMMON /ASYCM/ EASYAB,EASYBC,EASYAC                                       
C                                                                               
C Conversion constant from Angstroms to Bohr (Angstrom/Bohr)                    
C                                                                               
         PARAMETER (BOHR = .52917706D0)                                         
C                                                                               
C Conversion constant from Hartree to kcal (kcal/Hartree)                       
C                                                                               
         PARAMETER (HRTREE = 627.5095D0)                                        
C                                                                               
         COMMON /NSTEP/  STEP                                                   
         COMMON /POTCM/  XBC(3),XAB(3),CBC(3),ABC(3),CAB(3),                    
     +                   AAB(3),PHI(40),BSP(40,3),                              
     +                   DE,BETA,REQ(3),A,GAMMA,RBB,RHH,                        
     +                   R1S,R2S,VSP,DBCOOR(2),NPHI                             
C                                                                               
      IF(NATOMS.GT.25) THEN                                                     
         WRITE(NFLAG(18),1111)                                                  
 1111    FORMAT(2X,'STOP. NUMBER OF ATOMS EXCEEDS ARRAY DIMENSIONS')            
         STOP                                                                   
      END IF                                                                    
C                                                                               
C      WRITE(NFLAG(18), 600)                                                     
600   FORMAT (/,2X,T5,'PREPOT2 has been called for the OH2 ',                   
     *                'potential energy surface DIM',                           
     *        /,2X,T5,'Parameters for the potential energy surface',/)          
C                                                                               
      CALL PREPOT2                                                              
C                                                                               
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                        
C      BENDING POTENTIAL PARAMETERS                                             
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                        
C                                                                               
C      WRITE(NFLAG(18),3)                                                        
 3    FORMAT(/,2X,T5,'Parameters for the bending potential ',                   
     +       'initialized in BLOCK DATA')                                       
C                                                                               
C   Echo the potential parameters to the file linked to UNIT NFLAG(18)          
C                                                                               
C      WRITE (NFLAG(18),25) (REQ(IT), IT = 1,3)                                  
C      WRITE(NFLAG(18),10) DE                                                    
C      WRITE(NFLAG(18),21) BETA                                                  
C      WRITE (NFLAG(18),30) A                                                    
C      WRITE (NFLAG(18),31) GAMMA                                                
C      WRITE(NFLAG(18),35) RBB                                                   
C                                                                               
25    FORMAT(2X,T10,'Equilibrium bond distances (Angstroms):',                  
     *       /,2X,T15,3(1PE20.10,1X))                                           
10    FORMAT(2X,T10,'Dissociation energies (kcal/mol):',                        
     *          T50,1PE20.10)                                                   
21    FORMAT(2X,T10,'Morse Beta parameters (Angstroms**-1):',                   
     *          T50,1PE20.10)                                                   
35    FORMAT(2X,T10,'RBB (Angstroms):',                                         
     *          T50,1PE20.10)                                                   
30    FORMAT(2X,T10,'Pauling parameter (Angstroms):',                           
     *          T50,1PE20.10)                                                   
31    FORMAT(2X,T10,'Gamma (unitless):',                                        
     *          T50,1PE20.10)                                                   
C                                                                               
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                                 
C       CONVERT TO ATOMIC UNITS                                                 
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                                 
C                                                                               
      DO 50 IT = 1,3                                                            
      REQ(IT) = REQ(IT)/BOHR                                                    
   50 CONTINUE                                                                  
      BETA = BETA * BOHR                                                        
      DE = DE/HRTREE                                                            
      A = A/BOHR                                                                
      RHH = 1.4007977D0                                                         
      RBB = RBB /BOHR                                                           
C                                                                               
CCCCCCCCCCCC                                                                    
C                                                                               
C                                                                               
      EZERO(1)=VSP                                                              
C                                                                               
       DO I=1,5                                                                 
          REF(I) = ' '                                                          
       END DO                                                                   
C                                                                               
       REF(1)='No Reference'                                                    
C                                                                               
      INDEXES(1) = 8                                                            
      INDEXES(2) = 1                                                            
      INDEXES(3) = 1                                                            
C                                                                               
C                                                                               
C                                                                               
      IRCTNT=2                                                                  
C                                                                               
C      CALL POTINFO                                                              
C                                                                               
      CALL ANCVRT                                                               
C                                                                               
      RETURN                                                                    
      END                                                                       
C                                                                               
CCCCCCCCCCCC                                                                    
C                                                                               
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                 
C        MOVE TO POT SUBROUTINE                                                 
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                 
C                                                                               
      SUBROUTINE POT                                                            
C                                                                               
C   The potential energy in the AB valley, EASYAB, is equal to the potential    
C   energy of the H "infinitely" far from the OH diatomic, with the             
C   OH diatomic at its equilibrium configuration.  Similarly, the terms         
C   EASYBC and EASYAC represent the H2 and the OH asymptotic valleys,           
C   respectively.                                                               
C                                                                               
C   This potential is written such that:                                        
C                  R(1) = R(O-H)                                                
C                  R(2) = R(H-H)                                                
C                  R(3) = R(H-O)                                                
C   The zero of energy is defined at O "infinitely" far from the H2 diatomic.   
C                                                                               
CCCCCCCCCCCCCCCC                                                                
C      ENTRY POT                                                         8/17R79
CCCCCCCCCCCCCCCC                                                                
C                                                                               
      IMPLICIT REAL*8 (A-H,O-Z)                                                 
C                                                                               
      REAL*8 NAB,NAB1,NBC,NBC1,JUNK,HRTREE,BOHR                                 
      DIMENSION JUNK(4)                                                         
C                                                                               
      CHARACTER*75 REF(5)                                                       
C                                                                               
      PARAMETER (N3ATOM = 75)                                                   
      PARAMETER (ISURF = 5)                                                     
      PARAMETER (JSURF = ISURF*(ISURF+1)/2)                             
      PARAMETER (PI = 3.141592653589793D0)                                      
      PARAMETER (NATOM = 25)                                                    
C                                                                               
      COMMON /PT1CM/ R(N3ATOM),ENGYGS,DEGSDR(N3ATOM)                            
      COMMON /PT3CM/ EZERO(ISURF+1)                                             
      COMMON /PT4CM/ ENGYES(ISURF),DEESDR(N3ATOM,ISURF)                         
      COMMON /PT5CM/ ENGYIJ(JSURF),DEIJDR(N3ATOM,JSURF)                         
C                                                                               
      COMMON/INFOCM/ CARTNU(NATOM,3),INDEXES(NATOM),                            
     +               IRCTNT,NATOMS,ICARTR,MDER,MSURF,REF                        
C                                                                               
      COMMON/USROCM/ PENGYGS,PENGYES(ISURF),                                    
     +               PENGYIJ(JSURF),                                            
     +               DGSCART(NATOM,3),DESCART(NATOM,3,ISURF),                   
     +               DIJCART(NATOM,3,JSURF)                                     
C                                                                               
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,                                     
     +               NULBL(NATOM),NFLAG(20),                                    
     +               NASURF(ISURF+1,ISURF+1),NDER                               
C                                                                               
      COMMON /ASYCM/ EASYAB,EASYBC,EASYAC                                       
C                                                                               
C Conversion constant from Angstroms to Bohr (Angstrom/Bohr)                    
C                                                                               
         PARAMETER (BOHR = .52917706D0)                                         
C                                                                               
C Conversion constant from Hartree to kcal (kcal/Hartree)                       
C                                                                               
         PARAMETER (HRTREE = 627.5095D0)                                        
C                                                                               
         COMMON /NSTEP/  STEP                                                   
         COMMON /POTCM/  XBC(3),XAB(3),CBC(3),ABC(3),CAB(3),                    
     +                   AAB(3),PHI(40),BSP(40,3),                              
     +                   DE,BETA,REQ(3),A,GAMMA,RBB,RHH,                        
     +                   R1S,R2S,VSP,DBCOOR(2),NPHI                             
C                                                                               
      CALL CARTOU                                                               
      CALL CARTTOR                                                              
C                                                                               
C   Check the values of NASURF and NDER for validity.                           
C                                                                               
C      IF (NASURF(1,1) .EQ. 0) THEN                                              
C         WRITE(NFLAG(18), 900) NASURF(1,1)                                      
C         STOP                                                                   
C      ENDIF                                                                     
C         IF (NDER .GT. 1) THEN                                                  
C             WRITE (NFLAG(18), 910) NDER                                        
C             STOP 'POT 2'                                                       
C         ENDIF                                                                  
C                                                                               
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                    
C        FIRST CALCULATE SOME USEFUL NUMBERS                                    
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                    
C                                                                               
C        NAB AND NBC ARE THE BOND ORDERS OF THE DIATOMICS                       
C        AB AND BC RESPECTIVELY. (EQUATION 2.2)                                 
C                                                                               
      NAB = EXP((REQ(1) - R(1))/A)                                              
C                                                                               
      IF (NAB.LT.1.D-15) NAB = 1.D-15                                           
C                                                                               
      NBC = EXP((REQ(2) - R(2))/A)                                              
C                                                                               
      IF (NBC.LT.1.D-15) NBC = 1.D-15                                           
C                                                                               
C       CALCULATE BOND ORDERS ALONG THE REACTION COORDINATE                     
C       SEE EQUATION 2.7A, 2.7B                                                 
C                                                                               
      C = 1.D0 - NAB/NBC                                                        
      IF (ABS(C).GT.1.D-14) GOTO 90                                             
      NAB1=.5D0                                                                 
      NBC1=.5D0                                                                 
      GO TO 95                                                                  
   90 C = C/NAB                                                                 
      NAB1 = (2.D0 + C - SQRT(4.D0+C*C))/(2.D0*C)                               
      NBC1 = 1.D0 - NAB1                                                        
C                                                                               
C          ROB IS USED IN THE BENDING POTENTIAL CALCULATIONS                    
C                                                                               
C          FIRST TRAP OUT ANY ZERO ARGUEMENTS                                   
C                                                                               
   95 IF (NAB1*NBC1.GT.0.0D0) GO TO 103                                         
           ROB = 1.D0                                                           
      GO TO 107                                                                 
C                                                                               
  103 STUFF = A * LOG(NAB1*NBC1)                                                
      ROB = (RBB - STUFF)/(RHH - STUFF)                                         
C                                                                               
  107 CONTINUE                                                                  
C                                                                               
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                           
C        CALCULATE BENDING CORRECTION                                           
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                           
C                                                                               
C        CALCULATE V(R(3))                                                      
C                                                                               
      JUNK(3) = EXP(-BETA*(R(3)-REQ(3))/ROB)                                    
      VAC = GAMMA *1.0D-14 * DE * JUNK(3)* (1.D0 + 0.5D0*JUNK(3))               
C                                                                               
C        CALCULATE V(R(1)+R(2))                                                 
C                                                                               
      JUNK(4) = EXP(BETA*(REQ(3)-R(2)-R(1))/ROB)                                
      VABBC= GAMMA *1.0D-14 * DE * JUNK(4) * (1.D0 + 0.5D0*JUNK(4))             
C                                                                               
C        HERE IS THE BENDING CORRECTION                                         
C                                                                               
      BCOOR = (VAC - VABBC)*1.0D14                                              
C                                                                               
C          WHILE IT'S CONVENIENT, CALCULATE THE DERIVATIVE                      
C          OF BCOOR WITH RESPECT TO R(1), R(2), AND R(3).                       
C                                                                               
C        CALCULATE DAC (THE DERIVATIVE WITH RESPECT TO R(3))                    
C                                                                               
      IF (NDER .EQ. 1) THEN                                                     
          DAC = -GAMMA*DE*BETA*JUNK(3)*(1.D0+JUNK(3))/ROB                       
          DBCOOR(1) = GAMMA * DE * BETA * JUNK(4) *                             
     *                (1.D0 + JUNK(4))/ROB                                      
          DBCOOR(2)= DBCOOR(1)                                                  
      ENDIF                                                                     
C                                                                               
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                     
C        NOW CALCULATE THE COLLINEAR ENERGY                                     
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                                     
C                                                                               
C          STORE R(3) IN RACTMP THEN SET R(3) TO THE COLLINEAR                  
C          GEOMETRY AND CALL POT2                                               
C                                                                               
      RACTMP = R(3)                                                             
      R(3) = R(2) + R(1)                                                        
C                                                                               
      CALL POT2                                                         8/17R79 
C                                                                               
      IF (NDER .EQ. 1) THEN                                                     
          DEGSDR(1) = DEGSDR(1) + DEGSDR(3)                                     
          DEGSDR(2) = DEGSDR(2) + DEGSDR(3)                                     
          DEGSDR(3) = DAC                                                       
      ENDIF                                                                     
      R(3) = RACTMP                                                             
C                                                                               
      ENGYGS = ENGYGS + BCOOR                                                   
C                                                                               
      IF (NDER .EQ. 1) THEN                                                     
          DO 300 IT = 1,2                                                       
                 DEGSDR(IT) = DBCOOR(IT) + DEGSDR(IT)                           
300       CONTINUE                                                              
      ENDIF                                                                     
C                                                                               
 900  FORMAT(/,2X,T5,13HNASURF(1,1) =,I5,                                       
     *       /,2X,T5,24HThis value is unallowed.                                
     *       /,2X,T5,31HOnly gs surface=>NASURF(1,1)=1 )                        
910   FORMAT(/, 2X,'POT has been called with NDER = ',I5,                       
     *       /, 2X, 'This value of NDER is not allowed in this ',               
     *              'version of the potential.')                                
C                                                                               
      CALL EUNITZERO                                                            
      IF(NDER.NE.0) THEN                                                        
         CALL RTOCART                                                           
         CALL DEDCOU                                                            
      ENDIF                                                                     
C                                                                               
      RETURN                                                                    
      END                                                                       
C                                                                               
      SUBROUTINE PREPOT2                                                        
C                                                                               
C   POTENTIAL FUNCTION FOR RATE1D SERIES                                        
C   RMO-SPLINE TYPE FIT WITH BEBO TYPE CONTINUATION INTO THE ASYMBTOTIC REGION  
C   POTENTIAL ROUTINE INTERACTS WITH REST OF PROGRAM WITH UNITS OF EV/BOHR      
C   POTENTIAL ROUTINE ASSUMES SPLINE INFO IS IN UNITS OF KCAL/ANGSTROM          
C                                                                               
      IMPLICIT REAL*8 (A-H,O-Z)                                                 
C                                                                               
      REAL*8 NAB,NAB1,NBC,NBC1,JUNK,HRTREE,BOHR                                 
      DIMENSION JUNK(4)                                                         
C                                                                               
      CHARACTER*75 REF(5)                                                       
C                                                                               
      PARAMETER (N3ATOM = 75)                                                   
      PARAMETER (ISURF = 5)                                                     
      PARAMETER (JSURF = ISURF*(ISURF+1)/2)                             
      PARAMETER (PI = 3.141592653589793D0)                                      
      PARAMETER (NATOM = 25)                                                    
C                                                                               
      COMMON /PT3CM/ EZERO(ISURF+1)                                             
C                                                                               
      COMMON/INFOCM/ CARTNU(NATOM,3),INDEXES(NATOM),                            
     +               IRCTNT,NATOMS,ICARTR,MDER,MSURF,REF                        
C                                                                               
C                                                                               
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,                                     
     +               NULBL(NATOM),NFLAG(20),                                    
     +               NASURF(ISURF+1,ISURF+1),NDER                               
C                                                                               
      COMMON /ASYCM/ EASYAB,EASYBC,EASYAC                                       
C                                                                               
C Conversion constant from Angstroms to Bohr (Angstrom/Bohr)                    
C                                                                               
      PARAMETER (BOHR = .52917706D0)                                            
C                                                                               
C Conversion constant from Hartree to kcal (kcal/Hartree)                       
C                                                                               
      PARAMETER (HRTREE = 627.5095D0)                                           
C                                                                               
      PARAMETER (DETRAD=.0174532D0)                                             
C                                                                               
      COMMON /NSTEP/  STEP                                                      
      COMMON /POTCM/  XBC(3),XAB(3),CBC(3),ABC(3),CAB(3),                       
     +                AAB(3),PHI(40),BSP(40,3),                                 
     +                DE,BETA,REQ(3),A,GAMMA,RBB,RHH,                           
     +                R1S,R2S,VSP,DBCOOR(2),NPHI                                
C                                                                               
      DIMENSION       V(4),CSP(48,3),SCRAP(48)                                  
C                                                                               
      CHARACTER*80 TITLE                                                        
C                                                                               
      TITLE=' RMOFIT to DIM surface with BEBO continuations '                   
C                                                                               
C      WRITE(NFLAG(18),845)TITLE                                                 
C      WRITE(NFLAG(18),125)STEP                                                  
C      WRITE(NFLAG(18),111)XAB(1), XBC(1), XAB(1),                               
C     *               XAB(2), XBC(2), XAB(2),                                    
C     *               XAB(3), XBC(3), XAB(3)                                     
C      WRITE(NFLAG(18),105)R1S,R2S,VSP                                           
C      WRITE(NFLAG(18),113)(PHI(I),(BSP(I,J),J = 1,3),I = 1,NPHI)                
C      WRITE(NFLAG(18),117)(CBC(I),ABC(I),I = 1,3),                              
C     +                    (CAB(I),AAB(I),I = 1,3)                               
C                                                                               
C   Initialize the energy in the asymptotic valleys                             
C                                                                               
      EASYAB = XAB(1)/HRTREE                                                    
      EASYBC = XBC(1)/HRTREE                                                    
      EASYAC = EASYAB                                                           
C                                                                               
2     FORMAT(F12.10)                                                            
105   FORMAT(/,2X,T5,'R1S, R2S, VSP = ',3(F10.5,1X))                            
111   FORMAT (/,2X,T5,'Bond', T47, 'O-H', T58, 'H-H', T69, 'H-O',               
     *        /,2X,T5,'Dissociation energies (kcal/mol):',                      
     *        T44, F10.5, T55, F10.5, T66, F10.5,                               
     *        /,2X,T5,'Equilibrium bond lengths (Angstroms):',                  
     *        T44, F10.5, T55, F10.5, T66, F10.5,                               
     *        /,2X,T5,'Morse beta parameters (Angstroms**-1):',                 
     *        T44, F10.5, T55, F10.5, T66, F10.5)                               
113   FORMAT(/,2X,T24,'Phi',T39,'De',T59,'Re',T73,'Beta',/,                     
     *      (2X,T20,F10.5,T35,F10.5,T55,F10.5,T70,F10.5))                       
117   FORMAT(/,2X,T5,'For the asymptote: MO parameter value = ',                
     *               '(asymp. value)+C*EXP(-A*(RI-RIS))',                       
     *       /,2X,T10,'CBC(I); I=1,3: ',3(F15.5, 1X),                           
     *       /,2X,T10,'ABC(I); I=1,3: ',3(F15.5, 1X),                           
     *       /,2X,T10,'CAB(I); I=1,3: ',3(F15.5, 1X),                           
     *       /,2X,T10,'AAB(I); I=1,3: ',3(F15.5, 1X))                           
125   FORMAT(2X,T5,'Step size for the numerical derivative ',                   
     *               'calculation = ',1PE20.10)                                 
401   FORMAT(16I5)                                                              
403   FORMAT(3E20.7)                                                            
407   FORMAT(4E20.7)                                                            
843   FORMAT(A80)                                                               
845   FORMAT(2X,T5,//'Title card in potential input data file: ',//,A80)        
C                                                                               
      RETURN                                                                    
      END                                                                       
C                                                                               
      SUBROUTINE POT2                                                           
C                                                                               
C COCK SPLINES                                                                  
C                                                                               
C      ENTRY POT2                                                               
      IMPLICIT REAL*8 (A-H,O-Z)                                                 
C                                                                               
      REAL*8 NAB,NAB1,NBC,NBC1,JUNK,HRTREE,BOHR                                 
      DIMENSION JUNK(4)                                                         
C                                                                               
      CHARACTER*75 REF(5)                                                       
C                                                                               
      PARAMETER (N3ATOM = 75)                                                   
      PARAMETER (ISURF = 5)                                                     
      PARAMETER (JSURF = ISURF*(ISURF+1)/2)                             
      PARAMETER (PI = 3.141592653589793D0)                                      
      PARAMETER (NATOM = 25)                                                    
C                                                                               
      COMMON /PT1CM/ R(N3ATOM),ENGYGS,DEGSDR(N3ATOM)                            
      COMMON /PT3CM/ EZERO(ISURF+1)                                             
      COMMON /PT4CM/ ENGYES(ISURF),DEESDR(N3ATOM,ISURF)                         
      COMMON /PT5CM/ ENGYIJ(JSURF),DEIJDR(N3ATOM,JSURF)                         
C                                                                               
      COMMON/INFOCM/ CARTNU(NATOM,3),INDEXES(NATOM),                            
     +               IRCTNT,NATOMS,ICARTR,MDER,MSURF,REF                        
C                                                                               
      COMMON/USROCM/ PENGYGS,PENGYES(ISURF),                                    
     +               PENGYIJ(JSURF),                                            
     +               DGSCART(NATOM,3),DESCART(NATOM,3,ISURF),                   
     +               DIJCART(NATOM,3,JSURF)                                     
C                                                                               
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,                                     
     +               NULBL(NATOM),NFLAG(20),                                    
     +               NASURF(ISURF+1,ISURF+1),NDER                               
C                                                                               
      COMMON /ASYCM/ EASYAB,EASYBC,EASYAC                                       
C                                                                               
      PARAMETER (HRTREE = 627.5095D0)                                           
      PARAMETER (DETRAD=.0174532D0)                                             
C                                                                               
      COMMON /NSTEP/  STEP                                                      
      COMMON /POTCM/  XBC(3),XAB(3),CBC(3),ABC(3),CAB(3),                       
     +                AAB(3),PHI(40),BSP(40,3),                                 
     +                DE,BETA,REQ(3),A,GAMMA,RBB,RHH,                           
     +                R1S,R2S,VSP,DBCOOR(2),NPHI                                
C                                                                               
      DIMENSION V(4),CSP(48,3),SCRAP(48)                                        
C                                                                               
      IC=1                                                                      
   10 GO TO (81,82,83,84),IC                                                    
  81  R1=R(1)                                                                   
      R2=R(2)                                                                   
      R3=R(3)                                                                   
      GO TO 85                                                                  
   82 R1=R(1) + STEP                                                            
      R2=R(2)                                                                   
      R3=R(3)                                                                   
      GO TO 85                                                                  
   83 R1=R(1)                                                                   
      R2=R(2) + STEP                                                            
      R3=R(3)                                                                   
      GO TO 85                                                                  
   84 R1=R(1)                                                                   
      R2=R(2)                                                                   
      R3=R(3) + STEP                                                            
 85   R1=R1*0.529177D0                                                          
      R2=R2*0.529177D0                                                          
      R3=R3*0.529177D0                                                          
      DR1=R1S - R1                                                              
      DR2=R2S - R2                                                              
      ANGLE=ATAN(DR1/DR2)                                                       
      ANGLE=ANGLE/DETRAD                                                        
      DO 500 K=1,3                                                              
      PPP=SPLINE(1,NPHI,PHI,BSP(1,K),CSP(1,K),SCRAP,ANGLE)                      
 500  CONTINUE                                                                  
C                                                                               
C SETUP ANY CONSTANTS                                                           
C                                                                               
      DBC = XBC(1)                                                              
      DERG = XBC(1)/23.061D0                                                    
      RERG = (R2S-XBC(2))/.529177D0                                             
      BETRG = XBC(3)*.529177D0                                                  
      DEPR = XAB(1)/23.061D0                                                    
      REPR = (R1S-XAB(2))/.529177D0                                             
      BETPR = XAB(3)*.529177D0                                                  
C                                                                               
C ENTRY INTO POTENTIAL CALCULATOR                                               
C                                                                               
      IF(R1.GT.R1S) GO TO 100                                                   
      IF(R2.GT.R2S) GO TO 102                                                   
C                                                                               
C INTERACTION REGION OF POLAR COORDINATES                                       
C                                                                               
      DR1=R1S-R1                                                                
      DR2=R2S-R2                                                                
      ANGLE=ATAN(DR1/DR2)                                                       
      ANGLE=ANGLE/DETRAD                                                        
      RR=SQRT(DR1*DR1+DR2*DR2)                                                  
      DIS=SPLINE(2,NPHI,PHI,BSP(1,1),CSP(1,1),SCRAP,ANGLE)                      
      REQ2=SPLINE(2,NPHI,PHI,BSP(1,2),CSP(1,2),SCRAP,ANGLE)                     
      BET=SPLINE(2,NPHI,PHI,BSP(1,3),CSP(1,3),SCRAP,ANGLE)                      
C      D(1)=SPLINE(3,NPHI,PHI,BSP(1,1),CSP(1,1),SCRAP,ANGLE)                    
C      D(2)=SPLINE(3,NPHI,PHI,BSP(1,2),CSP(1,2),SCRAP,ANGLE)                    
C30      D(1)=D(1)/627.5095D0*0.529177D0                                        
C      D(2)=D(2)/627.5095D0*0.529177D0                                          
C                                                                               
C 30   X = DIS*((1.D0-EXP(BET*(RR-REQ2)))**2.0D0 -1.D0) + VSP                   
 30   X = DIS*((1.D0-EXP(BET*(RR-REQ2)))**2.0D0 -1.D0) +                        
     +    EZERO(1) - (ANUZERO*627.5095D0)                                       
C       1                                                                       
      V(IC) = X                                                                 
      IC=IC+1                                                                   
      IF(IC.LT.5) GO TO 10                                                      
      DO 333 I=1,3                                                              
 333  V(I)=V(I)/627.5095D0                                                      
      IF (NDER .EQ. 1) THEN                                                     
          DEGSDR(1)=(V(2)-V(1))/STEP                                            
          DEGSDR(2)=(V(3)-V(1))/STEP                                            
          DEGSDR(3)=0.0D0                                                       
      ENDIF                                                                     
      ENGYGS=V(1)                                                               
   93 RETURN                                                                    
C                                                                               
C LARGE R1 ASYMPTOTIC REGION                                                    
C                                                                               
  100 IF(R2.GT.R2S) GO TO 104                                                   
      RR = R2S-R2                                                               
      SEP = R1-R1S                                                              
      DIS = XBC(1) + CBC(1)*EXP(-MIN(ABC(1)*SEP,25.D0))                         
      REQ2 = XBC(2) + CBC(2)*EXP(-MIN(ABC(2)*SEP,25.D0))                        
      BET = XBC(3) + CBC(3)*EXP(-MIN(ABC(3)*SEP,25.D0))                         
C      IF(R1.GT.10.D0)D(1)=1.0D1                                                
C      IF(R1.GT.10.D0)D(2)=1.0D-8                                               
C      IF(R1.GT.10.D0)GO TO 30                                                  
C      D(1)=-CBC(1)*ABC(1)*((1.D0-EXP(-BET*(RR-REQ2)))**2-1.D0)-                
C     +     DIS*2.D0*(1.D0-EXP(-BET*(RR-REQ2)))*EXP(-BET*(RR-REQ2))*            
C     +     ((-CBC(3)*ABC(3)*EXP(-ABC(3)*SEP)*(RR-REQ2) -                       
C     +     CBC(2)*ABC(2)*EXP(ABC(2)*SEP)*BET))*BET*(RR-REQ2)                   
C      D(2)=2.D0*DIS*(1.D0-EXP(-BET*(RR-REQ2)))*BET*(RR-REQ2)*                  
C     +     EXP(-BET*(RR-REQ2))*BET                                             
       GO TO 30                                                                 
C                                                                               
C LARGE R2 ASYMPTOTIC REGION                                                    
C                                                                               
  102 CONTINUE                                                                  
      RR = R1S-R1                                                               
      SEP = R2-R2S                                                              
      DIS = XAB(1) + CAB(1)*EXP(-MIN(AAB(1)*SEP,25.D0))                         
      REQ2 = XAB(2) + CAB(2)*EXP(-MIN(AAB(2)*SEP,25.D0))                        
      BET = XAB(3) + CAB(3)*EXP(-MIN(AAB(3)*SEP,25.D0))                         
C      IF(R2.GT.10.D0)D(2)=1.0D1                                                
C      IF(R2.GT.10.D0)D(1)=1.0D-8                                               
C      IF(R2.GT.10.D0)GO TO 30                                                  
C      D(1)=-CAB(1)*AAB(1)*((1.D0-EXP(-BET*(RR-REQ2)))**2-1.D0)-                
C     +     DIS*2.D0*(1.D0-EXP(-BET*(RR-REQ2)))*EXP(-BET*(RR-REQ2))*            
C     +     ((-CAB(3)*AAB(3)*EXP(-AAC(3)*SEP)*(RR-REQ2) -                       
C     +     CAB(2)*AAB(2)*EXP(AAB(2)*SEP)*BET))*BET*(RR-REQ2)                   
C      D(2)=2.D0*DIS*(1.D0-EXP(-BET*(RR-REQ2)))*BET*(RR-REQ2)*                  
C     +     EXP(-BET*(RR-REQ2))*BET                                             
       GO TO 30                                                                 
C                                                                               
C LARGE R1,R2 3 BODY BREAK-UP REGION                                            
C                                                                               
  104 CONTINUE                                                                  
      J=J+1                                                                     
      ENGYGS=XBC(1)/627.5095D0                                                  
      IF (NDER .EQ. 1) THEN                                                     
          DEGSDR(1)=1.0D-9                                                      
          DEGSDR(2)=1.0D-9                                                      
          DEGSDR(3)=0.0D0                                                       
      ENDIF                                                                     
      GO TO 93                                                                  
      END                                                                       
C                                                                               
      FUNCTION SPLINE(ISW,NN,X,Y,C,D,XPT)                                       
      IMPLICIT REAL*8 (A-H,O-Z)                                                 
C                                                                               
      CHARACTER*75 REF(5)                                                       
C                                                                               
      PARAMETER (N3ATOM = 75)                                                   
      PARAMETER (ISURF = 5)                                                     
      PARAMETER (JSURF = ISURF*(ISURF+1)/2)                             
      PARAMETER (PI = 3.141592653589793D0)                                      
      PARAMETER (NATOM = 25)                                                    
C                                                                               
      COMMON /PT1CM/ R(N3ATOM),ENGYGS,DEGSDR(N3ATOM)                            
      COMMON /PT3CM/ EZERO(ISURF+1)                                             
      COMMON /PT4CM/ ENGYES(ISURF),DEESDR(N3ATOM,ISURF)                         
      COMMON /PT5CM/ ENGYIJ(JSURF),DEIJDR(N3ATOM,JSURF)                         
C                                                                               
      COMMON/INFOCM/ CARTNU(NATOM,3),INDEXES(NATOM),                            
     +               IRCTNT,NATOMS,ICARTR,MDER,MSURF,REF                        
C                                                                               
      COMMON/USROCM/ PENGYGS,PENGYES(ISURF),                                    
     +               PENGYIJ(JSURF),                                            
     +               DGSCART(NATOM,3),DESCART(NATOM,3,ISURF),                   
     +               DIJCART(NATOM,3,JSURF)                                     
C                                                                               
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,                                     
     +               NULBL(NATOM),NFLAG(20),                                    
     +               NASURF(ISURF+1,ISURF+1),NDER                               
C                                                                               
      COMMON /ASYCM/ EASYAB,EASYBC,EASYAC                                       
C                                                                               
C      DIMENSION X(*),Y(*),C(*),D(*)                                            
      DIMENSION X(NN+2),Y(NN+2),C(NN+2),D(NN+2)                                 
C                                                                               
C                                                                               
C  THIS IS A SUBROUTINE FOR FITTING DATA WITH A CUBIC SPLINE                    
C  POLYNOMIAL AND EVALUATING THAT POLYNOMIAL AT A GIVEN POINT                   
C  OR ITS DERIVATIVE AT A GIVEN POINT                                           
C                                                                               
C  CALLING SEQUENCE .......                                                     
C                                                                               
C     ISW ... CONTROL OPTION                                                    
C         ISW=1  IF A CUBIC SPLINE IS TO BE FITTED TO THE SET OF KNOTS          
C                DEFINED BY THE ARRAYS X AND Y.  THE SPLINE COEFFICIENTS        
C                ARE STORED IN THE ARRAY C.                                     
C         ISW=2  IF THE SPLINE DEFINED BY THE COEFFICIENT ARRAY 'C' IS          
C                TO BE EVALUATED (INTERPOLATED) AT THE POINT DEFINED BY         
C                THE PARAMETER 'XPT'.                                           
C         ISW=3  AS IN ISW=2, ONLY THE DERIVATIVE/3.D0 IS ALSO CALCULATED AT XPT
C         ISW=4  THE DERIVATIVE CALCULATED BY THE LAST USE OF SPLINE WITH ISW=3 
C                IS RETURNED.                                                   
C                                                                               
C     NN ... THE NUMBER OF KNOTS (DATA POINTS) TO WHICH THE SPLINE IS TO        
C            BE FITTED                                                          
C                                                                               
C     X,Y ... THE ARRAYS DEFINING THE KNOTS.  THE X-VALUES MUST BE IN           
C             INCREASING ORDER.  THE ARRAYS MUST BE DIMENSIONED AT LEAST        
C             NN.                                                               
C                                                                               
C     C ... THE ARRAY THAT CONTAINS THE CUBIC SPLINE COEFFICIENTS.              
C           MUST BE DIMENSIONED AT LEAST NN+2 .                                 
C                                                                               
C     D ... A WORK SPACE.  MUST BE DIMENSIONED AT LEAST NN+2 .                  
C                                                                               
C     XPT ... THE POINT AT WHICH THE INTERPOLATION IS DESIRED (IF ISW IS        
C              SET TO 2).  THE VALUE OF SPLINE IS SET TO THE                    
C              INTERPOLATED VALUE.                                              
C                                                                               
C *****  USER NOTES  *****                                                      
C                                                                               
C     INTERPOLATION INVOLVES AT LEAST TWO STEPS .......                         
C                                                                               
C       A.  CALL SPLINE WITH THE KNOTS.  THIS SETS UP THE                       
C           COEFFICIENT ARRAY C.                                                
C           EG.  DUMY=SPLINE(1,NN,X,Y,C,D,XPT)                                  
C                                                                               
C       B.  CALL SPLINE WITH THE ARRAY C WHICH WAS DEFINED BY THE               
C           PREVIOUS CALL AND WILL BE USED TO FIND THE VALUE AT THE             
C           POINT 'XPT' .                                                       
C           EG.   VALUE=SPLINE(2,NN,X,Y,C,D,XPT)                                
C                                                                               
C     STEP 'A' NEED BE EXECUTED ONLY ONCE FOR A GIVEN SET OF KNOTS.             
C     STEP B MAY BE EXECUTED AS MANY TIMES AS NECESSARY.                        
C                                                                               
C     Output from this subprogram is written to unit 6.                         
C                                                                               
2     N=NN                                                                      
      NP1=N+1                                                                   
      NP2=N+2                                                                   
      Z=XPT                                                                     
24    GO TO (4,5,6,7),ISW                                                       
4     C(1)=Y(1)                                                                 
      D(1)=1.0D0                                                                
      C(NP1)=0.0D0                                                              
      D(NP1)=0.0D0                                                              
      C(NP2)=0.0D0                                                              
      D(NP2)=0.0D0                                                              
      DO 41 I=2,N                                                               
      C(I)=Y(I)-Y(1)                                                            
41    D(I)=X(I)-X(1)                                                            
      DO 410 I=3,NP2                                                            
      IF(D(I-1).NE.0)GO TO 43                                                   
C      WRITE(NFLAG(18),1001)                                                     
      STOP 'SPLINE 1'                                                           
43    PIVOT=1.0D0/D(I-1)                                                        
      IF(I.GE.NP2)GO TO 45                                                      
      SUPD=X(I-1)-X(I-2)                                                        
      IF(SUPD.GE.0)GO TO 44                                                     
C      WRITE(NFLAG(18),1000)                                                     
      STOP 'SPLINE 2'                                                           
44    SUPD=SUPD*SUPD*SUPD                                                       
      GO TO 46                                                                  
45    SUPD=1.0D0                                                                
46    DFACT=SUPD*PIVOT                                                          
      CFACT=C(I-1)*PIVOT                                                        
      IF(I.GT.N)GO TO 48                                                        
      DO 47 J=I,N                                                               
      V=X(J)-X(I-2)                                                             
      C(J)=C(J)-D(J)*CFACT                                                      
47    D(J)=V*V*V-D(J)*DFACT                                                     
48    CONTINUE                                                                  
      IF(I.GE.NP2)GO TO 49                                                      
      C(NP1)=C(NP1)-D(NP1)*CFACT                                                
      D(NP1)=1.0D0-D(NP1)*DFACT                                                 
49    C(NP2)=C(NP2)-D(NP2)*CFACT                                                
410   D(NP2)=X(I-2)-D(NP2)*DFACT                                                
      DO 411 I=1,N                                                              
      J=NP2-I                                                                   
      IF(J.NE.NP1)GO TO 413                                                     
      V=1.0D0                                                                   
      GO TO 414                                                                 
413   V=X(J)-X(J-1)                                                             
      V=V*V*V                                                                   
414   IF(D(J+1).NE.0)GO TO 415                                                  
C      WRITE(NFLAG(18),1001)                                                     
      STOP 'SPLINE 3'                                                           
415   C(J+1)=C(J+1)/D(J+1)                                                      
411   C(J)=C(J)-C(J+1)*V                                                        
      IF(D(2).NE.0)GO TO 416                                                    
C      WRITE(NFLAG(18),1001)                                                     
      STOP 'SPLINE 4'                                                           
416   C(2)=C(2)/D(2)                                                            
      RETURN                                                                    
5     SPLINE=C(1)+C(2)*(Z-X(1))                                                 
      DO 51 I=1,N                                                               
      V=Z-X(I)                                                                  
      IF(V.GT.0)GO TO 51                                                        
      RETURN                                                                    
51    SPLINE=SPLINE+C(I+2)*V*V*V                                                
      RETURN                                                                    
    6 CONTINUE                                                                  
      SPLINE=C(1)+C(2)*(Z-X(1))                                                 
      DERIV = C(2)/3.D0                                                         
      DO 53 I = 1,N                                                             
      V=Z-X(I)                                                                  
      IF(V.LE.0) RETURN                                                         
      V2 = V*V                                                                  
      SPLINE = SPLINE + C(I+2)*V2*V                                             
      DERIV = DERIV + C(I+2)*V2                                                 
   53 CONTINUE                                                                  
      RETURN                                                                    
    7 CONTINUE                                                                  
      SPLINE = 3.D0*DERIV                                                       
      RETURN                                                                    
1000  FORMAT(1X,5X,'***** ERROR IN SPLINE ... UNORDERED X-VALUES                
     1*****')                                                                   
1001  FORMAT(1X,5X,' ***** ERROR IN SPLINE ... DIVIDE FAULT *****')             
      END                                                                       
C                                                                               
C*****                                                                          
C                                                                               
         BLOCK DATA PTPACM                                                      
         IMPLICIT REAL*8 (A-H,O-Z)                                              
C                                                                               
C         REAL*8 NAB,NAB1,NBC,NBC1,JUNK,HRTREE,BOHR                             
C                                                                               
      CHARACTER*75 REF(5)                                                       
C                                                                               
      PARAMETER (N3ATOM = 75)                                                   
      PARAMETER (ISURF = 5)                                                     
      PARAMETER (JSURF = ISURF*(ISURF+1)/2)                             
      PARAMETER (PI = 3.141592653589793D0)                                      
      PARAMETER (NATOM = 25)                                                    
C                                                                               
      COMMON /PT3CM/ EZERO(ISURF+1)                                             
C                                                                               
      COMMON/INFOCM/ CARTNU(NATOM,3),INDEXES(NATOM),                            
     +               IRCTNT,NATOMS,ICARTR,MDER,MSURF,REF                        
C                                                                               
C                                                                               
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,                                     
     +               NULBL(NATOM),NFLAG(20),                                    
     +               NASURF(ISURF+1,ISURF+1),NDER                               
C                                                                               
      COMMON /ASYCM/ EASYAB,EASYBC,EASYAC                                       
C                                                                               
         COMMON /NSTEP/  STEP                                                   
         COMMON /POTCM/  XBC(3),XAB(3),CBC(3),ABC(3),CAB(3),                    
     +                   AAB(3),PHI(40),BSP(40,3),                              
     +                   DE,BETA,REQ(3),A,GAMMA,RBB,RHH,                        
     +                   R1S,R2S,VSP,DBCOOR(2),NPHI                             
C                                                                               
C   Initialize the flags and the I/O unit numbers for the potential             
C                                                                               
C                                                                               
      DATA NASURF /1,35*0/                                                      
      DATA NDER /0/                                                             
         DATA NFLAG /1,1,15*0,6,0,0/                                            
C                                                                               
      DATA ANUZERO /0.0D0/                                                      
      DATA ICARTR,MSURF,MDER/3,0,1/                                             
      DATA NULBL /25*0/                                                         
      DATA NATOMS /3/                                                           
C                                                                               
         DATA STEP /0.000000008d0/                                              
         DATA NPHI /17/                                                         
         DATA R1S /0.2212079d+01/                                               
         DATA R2S /0.2215309d+01/                                               
         DATA VSP /0.1094890d+03/                                               
         DATA XBC / 0.1094890d+03, 0.1473409d+01, 0.1941998d+01/                
         DATA XAB / 0.1056400d+03, 0.1241479d+01, 0.2304798d+01/                
         DATA CBC /-0.4815674d-01, 0.3814697d-05, 0.4415512d-03/                
         DATA ABC / 0.7873216d+01, 0.7873216d+01, 0.7873216d+01/                
         DATA CAB /-0.1482804d+01,-0.2084732d-02,-0.3727913d-02/                
         DATA AAB / 0.1932070d+01, 0.1932070d+01, 0.1932070d+01/                
         DATA (PHI(I), I=1,17)                                                  
     +            / 0.0000000d+00, 0.2000000d+01,                               
     +              0.4000000d+01, 0.6000000d+01,                               
     +              0.1800000d+02, 0.2400000d+02,                               
     +              0.3000000d+02, 0.3400000d+02,                               
     +              0.3800000d+02, 0.4400000d+02,                               
     +              0.4800000d+02, 0.5400000d+02,                               
     +              0.6000000d+02, 0.7600000d+02,                               
     +              0.8600000d+02, 0.8800000d+02,                               
     +              0.9000000d+02/                                              
                                                                                
         DATA (BSP(I,1),I=1,17)                                                 
     +            / 0.1094409d+03, 0.1094212d+03,                               
     +              0.1094004d+03, 0.1093775d+03,                               
     +              0.1088412d+03, 0.1077417d+03,                               
     +              0.1055117d+03, 0.1030257d+03,                               
     +              0.9966266d+02, 0.9630693d+02,                               
     +              0.9637480d+02, 0.9811765d+02,                               
     +              0.1000138d+03, 0.1029822d+03,                               
     +              0.1038929d+03, 0.1040309d+03,                               
     +              0.1041572d+03/                                              
         DATA (BSP(I,2),I=1,17)                                                 
     +            / 0.1473413d+01, 0.1474257d+01,                               
     +              0.1476847d+01, 0.1481213d+01,                               
     +              0.1545280d+01, 0.1599182d+01,                               
     +              0.1655956d+01, 0.1681611d+01,                               
     +              0.1680401d+01, 0.1626349d+01,                               
     +              0.1572269d+01, 0.1486160d+01,                               
     +              0.1408802d+01, 0.1273705d+01,                               
     +              0.1241724d+01, 0.1239825d+01,                               
     +              0.1239394d+01/                                              
         DATA (BSP(I,3),I=1,17)                                                 
     +        / 0.1942440d+01, 0.1940545d+01,                                   
     +          0.1936212d+01, 0.1929558d+01,                                   
     +          0.1825750d+01, 0.1719964d+01,                                   
     +          0.1603891d+01, 0.1538857d+01,                                   
     +          0.1490752d+01, 0.1525683d+01,                                   
     +          0.1620584d+01, 0.1788983d+01,                                   
     +          0.1942842d+01, 0.2222638d+01,                                   
     +          0.2294156d+01, 0.2299114d+01,                                   
     +          0.2301070d+01/                                                  
C                                                                               
C       DISSOCIATION ENERGY IN KCAL/MOLE                                        
C                                                                               
         DATA DE /106.56d0/                                                     
C                                                                               
C       MORSE BETAS--RECIPROCAL ANGSTROMS                                       
C                                                                               
         DATA BETA /2.07942d0/                                                  
C                                                                               
C       THE EQUILIBRIUM DISTANCES IN ANGSTROMS                                  
C                                                                               
         DATA REQ /0.96966d0,0.74144d0,0.96966d0/                               
C                                                                               
C       PAULING PARAMETER IN ANGSTROMS                                          
C                                                                               
         DATA A /0.26d0/                                                        
C                                                                               
C       GAMMA FOR THE BEND CORRECTION                                           
C       GAMMA IS DIMENSIONLESS AND RANGES FROM .5 TO .65                        
C                                                                               
         DATA GAMMA / 0.4131d0/                                                 
C                                                                               
C       RBB IN ANGSTROMS--THIS NUMBER IS USED IN A SCALING                      
C       CALCULATION FOR THE BENDING CORRECTION                                  
C                                                                               
         DATA RBB / 0.74144d0/                                                  
C                                                                               
         END                                                                    
C                                                                               
C*****                                                                          
      SUBROUTINE POTINFO

      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*75 REF(5)
      PARAMETER (N3ATOM=75)
      PARAMETER (NATOM=25)
      PARAMETER (ISURF = 5)
      PARAMETER (JSURF = ISURF*(ISURF+1)/2)
      PARAMETER (PI = 3.141592653589793D0)
      COMMON /PT1CM/  R(N3ATOM), ENGYGS, DEGSDR(N3ATOM)
      COMMON /PT3CM/  EZERO(ISURF+1)
      COMMON /PT4CM/  ENGYES(ISURF),DEESDR(N3ATOM,ISURF)
      COMMON /PT5CM/  ENGYIJ(JSURF),DEIJDR(N3ATOM,JSURF)
      COMMON/INFOCM/ CARTNU(NATOM,3),INDEXES(NATOM),
     +               IRCTNT,NATOMS,ICARTR,MDER,MSURF,REF
      COMMON/USROCM/ PENGYGS,PENGYES(ISURF),
     +               PENGYIJ(JSURF),
     +               DGSCART(NATOM,3),DESCART(NATOM,3,ISURF),
     +               DIJCART(NATOM,3,JSURF)
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,
     +               NULBL(NATOM),NFLAG(20),
     +               NASURF(ISURF+1,ISURF+1),NDER
      COMMON/UTILCM/ DGSCARTNU(NATOM,3),DESCARTNU(NATOM,3,ISURF),
     +               DIJCARTNU(NATOM,3,JSURF),CNVRTD,CNVRTE,
     +               CNVRTDE,IREORDER,KSDIAG,KEDIAG,KSOFFD,KEOFFD
      write(NFLAG(18),96)
 96   format(/)
      do i =1,5
         write(NFLAG(18),97) REF(i)
      end do
 97   format(2x,a75)
      WRITE(NFLAG(18),96)
      KMAX = 0
      DO I = 1,ISURF+1
         DO J = 1,ISURF+1
            IF(NASURF(I,J).NE.0.AND.KMAX.LT.MAX(I,J)) KMAX = MAX(I,J)
         ENDDO
      ENDDO
      WRITE(NFLAG(18),101) MSURF,KMAX-1
101   FORMAT(2x,' MAX. AND ACTUAL NO. OF EXCITED SURFACES: ',I3,5x,I3)
      IF(KMAX-1.GT.MSURF) THEN
         WRITE(6,*) ' WRONG INPUT ON NUMBER OF EXCITED SURFACES'
         STOP
      ENDIF
      KSDIAG = 0
      KEDIAG = 0
      DO I = 2,ISURF+1
         IF(NASURF(I,I).NE.0) THEN
            KEDIAG = I-1
            IF(KSDIAG.EQ.0) KSDIAG = I-1
         ENDIF
      ENDDO
      KSOFFD = 0
      KEOFFD = 0
      K = 0
      DO I = 1,ISURF
         DO J = I+1,ISURF+1
            K = K+1
            IF(NASURF(I,J)+NASURF(J,I).NE.0) THEN
               KEOFFD = K
               IF(KSOFFD.EQ.0) KSOFFD = K
            ENDIF
         ENDDO
      ENDDO
      WRITE(NFLAG(18),103) MDER,NDER
103   FORMAT(2x,' MAX. AND ACTUAL ORDER OF DERIVATIVES:    ',I3,5x,I3)
      IF(NDER.GT.MDER) THEN
         WRITE(6,*) ' WRONG INPUT ON ORDER OF DERIVATIVES'
         STOP
      ENDIF
      IF(NFLAG(19).EQ.1) THEN
         write(NFLAG(18),100)
 100     format(/)
         write(NFLAG(18),120)
 120     format(2x,'Cartesian coordinates are supplied by',/,
     +          2x,'the user in the array CART.',//)
         write(NFLAG(18),125)
 125     format(2x,'Provide cartesian coordinates in the',/,
     +          2x,'following order using the array CART',//,
     +          2x,' CART(1,1)...CART(1,3)   => ATOM 1',/,
     +          2x,' CART(2,1)...CART(2,3)   => ATOM 2',/,
     +          2x,' CART(3,1)...CART(3,3)   => ATOM 3',/,
     +          2x,' CART(N,1)...CART(N,3)   => ATOM N',/,
     +          2x,'CART(25,1)...CART(25,3)  => ATOM 25',/)
         write(NFLAG(18),130)
 130     format(2x,'If the user wishes to relabel the atoms,',/,
     +          2x,'set the variable IREORDER equal to 1',/,
     +          2x,'in the PARAMETER statement.  The user',/,
     +          2x,'must also specify the new labeling',/,
     +          2x,'scheme.  This is done using the array',/,
     +          2x,'NULBL in the following manner:',//,
     +          2x,'NULBL(i) = j',/,
     +          2x,'where:  i => old index',/,
     +          2x,'        j => new index',//)
         write(NFLAG(18),150)
 150     format(2x,'Cartesian coordinates can be provided to',/,
     +          2x,'the potential routine in a variety of units.',/,
     +          2x,'The input units will be converted to Bohr',/,
     +          2x,'based on the following values of the NFLAG',/,
     +          2x,'variable:',//,
     +          2x,'NFLAG(1)  =  1  =>  CARTESIANS IN BOHR (no',/,
     +          2x,'                    conversion required)',/,
     +          2x,'NFLAG(1)  =  2  =>  CARTESIANS IN ANGSTROMS',//)
         write(NFLAG(18),160)
 160     format(2x,'The value of the energy and derivatives',/,
     +          2x,'(if computed) can be reported in a variety',/,
     +          2x,'units.  A units conversion will take place',/,
     +          2x,'as specified by the following values of the',/,
     +          2x,'NFLAG variable:',//,
     +          2x,'NFLAG(2) = 1 =>  ENERGIES REPORTED IN HARTEEE',/,
     +          2x,'NFLAG(2) = 2 =>  ENERGIES REPORTED IN mHARTREE',/,
     +          2x,'NFLAG(2) = 3 =>  ENERGIES REPORTED IN eV',/,
     +          2x,'NFLAG(2) = 4 =>  ENERGIES REPORTED IN kcal/mol',/,
     +          2x,'NFLAG(2) = 5 =>  ENERGIES REPORTED IN cm**-1',//)
         write(NFLAG(18),165)
 165     format(2x,'A units conversion will take place',/,
     +       2x,'as specified by the following values of the',/,
     +       2x,'NFLAG variable:',//,
     +       2x,'NFLAG(1)=1 & NFLAG(2)=1 => DERIVATIVES REPORTED IN',/,
     +       2x,'                           HARTEEE/BOHR',/,
     +       2x,'NFLAG(1)=1 & NFLAG(2)=2 => DERIVATIVES REPORTED IN',/,
     +       2x,'                           mHARTREE/BOHR',/,
     +       2x,'NFLAG(1)=1 & NFLAG(2)=3 => DERIVATIVES REPORTED IN',/,
     +       2x,'                           eV/BOHR',/,
     +       2x,'NFLAG(1)=1 & NFLAG(2)=4 => DERIVATIVES REPORTED IN',/,
     +       2x,'                           kcal/mol/BOHR',/,
     +       2x,'NFLAG(1)=1 & NFLAG(2)=5 => DERIVATIVES REPORTED IN',/,
     +       2x,'                           cm**-1/BOHR',//)
         write(NFLAG(18),170)
 170     format(2x,'A units conversion will take place',/,
     +       2x,'as specified by the following values of the',/,
     +       2x,'NFLAG variable:',//,
     +       2x,'NFLAG(1)=2 & NFLAG(2)=1 => DERIVATIVES REPORTED IN',/,
     +       2x,'                           HARTEEE/ANGSTROM',/,
     +       2x,'NFLAG(1)=2 & NFLAG(2)=2 => DERIVATIVES REPORTED IN',/,
     +       2x,'                           mHARTREE/ANGSTROM',/,
     +       2x,'NFLAG(1)=2 & NFLAG(2)=3 => DERIVATIVES REPORTED IN',/,
     +       2x,'                           eV/ANGSTROM',/,
     +       2x,'NFLAG(1)=2 & NFLAG(2)=4 => DERIVATIVES REPORTED IN',/,
     +       2x,'                           kcal/mol/ANGSTROM',/,
     +       2x,'NFLAG(1)=2 & NFLAG(2)=5 => DERIVATIVES REPORTED IN',/,
     +       2x,'                           cm**-1/ANGSTROM',//)
      ENDIF
      RETURN
      END


      SUBROUTINE ANCVRT
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*75 REF(5)
      CHARACTER*3 PERIODIC_1(7,32)
      PARAMETER (N3ATOM=75)
      PARAMETER (NATOM=25)
      PARAMETER (ISURF = 5)
      PARAMETER (JSURF = ISURF*(ISURF+1)/2)
      CHARACTER*2 NAME1(NATOM)
      CHARACTER*2 NAME2(NATOM)
      CHARACTER*1 IBLANK
      CHARACTER*20 DISTANCE
      CHARACTER*20 UNITS
      COMMON /PT1CM/  R(N3ATOM), ENGYGS, DEGSDR(N3ATOM)
      COMMON /PT3CM/  EZERO(ISURF+1)
      COMMON /PT4CM/  ENGYES(ISURF),DEESDR(N3ATOM,ISURF)
      COMMON /PT5CM/  ENGYIJ(JSURF),DEIJDR(N3ATOM,JSURF)
      COMMON/USROCM/ PENGYGS,PENGYES(ISURF),
     +               PENGYIJ(JSURF),
     +               DGSCART(NATOM,3),DESCART(NATOM,3,ISURF),
     +               DIJCART(NATOM,3,JSURF)
      COMMON/UTILCM/ DGSCARTNU(NATOM,3),DESCARTNU(NATOM,3,ISURF),
     +               DIJCARTNU(NATOM,3,JSURF),CNVRTD,CNVRTE,
     +               CNVRTDE,IREORDER,KSDIAG,KEDIAG,KSOFFD,KEOFFD
      COMMON/INFOCM/ CARTNU(NATOM,3),INDEXES(NATOM),
     +               IRCTNT,NATOMS,ICARTR,MDER,MSURF,REF
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,
     +               NULBL(NATOM),NFLAG(20),
     +               NASURF(ISURF+1,ISURF+1),NDER
      DIMENSION IANUM(7,32)
      DIMENSION ISAVE(NATOM),JSAVE(NATOM)
      PARAMETER(        PI = 3.141592653589793D0)
      PARAMETER(    CLIGHT = 2.99792458D08)
      PARAMETER(     CMU_0 = 4.0D0*PI*1.0D-07)
      PARAMETER(CEPSILON_0 = 1.0D0/(CMU_0*CLIGHT**2))
      PARAMETER(        CE = 1.602176462D-19)
      PARAMETER(   CPLANCK = 6.62606876D-34)
      PARAMETER(      CM_E = 9.10938188D-31)
      PARAMETER(      CANG = 1.0D-10)
      PARAMETER( CAVOGADRO = 6.02214199D23)
      PARAMETER(     CKCAL = 4.184D10)
      PARAMETER(  HTOMILLH = 1000.D0)
      PARAMETER(     HTOEV = 27.2113834D0)
      PARAMETER(   HTOKCAL = 627.509470D0)
      PARAMETER(   HTOWAVE = 219474.631D0)
      PARAMETER(     HTOKJ = 2625.49962D0)
      PARAMETER(    BOHR_A = .5291772083D0)
      DO I=1,7
         DO J=1,32
            IANUM(I,J)=0
            PERIODIC_1(I,J)=' '
         END DO
      END DO
      DISTANCE = 'BOHR                '
      UNITS    = 'HARTREE             '
      IANUM(1,1)  =  1
      IANUM(1,32) =  2
      IANUM(2,1)  =  3
      IANUM(2,2)  =  4
      IANUM(2,27) =  5
      IANUM(2,28) =  6
      IANUM(2,29) =  7
      IANUM(2,30) =  8
      IANUM(2,31) =  9
      IANUM(2,32) = 10
      IANUM(3,1)  = 11
      IANUM(3,2)  = 12
      IANUM(3,27) = 13
      IANUM(3,28) = 14
      IANUM(3,29) = 15
      IANUM(3,30) = 16
      IANUM(3,31) = 17
      IANUM(3,32) = 18
      IANUM(4,1)  = 19
      IANUM(4,2)  = 20
      IANUM(4,17) = 21
      IANUM(4,18) = 22
      IANUM(4,19) = 23
      IANUM(4,20) = 24
      IANUM(4,21) = 25
      IANUM(4,22) = 26
      IANUM(4,23) = 27
      IANUM(4,24) = 28
      IANUM(4,25) = 29
      IANUM(4,26) = 30
      IANUM(4,27) = 31
      IANUM(4,28) = 32
      IANUM(4,29) = 33
      IANUM(4,30) = 34
      IANUM(4,31) = 35
      IANUM(4,32) = 36
      IANUM(5,1)  = 37
      IANUM(5,2)  = 38
      IANUM(5,17) = 39
      IANUM(5,18) = 40
      IANUM(5,19) = 41
      IANUM(5,20) = 42
      IANUM(5,21) = 43
      IANUM(5,22) = 44
      IANUM(5,23) = 45
      IANUM(5,24) = 46
      IANUM(5,25) = 47
      IANUM(5,26) = 48
      IANUM(5,27) = 49
      IANUM(5,28) = 50
      IANUM(5,29) = 51
      IANUM(5,30) = 52
      IANUM(5,31) = 53
      IANUM(5,32) = 54
      IANUM(6,1)  = 55
      IANUM(6,2)  = 56
      IANUM(6,3)  = 57
      IANUM(6,4)  = 58
      IANUM(6,5)  = 59
      IANUM(6,6)  = 60
      IANUM(6,7)  = 61
      IANUM(6,8)  = 62
      IANUM(6,9)  = 63
      IANUM(6,10) = 64
      IANUM(6,11) = 65
      IANUM(6,12) = 66
      IANUM(6,13) = 67
      IANUM(6,14) = 68
      IANUM(6,15) = 69
      IANUM(6,16) = 70
      IANUM(6,17) = 71
      IANUM(6,18) = 72
      IANUM(6,19) = 73
      IANUM(6,20) = 74
      IANUM(6,21) = 75
      IANUM(6,22) = 76
      IANUM(6,23) = 77
      IANUM(6,24) = 78
      IANUM(6,25) = 79
      IANUM(6,26) = 80
      IANUM(6,27) = 81
      IANUM(6,28) = 82
      IANUM(6,29) = 83
      IANUM(6,30) = 84
      IANUM(6,31) = 85
      IANUM(6,32) = 86
      IANUM(7,1)  = 87
      IANUM(7,2)  = 88
      IANUM(7,3)  = 89
      IANUM(7,4)  = 90
      IANUM(7,5)  = 91
      IANUM(7,6)  = 92
      IANUM(7,7)  = 93
      IANUM(7,8)  = 94
      IANUM(7,9)  = 95
      IANUM(7,10) = 96
      IANUM(7,11) = 97
      IANUM(7,12) = 98
      IANUM(7,13) = 99
      IANUM(7,14) = 100
      IANUM(7,15) = 101
      IANUM(7,16) = 102
      IANUM(7,17) = 103
      IANUM(7,18) = 104
      IANUM(7,19) = 105
      IANUM(7,20) = 106
      IANUM(7,21) = 107
      IANUM(7,22) = 108
      IANUM(7,23) = 109
      IANUM(7,24) = 110
      IANUM(7,25) = 111
      IANUM(7,26) = 112
      IANUM(7,27) = 113
      IANUM(7,28) = 114
      IANUM(7,29) = 115
      IANUM(7,30) = 116
      IANUM(7,31) = 117
      IANUM(7,32) = 120
      PERIODIC_1(1,1)   = 'H  '
      PERIODIC_1(1,32)  = 'He '
      PERIODIC_1(2,1)   = 'Li '
      PERIODIC_1(2,2)   = 'Be '
      PERIODIC_1(2,27)  = 'B  '
      PERIODIC_1(2,28)  = 'C  '
      PERIODIC_1(2,29)  = 'N  '
      PERIODIC_1(2,30)  = 'O  '
      PERIODIC_1(2,31)  = 'F  '
      PERIODIC_1(2,32)  = 'Ne '
      PERIODIC_1(3,1)   = 'Na '
      PERIODIC_1(3,2)   = 'Mg '
      PERIODIC_1(3,27)  = 'Al '
      PERIODIC_1(3,28)  = 'Si '
      PERIODIC_1(3,29)  = 'P  '
      PERIODIC_1(3,30)  = 'S  '
      PERIODIC_1(3,31)  = 'Cl '
      PERIODIC_1(3,32)  = 'Ar '
      PERIODIC_1(4,1)   = 'K  '
      PERIODIC_1(4,2)   = 'Ca '
      PERIODIC_1(4,17)  = 'Sc '
      PERIODIC_1(4,18)  = 'Ti '
      PERIODIC_1(4,19)  = 'V  '
      PERIODIC_1(4,20)  = 'Cr '
      PERIODIC_1(4,21)  = 'Mn '
      PERIODIC_1(4,22)  = 'Fe '
      PERIODIC_1(4,23)  = 'Co '
      PERIODIC_1(4,24)  = 'Ni '
      PERIODIC_1(4,25)  = 'Cu '
      PERIODIC_1(4,26)  = 'Zn '
      PERIODIC_1(4,27)  = 'Ga '
      PERIODIC_1(4,28)  = 'Ge '
      PERIODIC_1(4,29)  = 'As '
      PERIODIC_1(4,30)  = 'Se '
      PERIODIC_1(4,31)  = 'Br '
      PERIODIC_1(4,32)  = 'Kr '
      PERIODIC_1(5,1)   = 'Rb '
      PERIODIC_1(5,2)   = 'Sr '
      PERIODIC_1(5,17)  = 'Y  '
      PERIODIC_1(5,18)  = 'Zr '
      PERIODIC_1(5,19)  = 'Nb '
      PERIODIC_1(5,20)  = 'Mo '
      PERIODIC_1(5,21)  = 'Tc '
      PERIODIC_1(5,22)  = 'Ru '
      PERIODIC_1(5,23)  = 'Rh '
      PERIODIC_1(5,24)  = 'Pd '
      PERIODIC_1(5,25)  = 'Ag '
      PERIODIC_1(5,26)  = 'Cd '
      PERIODIC_1(5,27)  = 'In '
      PERIODIC_1(5,28)  = 'Sn '
      PERIODIC_1(5,29)  = 'Sb '
      PERIODIC_1(5,30)  = 'Te '
      PERIODIC_1(5,31)  = 'I  '
      PERIODIC_1(5,32)  = 'Xe '
      PERIODIC_1(5,32)  = 'Xe '
      DO I=1,NATOMS
         ISAVE(I)=0
         JSAVE(I)=0
         NAME1(I)='  '
         NAME2(I)='  '
      END DO
      IBLANK=' '
      DO IND=1,NATOMS
         DO I=1,7
            DO J=1,32
               IF(INDEXES(IND).EQ.IANUM(I,J)) THEN
                  ISAVE(IND)=I
                  JSAVE(IND)=J
               END IF
            END DO
         END DO
      END DO
 
      DO IND=1,NATOMS
         IND2=NULBL(IND)
         IF(IND2.EQ.0) IND2=IND
      END DO
      INC1=0
      DO IND=1,IRCTNT-1
         INC1=INC1+1
         NAME1(INC1)=PERIODIC_1(ISAVE(IND),JSAVE(IND))(:2)
      END DO
      INC2=0
      DO IND=IRCTNT,NATOMS
         INC2=INC2+1
         NAME2(INC2)=PERIODIC_1(ISAVE(IND),JSAVE(IND))(:2)
      END DO
      IF(NFLAG(1).EQ.2) DISTANCE = 'ANGSTROMS           '
      IF(NFLAG(2).EQ.2) THEN
         UNITS = 'MILLIHARTREE        '
      ELSEIF(NFLAG(2).EQ.3) THEN
         UNITS = 'EV                  '
      ELSEIF(NFLAG(2).EQ.4) THEN
         UNITS = 'KCAL PER MOLE       '
      ELSEIF(NFLAG(2).EQ.5) THEN
         UNITS = 'WAVENUMBERS         '
      ELSEIF(NFLAG(2).EQ.6) THEN
         UNITS = 'KILOJOULES PER MOLE '
      ENDIF
      CNVRTD = 1.D0
      CNVRTE = 1.D0
      CNVRTDE = 1.D0
      IF(NFLAG(1).EQ.2) CNVRTD = BOHR_A
      IF(NFLAG(2).EQ.2) THEN
         CNVRTE = CNVRTE*HTOMILLH
      ELSEIF(NFLAG(2).EQ.3) THEN
         CNVRTE = CNVRTE*HTOEV
      ELSEIF(NFLAG(2).EQ.4) THEN
         CNVRTE = CNVRTE*HTOKCAL
      ELSEIF(NFLAG(2).EQ.5) THEN
         CNVRTE = CNVRTE*HTOWAVE
      ELSEIF(NFLAG(2).EQ.6) THEN
         CNVRTE = CNVRTE*HTOKJ
      ENDIF
      CNVRTDE = CNVRTE/CNVRTD
      ISUM = 0
      DO INU=1,25
         ISUM=ISUM + NULBL(INU)
      END DO
      IREORDER = 0
      IF(ISUM.NE.0) IREORDER = 1
      RETURN
      END
      SUBROUTINE CARTOU
      IMPLICIT REAL*8(A-H,O-Z)
      CHARACTER*75 REF(5)
      PARAMETER (N3ATOM=75)
      PARAMETER (NATOM=25)
      PARAMETER (ISURF = 5)
      PARAMETER (JSURF = ISURF*(ISURF+1)/2)
      COMMON/INFOCM/ CARTNU(NATOM,3),INDEXES(NATOM),
     +               IRCTNT,NATOMS,ICARTR,MDER,MSURF,REF
      COMMON/UTILCM/ DGSCARTNU(NATOM,3),DESCARTNU(NATOM,3,ISURF),
     +               DIJCARTNU(NATOM,3,JSURF),CNVRTD,CNVRTE,
     +               CNVRTDE,IREORDER,KSDIAG,KEDIAG,KSOFFD,KEOFFD
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,
     +               NULBL(NATOM),NFLAG(20),
     +               NASURF(ISURF+1,ISURF+1),NDER
      IF (IREORDER.EQ.1) THEN
          DO I=1,NATOMS
             DO J=1,3
                CARTNU(NULBL(I),J)=CART(I,J)/CNVRTD
             END DO
          END DO
      ELSE
          DO I=1,NATOMS
             DO J=1,3
                CARTNU(I,J)=CART(I,J)/CNVRTD
             END DO
          END DO
      END IF
      RETURN
      END
 
      SUBROUTINE CARTTOR
      IMPLICIT REAL*8(A-H,O-Z)
      CHARACTER*75 REF(5)
      PARAMETER (N3ATOM=75)
      PARAMETER (NATOM=25)
      PARAMETER (ISURF=5)
      COMMON /PT1CM/  R(N3ATOM), ENGYGS, DEGSDR(N3ATOM)
      COMMON/INFOCM/ CARTNU(NATOM,3),INDEXES(NATOM),
     +               IRCTNT,NATOMS,ICARTR,MDER,MSURF,REF
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,
     +               NULBL(NATOM),NFLAG(20),
     +               NASURF(ISURF+1,ISURF+1),NDER
      IF(ICARTR.EQ.1) THEN
         DO I=1,NATOMS
            IND=3*I-2
            R(IND)   = CARTNU(I,1)
            R(IND+1) = CARTNU(I,2)
            R(IND+2) = CARTNU(I,3)
         END DO
      ELSEIF(ICARTR.EQ.2) THEN
         I = 1                                                       
         DO K=1,NATOMS-1
            DO L = K+1,NATOMS                                  
               R(I) = SQRT( (CARTNU(K,1)-CARTNU(L,1))**2 +
     +                      (CARTNU(K,2)-CARTNU(L,2))**2 +
     +                      (CARTNU(K,3)-CARTNU(L,3))**2 )
               I = I + 1                  
            END DO
         ENDDO
      ELSEIF(ICARTR.EQ.3) THEN
         R(1) = SQRT( (CARTNU(1,1)-CARTNU(2,1))**2 +
     +                (CARTNU(1,2)-CARTNU(2,2))**2 +
     +                (CARTNU(1,3)-CARTNU(2,3))**2 )
         R(2) = SQRT( (CARTNU(2,1)-CARTNU(3,1))**2 +
     +                (CARTNU(2,2)-CARTNU(3,2))**2 +
     +                (CARTNU(2,3)-CARTNU(3,3))**2 )
         R(3) = SQRT( (CARTNU(1,1)-CARTNU(3,1))**2 +
     +                (CARTNU(1,2)-CARTNU(3,2))**2 +
     +                (CARTNU(1,3)-CARTNU(3,3))**2 )
      ELSEIF(ICARTR.EQ.4) THEN
      FLM=18.99840D0
      HYM=1.007825D0
      XCM1=(HYM*CARTNU(1,1)+FLM*CARTNU(2,1))/(FLM+HYM)
      YCM1=(HYM*CARTNU(1,2)+FLM*CARTNU(2,2))/(FLM+HYM)
      ZCM1=(HYM*CARTNU(1,3)+FLM*CARTNU(2,3))/(FLM+HYM)
      XCM2=(HYM*CARTNU(3,1)+FLM*CARTNU(4,1))/(FLM+HYM)
      YCM2=(HYM*CARTNU(3,2)+FLM*CARTNU(4,2))/(FLM+HYM)
      ZCM2=(HYM*CARTNU(3,3)+FLM*CARTNU(4,3))/(FLM+HYM)
      XCM3=XCM2-XCM1
      YCM3=YCM2-YCM1
      ZCM3=ZCM2-ZCM1
      XRM1=CARTNU(1,1)-XCM1
      YRM1=CARTNU(1,2)-YCM1
      ZRM1=CARTNU(1,3)-ZCM1
      THETA1=(XRM1*XCM3+YRM1*YCM3+ZRM1*ZCM3)
      THETA1=THETA1/(SQRT(XRM1**2+YRM1**2+ZRM1**2))
      THETA1=THETA1/(SQRT(XCM3**2+YCM3**2+ZCM3**2))
      IF(THETA1.GT.1.0D0)THETA1=1.0D0
      IF(THETA1.LT.-1.0D0)THETA1=-1.0D0
      THETA1=ACOS(THETA1)
      XRM2=CARTNU(3,1)-XCM2
      YRM2=CARTNU(3,2)-YCM2
      ZRM2=CARTNU(3,3)-ZCM2
      THETA2=(XRM2*(-XCM3)+YRM2*(-YCM3)+ZRM2*(-ZCM3))
      THETA2=THETA2/(SQRT(XRM2**2+YRM2**2+ZRM2**2))
      THETA2=THETA2/(SQRT(XCM3**2+YCM3**2+ZCM3**2))
      IF(THETA2.GT.1.0D0)THETA2=1.0D0
      IF(THETA2.LT.-1.0D0)THETA2=-1.0D0
      THETA2=ACOS(THETA2)
      PI=ACOS(-1.0D0)
      THETA2=PI-THETA2
      Q1=SQRT(XRM1**2+YRM1**2+ZRM1**2)
      Q2=SQRT(XRM2**2+YRM2**2+ZRM2**2)
      CMM=(XCM3**2+YCM3**2+ZCM3**2)
      CMM=SQRT(CMM)
      HHD=(CARTNU(1,1)-CARTNU(3,1))**2 +
     +    (CARTNU(1,2)-CARTNU(3,2))**2 +
     +    (CARTNU(1,3)-CARTNU(3,3))**2
      HHD=SQRT(HHD)
      Q=CMM-Q1*COS(THETA1)+Q2*COS(THETA2)
      Q3=SQRT(ABS(HHD**2-Q**2))
      Q1=Q1*SIN(THETA1)
      Q2=Q2*SIN(THETA2)
      CPHI=(Q1**2+Q2**2-Q3**2)/(2.*Q1*Q2)
      IF(CPHI.LT.-1.0D0)CPHI=-1.0D0
      IF(CPHI.GT.1.0D0)CPHI=1.0D0
      PHI=ACOS(CPHI)
 2001 FORMAT(6F12.8)
      R(1)=SQRT(XCM3**2+YCM3**2+ZCM3**2)
      R(2)=(SQRT(XRM1**2+YRM1**2+ZRM1**2))*(FLM+HYM)/FLM
      R(3)=(SQRT(XRM2**2+YRM2**2+ZRM2**2))*(FLM+HYM)/FLM
      R(4)=THETA1
      R(5)=THETA2
      R(6)=PHI
      ELSEIF(ICARTR.NE.0) THEN
         WRITE(NFLAG(18),1000) ICARTR
 1000    FORMAT(2X,'WRONG ICARTR FOR CARTNU; ICARTR =',I5//)
         STOP
      ENDIF
      RETURN
      END
 
 
      SUBROUTINE EUNITZERO
      IMPLICIT REAL*8(A-H,O-Z)
      CHARACTER*75 REF(5)
      PARAMETER (N3ATOM=75)
      PARAMETER (NATOM=25)
      PARAMETER (ISURF = 5)
      PARAMETER (JSURF = ISURF*(ISURF+1)/2)
 
      COMMON /PT1CM/  R(N3ATOM), ENGYGS, DEGSDR(N3ATOM)
      COMMON /PT3CM/  EZERO(ISURF+1)
      COMMON /PT4CM/  ENGYES(ISURF),DEESDR(N3ATOM,ISURF)
      COMMON /PT5CM/  ENGYIJ(JSURF),DEIJDR(N3ATOM,JSURF)
      COMMON/UTILCM/ DGSCARTNU(NATOM,3),DESCARTNU(NATOM,3,ISURF),
     +               DIJCARTNU(NATOM,3,JSURF),CNVRTD,CNVRTE,
     +               CNVRTDE,IREORDER,KSDIAG,KEDIAG,KSOFFD,KEOFFD
      COMMON/USROCM/ PENGYGS,PENGYES(ISURF),
     +               PENGYIJ(JSURF),
     +               DGSCART(NATOM,3),DESCART(NATOM,3,ISURF),
     +               DIJCART(NATOM,3,JSURF)
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,
     +               NULBL(NATOM),NFLAG(20),
     +               NASURF(ISURF+1,ISURF+1),NDER
      PENGYGS = ENGYGS * CNVRTE - ANUZERO
      IF(KSDIAG.NE.0) THEN
         DO I=KSDIAG,KEDIAG
            PENGYES(I) = ENGYES(I) * CNVRTE - ANUZERO
         END DO
      ENDIF
      IF(KSOFFD.NE.0) THEN
         DO J=KSOFFD,KEOFFD
            PENGYIJ(J) = ENGYIJ(J) * CNVRTE
         END DO
      ENDIF
      RETURN
      END
 
      SUBROUTINE RTOCART
      IMPLICIT REAL*8(A-H,O-Z)
      CHARACTER*75 REF(5)
      PARAMETER (N3ATOM=75)
      PARAMETER (NATOM=25)
      PARAMETER (ISURF = 5)
      PARAMETER (JSURF = ISURF*(ISURF+1)/2)
      COMMON /PT1CM/  R(N3ATOM), ENGYGS, DEGSDR(N3ATOM)
      COMMON /PT3CM/  EZERO(ISURF+1)
      COMMON /PT4CM/  ENGYES(ISURF),DEESDR(N3ATOM,ISURF)
      COMMON /PT5CM/  ENGYIJ(JSURF),DEIJDR(N3ATOM,JSURF)
      COMMON /UTILCM/ DGSCARTNU(NATOM,3),DESCARTNU(NATOM,3,ISURF),
     +                DIJCARTNU(NATOM,3,JSURF),CNVRTD,CNVRTE,CNVRTDE,
     +                IREORDER,KSDIAG,KEDIAG,KSOFFD,KEOFFD
      COMMON/INFOCM/ CARTNU(NATOM,3),INDEXES(NATOM),
     +               IRCTNT,NATOMS,ICARTR,MDER,MSURF,REF
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,
     +               NULBL(NATOM),NFLAG(20),
     +               NASURF(ISURF+1,ISURF+1),NDER
      DIMENSION YGS(N3ATOM),YES(N3ATOM,ISURF),YIJ(N3ATOM,JSURF)
      IF(ICARTR.EQ.1) THEN
         DO I = 1, NATOMS
            IND=3*I-2
            DGSCARTNU(I,1) = DEGSDR(IND)
            DGSCARTNU(I,2) = DEGSDR(IND+1)
            DGSCARTNU(I,3) = DEGSDR(IND+2)
            IF(KSDIAG.NE.0) THEN
               DO J = KSDIAG,KEDIAG
                  DESCARTNU(I,1,J) = DEESDR(IND,J)
                  DESCARTNU(I,2,J) = DEESDR(IND+1,J)
                  DESCARTNU(I,3,J) = DEESDR(IND+2,J)
               END DO
            ENDIF
            IF(KEOFFD.NE.0) THEN
               DO K = KSOFFD,KEOFFD
                  DIJCARTNU(I,1,K) = DEIJDR(IND,K)
                  DIJCARTNU(I,2,K) = DEIJDR(IND+1,K)
                  DIJCARTNU(I,3,K) = DEIJDR(IND+2,K)
               END DO
            ENDIF
         END DO
      ELSEIF(ICARTR.EQ.2) THEN
         DO I = 1, NATOMS         
            DGSCARTNU(I,1) = 0.D0
            DGSCARTNU(I,2) = 0.D0
            DGSCARTNU(I,3) = 0.D0
            IF(KSDIAG.NE.0) THEN
               DO J1=KSDIAG,KEDIAG
                  DESCARTNU(I,1,J1) = 0.D0
                  DESCARTNU(I,2,J1) = 0.D0
                  DESCARTNU(I,3,J1) = 0.D0
               ENDDO
            ENDIF
            IF(KSOFFD.NE.0) THEN
               DO J2=KSOFFD,KEOFFD
                  DIJCARTNU(I,1,J2) = 0.D0
                  DIJCARTNU(I,2,J2) = 0.D0
                  DIJCARTNU(I,3,J2) = 0.D0
               ENDDO
            ENDIF
            DO J = 1,NATOMS
               IF(J.LT.I) THEN
                  M1 = NATOMS*(J-1) - (J*(J-1))/2 + I-J
               ELSEIF(J.GT.I) THEN
                  M1 = NATOMS*(I-1) - (I*(I-1))/2 + J-I
               ELSE
                  GO TO 20
               ENDIF
               Y = DEGSDR(M1)
               TERMX = (CARTNU(I,1)-CARTNU(J,1))/R(M1)
               TERMY = (CARTNU(I,2)-CARTNU(J,2))/R(M1)
               TERMZ = (CARTNU(I,3)-CARTNU(J,3))/R(M1)
               DGSCARTNU(I,1) = DGSCARTNU(I,1) + TERMX*Y
               DGSCARTNU(I,2) = DGSCARTNU(I,2) + TERMY*Y
               DGSCARTNU(I,3) = DGSCARTNU(I,3) + TERMZ*Y
               IF(KSDIAG.GT.0) THEN
                  Y = DEESDR(M1,J1)
                  DO J1=KSDIAG,KEDIAG
                     DESCARTNU(I,1,J1)=DESCARTNU(I,1,J1) + TERMX*Y
                     DESCARTNU(I,2,J1)=DESCARTNU(I,2,J1) + TERMY*Y
                     DESCARTNU(I,3,J1)=DESCARTNU(I,3,J1) + TERMZ*Y
                  ENDDO
               ELSEIF(KSOFFD.GT.0) THEN
                  DO J2=KSOFFD,KEOFFD
                     Y = DEIJDR(M1,J2)
                     DIJCARTNU(I,1,J2)=DIJCARTNU(I,1,J2) + TERMX*Y
                     DIJCARTNU(I,2,J2)=DIJCARTNU(I,2,J2) + TERMY*Y
                     DIJCARTNU(I,3,J2)=DIJCARTNU(I,3,J2) + TERMZ*Y
                  ENDDO
               ENDIF
20             CONTINUE
            ENDDO
         ENDDO
      ELSEIF(ICARTR.EQ.3) THEN
         DO I = 1, NATOMS
            YGS(I) = DEGSDR(I)/R(I)
            IF(KSDIAG.NE.0) THEN
               DO J=KSDIAG,KEDIAG
                  YES(I,J) = DEESDR(I,J)/R(I)
               ENDDO
            ENDIF
            IF(KSOFFD.NE.0) THEN
               DO K=KSOFFD,KEOFFD
                  YIJ(I,K) = DEIJDR(I,K)/R(I)
               ENDDO
            ENDIF
         ENDDO
         DO K = 1,3
            TERM12 = CARTNU(1,K)-CARTNU(2,K)
            TERM23 = CARTNU(2,K)-CARTNU(3,K)
            TERM13 = CARTNU(1,K)-CARTNU(3,K)
            DGSCARTNU(1,K) = TERM12*YGS(1) + TERM13*YGS(3)
            DGSCARTNU(2,K) =-TERM12*YGS(1) + TERM23*YGS(2)
            DGSCARTNU(3,K) =-TERM13*YGS(3) - TERM23*YGS(2)
            IF(KSDIAG.NE.0) THEN
               DO J1=KSDIAG,KEDIAG
                 DESCARTNU(1,K,J1) = TERM12*YES(1,J1) + TERM13*YES(3,J1)
                 DESCARTNU(2,K,J1) =-TERM12*YES(1,J1) + TERM23*YES(2,J1)
                 DESCARTNU(3,K,J1) =-TERM13*YES(3,J1) - TERM23*YES(2,J1)
               ENDDO
            ENDIF
            IF(KSOFFD.NE.0) THEN
               DO J2=KSOFFD,KEOFFD
                 DIJCARTNU(1,K,J2) = TERM12*YIJ(1,J2) + TERM13*YIJ(3,J2)
                 DIJCARTNU(2,K,J2) =-TERM12*YIJ(1,J2) + TERM23*YIJ(2,J2)
                 DIJCARTNU(3,K,J2) =-TERM13*YIJ(3,J2) - TERM23*YIJ(2,J2)
               ENDDO
            ENDIF
         ENDDO
      ELSEIF(ICARTR.EQ.4) THEN
      WH=1.007825D0
      WF=18.99840D0
      SUM=WH+WF
      EPS=WF/SUM
      EPSP=WH/SUM
      U1=COS(THETA1)
      U2=COS(THETA2)
      U3=COS(PHI)
      SS1=SIN(THETA1)
      SS2=SIN(THETA2)
      SS3=SIN(PHI)
      YA=0.0D0
      YB=0.0D0
      T0=R1*U1
      ZA=-EPSP*T0
      ZB=EPS*T0
      T0=R1*SS1
      XA=-EPSP*T0
      XBB=EPS*T0
      T0=R2*SS2
      T1=T0*U3
      XC=-EPSP*T1
      XD=EPS*T1
      T1=T0*SS3
      YC=-EPSP*T1
      YD=EPS*T1
      T0=R2*U2
      ZC=-EPSP*T0+RCM
      ZD=EPS*T0+RCM
      RFF=SQRT((XA-XC)**2+YC**2+(ZA-ZC)**2)
      ELSE
          WRITE(NFLAG(18),1000) ICARTR
1000      FORMAT(2X,' WRONG ICARTR FOR DERIVATIVE; ICARTR =',I5//)
          STOP
      ENDIF
      RETURN
      END
 
      SUBROUTINE DEDCOU
      IMPLICIT REAL*8(A-H,O-Z)
      CHARACTER*75 REF(5)
      PARAMETER (N3ATOM=75)
      PARAMETER (NATOM=25)
      PARAMETER (ISURF = 5)
      PARAMETER (JSURF = ISURF*(ISURF+1)/2)
      COMMON /UTILCM/ DGSCARTNU(NATOM,3),DESCARTNU(NATOM,3,ISURF),
     +                DIJCARTNU(NATOM,3,JSURF),CNVRTD,CNVRTE,CNVRTDE,
     +                IREORDER,KSDIAG,KEDIAG,KSOFFD,KEOFFD
      COMMON/USROCM/ PENGYGS,PENGYES(ISURF),
     +               PENGYIJ(JSURF),
     +               DGSCART(NATOM,3),DESCART(NATOM,3,ISURF),
     +               DIJCART(NATOM,3,JSURF)
      COMMON/INFOCM/ CARTNU(NATOM,3),INDEXES(NATOM),
     +               IRCTNT,NATOMS,ICARTR,MDER,MSURF,REF
      COMMON/USRICM/ CART(NATOM,3),ANUZERO,
     +               NULBL(NATOM),NFLAG(20),
     +               NASURF(ISURF+1,ISURF+1),NDER
      IF (IREORDER.EQ.1) THEN
         DO I = 1, NATOMS
            DGSCART(I,1) = DGSCARTNU(NULBL(I),1) * CNVRTDE
            DGSCART(I,2) = DGSCARTNU(NULBL(I),2) * CNVRTDE
            DGSCART(I,3) = DGSCARTNU(NULBL(I),3) * CNVRTDE
            IF(KSDIAG.NE.0) THEN
               DO J=KSDIAG,KEDIAG
                  DESCART(I,1,J) = DESCARTNU(NULBL(I),1,J) * CNVRTDE
                  DESCART(I,2,J) = DESCARTNU(NULBL(I),2,J) * CNVRTDE
                  DESCART(I,3,J) = DESCARTNU(NULBL(I),3,J) * CNVRTDE
               END DO
            ENDIF
            IF(KSOFFD.NE.0) THEN
               DO K=KSOFFD,KEOFFD
                  DIJCART(I,1,K) = DIJCARTNU(NULBL(I),1,K) * CNVRTDE
                  DIJCART(I,2,K) = DIJCARTNU(NULBL(I),2,K) * CNVRTDE
                  DIJCART(I,3,K) = DIJCARTNU(NULBL(I),3,K) * CNVRTDE
               END DO
            ENDIF
         END DO
      ELSE
         DO I = 1, NATOMS
            DGSCART(I,1) = DGSCARTNU(I,1) * CNVRTDE
            DGSCART(I,2) = DGSCARTNU(I,2) * CNVRTDE
            DGSCART(I,3) = DGSCARTNU(I,3) * CNVRTDE
            IF(KSDIAG.NE.0) THEN
               DO J=KSDIAG,KEDIAG
                  DESCART(I,1,J) = DESCARTNU(I,1,J) * CNVRTDE
                  DESCART(I,2,J) = DESCARTNU(I,2,J) * CNVRTDE
                  DESCART(I,3,J) = DESCARTNU(I,3,J) * CNVRTDE
               END DO
            ENDIF
            IF(KSOFFD.NE.0) THEN
               DO K=KSOFFD,KEOFFD
                  DIJCART(I,1,K) = DIJCARTNU(I,1,K) * CNVRTDE
                  DIJCART(I,2,K) = DIJCARTNU(I,2,K) * CNVRTDE
                  DIJCART(I,3,K) = DIJCARTNU(I,3,K) * CNVRTDE
               END DO
            ENDIF
         END DO
      ENDIF
      RETURN
      END
