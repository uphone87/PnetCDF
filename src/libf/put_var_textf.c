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
#define nfmpi_put_var_text_ NFMPI_PUT_VAR_TEXT
#elif defined(F77_NAME_LOWER_2USCORE)
#define nfmpi_put_var_text_ nfmpi_put_var_text__
#elif !defined(F77_NAME_LOWER_USCORE)
#define nfmpi_put_var_text_ nfmpi_put_var_text
/* Else leave name alone */
#endif


/* Prototypes for the Fortran interfaces */
#include "mpifnetcdf.h"
FORTRAN_API void FORT_CALL nfmpi_put_var_text_ ( int *v1, int *v2, char *v3 FORT_MIXED_LEN(d3), MPI_Fint *ierr FORT_END_LEN(d3) ){
    int l2 = *v2 - 1;
    char *p3;

    {char *p = v3 + d3 - 1;
     int  li;
        while (*p == ' ' && p > v3) p--;
        p++;
        p3 = (char *)malloc( p-v3 + 1 );
        for (li=0; li<(p-v3); li++) { p3[li] = v3[li]; }
        p3[li] = 0; 
    }
    *ierr = ncmpi_put_var_text( *v1, l2, p3 );
    free( p3 );
}
