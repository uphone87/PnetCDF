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
#define nfmpi_get_var1_long_ NFMPI_GET_VAR1_LONG
#elif defined(F77_NAME_LOWER_2USCORE)
#define nfmpi_get_var1_long_ nfmpi_get_var1_long__
#elif !defined(F77_NAME_LOWER_USCORE)
#define nfmpi_get_var1_long_ nfmpi_get_var1_long
/* Else leave name alone */
#endif


/* Prototypes for the Fortran interfaces */
#include "mpifnetcdf.h"
FORTRAN_API int FORT_CALL nfmpi_get_var1_long_ ( int *v1, int *v2, MPI_Offset v3[], long*v4 ){
    int ierr;
    ierr = ncmpi_get_var1_long( *v1, *v2, (const MPI_Offset *)(v3), v4 );
    return ierr;
}
