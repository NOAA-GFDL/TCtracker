  PROGRAM FREQ_ORI
!===================================================================
  implicit none
!-------------------------------------------------------------------

  integer, parameter :: ix   = 72
  integer, parameter :: jx   = 44
  integer, parameter :: ixp  = ix + 1
  real,    parameter :: dlon =   5.0
  real,    parameter :: dlat =   4.0
  real,    parameter :: slat = -86.0

  integer, parameter :: j40s = 12
  integer, parameter :: j40n = 33

  real, dimension(ixp,jx) ::     freq
  real, dimension(ixp,3)  :: lon_freq
  real, dimension(jx)     :: lat_freq 

  real                    :: xcyc, ycyc,  rmax, rmin, rnyr
  integer                 :: year, month, day,  hour
  integer                 :: i, j, jb, je, n, nc
  integer                 :: nyr = 0
  integer                 :: yr0 = 0
  character*5             :: dummy

  logical :: do_40ns = .true.
  logical :: do_map  = .true.
  logical :: do_lon  = .false.
  logical :: do_lat  = .false.
  logical :: do_latf = .false.
  logical :: do_fot  = .false.
  logical :: traj_in = .false.
  integer :: nexp    = 1

  namelist /input/ do_40ns, do_map, do_lon, do_lat, do_latf, &
                   do_fot, nexp, traj_in

!===================================================================

  read(*,input)

     freq(:,:) = 0.0
 lon_freq(:,:) = 0.0
 lat_freq(:)   = 0.0

! --- loop through file & count storms

      OPEN( 12, file='ori', status='unknown' )
  100 continue
      if ( traj_in ) then
        READ( 12,*,end=101 ) dummy, nc, year, month, day, hour
        READ( 12,*)          xcyc, ycyc
        do n = 2,nc
        READ( 12,*)
        enddo
      else
        READ( 12,*,end=101 ) xcyc, ycyc, year, month, day, hour
      endif

  if( yr0 /= year ) then
      yr0 = year
      nyr = nyr + 1
  end if

  i =   xcyc          / dlon + 1.5
  j = ( ycyc - slat ) / dlat + 1.5

  if ( i == 0   ) i = ix
  if ( i == ixp ) i = 1

     freq(i,j) =     freq(i,j) + 1.0
 lon_freq(i,1) = lon_freq(i,1) + 1.0 
 lat_freq(j)   = lat_freq(j)   + 1.0 

 if ( ycyc >= 0.0 ) then
    lon_freq(i,2) = lon_freq(i,2) + 1.0     ! nh
 else 
    lon_freq(i,3) = lon_freq(i,3) + 1.0     ! sh
 endif

      go to 100
  101 continue
      CLOSE( 12 )

  if( do_fot ) then
      rnyr = SUM( freq(1:ix,:) )
  else
      rnyr = FLOAT( nyr )
  endif
      rnyr = rnyr * FLOAT( nexp )

! --- overlap 
      freq(ixp,:) =     freq(1,:)
  lon_freq(ixp,:) = lon_freq(1,:)

! --- number of storms per year
     freq(:,:) =     freq(:,:) / rnyr
 lat_freq(:)   = lat_freq(:)   / rnyr
 lon_freq(:,:) = lon_freq(:,:) / rnyr


! --- print max & min
  rmax = maxval( freq )
  rmin = minval( freq )
  print *, ' max & min  = ', rmax, rmin
  print *, ' nyr & rnyr = ', nyr, rnyr
  
! --- output

  if( do_40ns ) then
    jb = j40s ;  je = j40n
  else
    jb = 1    ;  je = jx
  endif

  if( do_map ) then
     OPEN (12, file='fmap', form='unformatted' )
     WRITE(12) freq(:,jb:je) 
     CLOSE(12)
  endif

  if( do_lat ) then
     OPEN (12, file='flat', form='formatted' )
  do j = jb,je
     ycyc = ( j - 1 ) * dlat + slat
     ycyc = ( j - 1 ) * dlat + slat + 0.5*dlat
     WRITE(12,99) ycyc, lat_freq(j) 
  end do
     WRITE(12,*) '&'
     CLOSE(12)
  endif

  if( do_latf ) then
     OPEN (12, file='flat', form='formatted' )
  do j = jb,je
!    ycyc = ( j - 1 ) * dlat + slat
     ycyc = ( j - 1 ) * dlat + slat + 0.5*dlat
     WRITE(12,98) lat_freq(j), ycyc  
  end do
     WRITE(12,*) '&'
     CLOSE(12)
  endif

  if( do_lon ) then
     OPEN (12, file='flon_gl', form='formatted' )
     OPEN (13, file='flon_nh', form='formatted' )
     OPEN (14, file='flon_sh', form='formatted' )
  do i = 1,ixp
!    xcyc = ( i - 1 ) * dlon
     xcyc = ( i - 1 ) * dlon + 0.5*dlon
     WRITE(12,99) xcyc, lon_freq(i,1) 
     WRITE(13,99) xcyc, lon_freq(i,2)
     WRITE(14,99) xcyc, lon_freq(i,3)
  end do
     WRITE(12,*) '&'
     WRITE(13,*) '&'
     WRITE(14,*) '&'
     CLOSE(12)
     CLOSE(13)
     CLOSE(14)
  endif

 99 format( f8.2, e13.5 )
 98 format( e13.5, f8.2 )

!===================================================================
  end PROGRAM FREQ_ORI
