dnl Process this m4 file to produce 'C' language file.
dnl
dnl If you see this line, you can ignore the next one.
/* Do not edit this file. It is produced from the corresponding .m4 source */
dnl
/*********************************************************************
 *
 *  Copyright (C) 2017, Northwestern University and Argonne National Laboratory
 *  See COPYRIGHT notice in top-level directory.
 *
 *********************************************************************/
/* $Id$ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h> /* memset() */
#include <libgen.h> /* basename() */
#include <mpi.h>
#include <pnetcdf.h>

#include <testutils.h>

include(`foreach.m4')dnl
include(`utils.m4')dnl

#define text char
#ifndef schar
#define schar signed char
#endif
#ifndef uchar
#define uchar unsigned char
#endif
#ifndef ushort
#define ushort unsigned short
#endif
#ifndef uint
#define uint unsigned int
#endif
#ifndef longlong
#define longlong long long
#endif
#ifndef ulonglong
#define ulonglong unsigned long long
#endif

#define NY 16
#define NX 16
#define NVARS 4

define(`TEST_VARS_FILL',dnl
`dnl
static int
test_vars_$1(char *filename)
{
    char var_name[32];
    int i, j, k, nprocs, rank, err, nerrs=0, ncid, dimid[2], varid[NVARS];
    MPI_Offset start[2], count[2], stride[2];
    $1 buf[NY][NX];

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);

    err = ncmpi_create(MPI_COMM_WORLD, filename, NC_CLOBBER, MPI_INFO_NULL, &ncid);
    CHECK_ERR

    err = ncmpi_def_dim(ncid, "Y", NY, &dimid[0]); CHECK_ERR
    err = ncmpi_def_dim(ncid, "X", nprocs*NX, &dimid[1]); CHECK_ERR
    for (k=0; k<NVARS; k++) {
        sprintf(var_name,"var%d",k);
        err = ncmpi_def_var(ncid, var_name, NC_TYPE($1), 2, dimid, &varid[k]);
        CHECK_ERR
    }
    err = ncmpi_set_fill(ncid, NC_FILL, NULL); CHECK_ERR
    err = ncmpi_enddef(ncid); CHECK_ERR

    for (k=0; k<NVARS; k++) {
        /* write strided subarray */
        stride[0] = 2+k;  stride[1] = 2+k;
         start[0] = 0;   start[1] = rank*NX;
         count[0] = NY/stride[0];  count[1] = NX/stride[1];
        if (NY % stride[0]) count[0]++;
        if (NX % stride[1]) count[1]++;
        for (i=0; i<NY; i++) for (j=0; j<NX; j++) buf[i][j] = ($1)rank;
        err = PUT_VARS($1)(ncid, varid[k], start, count, stride, &buf[0][0]);
        CHECK_ERR

        /* read the subarray back and check contents */
        for (i=0; i<NY; i++) for (j=0; j<NX; j++) buf[i][j] = 0;
        start[0] = 0;  start[1] = rank*NX;
        count[0] = NY; count[1] = NX;
        err = GET_VARA($1)(ncid, varid[k], start, count, &buf[0][0]); CHECK_ERR

        for (i=0; i<NY; i++) {
            if (i % stride[0] == 0) {
                for (j=0; j<NX; j++) {
                    if (j % stride[1] == 0) {
                        if (buf[i][j] != ($1)rank) {
                            printf("Error at line %d in %s: expect buf[%d][%d]=IFMT($1) but got IFMT($1)\n",
                                   __LINE__,__FILE__, i,j, ($1)rank, buf[i][j]);
                            nerrs++;
                        }
                    }
                    else {
                        if (buf[i][j] != NC_FILL_VALUE($1)) {
                            printf("Error at line %d in %s: expect buf[%d][%d]=IFMT($1) but got IFMT($1)\n",
                                   __LINE__,__FILE__, i,j, NC_FILL_VALUE($1), buf[i][j]);
                            nerrs++;
                        }
                    }
                }
            }
            else { /* the entire row should be NC_FILL_VALUE($1) */
                for (j=0; j<NX; j++) {
                    if (buf[i][j] != NC_FILL_VALUE($1)) {
                        printf("Error at line %d in %s: expect buf[%d][%d]=IFMT($1) but got IFMT($1)\n",
                               __LINE__,__FILE__, i,j, NC_FILL_VALUE($1), buf[i][j]);
                        nerrs++;
                    }
                }
            }
        }
    }

    err = ncmpi_close(ncid); CHECK_ERR
    return nerrs;
}
')dnl

foreach(`itype', (schar,uchar,short,ushort,int,uint,float,double,longlong,ulonglong), `TEST_VARS_FILL(itype)')

int main(int argc, char **argv)
{
    char filename[256], var_name[32];
    int err, nerrs=0, ncid, dimid[2], varid[NVARS];
    int i, j, k, nprocs, rank, req;
    int buf[NY][NX];
    MPI_Offset start[2];
    MPI_Offset count[2];
    MPI_Offset stride[2];

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);

    if (argc > 2) {
        if (!rank) printf("Usage: %s [filename]\n",argv[0]);
        MPI_Finalize();
        return 1;
    }
    if (argc == 2) snprintf(filename, 256, "%s", argv[1]);
    else           strcpy(filename, "testfile.nc");

    if (rank == 0) {
        char *cmd_str = (char*)malloc(strlen(argv[0]) + 256);
        sprintf(cmd_str, "*** TESTING C   %s for strided put with fill mode on", basename(argv[0]));
        printf("%-66s ------ ", cmd_str); fflush(stdout);
        free(cmd_str);
    }

    ncmpi_set_default_format(NC_FORMAT_CDF5, NULL);

    foreach(`itype', (schar,uchar,short,ushort,int,uint,float,double,longlong,ulonglong), `
    _CAT(`nerrs += test_vars_',itype)'`(filename);')

    /* check if PnetCDF freed all internal malloc */
    MPI_Offset malloc_size, sum_size;
    err = ncmpi_inq_malloc_size(&malloc_size);
    if (err == NC_NOERR) {
        MPI_Reduce(&malloc_size, &sum_size, 1, MPI_OFFSET, MPI_SUM, 0, MPI_COMM_WORLD);
        if (rank == 0 && sum_size > 0)
            printf("heap memory allocated by PnetCDF internally has %lld bytes yet to be freed\n",
                   sum_size);
    }

    MPI_Allreduce(MPI_IN_PLACE, &nerrs, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    if (rank == 0) {
        if (nerrs) printf(FAIL_STR,nerrs);
        else       printf(PASS_STR);
    }

    MPI_Finalize();
    return (nerrs > 0);
}
