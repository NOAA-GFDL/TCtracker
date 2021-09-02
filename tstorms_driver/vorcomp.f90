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
