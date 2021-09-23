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

  MODULE INDATA_MOD
!=====================================================================
  use netcdf
  use get_date_mod,      only: CURRENT_DATE
  use vorcomp_mod,       only: SET_DX_DY, COMP_VORT
  implicit none

  integer :: file_u, file_v, file_vort, file_tm, file_slp
  integer           :: imx,  jmx,  nmx, status

  real, allocatable, dimension(:) :: time

!=====================================================================
! --- NAMELIST
!=====================================================================

  character*120 :: fn_u    = '       '
  character*120 :: fn_v    = '       '
  character*120 :: fn_vort = '       '
  character*120 :: fn_tm   = '       '
  character*120 :: fn_slp  = '       '
  logical :: use_sfc_wnd = .false.

  namelist / input / fn_u, fn_v, fn_vort, fn_tm, fn_slp, &
                     use_sfc_wnd

!=====================================================================
  contains

!######################################################################

  SUBROUTINE SET_GRID
!=====================================================================
  implicit none
!=====================================================================

  READ( *, input )

  status = nf90_open(path = TRIM(fn_u), mode = nf90_nowrite, ncid = file_u)
  if (status /= nf90_noerr) call handle_err(status)
  status = nf90_open(path = TRIM(fn_v), mode = nf90_nowrite, ncid = file_v)
  if (status /= nf90_noerr) call handle_err(status)
  status = nf90_open(path = TRIM(fn_vort), mode = nf90_nowrite, ncid = file_vort)
  if (status /= nf90_noerr) call handle_err(status)
  status = nf90_open(path = TRIM(fn_tm), mode = nf90_nowrite, ncid = file_tm)
  if (status /= nf90_noerr) call handle_err(status)
  status = nf90_open(path = TRIM(fn_slp), mode = nf90_nowrite, ncid = file_slp)
  if (status /= nf90_noerr) call handle_err(status)

  imx = AXIS_LENGTH( file_u, 'lon'   )
  jmx = AXIS_LENGTH( file_u, 'lat'   )
  nmx = AXIS_LENGTH( file_u, 'time'  )

  WRITE(*,*) '        '
  WRITE(*,*) TRIM( fn_u    )
  WRITE(*,*) TRIM( fn_v    )
  WRITE(*,*) TRIM( fn_vort )
  WRITE(*,*) TRIM( fn_tm   )
  WRITE(*,*) TRIM( fn_slp  )
  WRITE(*,*) '        '
  WRITE(*,*) ' imx, jmx, nmx = ', imx, jmx, nmx
  WRITE(*,*) '        '

!=====================================================================
  end SUBROUTINE SET_GRID

!######################################################################

  SUBROUTINE SET_LOLA( rlon, rlat )
!=====================================================================
! --- SET LONGITUDE & LATITUDE ETC
!=====================================================================
  implicit none
  real, intent(out), dimension(:) :: rlon, rlat
  real, dimension(SIZE(rlat))     :: buf
  integer :: lon_id, lat_id, status

!=====================================================================

  CALL READ_VARIABLE_1D( file_u, 'lon', rlon )
  CALL READ_VARIABLE_1D( file_u, 'lat', buf )

  rlat(:) = buf(jmx:1:-1)

!--------------------------------------------------------

  ALLOCATE( time(nmx) )

  CALL READ_VARIABLE_1D( file_u, 'time', time )

!=====================================================================
  end SUBROUTINE SET_LOLA

!######################################################################

  SUBROUTINE GET_DATA( itime,  wind,  vor, tbar,  psl, thick, &
                       year,   month, day, hour )
!=====================================================================
  implicit none

  integer, intent(in)                  :: itime
  real,    intent(out), dimension(:,:) :: wind, vor,   tbar, psl, thick
  integer, intent(out)                 :: year, month, day,  hour

  integer, dimension(3) :: start
  integer, dimension(6) :: date

  real, dimension(SIZE(wind,1),SIZE(wind,2)) :: buf, ucomp, vcomp

  real :: rtime

!=====================================================================

  start(1) = 1        !--- x dimension
  start(2) = 1        !--- y dimension
  start(3) = itime    !--- t dimension
  rtime    = time(itime)

  CALL CURRENT_DATE( file_u, rtime, date )

  year  = date(1)
  month = date(2)
  day   = date(3)
  hour  = date(4)

!-------------------------------------------------------------------
! --- WIND SPEED
!-------------------------------------------------------------------

  if( use_sfc_wnd ) then

  CALL READ_VARIABLE_2D( file_u, 'u_ref', start(1:3), buf )
     ucomp(:,:) = buf(:,jmx:1:-1)
  CALL READ_VARIABLE_2D( file_v, 'v_ref', start(1:3), buf )
     vcomp(:,:) = buf(:,jmx:1:-1)

  else

  CALL READ_VARIABLE_2D( file_u, 'u850', start(1:3), buf )
     ucomp(:,:) = buf(:,jmx:1:-1)
  CALL READ_VARIABLE_2D( file_v, 'v850', start(1:3), buf )
     vcomp(:,:) = buf(:,jmx:1:-1)

  endif

  wind(:,:) = SQRT( ucomp(:,:)*ucomp(:,:) + vcomp(:,:)*vcomp(:,:) )

!-------------------------------------------------------------------
! --- VORTICITY AT 850 MB
!-------------------------------------------------------------------

  CALL READ_VARIABLE_2D( file_vort, 'vort850', start(1:3), buf )
     vor(:,:) = buf(:,jmx:1:-1)

!-------------------------------------------------------------------
! --- THICKNESS BETWEEN 1000 AND 200 MB
!-------------------------------------------------------------------

! --- data not available

     thick(:,:) = 0.0

!-------------------------------------------------------------------
! --- MEAN TEMPERATURE FOR WARM CORE LAYER
!-------------------------------------------------------------------

  CALL READ_VARIABLE_2D( file_tm, 'tm', start(1:3), buf )
      tbar(:,:) = buf(:,jmx:1:-1)

!-------------------------------------------------------------------
! --- Sea level pressure
!-------------------------------------------------------------------

  CALL READ_VARIABLE_2D( file_slp, 'slp', start(1:3), buf )
!     psl(:,:) = 100.0 * buf(:,jmx:1:-1)
     psl(:,:) = buf(:,jmx:1:-1)

!=====================================================================
  end SUBROUTINE GET_DATA

  subroutine read_variable_1d (ncid, varname, buffer)
    integer, intent(in)  :: ncid
    character(len=*) , intent(in)  :: varname
    real             , intent(out) :: buffer(:)
    integer              :: varid, status

    status = nf90_inq_varid(ncid, varname, varid)
    if(status /= nf90_NoErr) call handle_err(status)
    status = nf90_get_var(ncid, varid, buffer)
    if(status /= nf90_NoERr) call handle_err(status)
  end subroutine read_variable_1d

  subroutine read_variable_2d (ncid, varname, start, buffer)
    integer, intent(in)  :: ncid
    character(len=*) , intent(in)  :: varname
    integer          , intent(in)  :: start(:)
    real             , intent(out) :: buffer(:,:)
    integer              :: varid, status

    status = nf90_inq_varid(ncid, varname, varid)
    if(status /= nf90_NoErr) call handle_err(status)
    status = nf90_get_var(ncid, varid, buffer, start)
    if(status /= nf90_NoERr) call handle_err(status)
  end subroutine read_variable_2d

  function axis_length (ncid, dimname) result (length)
    integer, intent(in)  :: ncid
    character(len=*) , intent(in)  :: dimname
    integer              :: length, dimid, status

    status = nf90_inq_dimid(ncid, dimname, dimid)
    if(status /= nf90_NoErr) call handle_err(status)
    status = nf90_inquire_dimension(ncid, dimid, len=length)
    if(status /= nf90_NoErr) call handle_err(status)
  end function axis_length

  subroutine handle_err (status)
    integer, intent(in) :: status
    character(len=80) :: errstrg
    errstrg = NF90_STRERROR (status)
    write (*,*) "NETCDF ERROR: "//trim(errstrg)
    stop 111
  end subroutine handle_err


!######################################################################
  end MODULE INDATA_MOD
