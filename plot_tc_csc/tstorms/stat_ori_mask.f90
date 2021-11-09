subroutine STAT_ORI(cmask, do_fancy, traj_in)
  implicit none
  character(len=*), intent(in) :: cmask
  logical, intent(in) :: do_fancy
  logical, intent(in) :: traj_in

  integer, parameter :: ix   =  360
  integer, parameter :: iy   =  180
  integer, parameter :: ireg = 13

  real,    parameter ::   pi = 180.0
  real,    parameter ::  tpi = 360.0
  real,    parameter ::  hpi =  90.0

  real :: dlon, lon0, dlat, lat0

  integer, dimension(ix,iy) :: imask

  character*2, dimension(ireg) :: bx
  data bx /' G','WA','EA','WP','EP','NI','SI','AU','SP','SA','NH','SH','NA'/

!-------------------------------------------------------------------

  integer, parameter :: iyrmx = 500
  integer, parameter :: imomx = 12
  integer, parameter :: imomp = imomx + 1

  real     :: xcyc, ycyc,  div
  integer  :: year, month, day, hour
  integer  :: nr,   ny,    m,   indyr, indyr0
  integer  :: n, nc, ii, jj

  integer, dimension(imomp,iyrmx,ireg) :: icnt
  integer, dimension(imomp,ireg)       :: icntmo, ispread
  real,    dimension(imomp,ireg)       :: avgmo,  stdmo
  integer, dimension(iyrmx)            :: iyr
  character*2                          :: dum = '  '
  integer                              :: yr0 = 0
  character*5                          :: dummy

  character*2, dimension(imomp) :: cmo = &
  (/ ' J',' F',' M',' A',' M',' J',' J',' A',' S',' O',' N',' D','Yr' /)

!===================================================================

  icnt(:,:,:) = 0

!------------------------------------------------------------
! --- get mask
!------------------------------------------------------------

 open ( 10, FILE = trim(cmask), FORM = 'formatted' )
 do jj = 1,iy
    read(10,114) ( imask(ii,jj), ii=1,ix )
 end do
 close( 10 )
 114 format( 360i3  )

   lon0 =  0.0
   dlon =  tpi / FLOAT( ix )
   lat0 =  hpi - 0.5 *   pi / FLOAT( iy )
   dlat =        2.0 * lat0 / FLOAT( iy - 1 )

!------------------------------------------------------------
! --- loop through file & count storms
!------------------------------------------------------------

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

  if( yr0 == 0 ) then
      yr0 = year
    do ny = 1,iyrmx
      iyr(ny) = yr0 + ( ny - 1 )
    end do
  end if

  indyr  = year - yr0 + 1

  icnt(month,indyr,1) = icnt(month,indyr,1) + 1

         jj = ( lat0 - ycyc ) / dlat + 1.5
         ii = ( xcyc - lon0 ) / dlon + 1.5
    if ( ii == 0  ) ii = ix
    if ( ii >  ix ) ii = ii - ix
         nr = imask(ii,jj)

    if( nr > 0 ) icnt(month,indyr,nr) = icnt(month,indyr,nr) + 1

      go to 100
  101 continue
      CLOSE( 12 )

   icnt(1:imomx,1:indyr,11) = SUM( icnt(1:imomx,1:indyr,2:6 ), 3 )
   icnt(1:imomx,1:indyr,12) = SUM( icnt(1:imomx,1:indyr,7:10), 3 )
   icnt(1:imomx,1:indyr,13) = SUM( icnt(1:imomx,1:indyr,2:3),  3 )

   icnt(imomp,1:indyr,1:ireg) = SUM( icnt(1:imomx,1:indyr,1:ireg), 1 )

   indyr0 = COUNT( iyr(1:indyr) > 0 )

!------------------------------------------------------------
! --- statistics
!------------------------------------------------------------

  icntmo(1:imomp,1:ireg) = SUM( icnt(1:imomp,1:indyr,1:ireg), 2 )

   avgmo(1:imomp,1:ireg) = icntmo(1:imomp,1:ireg)
   avgmo(1:imomp,1:ireg) =  avgmo(1:imomp,1:ireg) / FLOAT(indyr0)

  stdmo(:,:) = 0.0
  if( indyr > 1 ) then
  do ny = 1,indyr
  if( iyr(ny) > 0 ) then
  stdmo(1:imomp,1:ireg) = stdmo(1:imomp,1:ireg)     + &
                   ( FLOAT(icnt(1:imomp,ny,1:ireg)) - &
                          avgmo(1:imomp,1:ireg) ) ** 2
  end if
  end do
  div = 1.0 / FLOAT(indyr0-1)
  stdmo(:,:) = SQRT( stdmo(:,:) * div )
  endif

    do m = 1,imomp
  do nr = 1,ireg
  ispread(m,nr) = MAXVAL( icnt(m,1:indyr,nr) )  &
                - MINVAL( icnt(m,1:indyr,nr) )
  end do
    end do

!------------------------------------------------------------
! --- output storm counts
!------------------------------------------------------------

  OPEN( 12, file='stat_mo', status='unknown' )


  do nr = 1,ireg
! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if( do_fancy ) then
! ----------------------------------------------
  WRITE(12, *) '   '
  WRITE(12, *) ' *** Box = ', bx(nr)
  WRITE(12,16)
  WRITE(12,10) ( cmo(m), m = 1,imomp )
  WRITE(12,16)
  do ny = 1,indyr
!  if( iyr(ny) > 0 ) then
  WRITE(12,11) iyr(ny), ( icnt(m,ny,nr), m = 1,imomp )
!  end if
  end do
  WRITE(12,16)
  WRITE(12,12)  ( icntmo(m,nr), m = 1,imomp )
  WRITE(12,15)  (ispread(m,nr), m = 1,imomp )
  WRITE(12,16)
  WRITE(12,13)  (  avgmo(m,nr), m = 1,imomp )
  WRITE(12,14)  (  stdmo(m,nr), m = 1,imomp )
  WRITE(12,16)
! ----------------------------------------------
  else
! ----------------------------------------------
  WRITE(12, *) '   '
  WRITE(12, *) ' *** Box = ', bx(nr)
  WRITE(12,20) ( cmo(m), m = 1,imomp )
  do ny = 1,indyr
!  if( iyr(ny) > 0 ) then
  WRITE(12,21) iyr(ny), ( icnt(m,ny,nr), m = 1,imomp )
!  end if
  end do
  WRITE(12,22)  ( icntmo(m,nr), m = 1,imomp )
  WRITE(12,25)  (ispread(m,nr), m = 1,imomp )
  WRITE(12,23)  (  avgmo(m,nr), m = 1,imomp )
  WRITE(12,24)  (  stdmo(m,nr), m = 1,imomp )
! ----------------------------------------------
  endif

! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  end do

  CLOSE(12)

!------------------------------------------------------------

  20 format( 2x, 5x,      13a6   )
  21 format( 2x, i5,      13i6   )
  22 format( 2x, 'sum  ', 13i6   )
  23 format( 2x, 'mean ', 13f6.1 )
  24 format( 2x, 'std  ', 13f6.1 )
  25 format( 2x, 'sprd ', 13i6   )

  10 format( '| ', 5x,      ' |',12a5,   ' |', a6,   ' |' )
  11 format( '| ', i4,1x,   ' |',12i5,   ' |', i6,   ' |' )
  12 format( '| ', 'sum  ', ' |',12i5,   ' |', i6,   ' |' )
  13 format( '| ', 'mean ', ' |',12f5.1, ' |', f6.1, ' |' )
  14 format( '| ', 'std  ', ' |',12f5.1, ' |', f6.1, ' |' )
  15 format( '| ', 'sprd ', ' |',12i5,   ' |', i6,   ' |' )
  16 format( '+',7('-'), '+',  61('-'), '+', 7('-'), '+' )

!===================================================================
end subroutine STAT_ORI
