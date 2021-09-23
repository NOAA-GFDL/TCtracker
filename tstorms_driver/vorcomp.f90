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

MODULE VORCOMP_MOD
implicit none

real, allocatable, dimension(:) :: dx, dy

contains

!################################################################

subroutine set_dx_dy( rlat, rlon )

real, intent(in),  dimension(:) :: rlat, rlon

 real, parameter :: radius = 6371.0e3 
 real            :: PI, RADIAN
 real            :: dlon
 integer         :: j
 integer         :: jmx

 jmx = size(rlat)

ALLOCATE( dx(jmx), dy(jmx) )

PI     = 4.0*ATAN(1.0)
RADIAN = 180.0/PI

  dlon = ( rlon(2) - rlon(1) ) / RADIAN
do j = 1,jmx
  dx(j) = radius * cos( rlat(j) / RADIAN ) * dlon
end do

do j = 2,jmx-1
  dy(j) = 0.5*radius*( rlat(j-1) - rlat(j+1) ) / RADIAN
end do
  dy(1)   = dy(2)
  dy(jmx) = dy(jmx-1)

end subroutine set_dx_dy

!################################################################

subroutine comp_vort( uu, vv, vort )

real, intent(in),  dimension(:,:) :: uu, vv
real, intent(out), dimension(:,:) :: vort
integer                           :: i,   j
integer                           :: imx, jmx

imx = SIZE( uu, 1 )
jmx = SIZE( uu, 2 )

vort(:,:) = 0.0

do j = 2,jmx-1
do i = 2,imx-1
vort(i,j) = ( vv(i+1,j) - vv(i-1,j) ) / ( 2.0*dx(j) ) &
          - ( uu(i,j-1) - uu(i,j+1) ) / ( 2.0*dy(j) )
end do
end do

end subroutine comp_vort

!################################################################
end MODULE VORCOMP_MOD
