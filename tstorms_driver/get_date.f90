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

module get_date_mod

  use netcdf

  use time_manager_mod, only: time_type, set_date, get_date,   &
      &                       set_time, set_calendar_type,     &
      &                       operator(+), JULIAN, NO_LEAP,    &
      &                       THIRTY_DAY_MONTHS

  use utilities_mod, only: error_mesg

  implicit none

  private
  public :: current_date

contains

  !> Returns the reference date from time units label
  !!
  !! note: this version requires a specific format
  subroutine get_ref_date (units, date)
    character(len=*), intent(in)  :: units
    integer         , intent(out) :: date(6)

    integer :: is, ie


    date = 0

    is = index(units, 'since')

    if ( is > 0 ) then
      ie = is + 24
      read (units(is:ie),10) date(1:6)
10    format (6x,i4,5(1x,i2))
    endif
  end subroutine get_ref_date


  !> increments date1 by dt using time units label
  subroutine increment_date (units, dt, date1, date2)
    character(len=*), intent(in)  :: units
    real,             intent(in)  :: dt
    integer,          intent(in)  :: date1(6)
    integer,          intent(out) :: date2(6)

    type(time_type) :: Time

    Time = set_date (date1(1), date1(2), date1(3), &
        &            date1(4), date1(5), date1(6)) &
        & + to_time_type (units,dt)

    call get_date (Time, date2(1), date2(2), date2(3), &
        &                date2(4), date2(5), date2(6)  )

    date2(4) = get_hour(units,dt)
  end subroutine increment_date


  !> convert time_since to time_type
  !! valid time units are: seconds,minutes,hours,days
  function to_time_type (units, time_since) result (Time)
    character(len=*), intent(in) :: units
    real            , intent(in) :: time_since

    type(time_type)              :: Time

    integer :: nc
    real    :: dfac

    nc = len_trim(units)

    if (index(units(1:nc),'sec') > 0) then
      dfac = 86400.
    else if (index(units(1:nc),'min') > 0) then
      dfac = 1440.
    else if (index(units(1:nc),'hour') > 0) then
      dfac = 24.
    else if (index(units(1:nc),'day') > 0) then
      dfac = 1.
    else
      call error_mesg ('to_time_type', 'invalid time units', 2)
      dfac = 1.
    endif

    Time = set_time (0,int(time_since/dfac))
  end function to_time_type


  ! convert time_since to time_type
  ! valid time units are: seconds,minutes,hours,days
  function get_hour (units, time_since) result (hour)
    character(len=*), intent(in) :: units
    real            , intent(in) :: time_since

    integer :: nc
    real    :: rday, dfac
    integer :: hour

    nc = len_trim(units)

    if (index(units(1:nc),'sec') > 0) then
      dfac = 86400.
    else if (index(units(1:nc),'min') > 0) then
      dfac = 1440.
    else if (index(units(1:nc),'hour') > 0) then
      dfac = 24.
    else if (index(units(1:nc),'day') > 0) then
      dfac = 1.
    else
      call error_mesg ('to_time_type', 'invalid time units', 2)
      dfac = 1.
    endif

    rday = time_since/dfac
    hour = nint( 24.0*(rday - int(rday)) )
  end function get_hour


  subroutine current_date (ncid, time_since, date)
    integer, intent(in)  :: ncid !< netCDF ID
    real,              intent(in)  :: time_since !< Time axis value
    integer,           intent(out) :: date(6) !< date ([year, mon, day, hour, min, sec])

    integer :: axis, idate(6), recdimid, varid, status
    logical :: uflag, cflag
    character(len=128) :: units, calendar
    character(len=128) :: dimname

    date = 0
    uflag = .true.
    cflag = .true.

    status = nf90_inquire(ncid, unlimitedDimId = recdimid)
    if (status /= nf90_noerr) call handle_err(status)
    status = nf90_inquire_dimension(ncid, recdimid, name = dimname)
    if (status /= nf90_noerr) call handle_err(status)
    status = nf90_inq_varid(ncid, dimname, varid)
    if(status /= nf90_NoErr) call handle_err(status)
    status = nf90_get_att(ncid, varid, "units", units)
    if (status /= nf90_noerr) uflag = .false.
    status = nf90_get_att(ncid, varid, "calendar", calendar)
    if (status /= nf90_noerr) cflag = .false.

    !---- no units, so return ----
    if (.not.uflag) return

    !---- set calendar (default Julian ?) ----
    if (cflag) then
      call set_cal (calendar)
    else
      call set_cal ('julian')
    endif

    !---- get reference date and increment using time_since ----
    call get_ref_date (units, idate)
    call increment_date (units, time_since, idate, date)
  end subroutine current_date


 subroutine set_cal (cal)
    character(len=*), intent(in) :: cal

    if (  cal(1:6) == 'Julian'    .or.  &
        & cal(1:6) == 'julian'    .or.  &
        & cal(1:6) == 'JULIAN'    .or.  &
        & cal(1:9) == 'Gregorian' .or.  &
        & cal(1:9) == 'gregorian' .or.  &
        & cal(1:9) == 'GREGORIAN' ) then
      call set_calendar_type (JULIAN)
    else if (cal(1:6) == 'NOLEAP') then
      call set_calendar_type (NO_LEAP)
    else
      call set_calendar_type (NO_LEAP)
    endif
  end subroutine set_cal


  subroutine handle_err (status)
    integer, intent(in) :: status

    character(len=80) :: errstrg

    errstrg = NF90_STRERROR (status)
    write (*,*) "NETCDF ERROR: "//trim(errstrg)
    stop 111
  end subroutine handle_err
end module get_date_mod
