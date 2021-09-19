  PROGRAM TSTORMS_DRIVE
!===================================================================
! --- PROGRAMME PERMETTANT DE CALCULER LA POSITION
! --- DES CYCLONES TROPICAUX SUR UN MOIS
!===================================================================

   use TSTORMS_MOD, only : TSTORMS, SET_TSTORMS
   use INDATA_MOD,  only : SET_GRID, SET_LOLA, GET_DATA, &
                           imx, jmx, nmx
   implicit none

!-------------------------------------------------------------------

  integer, parameter :: iucy = 12

  real, allocatable, dimension(:)   :: rlon, rlat
  real, allocatable, dimension(:,:) :: wind, vor, tbar, psl, thick

  integer :: year, month, day, hour
  integer :: n
  real    :: rmax, rmin

!===================================================================

!-------------------------------------------------------------------
! --- INITALIZE
!-------------------------------------------------------------------

  OPEN( iucy, FILE = 'cyclones' )

  CALL SET_TSTORMS
  CALL SET_GRID

  ALLOCATE(  rlon(imx) )
  ALLOCATE(  rlat(jmx) )
  ALLOCATE(  wind(imx,jmx) )
  ALLOCATE(   vor(imx,jmx) )
  ALLOCATE(  tbar(imx,jmx) )
  ALLOCATE(   psl(imx,jmx) )
  ALLOCATE( thick(imx,jmx) )

  CALL SET_LOLA( rlon, rlat )

!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  do n = 1,nmx                               ! --- TIME LOOP STARTS
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

!-------------------------------------------------------------------
! --- INPUT DATA
!-------------------------------------------------------------------

  CALL GET_DATA( n, wind, vor, tbar, psl, thick, year, month, day, hour )
  if (year .lt. 100) year=year+1980

  print *, '   '
  print *, ' year, month, day, hour = ', year, month, day, hour
  print *, '   '

!-------------------------------------------------------------------
! --- FIND STORMS
!-------------------------------------------------------------------

  CALL TSTORMS ( wind, vor,  tbar, psl,   thick,      &
                 rlon, rlat, year, month, day, hour,  &
                 iucy )

!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  end do                                       ! --- TIME LOOP ENDS
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

!-------------------------------------------------------------------
! --- CLEAN UP
!-------------------------------------------------------------------

  CLOSE( iucy )

  DEALLOCATE( rlon  )
  DEALLOCATE( rlat  )
  DEALLOCATE( wind  )
  DEALLOCATE( vor   )
  DEALLOCATE( tbar  )
  DEALLOCATE( psl   )
  DEALLOCATE( thick )

!===================================================================
end PROGRAM TSTORMS_DRIVE

