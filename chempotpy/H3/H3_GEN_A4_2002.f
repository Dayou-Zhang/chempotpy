C   System:          H3
C   Functional form:
C   Common name:     A4
C   Number of derivatives: 0
C   Number of bodies: 3
C   Number of electronic surfaces: 1
C   Interface: 3-1V
C   Data file:
C
C   References:      SL Mielke, BC Garrett, and KA Peterson, J. Chem. Phys. 116 (2002) 4142.
C
C   Notes:    3 H-H distances passed in bohr. 
C             Energy returned in Hatrees relative to the classical minimum of H+H2.
C

      subroutine pes(x,igrad,p,g,d)

      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      ! number of electronic state
      integer, parameter :: nstates=1
      integer, parameter :: natoms=3
      integer, intent(in) :: igrad

      double precision, intent(in) :: x(natoms,3)
      double precision, intent(out) :: p(nstates), g(nstates,natoms,3)
      double precision, intent(out) :: d(nstates,nstates,natoms,3)

      double precision :: r(1,3), e(1), v
      integer :: iatom, idir, i, j
      logical, save :: first_time_data=.true.

      !initialize 
      v=0.d0
      g=0.d0
      d=0.d0

      ! input cartesian is HHH
      r(1,1)=sqrt((x(1,1)-x(2,1))**2+(x(1,2)-x(2,2))**2
     *          +(x(1,3)-x(2,3))**2)/0.529177211
      r(1,2)=sqrt((x(2,1)-x(3,1))**2+(x(2,2)-x(3,2))**2
     *          +(x(2,3)-x(3,3))**2)/0.529177211
      r(1,3)=sqrt((x(1,1)-x(3,1))**2+(x(1,2)-x(3,2))**2
     *          +(x(1,3)-x(3,3))**2)/0.529177211

      call pot(r,e,1)

      v=e(1)
      v=v*27.211386

      if (igrad==0) then
        do istate=1,nstates
          p(istate)=v
        enddo
      else
        write (*,*) 'Only energy is available'
      endif

      endsubroutine

      module a4data
      save
      double precision ::  eshift= 0.1739709107962980d0
      double precision ::  beta=0.9201192312615871d0
      double precision ::  rnought=2.d0                         
      double precision, dimension(89) :: xlin1=(/-0.1747684349138167d0,         
     &     1.277318541919902d0,         4.865120178227985d0,         
     &     -8.469658615576670d0,         -0.5743180823752541d0,         
     &     6.240393306718566d0,         -2.708137131341480d0,         
     &      -0.5692746751976894d0,         0.6546217258826842d0,         
     &     -0.1509110106019215d0,         1.0897871662071377d-2,      
     &     40.08907725517741d0,         78.14109140356737d0,         
     &     -114.9895503001828d0,         14.58341862464093d0,         
     &     32.62546038173688d0,         -17.51073267443663d0,         
     &     4.374012288933156d0,         -0.3395820839216175d0,         
     &     -7.0640001462913965d-3,       -151.5692355055670d0,         
     &     21.01354666590584d0,         -55.11286823230184d0,         
     &     2.770716740885964d0,         5.009995499090712d0,         
     &     -0.6464346348303938d0,         8.3910658414713523d-3,      
     &     49.25955250094846d0,         -9.603115825941249d0,         
     &     4.8272796970700860d-3,       6.5210196404216089d-2,      
     &     1.2052781423687001d-2,       1.153704488560043d0,         
     &     0.6779128659000427d0,         -8.7223899834716512d-2,      
     &     -0.1303377419808928d0,         -10.90700005830876d0,         
     &     145.7535863536604d0,         222.5532957606632d0,         
     &     -153.3725179930681d0,         -65.61649004631528d0,         
     &     98.77749621876600d0,         -37.38968164171358d0,         
     &     6.448018323092472d0,         0.1406206598020832d0,         
     &     -9.1763752206667951d-2,       577.9387530303504d0,         
     &     321.2258522767713d0,         -1956.057673174400d0,         
     &     -75.51415928657248d0,         207.0415614864125d0,         
     &     -44.79804897124119d0,         1.427806116568303d0,         
     &     0.3525406620212973d0,         -1255.200747980566d0,         
     &     196.2632339741470d0,         -138.6365615558797d0,         
     &     -10.64943395699545d0,         6.425094067862800d0,         
     &     -0.3444399405796634d0,         90.36916178542219d0,         
     &     16.37161644951711d0,         -7.480040057276788d0,         
     &     0.4011296752128877d0,         1.298019306755686d0,         
     &     0.2891734971459664d0,         1285.602684915883d0,         
     &     4565.798100354337d0,         -3155.673834080026d0,         
     &     -44.92705598116694d0,         168.9260873699247d0,         
     &     -7.844938785348392d0,         -1.666140934947715d0,         
     &     2779.863836531601d0,         537.1244197181024d0,         
     &     -170.2582980443451d0,         -5.290922323422062d0,         
     &     1.770830652534150d0,         52.20593427757114d0,         
     &     9.347628365683427d0,         -3.092797446921548d0,         
     &     2.379156980285720d0,         -3334.415420363777d0,         
     &     161.8383070634118d0,         19.96531657285394d0,         
     &     1.327410294913859d0,         -21.45733100652736d0,         
     &     -0.1662058917002993d0,         -0.2962531422178993d0/)  
      double precision, dimension(89) :: xlin2=(/3.6653811266866398d-2,      
     &    -6.0901908406171948d-2,       -0.4296166129329135d0,         
     &    -0.5999553551949833d0,         2.516208126297607d0,         
     &    -2.048432510828575d0,         0.3663315280773198d0,         
     &    0.2774060109660687d0,         -0.1575944525599335d0,         
     &    2.9695991705353031d-2,       -1.9203688037688026d-3,      
     &    -0.5834482485892581d0,         -10.26004544230231d0,         
     &    7.260618335575135d0,         9.670699153937617d0,         
     &    -12.63290323745150d0,         4.813462603326546d0,         
     &    -0.4949553387010042d0,         -6.7585812514542612d-2,      
     &    1.0929473861305191d-2,       38.39652796798982d0,         
     &    -8.046863706246480d0,         -9.322531512667055d0,         
     &    8.319538557744806d0,         -0.5844887973497459d0,         
     &    -0.2072100517931691d0,         1.7662601024712416d-2,      
     &    10.84542783635474d0,         2.719206724534208d0,         
     &    -2.661681915907651d0,         5.4511820020259769d-2,      
     &    4.0917094713795558d-2,       2.310535942300969d0,         
     &    -0.3313532425660889d0,         -1.9282783753774072d-2,      
     &    0.1076070240762595d0,         -1.535785256390712d0,         
     &    21.55814329603826d0,         -20.67412669364389d0,         
     &    -42.22253006381749d0,         63.24620365892324d0,         
     &    -29.72684500701624d0,         5.845208967229377d0,         
     &    0.1479499544852192d0,         -0.1927854989069523d0,         
     &    1.6801714288723839d-2,       137.1873413615389d0,         
     &    -257.7551343332649d0,         135.0209376494197d0,         
     &    13.64539095240564d0,         12.09164291321869d0,         
     &    -5.169736649305458d0,         0.8698478087116743d0,         
     &    -8.0291725093975599d-2,       -347.8994751159709d0,         
     &    -29.90289317716435d0,         2.681813980780868d0,         
     &    8.722110659596989d0,         -0.2420626678309532d0,         
     &     -0.1274172885241889d0,         55.06868860080869d0,         
     &    -12.74535530370019d0,         -0.2131001164206556d0,         
     &    0.1837891447312188d0,         3.041924830651179d0,         
     &    -0.2126407877934366d0,         -742.3965481348824d0,         
     &    -784.5779176647559d0,         -204.0838570881213d0,         
     &    27.41420672246095d0,         27.81184144136420d0,         
     &    -5.107775576751197d0,         0.2426879842278437d0,         
     &    673.8570609208289d0,         -110.1522754394637d0,         
     &    -30.37003163984198d0,         2.612700034489588d0,         
     &    0.4985395581182200d0,         67.07263299708157d0,         
     &    -2.044069233731526d0,         -1.022956710686919d0,         
     &    0.9605395343509358d0,         302.0563415645296d0,         
     &    -34.61819182491933d0,         -2.686757365342857d0,         
     &    -0.7220696373666605d0,         6.015885938467894d0,         
     &    1.207183412067369d0,         -4.708046093073749d0/)  
      double precision, dimension(71) :: xlin3=(/6.2633244088892953d-2,      
     &    -0.3594764662369648d0,         -3.600210064900942d0,         
     &    6.077024302044581d0,         -2.103247648143528d0,         
     &    -7.5336710734737355d-2,       -1.214802246636612d0,         
     &    1.424478564483824d0,         -0.5152381133998951d0,         
     &    5.8690423728471254d-2,       -21.07550548519476d0,         
     &    -68.04052224304678d0,         57.93242378809885d0,         
     &    27.37591131596061d0,         -42.01788015786860d0,         
     &    17.01097780464082d0,         -3.810546557911935d0,         
     &    0.1341788526198947d0,         39.21740752426907d0,         
     &    69.74078714802111d0,         19.18393280026359d0,         
     &    8.117596367547538d0,         -3.122024525347344d0,         
     &    -0.2382844161241255d0,         -89.25083728779680d0,         
     &    25.77704137475598d0,         -1.969043985146592d0,         
     &    -0.4855106421075169d0,         0.7855919428604119d0,         
     &    -0.8441424883696753d0,         9.448681574551424d0,         
     &    -79.69875321240659d0,         -193.2070036563253d0,         
     &    42.92224561943964d0,         111.7341031859155d0,         
     &    -104.4278320210573d0,         37.98166156896379d0,         
     &    -7.211132085860729d0,         -4.6723492922660093d-3,      
     &    -538.7716000645521d0,         -545.3793327560588d0,         
     &    1369.806489379943d0,         584.9126962811058d0,         
     &    -235.2608524242808d0,         44.32276578556720d0,         
     &    -1.162019393434994d0,         1190.467988321617d0,         
     &    620.3261156354067d0,         108.9394942519943d0,         
     &    6.060056785130230d0,         2.581991625425053d0,         
     &    -218.0491226601461d0,         13.36602093278375d0,         
     &    0.7718484142277729d0,         0.8430743860674987d0,         
     &    -957.4048659566447d0,         -4033.862537342876d0,         
     &    3191.552283364393d0,         574.5261882010860d0,         
     &    -220.9679992384400d0,         9.589933194356654d0,         
     &    -4986.101521958573d0,         -483.1000657856682d0,         
     &    16.05429422497049d0,         -15.62404181993110d0,         
     &    -90.73046075338512d0,         3.835596218545594d0,         
     &    2040.882666165481d0,         168.7823751649685d0,         
     &    84.39701838464045d0,         -72.00299079742861d0/)  
      double precision, dimension(71) :: xlin4=(/-1.3789322831534202d-2,      
     &    -5.3276062951444891d-3,       0.3280620147342902d0,         
     &    2.7087208142318464d-3,       -0.4121991913062390d0,         
     &    -0.2194705118222190d0,         0.7128681500449559d0,         
     &    -0.4529979958049952d0,         0.1189948966982933d0,         
     &    -1.1240573716569334d-2,       0.2786903571008327d0,         
     &   6.967391109018378d0,         -0.3729050190579263d0,         
     &    -12.24220706099335d0,         10.19906396811849d0,         
     &    -2.638016620492531d0,         9.1394461539987537d-3,      
     &    5.5889568628281538d-2,       -16.32524207951339d0,         
     &    -10.27043474888980d0,         8.195640957287562d0,         
     &    -1.026303873216019d0,         -2.533027615178429d0,         
     &    0.3931306992906919d0,         5.700236993312759d0,         
     &    -5.964165300509528d0,         -4.2236603189111335d-2,      
     &    0.5679808795239981d0,         -2.155880855745120d0,         
     &    0.3863665921458664d0,         0.4200525718978940d0,         
     &    -8.018391528470787d0,         -3.363559188467546d0,         
     &    53.69613583466297d0,         -52.75603349194013d0,         
     &    19.06668600609882d0,         -2.550942982823412d0,         
     &    -0.3464476386899833d0,         7.6947106143076857d-2,      
     &    -122.7689330815471d0,         158.8043086748957d0,         
     &    -45.97927653390762d0,         -56.47466715674170d0,         
     &    0.6113508220195394d0,         -2.641958330496622d0,         
     &    0.1064836300639488d0,         343.3356986270791d0,         
     &    102.5423266427451d0,         -0.4240044167349897d0,         
     &    -11.09858306988299d0,         0.2559185246181059d0,         
     &    -81.76030598060535d0,         11.92782620599065d0,         
     &    -0.6869535394737264d0,         -2.253291923744354d0,         
     &    245.0489145059600d0,         1182.806070145991d0,         
     &    152.7550042593918d0,         45.24212872272277d0,         
     &    -30.12697910280025d0,         2.918896114976833d0,         
     &    -184.2429751946113d0,         83.71871876387934d0,         
     &    19.99821094524841d0,         -1.471571531480851d0,         
     &    -47.00968833983665d0,         2.161626248435158d0,         
     &    -971.4885779654726d0,         58.68272991198457d0,         
     &    7.609238909723311d0,         -8.492629420669424d0/)  
      end module
      subroutine prepot
      implicit none
      integer          :: ivp,nt
      double precision :: rvp(nt,3),evp(nt),r1x,r2x,r3x
      call prepota4
      return

      entry pot(rvp, evp, nt)
c
      do ivp = 1, nt
         r1x=rvp(ivp,1)  
         r2x=rvp(ivp,2)  
         r3x=rvp(ivp,3)  
         call pota4(r1x,r2x,r3x,evp(ivp))
      enddo    
c
      return
      end

      subroutine prepota4 
      use a4data 
      implicit double precision (a-h,o-z)
      save
      parameter (n2=5000)
      common /indy/iind(n2),jind(n2),kind(n2),ipar(n2),maxi,maxi2
      double precision :: rho1t(0:12),rho2t(0:12),rho3t(0:12)

      write(6,*)' Using A4 H3 PES of 8/15/01'
      write(6,*)' S. L. Mielke, B. C. Garrett, and K. A. Peterson, J. Ch
     &em. Phys., 116 (2002) 4142'

      epslon=1.d-12
      epscem=1.d-12
      ald=0.02d0
      betad=0.72d0

      maxi2=0
      maxi=0
      call indexa3(12,12)     
      maxi2a=maxi2

      maxi=0
      call indexa3(11,11)        
      maxi2b=maxi2-maxi2a
      return

      entry pota4(r1x,r2x,r3x,eee)
      call trip(r1x,etrip1)
      call trip(r2x,etrip2)
      call trip(r3x,etrip3)
      call singlet(r1x,es1)
      call singlet(r2x,es2)
      call singlet(r3x,es3)
      q1=0.5d0*(es1+etrip1)
      q2=0.5d0*(es2+etrip2)
      q3=0.5d0*(es3+etrip3)
      xj1=0.5d0*(es1-etrip1)
      xj2=0.5d0*(es2-etrip2)
      xj3=0.5d0*(es3-etrip3)
      xj=sqrt(epslon+0.5d0*((xj3-xj1)**2+(xj2-xj1)**2+(xj3-xj2)**2))    
      xjs=0.25d0*(xj1+xj2+xj3)
      vlondon=q1+q2+q3-xj

      rho1=exp(-beta*(r1x-rnought))
      rho2=exp(-beta*(r2x-rnought))
      rho3=exp(-beta*(r3x-rnought))

      if((r1x.le.betad).or.(r2x.le.betad).or.(r3x.le.betad))then
        damper=0.d0
      else
        rdamp1=ald/(betad-r1x)
        rdamp2=ald/(betad-r2x)
        rdamp3=ald/(betad-r3x)
        damper=exp(rdamp1+rdamp2+rdamp3)
      endif

      bb=sqrt(epscem+(r1x-r3x)**2+(r1x-r2x)**2+(r2x-r3x)**2)
      warp=1.d0/(1.d0/r1x+1.d0/r2x+1.d0/r3x)

      v=eshift+vlondon

      sum1=0.d0
      sum2=0.d0
      sum3=0.d0
      sum4=0.d0
      
      rho1t(0)=1.d0
      rho2t(0)=1.d0
      rho3t(0)=1.d0

      do it=1,12
        rho1t(it)=rho1t(it-1)*rho1
        rho2t(it)=rho2t(it-1)*rho2
        rho3t(it)=rho3t(it-1)*rho3
      enddo    

      do ii=1,maxi2a
        rprod=rho1t(kind(ii))*rho2t(jind(ii))*rho3t(iind(ii))
        sum1=sum1+xlin1(ipar(ii))*rprod
        sum2=sum2+xlin2(ipar(ii))*rprod
      enddo     

      do ii=maxi2a+1,maxi2a+maxi2b
        rprod=rho1t(kind(ii))*rho2t(jind(ii))*rho3t(iind(ii))
        sum3=sum3+xlin3(ipar(ii))*rprod
        sum4=sum4+xlin4(ipar(ii))*rprod
      enddo     

      eee=v+damper*(sum1+sum2*bb+sum3*warp+sum4*bb*warp)

      return
      end
      
      subroutine indexa3(mbig,mtop)            
      parameter (n2=5000)
c     calculate the fitting indices for A3 symmetry
      common /indy/iind(n2),jind(n2),kind(n2),ipar(n2),maxi,maxi2

      l=maxi2
      l2=maxi

      do  i=0,min(mtop,mbig)
       do  j=i,min(mtop,mbig)
        do  k=j,min(mtop,mbig)
         isum=i+j+k
          if(isum.le.mbig)then
           if(((isum-i).gt.0).and.((isum-j).gt.0).and.
     &        ((isum-k).gt.0))then     
            l2=l2+1
            l=l+1
            ipar(l)=l2
            iind(l)=i
            jind(l)=j
            kind(l)=k
            if(i.ne.j)then
             if(j.ne.k)then
               l=l+1
               ipar(l)=l2
               iind(l)=i
               jind(l)=k
               kind(l)=j
               l=l+1
               ipar(l)=l2
               iind(l)=j
               jind(l)=i
               kind(l)=k
               l=l+1
               ipar(l)=l2
               iind(l)=j
               jind(l)=k
               kind(l)=i
               l=l+1
               ipar(l)=l2
               iind(l)=k
               jind(l)=i
               kind(l)=j
               l=l+1
               ipar(l)=l2
               iind(l)=k
               jind(l)=j
               kind(l)=i
              else
               l=l+1
               ipar(l)=l2
               iind(l)=j
               jind(l)=i
               kind(l)=k
               l=l+1
               ipar(l)=l2
               iind(l)=j
               jind(l)=k
               kind(l)=i
             endif
            elseif (j.ne.k)then
               l=l+1
               ipar(l)=l2
               iind(l)=j
               jind(l)=k
               kind(l)=i
               l=l+1
               ipar(l)=l2
               iind(l)=k
               jind(l)=j
               kind(l)=i
            endif
           endif
          endif
        enddo     
       enddo    
      enddo    
      maxi=l2
      maxi2=l
      return
      end

      subroutine trip(r,v)
c     H2 triplet curve for FCI/aug-cc-pVQZ
      implicit none
      integer          :: j
      double precision :: r,v,damp,xd,prefac
      double precision :: c6=-6.499027d0
      double precision :: c8=-124.3991d0
      double precision :: c10=-3285.828d0
      double precision :: beta=0.2d0
      double precision :: re=1.401d0

      double precision :: alpha= 3.8542531266774340d0    
      double precision,dimension(17) :: xlp=(/2.1913359720738420d-1,
     &        5.8422835449484010d-1, 8.5061017374705010d-1,
     &        8.4614320758188910d-1, 6.7185038364340950d-1,
     &        4.4194539374617390d-1, 2.2339961981172340d-1,
     &        6.5347598849164070d-2, -3.1377420901498310d-3,
     &        -8.3737736675708600d-3, 3.4989034143871880d-3,
     &        2.6754734558345340d-3, -7.7370541086400900d-4,
     &        -1.6880774643325540d-4, 1.1493550202349050d-4,
     &        -1.9309505011102930d-5, 1.1841183250969540d-6/)

      damp=1.d0-exp(-beta*r**2)
      xd=damp/r  
      v=c6*xd**6+c8*xd**8+c10*xd**10

      prefac=exp(- alpha*(r-re))
      if((r-re).ne.0.d0)then
        do j=1,17
          v=v+xlp(j)*(r-re)**(j-1)*prefac
        enddo    
      else
        v=v+xlp(1)*prefac
      endif

      return
      end

      subroutine singlet(r,v)
c     H2 singlet potential for FCI/aug-cc-pVQZ
      implicit none
      integer          :: j
      double precision :: r,v,damp,xd,prefac
      double precision :: c6=-6.499027d0
      double precision :: c8=-124.3991d0
      double precision :: c10=-3285.828d0
      double precision :: beta=0.2d0
      double precision :: re=1.401d0
      double precision :: alpha= 4.0590126171616700d0    
      double precision, dimension(17) :: xlp= (/-1.7046099537113510d-1,
     &         -6.7922917067867770d-1, -1.1517142440791580d0,
     &         -1.1910821267977240d0, -8.2784442225164410d-1,
     &         -4.0807832245803330d-1, -1.5672842672450390d-1,
     &         -6.8869155703744850d-2, -4.3662333239840700d-2,
     &         -2.3870880222600530d-2, -3.4451065483225290d-3,
     &         3.2887970319820380d-3, 1.9772166585174660d-4,
     &         -7.4858600680843820d-4, 1.8385885697114190d-4,
     &         -1.6249086298603110d-5, 3.6338862344567620d-10/)

      damp=1.d0-exp(-beta*r**2)
      xd=damp/r 
      prefac=exp(- alpha*(r-re))
      v=c6*xd**6+c8*xd**8+c10*xd**10

      if((r-re).ne.0.d0)then
        do j=1,17
          v=v+xlp(j)*(r-re)**(j-1)*prefac
        enddo    
      else
        v=v+xlp(1)*prefac
      endif

      return
      end
