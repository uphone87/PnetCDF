/* -*- Mode: C; c-basic-offset:4 ; -*- */
/*  
 *  (C) 2001 by Argonne National Laboratory.
 *      See COPYRIGHT in top-level directory.
 *
 * This file is automatically generated by buildiface -infile=../lib/pnetcdf.h -deffile=defs
 * DO NOT EDIT
 */
#include "mpinetcdf_impl.h"


#ifdef F77_NAME_UPPER
#define nfmpi_inq_attname_ NFMPI_INQ_ATTNAME
#elif defined(F77_NAME_LOWER_2USCORE)
#define nfmpi_inq_attname_ nfmpi_inq_attname__
#elif !defined(F77_NAME_LOWER_USCORE)
#define nfmpi_inq_attname_ nfmpi_inq_attname
/* Else leave name alone */
#endif


/* Prototypes for the Fortran interfaces */
#include "mpifnetcdf.h"
FORTRAN_API void FORT_CALL nfmpi_inq_attname_ ( int *v1, int *v2, int *v3, char *v4 FORT_MIXED_LEN(d4), MPI_Fint *ierr FORT_END_LEN(d4) ){
    *ierr = ncmpi_inq_attname( *v1, *v2, *v3, v4 );
}
