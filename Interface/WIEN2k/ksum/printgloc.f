SUBROUTINE PrintGloc(fh_dos, fh_gc, fh_dt, Glc, gloc, gtot, Deltac, omega, csize, nl, ll, legend, iatom, ncix, nomega, natom, norbitals, maxsize, Ry2eV)
  !-- Currently we use:  fh_dos = 100, fh_gc = 120, fh_dt = 140
  USE com_mpi, ONLY: myrank, master 
  IMPLICIT NONE
  INTEGER, intent(in)    :: fh_dos, fh_gc, fh_dt
  COMPLEX*16, intent(in) :: Glc(maxsize,ncix,nomega), gloc(norbitals,nomega), gtot(nomega), Deltac(maxsize,ncix,nomega)
  REAL*8, intent(in)     :: omega(nomega)
  INTEGER, intent(in)    :: csize(ncix), iatom(natom)
  INTEGER, intent(in)    :: nl(natom), ll(natom,4)
  CHARACTER*30, intent(in):: legend(maxsize,ncix)
  INTEGER, intent(in) :: nomega, norbitals, natom, ncix, maxsize
  REAL*8, intent(in)  :: Ry2eV
  ! local
  INTEGER :: L, wndim, iom, lcase, i, j, icix, itape, jtape, icase, iorb, wmaxsize, it
  COMPLEX*16 :: csum
  REAL*8     :: pi

  if (myrank.NE.master) RETURN

  pi=ACOS(-1.0D0)
  
  ! Header for correlated
  do icix=1,ncix
     ! Header
     itape = fh_gc+icix
     jtape = fh_dt+icix
     write(itape,'(A7,14x)',advance='no') '# omega'
     write(jtape,'(A7,14x)',advance='no') '# omega'
     do i=1,csize(icix)
        write(itape,'(A28)',advance='no') legend(i,icix)       !end relativistic DOS
        write(jtape,'(A28)',advance='no') legend(i,icix)       !end relativistic DOS
     enddo
     write(itape,*)
     write(jtape,*)
  enddo
  
  do iom=1,nomega
     do icix=1,ncix
        ! Header
        itape = fh_gc+icix
        jtape = fh_dt+icix
        write(itape,'(f14.8,1x)',advance='no') omega(iom)*Ry2eV
        write(jtape,'(f14.8,1x)',advance='no') omega(iom)*Ry2eV
        do i=1,csize(icix)
           write(itape,'(2f14.6)',advance='no') Glc(i,icix,iom)/Ry2eV
           write(jtape,'(2f14.6)',advance='no') Deltac(i,icix,iom)*Ry2eV
        enddo
        write(itape,*)
        write(jtape,*)
     enddo
  enddo


  ! Header for non-correlated
  itape = fh_dos
  write(itape,'(A14,6x)',advance='no') '# omega'
  write(itape,'(A5,9x)',advance='no') 'total'       
  do icase=1,natom
     do lcase=1,nl(icase)
        L=ll(icase,lcase)
        write(itape,'(A2,I2,1x,A2,I2,5x)',advance='no') 'a=', iatom(icase), 'L=', L 
     enddo
  enddo
  write(itape,*)
  do iom=1,nomega
     write(itape,'(f14.8,1x)',advance='no') omega(iom)*Ry2eV
     write(itape,'(f14.8)',advance='no') -aimag(gtot(iom))/pi/Ry2eV
     do iorb=1,norbitals
        write(itape,'(f14.8)',advance='no') -aimag(gloc(iorb,iom))/pi/Ry2eV
     enddo
     write(itape,*)
  enddo
  
  do icix=1,ncix
     close(fh_gc+icix)
     close(fh_dt+icix)
  enddo
  close(fh_dos)
  return
END SUBROUTINE PrintGloc



!SUBROUTINE PrintGloc_optimized(fh_dos, fh_gc, fh_dt, gvec, gtot, Delta, omega, noccur, t_size, cix, csize, nl, ll, legend, iatom, ncix, nomega, natom, iorbital, iorbitalcx, norbitals, maxsize, lmax2, Ry2eV)
!  !-- Currently we use:  fh_dos = 100, fh_gc = 120, fh_dt = 140
!  IMPLICIT NONE
!  INTEGER, intent(in)    :: fh_dos, fh_gc, fh_dt
!  COMPLEX*16, intent(in) :: gvec(maxsize,nomega,norbitals), Delta(maxsize,nomega,ncix), gtot(nomega)
!  REAL*8, intent(in)     :: omega(nomega)
!  INTEGER, intent(in)    :: noccur(maxsize,norbitals), t_size(norbitals)
!  INTEGER, intent(in)    :: cix(natom,4), csize(ncix), iatom(natom), iorbital(natom,lmax2+1), iorbitalcx(ncix)
!  INTEGER, intent(in)    :: nl(natom), ll(natom,4)
!  CHARACTER*30, intent(in):: legend(maxsize,ncix)
!  INTEGER, intent(in) :: nomega, norbitals, natom, ncix, maxsize, lmax2
!  REAL*8, intent(in)  :: Ry2eV
!  ! local
!  INTEGER :: L, iom, lcase, i, j, icix, itape, jtape, icase, iorb, wmaxsize, it
!  COMPLEX*16 :: csum
!  REAL*8     :: pi
!
!  pi=ACOS(-1.0D0)
!  
!  ! Header for correlated
!  do icix=1,ncix
!     ! Header
!     itape = fh_gc+icix
!     jtape = fh_dt+icix
!     write(itape,'(A7,14x)',advance='no') '# omega'
!     write(jtape,'(A7,14x)',advance='no') '# omega'
!     do i=1,csize(icix)
!        write(itape,'(A28)',advance='no') legend(i,icix)       !end relativistic DOS
!        write(jtape,'(A28)',advance='no') legend(i,icix)       !end relativistic DOS
!     enddo
!     write(itape,*)
!     write(jtape,*)
!  enddo
!  
!  do iom=1,nomega
!     do icix=1,ncix
!        iorb = iorbitalcx(icix)
!        itape = fh_gc+icix
!        jtape = fh_dt+icix
!        write(itape,'(f14.8,1x)',advance='no') omega(iom)*Ry2eV
!        write(jtape,'(f14.8,1x)',advance='no') omega(iom)*Ry2eV
!        do it=1,csize(icix)
!           write(itape,'(2f14.6)',advance='no') gvec(it,iom,iorb)/Ry2eV
!           write(jtape,'(2f14.6)',advance='no') Delta(it,iom,icix)*Ry2eV
!        enddo
!        write(itape,*)
!        write(jtape,*)
!     enddo
!  enddo
!
!
!  ! Header for non-correlated
!  itape = fh_dos
!  write(itape,'(A14,6x)',advance='no') '# omega'
!  write(itape,'(A5,9x)',advance='no') 'total'       !end relativistic DOS
!  do icase=1,natom
!     do lcase=1,nl(icase)
!        L=ll(icase,lcase)
!        write(itape,'(A2,I2,1x,A2,I2,5x)',advance='no') 'a=', iatom(icase), 'L=', L       !end relativistic DOS
!     enddo
!  enddo
!  write(itape,*)
!  
!  do iom=1,nomega
!     write(itape,'(f14.8,1x)',advance='no') omega(iom)*Ry2eV
!     write(itape,'(f14.8)',advance='no') -imag(gtot(iom))/pi/Ry2eV
!     do icase=1,natom
!        do lcase=1,nl(icase)
!           iorb = iorbital(icase,lcase)
!           csum=0
!           do it=1,t_size(iorb)
!              csum = csum + gvec(it,iom,iorb)*noccur(it,iorb)
!           enddo
!           ! Finally printing
!           write(itape,'(f14.8)',advance='no') -imag(csum)/pi/Ry2eV
!        enddo
!     enddo
!     write(itape,*)
!  enddo
!  
!  do icix=1,ncix
!     close(fh_gc+icix)
!  enddo
!  close(fh_dos)
!  return
!END SUBROUTINE PrintGloc_optimized
