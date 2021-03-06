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

!> A collection of simple useful programs.
!!
!!      file_exist       Function that returns if a given
!!                       file name exists
!!
!!      get_unit         Function that returns an available
!!                       Fortran unit number
!!
!!      error_mesg       Print warning and error messages,
!!                       terminates program for error messages.
!!
!!      check_nml_error  Checks the iostat returned when reading
!!                       namelists and determines if the error code
!!                       is valid, if not the program is terminated.
!!
!!      open_file        Opens a given file name for i/o and returns
!!                       a unit number.  If the file is already open
!!                       the unit number is returned.
!!
!!      print_version_number    Prints out a routine name and
!!                              version number to a specified unit
module utilities_mod

  implicit none

  integer, private :: num_nml_error_codes, nml_error_codes(5)
  logical, private :: do_nml_error_init = .true.
  private  nml_error_init

contains

  function file_exist (file_name)
    character(len=*), intent(in) :: file_name

    logical  file_exist

    inquire (file=file_name(1:len_trim(file_name)), exist=file_exist)
  end function file_exist


  function get_unit () result (unit)
    integer  i, unit
    logical  open

    ! ---- get available unit ----
    unit = -1
    do i = 10, 80
      inquire (i, opened=open)
      if (.not.open) Then
        unit = i
        exit
      endif
    enddo

    if (unit == -1) Then
      call error_mesg ('get_unit', 'no available units.', 1)
    endif
  end function get_unit


  !> Simple error handler
  subroutine error_mesg (routine, message, level)

!  input:
!      routine   name of the calling routine (character string)
!      message   message written to standard output (character string)
!      level     if not equal to zero then the program terminates
!
    character(len=*), intent(in) :: routine !< Name of the calling routine
    character(len=*), intent(in) :: message !< Message written to stndard error
    integer,          intent(in) :: level !< If not equal to zero, then program terminates

    select case (iabs(level))
    case (0)
      print *, ' MESSAGE from ',routine(1:len_trim(routine))
      print *, ' ',message(1:len_trim(message))
    case (1)
      print *, ' WARNING in ',routine(1:len_trim(routine))
      print *, ' ',message(1:len_trim(message))
      call abort ( )
    case default
      print *, ' ERROR in ',routine(1:len_trim(routine))
      print *, ' ',message(1:len_trim(message))
      call abort ( )
    end select
  end subroutine error_mesg


  function check_nml_error (iostat, nml_name) result (error_code)
    integer,          intent(in) :: iostat
    character(len=*), intent(in) :: nml_name

    integer :: error_code, i
    character(len=128) :: err_str

    if (do_nml_error_init) call nml_error_init

    error_code = iostat

    do i = 1, num_nml_error_codes
      if (error_code == nml_error_codes(i)) return
    end do

    !  ------ fatal namelist error -------
    write (err_str,*) 'while reading namelist ',  &
        &              nml_name(1:len_trim(nml_name)),  &
        &              ', iostat = ',error_code
    call error_mesg ('check_nml_error', err_str, 3)
  end function check_nml_error


  !> Private routine for initializing allowable error codes
  subroutine nml_error_init

    integer  unit, io, ir
    real ::  b=1.
    namelist /b_nml/  b

    nml_error_codes(1) = 0

    !     ---- create dummy namelist file ----
    unit=get_unit(); open (unit, file='_read_error.nml')
    write (unit, 10)
10  format (' &a_nml  a=1.  /',  &
        &  /'-------------------',  &
        &  /' &b_nml  e=5.  &end')
    close (unit)

    !     ---- read namelist file and save error codes ----
    unit=get_unit(); open (unit, file='_read_error.nml')
    ir=1; io=1; do
       read  (unit, nml=b_nml, iostat=io, end=20)
       if (io == 0) exit
       ir=ir+1; nml_error_codes(ir)=io
    enddo
20  close (unit, status='delete')

    num_nml_error_codes = ir
    do_nml_error_init = .false.
  end subroutine nml_error_init


  function open_file (file, form, position) result (unit)
    character(len=*), intent(in) :: file
    character(len=*), intent(in), optional :: form
    character(len=*), intent(in), optional :: position
    integer  :: unit

    integer           :: nc
    logical           :: open
    character(len=11) :: format
    character(len=6)  :: location

    inquire (file=file(1:len_trim(file)), opened=open, number=unit,  &
        &    form=format)

    if (open) then
      ! ---------- check format ??? ---------
      ! ---- (skip this and let fortran i/o catch bug) -----
      ! if (present(form)) then
      !   nc = min(11,len(form))
      !   if (format == 'UNFORMATTED') then
      !     if (form(1:nc) /= 'unformatted' .and.  &
      !         & form(1:nc) /= 'UNFORMATTED')       &
      !         & call error_mesg ('open_file in utilities_mod', &
      !         &                  'invalid form argument', 2)
      !     else if (format(1:9) == 'FORMATTED') then
      !       if (form(1:nc) /= 'formatted' .and.  &
      !           & form(1:nc) /= 'FORMATTED')       &
      !           & call error_mesg ('open_file in utilities_mod', &
      !           &                  'invalid form argument', 2)
      !     else
      !       call error_mesg ('open_file in utilities_mod', &
      !           &            'unexpected format returned by inquire', 2)
      !     endif
      !   endif

    else
      ! ---------- open file ----------
      format   = 'formatted  '
      location = 'asis  '

      if (present(form)) then
        nc = min(11,len(form))
        format(1:nc) = form(1:nc)
      endif

      if (present(position)) then
        nc = min(6,len(position))
        location(1:nc) = position(1:nc)
      endif

      unit = get_unit()

      if (format == 'formatted  ' .or. format == 'FORMATTED  ') then
        open (unit, file=file(1:len_trim(file)),      &
            &       form=format(1:len_trim(format)),  &
            &       position=location(1:len_trim(location)),  &
            &       delim='apostrophe')
      else
        open (unit, file=file(1:len_trim(file)),      &
            &       form=format(1:len_trim(format)),  &
            &       position=location(1:len_trim(location)) )
      endif
    endif
  end function open_file


  !> prints routine name and version number to a log file
  subroutine print_version_number (unit, routine, version)
    integer,          intent(in) :: unit !< Unit number for output
    character(len=*), intent(in) :: routine !< Routine name
    character(len=*), intent(in) :: version !< Version name or number

    integer           :: n
    character(len=20) :: name
    character(len=8)  :: vers

    n = min(len(routine),20); name = adjustl(routine(1:n))
    n = min(len(version), 8); vers = adjustl(version(1:n))

    if (unit > 0) then
      write (unit,10) name, vers
    else
      write (*,10) name, vers
    endif

10  format (/,60('-'),  &
        &   /,10x, 'ROUTINE = ',a20, '  VERSION = ', a8, &
        &   /,60('-'))
  end subroutine print_version_number
end module utilities_mod
