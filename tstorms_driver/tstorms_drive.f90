! **********************************************************************
! TCtracker - Tropical Storm Detection
! Copyright (C) 1997-2008, 2021 Frederic Vitart, Joe Sirutis, Ming Zhao,
! Kyle Olivo, Keren Rosado and Seth Underwood
!
! This program is free software; you can redistribute it and/or
! modify it under the terms of the GNU General Public License
! as published by the Free Software Foundation; either version 2
! of the License, or (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with this program; if not, write to the Free Software
! Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
! 02110-1301, USA.
! **********************************************************************

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

