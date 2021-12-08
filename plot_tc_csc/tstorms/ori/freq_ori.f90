!> Generate storm frequency from ori file
!!
!! Reads in data from ori file, and calculates storm frequency for global, lat or lon, formatted
!! to be read and plotted with the Grace 2D plotting tool.
SUBROUTINE freq_ori(do_40ns, do_map, do_lon, do_lat, do_latf, do_fot, traj_in)
  implicit none

  logical, intent(in) :: do_40ns !< Bound latatude to 40°N and 40°S
  logical, intent(in) :: do_map !< Produce fmap file with global frequency
  logical, intent(in) :: do_lon !< Produce longitude frequency file `flon`
  logical, intent(in) :: do_lat !< Produce latitude frequency file `flat`
  logical, intent(in) :: do_latf !< Produce latitude frequency file `flat` with frequency first
  logical, intent(in) :: do_fot !< Write frequency as fraction of total storms, instead of frac/year
  logical, intent(in) :: traj_in !< Ori file uses `traj` file formatting

  integer, parameter :: ix   = 72 ! Total number of longitude regions (360/dlon)
  integer, parameter :: jx   = 44 ! Total number of latitude regions ((90-slat)/dlat)
  integer, parameter :: ixp  = ix + 1
  real,    parameter :: dlon =   5.0 ! Longitude region delta
  real,    parameter :: dlat =   4.0 ! Latitude region delta
  real,    parameter :: slat = -86.0 ! Lowest southern latitude

  integer, parameter :: j40s = 12 ! Closest index to 40°S (integer((-40-slat)/4)+1)
  integer, parameter :: j40n = 33 ! Closest index to 40°N (jx-j40s+1)

  real, dimension(ixp,jx) ::     freq ! Global storm frequency
  real, dimension(ixp,3)  :: lon_freq ! Storm frequency for logitude, three different regions (G, NH, SH)
  real, dimension(jx)     :: lat_freq ! Storm frequency for latitude

  real                    :: xcyc, ycyc ! lon, lat location of storm
  real                    :: rnyr ! Number of years (or total number of storms if do_fot = .TRUE.)
  integer                 :: year, month, day, hour ! year, month, day, hour of storm
  integer                 :: i, j, jb, je, n, nc
  integer                 :: nyr
  integer                 :: yr0
  character*5             :: dummy ! Dummy string to hold character string when reading in data

  integer :: nexp = 1

  freq(:,:) = 0.0
  lon_freq(:,:) = 0.0
  lat_freq(:)   = 0.0
  yr0 = 0
  nyr = 0

  ! --- loop through file & count storms
  OPEN (12, file='ori', status='unknown')
100 continue
  if ( traj_in ) then
    READ (12, *, end=101) dummy, nc, year, month, day, hour
    READ (12, *)          xcyc, ycyc
    do n = 2,nc
      READ( 12,*)
    end do
  else
    READ (12, *, end=101) xcyc, ycyc, year, month, day, hour
  end if

  if ( yr0 /= year ) then
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
  end if

  go to 100
101 continue
  CLOSE (12)

  if ( do_fot ) then
    rnyr = SUM( freq(1:ix,:) )
  else
    rnyr = FLOAT( nyr )
  end if
  rnyr = rnyr * FLOAT( nexp )

  ! --- overlap
  freq(ixp,:) =     freq(1,:)
  lon_freq(ixp,:) = lon_freq(1,:)

  ! --- number of storms per year
  freq(:,:) =     freq(:,:) / rnyr
  lat_freq(:)   = lat_freq(:)   / rnyr
  lon_freq(:,:) = lon_freq(:,:) / rnyr

  ! --- output
  if ( do_40ns ) then
    jb = j40s
    je = j40n
  else
    jb = 1
    je = jx
  end if

  if ( do_map ) then
    OPEN (12, file='fmap', form='unformatted' )
    WRITE (12) freq(:,jb:je)
    CLOSE (12)
  end if

  if( do_lat .OR. do_latf) then
    OPEN (12, file='flat', form='formatted' )
    do j = jb,je
      ycyc = ( j - 1 ) * dlat + slat + 0.5*dlat
      if( do_lat ) then
        WRITE(12,99) ycyc, lat_freq(j)
      else
        ! do_latf
        WRITE (12,98) lat_freq(j), ycyc
      end if
    end do
    WRITE(12,*) '&'
    CLOSE(12)
  end if

  if ( do_lon ) then
    OPEN (12, file='flon_gl', form='formatted' )
    OPEN (13, file='flon_nh', form='formatted' )
    OPEN (14, file='flon_sh', form='formatted' )
    do i = 1,ixp
      xcyc = ( i - 1 ) * dlon + 0.5*dlon
      WRITE (12,99) xcyc, lon_freq(i,1)
      WRITE (13,99) xcyc, lon_freq(i,2)
      WRITE (14,99) xcyc, lon_freq(i,3)
    end do
    WRITE(12,*) '&'
    WRITE(13,*) '&'
    WRITE(14,*) '&'
    CLOSE(12)
    CLOSE(13)
    CLOSE(14)
  end if

99 format( f8.2, e13.5 )
98 format( e13.5, f8.2 )
END SUBROUTINE freq_ori
