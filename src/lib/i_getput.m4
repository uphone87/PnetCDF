dnl Process this m4 file to produce 'C' language file.
dnl
dnl If you see this line, you can ignore the next one.
/* Do not edit this file. It is produced from the corresponding .m4 source */
dnl
/*
 *  Copyright (C) 2003, Northwestern University and Argonne National Laboratory
 *  See COPYRIGHT notice in top-level directory.
 */
/* $Id$ */

#if HAVE_CONFIG_H
# include <ncconfig.h>
#endif

#include <stdio.h>
#include <unistd.h>
#ifdef HAVE_STDLIB_H
#include <stdlib.h>
#endif
#include <assert.h>

#include <string.h> /* memcpy() */
#include <mpi.h>

#include "nc.h"
#include "ncx.h"
#include "ncmpidtype.h"
#include "macro.h"


define(`CollIndep',   `ifelse(`$1',`_all', `COLL_IO', `INDEP_IO')')dnl
define(`ReadWrite',   `ifelse(`$1', `get', `READ_REQ', `WRITE_REQ')')dnl
define(`BufConst',    `ifelse(`$1', `put', `const')')dnl
define(`CheckRecord1',`ifelse(`$1', `get', `if (IS_RECVAR(varp) && start[0] + 1 > NC_get_numrecs(ncp)) return NC_EEDGE;')')dnl
define(`CheckRecords',`ifelse(`$1', `get', `if (IS_RECVAR(varp) && start[0] + count[0] > NC_get_numrecs(ncp)) return NC_EEDGE;')')dnl

dnl
dnl VAR_FLEXIBLE
dnl
define(`VAR_FLEXIBLE',dnl
`dnl
/*----< ncmpi_i$1_var() >----------------------------------------------------*/
int
ncmpi_i$1_var(int                ncid,
              int                varid,
              BufConst($1) void *buf,
              MPI_Offset         bufcount,
              MPI_Datatype       buftype,
              int               *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset *start, *count;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, ReadWrite($1), INDEP_COLL_IO, status)
    GET_FULL_DIMENSIONS(start, count)

    /* i$1_var is a special case of i$1_varm */
    status = ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                                 (void*)buf, bufcount, buftype, reqid,
                                 ReadWrite($1), 0, 0);
    if (varp->ndims > 0) NCI_Free(start);

    return status;
}
')dnl

VAR_FLEXIBLE(put)
VAR_FLEXIBLE(get)

dnl
dnl VAR
dnl
define(`VAR',dnl
`dnl
/*----< ncmpi_i$1_var_$2() >-------------------------------------------------*/
int
ncmpi_i$1_var_$2(int              ncid,
                 int              varid,
                 BufConst($1) $3 *buf,
                 int             *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset  nelems, *start, *count;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, ReadWrite($1), INDEP_COLL_IO, status)
    GET_TOTAL_NUM_ELEMENTS(nelems)
    GET_FULL_DIMENSIONS(start, count)

    /* i$1_var is a special case of i$1_varm */
    status = ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                                 (void*)buf, nelems, $4, reqid,
                                 ReadWrite($1), 0, 0);
    if (varp->ndims > 0) NCI_Free(start);

    return status;
}
')dnl

VAR(put, text,      char,               MPI_CHAR)
VAR(put, schar,     schar,              MPI_BYTE)
VAR(put, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VAR(put, short,     short,              MPI_SHORT)
VAR(put, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VAR(put, int,       int,                MPI_INT)
VAR(put, uint,      uint,               MPI_UNSIGNED)
VAR(put, long,      long,               MPI_LONG)
VAR(put, float,     float,              MPI_FLOAT)
VAR(put, double,    double,             MPI_DOUBLE)
VAR(put, longlong,  long long,          MPI_LONG_LONG_INT)
VAR(put, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

VAR(get, text,      char,               MPI_CHAR)
VAR(get, schar,     schar,              MPI_BYTE)
VAR(get, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VAR(get, short,     short,              MPI_SHORT)
VAR(get, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VAR(get, int,       int,                MPI_INT)
VAR(get, uint,      uint,               MPI_UNSIGNED)
VAR(get, long,      long,               MPI_LONG)
VAR(get, float,     float,              MPI_FLOAT)
VAR(get, double,    double,             MPI_DOUBLE)
VAR(get, longlong,  long long,          MPI_LONG_LONG_INT)
VAR(get, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)


dnl
dnl VAR1_FLEXIBLE
dnl
define(`VAR1_FLEXIBLE',dnl
`dnl
/*----< ncmpi_i$1_var1() >---------------------------------------------------*/
int
ncmpi_i$1_var1(int                ncid,
               int                varid,
               const MPI_Offset  *start,
               BufConst($1) void *buf,
               MPI_Offset         bufcount,
               MPI_Datatype       buftype,
               int               *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset *count;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, ReadWrite($1), INDEP_COLL_IO, status)

    status = NCcoordck(ncp, varp, start, ReadWrite($1));
    if (status != NC_NOERR) return status;
    CheckRecord1($1)
    GET_ONE_COUNT(count)

    status = ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                                 (void*)buf, bufcount, buftype, reqid,
                                 ReadWrite($1), 0, 0);
    if (varp->ndims > 0) NCI_Free(count);
    return status;
}
')dnl

VAR1_FLEXIBLE(put)
VAR1_FLEXIBLE(get)

dnl
dnl VAR1
dnl
define(`VAR1',dnl
`dnl
/*----< ncmpi_i$1_var1_$2() >------------------------------------------------*/
int
ncmpi_i$1_var1_$2(int               ncid,
                  int               varid,
                  const MPI_Offset  start[],
                  BufConst($1) $3  *buf,
                  int              *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset *count;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, ReadWrite($1), INDEP_COLL_IO, status)

    status = NCcoordck(ncp, varp, start, ReadWrite($1));
    if (status != NC_NOERR) return status;
    CheckRecord1($1)
    GET_ONE_COUNT(count)

    status = ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                                 (void*)buf, 1, $4, reqid,
                                 ReadWrite($1), 0, 0);
    if (varp->ndims > 0) NCI_Free(count);
    return status;
}
')dnl

VAR1(put, text,      char,               MPI_CHAR)
VAR1(put, schar,     schar,              MPI_BYTE)
VAR1(put, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VAR1(put, short,     short,              MPI_SHORT)
VAR1(put, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VAR1(put, int,       int,                MPI_INT)
VAR1(put, uint,      uint,               MPI_UNSIGNED)
VAR1(put, long,      long,               MPI_LONG)
VAR1(put, float,     float,              MPI_FLOAT)
VAR1(put, double,    double,             MPI_DOUBLE)
VAR1(put, longlong,  long long,          MPI_LONG_LONG_INT)
VAR1(put, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

VAR1(get, text,      char,               MPI_CHAR)
VAR1(get, schar,     schar,              MPI_BYTE)
VAR1(get, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VAR1(get, short,     short,              MPI_SHORT)
VAR1(get, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VAR1(get, int,       int,                MPI_INT)
VAR1(get, uint,      uint,               MPI_UNSIGNED)
VAR1(get, long,      long,               MPI_LONG)
VAR1(get, float,     float,              MPI_FLOAT)
VAR1(get, double,    double,             MPI_DOUBLE)
VAR1(get, longlong,  long long,          MPI_LONG_LONG_INT)
VAR1(get, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)


dnl
dnl VARA_FLEXIBLE
dnl
define(`VARA_FLEXIBLE',dnl
`dnl
/*----< ncmpi_i$1_vara() >---------------------------------------------------*/
int
ncmpi_i$1_vara(int                ncid,
               int                varid,
               const MPI_Offset  *start,
               const MPI_Offset  *count,
               BufConst($1) void *buf,
               MPI_Offset         bufcount,
               MPI_Datatype       buftype,
               int               *reqid)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, ReadWrite($1), INDEP_COLL_IO, status)

    status = NCcoordck(ncp, varp, start, ReadWrite($1));
    if (status != NC_NOERR) return status;
    status = NCedgeck(ncp, varp, start, count);
    if (status != NC_NOERR) return status;
    CheckRecords($1)

    return ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                               (void*)buf, bufcount, buftype, reqid,
                               ReadWrite($1), 0, 0);
}
')dnl

VARA_FLEXIBLE(put)
VARA_FLEXIBLE(get)

dnl
dnl VARA
dnl
define(`VARA',dnl
`dnl
/*----< ncmpi_i$1_vara_$1() >------------------------------------------------*/
int
ncmpi_i$1_vara_$2(int               ncid,
                  int               varid,
                  const MPI_Offset  start[],
                  const MPI_Offset  count[],
                  BufConst($1) $3  *buf,
                  int              *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset  nelems;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, ReadWrite($1), INDEP_COLL_IO, status)

    status = NCcoordck(ncp, varp, start, ReadWrite($1));
    if (status != NC_NOERR) return status;
    status = NCedgeck(ncp, varp, start, count);
    if (status != NC_NOERR) return status;
    CheckRecords($1)
    GET_NUM_ELEMENTS(nelems)

    return ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                               (void*)buf, nelems, $4, reqid,
                               ReadWrite($1), 0, 0);
}
')dnl

VARA(put, text,      char,               MPI_CHAR)
VARA(put, schar,     schar,              MPI_BYTE)
VARA(put, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARA(put, short,     short,              MPI_SHORT)
VARA(put, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARA(put, int,       int,                MPI_INT)
VARA(put, uint,      uint,               MPI_UNSIGNED)
VARA(put, long,      long,               MPI_LONG)
VARA(put, float,     float,              MPI_FLOAT)
VARA(put, double,    double,             MPI_DOUBLE)
VARA(put, longlong,  long long,          MPI_LONG_LONG_INT)
VARA(put, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

VARA(get, text,      char,               MPI_CHAR)
VARA(get, schar,     schar,              MPI_BYTE)
VARA(get, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARA(get, short,     short,              MPI_SHORT)
VARA(get, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARA(get, int,       int,                MPI_INT)
VARA(get, uint,      uint,               MPI_UNSIGNED)
VARA(get, long,      long,               MPI_LONG)
VARA(get, float,     float,              MPI_FLOAT)
VARA(get, double,    double,             MPI_DOUBLE)
VARA(get, longlong,  long long,          MPI_LONG_LONG_INT)
VARA(get, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)


dnl
dnl VARS_FLEXIBLE
dnl
define(`VARS_FLEXIBLE',dnl
`dnl
/*----< ncmpi_i$1_vars() >---------------------------------------------------*/
int
ncmpi_i$1_vars(int                ncid,
               int                varid,
               const MPI_Offset   start[],
               const MPI_Offset   count[],
               const MPI_Offset   stride[],
               BufConst($1) void *buf,
               MPI_Offset         bufcount,
               MPI_Datatype       buftype,
               int               *reqid)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    if (stride == NULL)
        return ncmpi_i$1_vara(ncid, varid, start, count, buf, bufcount,
                              buftype, reqid);

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, ReadWrite($1), INDEP_COLL_IO, status)

    status = NCcoordck(ncp, varp, start, ReadWrite($1));
    if (status != NC_NOERR) return status;
    status = NCstrideedgeck(ncp, varp, start, count, stride);
    if (status != NC_NOERR) return status;
    CheckRecords($1)

    return ncmpii_igetput_varm(ncp, varp, start, count, stride, NULL,
                               (void*)buf, bufcount, buftype, reqid,
                               ReadWrite($1), 0, 0);
}
')dnl

VARS_FLEXIBLE(put)
VARS_FLEXIBLE(get)

dnl
dnl VARS
dnl
define(`VARS',dnl
`dnl
/*----< ncmpi_i$1_vars_$2() >------------------------------------------------*/
int
ncmpi_i$1_vars_$2(int               ncid,
                  int               varid,
                  const MPI_Offset  start[],
                  const MPI_Offset  count[],
                  const MPI_Offset  stride[],
                  BufConst($1) $3  *buf,
                  int              *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset  nelems;

    if (stride == NULL)
        return ncmpi_i$1_vara_$2(ncid, varid, start, count, buf, reqid);

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, ReadWrite($1), INDEP_COLL_IO, status)

    status = NCcoordck(ncp, varp, start, ReadWrite($1));
    if (status != NC_NOERR) return status;
    status = NCstrideedgeck(ncp, varp, start, count, stride);
    if (status != NC_NOERR) return status;
    CheckRecords($1)
    GET_NUM_ELEMENTS(nelems)

    return ncmpii_igetput_varm(ncp, varp, start, count, stride, NULL,
                               (void*)buf, nelems, $4, reqid,
                               ReadWrite($1), 0, 0);
}
')dnl

VARS(put, text,      char,               MPI_CHAR)
VARS(put, schar,     schar,              MPI_BYTE)
VARS(put, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARS(put, short,     short,              MPI_SHORT)
VARS(put, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARS(put, int,       int,                MPI_INT)
VARS(put, uint,      uint,               MPI_UNSIGNED)
VARS(put, long,      long,               MPI_LONG)
VARS(put, float,     float,              MPI_FLOAT)
VARS(put, double,    double,             MPI_DOUBLE)
VARS(put, longlong,  long long,          MPI_LONG_LONG_INT)
VARS(put, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

VARS(get, text,      char,               MPI_CHAR)
VARS(get, schar,     schar,              MPI_BYTE)
VARS(get, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARS(get, short,     short,              MPI_SHORT)
VARS(get, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARS(get, int,       int,                MPI_INT)
VARS(get, uint,      uint,               MPI_UNSIGNED)
VARS(get, long,      long,               MPI_LONG)
VARS(get, float,     float,              MPI_FLOAT)
VARS(get, double,    double,             MPI_DOUBLE)
VARS(get, longlong,  long long,          MPI_LONG_LONG_INT)
VARS(get, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)


/* buffer layers:

        User Level              buf     (user defined buffer of MPI_Datatype)
        MPI Datatype Level      cbuf    (contiguous buffer of ptype)
        NetCDF XDR Level        xbuf    (XDR I/O buffer)
*/

static int
pack_request(NC *ncp, NC_var *varp, NC_req *req, int do_vars, void *buf,
             void *xbuf, const MPI_Offset start[], const MPI_Offset count[],
             const MPI_Offset stride[], MPI_Offset fnelems, MPI_Offset bnelems,
             MPI_Offset lnelems, MPI_Offset bufcount, MPI_Datatype buftype,
             MPI_Datatype ptype, int iscontig_of_ptypes,
             int need_swap_back_buf, int use_abuf);

dnl
dnl VARM_FLEXIBLE
dnl
define(`VARM_FLEXIBLE',dnl
`dnl
/*----< ncmpi_i$1_varm() >---------------------------------------------------*/
int
ncmpi_i$1_varm(int                ncid,
               int                varid,
               const MPI_Offset   start[],
               const MPI_Offset   count[],
               const MPI_Offset   stride[],
               const MPI_Offset   imap[],
               BufConst($1) void *buf,
               MPI_Offset         bufcount,
               MPI_Datatype       buftype,
               int               *reqid)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    if (imap == NULL)
        return ncmpi_i$1_vars(ncid, varid, start, count, stride, buf, bufcount,
                              buftype, reqid);

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, ReadWrite($1), INDEP_COLL_IO, status)

    status = NCcoordck(ncp, varp, start, ReadWrite($1));
    if (status != NC_NOERR) return status;
    status = NCstrideedgeck(ncp, varp, start, count, stride);
    if (status != NC_NOERR) return status;
    CheckRecords($1)

    return ncmpii_igetput_varm(ncp, varp, start, count, stride, imap,
                               (void*)buf, bufcount, buftype, reqid,
                               ReadWrite($1), 0, 0);
}
')dnl

VARM_FLEXIBLE(put)
VARM_FLEXIBLE(get)

dnl
dnl VARM
dnl
define(`VARM',dnl
`dnl
/*----< ncmpi_i$1_varm_$2() >------------------------------------------------*/
int
ncmpi_i$1_varm_$2(int               ncid,
                  int               varid,
                  const MPI_Offset  start[],
                  const MPI_Offset  count[],
                  const MPI_Offset  stride[],
                  const MPI_Offset  imap[],
                  BufConst($1) $3  *buf,
                  int              *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset  nelems;

    if (imap == NULL)
        return ncmpi_i$1_vars_$2(ncid, varid, start, count, stride, buf, reqid);

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, ReadWrite($1), INDEP_COLL_IO, status)

    status = NCcoordck(ncp, varp, start, ReadWrite($1));
    if (status != NC_NOERR) return status;
    status = NCstrideedgeck(ncp, varp, start, count, stride);
    if (status != NC_NOERR) return status;
    CheckRecords($1)
    GET_NUM_ELEMENTS(nelems)

    return ncmpii_igetput_varm(ncp, varp, start, count, stride, imap,
                               (void*)buf, nelems, $4, reqid,
                               ReadWrite($1), 0, 0);
}
')dnl

VARM(put, text,      char,               MPI_CHAR)
VARM(put, schar,     schar,              MPI_BYTE)
VARM(put, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARM(put, short,     short,              MPI_SHORT)
VARM(put, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARM(put, int,       int,                MPI_INT)
VARM(put, uint,      uint,               MPI_UNSIGNED)
VARM(put, long,      long,               MPI_LONG)
VARM(put, float,     float,              MPI_FLOAT)
VARM(put, double,    double,             MPI_DOUBLE)
VARM(put, longlong,  long long,          MPI_LONG_LONG_INT)
VARM(put, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

VARM(get, text,      char,               MPI_CHAR)
VARM(get, schar,     schar,              MPI_BYTE)
VARM(get, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARM(get, short,     short,              MPI_SHORT)
VARM(get, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARM(get, int,       int,                MPI_INT)
VARM(get, uint,      uint,               MPI_UNSIGNED)
VARM(get, long,      long,               MPI_LONG)
VARM(get, float,     float,              MPI_FLOAT)
VARM(get, double,    double,             MPI_DOUBLE)
VARM(get, longlong,  long long,          MPI_LONG_LONG_INT)
VARM(get, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

/*----< ncmpii_abuf_malloc() >------------------------------------------------*/
/* allocate memory space from the attached buffer pool */
int
ncmpii_abuf_malloc(NC *ncp, MPI_Offset nbytes, void **buf)
{
    /* extend the table size if more entries are needed */
    if (ncp->abuf->tail + 1 == ncp->abuf->table_size) {
        ncp->abuf->table_size += NC_ABUF_DEFAULT_TABLE_SIZE;
        ncp->abuf->occupy_table = (NC_buf_status*)
                   NCI_Realloc(ncp->abuf->occupy_table,
                               ncp->abuf->table_size * sizeof(NC_buf_status));
    }
    /* mark the new entry is used and store the requested buffer size */
    ncp->abuf->occupy_table[ncp->abuf->tail].is_used  = 1;
    ncp->abuf->occupy_table[ncp->abuf->tail].req_size = nbytes;

    *buf = (char*)ncp->abuf->buf + ncp->abuf->size_used;
    ncp->abuf->size_used += nbytes;
    ncp->abuf->tail++;

    return NC_NOERR;
}

/*----< ncmpii_igetput_varm() >-----------------------------------------------*/
int
ncmpii_igetput_varm(NC               *ncp,
                    NC_var           *varp,
                    const MPI_Offset  start[],
                    const MPI_Offset  count[],
                    const MPI_Offset  stride[],
                    const MPI_Offset  imap[],
                    void             *buf,      /* user buffer */
                    MPI_Offset        bufcount,
                    MPI_Datatype      buftype,
                    int              *reqid,
                    int               rw_flag,
                    int               use_abuf, /* if use attached buffer */
                    int               isSameGroup) /* if part of a group */
{
    void *xbuf=NULL, *cbuf=NULL, *lbuf=NULL;
    int err, status, warning; /* err is for API abort and status is not */
    int el_size, iscontig_of_ptypes, do_vars, isderived;
    int need_convert, need_swap, need_swap_back_buf;
    int i, dim=0, imap_contig_blocklen=1;
    MPI_Offset fnelems, bnelems, lnelems, nbytes;
    MPI_Datatype ptype, imaptype=MPI_DATATYPE_NULL;
    NC_req *req;

    /* "API error" will abort this API call, but not the entire program */
    err = status = warning = NC_NOERR;

    if (varp->ndims > 0 && start == NULL) {
        err = NC_ENULLSTART;
        goto err_check;
    }
    if (varp->ndims > 0 && count == NULL) {
        err = NC_ENULLCOUNT;
        goto err_check;
    }

    if (buftype == MPI_DATATYPE_NULL) {
        /* In this case, bufcount is ignored and will be recalculated to match
         * count[]. Note buf's data type must match the data type of
         * variable defined in the file - no data conversion will be done.
         */
        bufcount = 1;
        for (i=0; i<varp->ndims; i++) {
            if (count[i] < 0) { /* no negative count[] */
                err = NC_ENEGATIVECNT;
                goto err_check;
            }
            bufcount *= count[i];
        }
        /* assign buftype match with the variable's data type */
        buftype = ncmpii_nc2mpitype(varp->type);
    }

    do_vars = 0;

    if (varp->ndims == 0)
        /* reduced to scalar var, only one value at one fixed place */
        do_vars = 1;

    if (imap == NULL) /* no mapping, same as vars */
        do_vars = 1;
    else {
        imap_contig_blocklen = 1;
        dim = varp->ndims;
        /* test each dim's contiguity until the 1st non-contiguous dim is
           reached */
        while ( --dim >= 0 && imap_contig_blocklen == imap[dim] ) {
            if (count[dim] < 0)
                return NC_ENEGATIVECNT;
            imap_contig_blocklen *= count[dim];
        }
        if (dim == -1) /* imap is a contiguous layout */
            do_vars = 1;
    }
    /* dim is the first dimension (C order, eg. ZYX) that has non-contiguous
       imap and it will be used only when do_vars == 1
     */

    /* find the ptype (primitive MPI data type) from buftype
     * el_size is the element size of ptype
     * bnelems is the total number of ptype elements in buftype
     * fnelems is the number of nc variable elements in nc_type
     * nbytes is the amount of read/write in bytes
     */
    err = ncmpii_dtype_decode(buftype, &ptype, &el_size, &bnelems,
                              &isderived, &iscontig_of_ptypes);
    if (err != NC_NOERR) goto err_check;

    err = NCMPII_ECHAR(varp->type, ptype);
    if (err != NC_NOERR) goto err_check;

    CHECK_NELEMS(varp, fnelems, count, bnelems, bufcount, nbytes, err)
    /* bnelems now is the number of ptype in the whole buf */
    /* warning is set in CHECK_NELEMS() */

    /* for bput call, check if the remaining buffer space is sufficient
       to accommodate this request */
    if (rw_flag == WRITE_REQ && use_abuf &&
        ncp->abuf->size_allocated - ncp->abuf->size_used < nbytes)
        return NC_EINSUFFBUF;

    need_convert  = ncmpii_need_convert(varp->type, ptype);
    need_swap     = ncmpii_need_swap(varp->type, ptype);
    need_swap_back_buf = 0;

err_check:
    if (err != NC_NOERR) return err;

    if (bnelems == 0) {
        /* zero-length request, mark this as a NULL request */
        *reqid = NC_REQ_NULL;
        return NCcoordck(ncp, varp, start, rw_flag);
    }

/* Here is the pseudo code description on buffer packing
    if (iscontig_of_ptypes)
        lbuf = buf
    else
        lbuf = malloc
        pack buf -> lbuf

    if do_vars
        build imaptype
        cbuf = malloc
        pack lbuf -> cbuf
        if lbuf != buf, free lbuf
    else
        cbuf = lbuf
    lbuf = NULL

    if need convert
        if use_abuf
            xbuf = attach_buf_malloc
        else
            xbuf = malloc
        convert cbuf -> xbuf
        if cbuf != buf, free cbuf
    else
        if use_abuf
            xbuf = attach_buf_malloc
            memcpy(xbuf, cbuf)
            if cbuf != buf, free cbuf
        else
            xbuf = cbuf
        if need swap
            swap xbuf
    cbuf = NULL
*/

    if (!do_vars) {
        /* construct a derived data type, imaptype, based on imap[], and use
         * it to pack lbuf to cbuf.
         */
        MPI_Type_vector(count[dim], imap_contig_blocklen, imap[dim],
                        ptype, &imaptype);
        MPI_Type_commit(&imaptype);
        for (i=dim, i--; i>=0; i--) {
            MPI_Datatype tmptype;
            if (count[i] < 0)
                return ((warning != NC_NOERR) ? warning : NC_ENEGATIVECNT);
#ifdef HAVE_MPI_TYPE_CREATE_HVECTOR
            MPI_Type_create_hvector(count[i], 1, imap[i]*el_size, imaptype,
                                    &tmptype);
#else
            MPI_Type_hvector(count[i], 1, imap[i]*el_size, imaptype, &tmptype);
#endif
            MPI_Type_free(&imaptype);
            MPI_Type_commit(&tmptype);
            imaptype = tmptype;
        }
    }

    lbuf = NULL;
    cbuf = NULL;
    xbuf = NULL;

    if (rw_flag == WRITE_REQ) {
        int position, outsize;

        /* Step 1: pack buf into a contiguous buffer, lbuf */
        lnelems = bnelems; /* (number of ptype in buftype) * bofcount */
        if (iscontig_of_ptypes) { /* buf is contiguous */
            lbuf = buf;
        }
        else if (lnelems > 0) {
            /* pack buf into lbuf, a contiguous buffer, based on buftype */
            outsize = lnelems*el_size;
            lbuf = NCI_Malloc(outsize);

            position = 0;
            MPI_Pack(buf, bufcount, buftype, lbuf, outsize, &position,
                     MPI_COMM_SELF);
        }

        /* Step 2: pack lbuf to cbuf if imap is non-contiguos */
        if (do_vars) { /* reuse lbuf */
            cbuf = lbuf;
        }
        else { /* a true varm case, pack lbuf to cbuf based on imap */
            bnelems = imap_contig_blocklen * count[dim];
            for (dim--; dim>=0; dim--)
                bnelems *= count[dim];

            if (bnelems > 0) {
                outsize = bnelems*el_size;
                cbuf = NCI_Malloc(outsize);

                /* pack lbuf to cbuf, a contiguous buffer, based on imaptype */
                position = 0;
                MPI_Pack(lbuf, 1, imaptype, cbuf, outsize, &position,
                         MPI_COMM_SELF);
            }
            MPI_Type_free(&imaptype);
            imaptype = MPI_DATATYPE_NULL;

            /* for write case, lbuf is no longer needed */
            if (lbuf != buf) NCI_Free(lbuf);
        }
        lbuf = NULL; /* no longer need lbuf */

        /* Step 3: pack cbuf to xbuf and xbuf will be used to write to file */
        if (need_convert) { /* user buf type != nc var type defined in file */
            if (use_abuf) { /* use attached buffer */
                status = ncmpii_abuf_malloc(ncp, nbytes, &xbuf);
                if (status != NC_NOERR) {
                    if (cbuf != NULL && cbuf != buf) NCI_Free(cbuf);
                    return ((warning != NC_NOERR) ? warning : status);
                }
            }
            else
                xbuf = NCI_Malloc(nbytes);

            /* datatype conversion + byte-swap from cbuf to xbuf */
            DATATYPE_PUT_CONVERT(varp->type, xbuf, cbuf, bnelems, ptype, err)
            /* retain the first error status */
            if (status == NC_NOERR) status = err;
        }
        else {  /* cbuf == xbuf */
            if (use_abuf) { /* use attached buffer */
                status = ncmpii_abuf_malloc(ncp, nbytes, &xbuf);
                if (status != NC_NOERR) {
                    if (cbuf != NULL && cbuf != buf) NCI_Free(cbuf);
                    return ((warning != NC_NOERR) ? warning : status);
                }
                memcpy(xbuf, cbuf, nbytes);
            } else {
                xbuf = cbuf;
            }
            if (need_swap) {
#ifdef DISABLE_IN_PLACE_SWAP
                if (xbuf == buf) {
                    /* allocate xbuf and copy buf to xbuf, xbuf is to be freed */
                    xbuf = NCI_Malloc(nbytes);
                    memcpy(xbuf, buf, nbytes);
                }
#endif
                /* perform array in-place byte swap on xbuf */
                ncmpii_in_swapn(xbuf, fnelems, ncmpix_len_nctype(varp->type));
                if (xbuf == buf)
                    need_swap_back_buf = 1;
                    /* user buf needs to be swapped back to its original
                     * contents as now buf == cbuf == xbuf */
            }
        }
        /* cbuf is no longer needed */
        if (cbuf != buf && cbuf != xbuf) NCI_Free(cbuf);
        cbuf = NULL;
    }
    else { /* rw_flag == READ_REQ */
        /* Read is done at wait call, need lnelems and bnelems to reverse the
         * steps as done in write case */
        if (iscontig_of_ptypes)
            lnelems = bnelems / bufcount;
        else
            lnelems = bnelems;

        if (!do_vars) {
            bnelems = imap_contig_blocklen * count[dim];
            for (dim--; dim>=0; dim--)
                bnelems *= count[dim];
        }
        if (iscontig_of_ptypes && do_vars && !need_convert)
            xbuf = buf;  /* there is no buffered read (bget_var, etc.) */
        else
            xbuf = NCI_Malloc(nbytes);
    }

    /* allocate a new request object to store the write info */
    req = (NC_req*) NCI_Malloc(sizeof(NC_req));

    req->is_imap        = 0;
    req->imaptype       = imaptype;
    req->rw_flag        = rw_flag;

    req->tmpBuf         = NULL;
    req->tmpBufSize     = 0;
    req->userBuf        = NULL;
    req->userBufCount   = 0;
    req->userBufType    = MPI_DATATYPE_NULL;

    if (!do_vars)
        req->is_imap = 1;

    pack_request(ncp, varp, req, do_vars, buf, xbuf, start, count, stride,
                 fnelems, bnelems, lnelems, bufcount, buftype, ptype,
                 iscontig_of_ptypes, need_swap_back_buf, use_abuf);

    /* add the new request to the internal request array (or linked list) */
    if (ncp->head == NULL) {
        req->id   = 0;
        ncp->head = req;
        ncp->tail = ncp->head;
    }
    else { /* add to the tail */
        if (isSameGroup)
            req->id = *reqid;
        else
            req->id = ncp->tail->id + 1;
        ncp->tail->next = req;
        ncp->tail = req;
    }
    for (i=0; i<req->num_subreqs; i++)
        req->subreqs[i].id = req->id;

    /* return the request ID */
    *reqid = req->id;

    return ((warning != NC_NOERR) ? warning : status);
}

/*----< pack_request() >------------------------------------------------------*/
static int
pack_request(NC               *ncp,
             NC_var           *varp,
             NC_req           *req,
             int               do_vars,  /* if it is a true vars request */
             void             *buf,      /* user buffer, may need to be swapped back for put */
             void             *xbuf,     /* buffer that is type coverted, byte swapped from buf */
             const MPI_Offset  start[],
             const MPI_Offset  count[],
             const MPI_Offset  stride[],
             MPI_Offset        fnelems,  /* number of variable elements in nc_type */
             MPI_Offset        bnelems,  /* total number of ptype elements in buftype */
             MPI_Offset        lnelems,  /* (number of ptype in buftype) * bofcount */
             MPI_Offset        bufcount,
             MPI_Datatype      buftype,
             MPI_Datatype      ptype,    /* primitive MPI data type in buftype */
             int               iscontig_of_ptypes,
             int               need_swap_back_buf,
             int               use_abuf) /* if this is called from a bput */
{
    int     i, j;
    NC_req *subreqs;

    req->varp     = varp;
    req->ndims    = varp->ndims;
    req->start    = (MPI_Offset*) NCI_Malloc(2*varp->ndims*sizeof(MPI_Offset));
    req->count    = req->start + varp->ndims;
    req->buf      = buf;
    req->xbuf     = xbuf;
    req->fnelems  = fnelems;
    req->bnelems  = bnelems;
    req->lnelems  = lnelems; /* used only for iget_varm case */
    req->buftype  = buftype;
    req->bufcount = bufcount;
    req->ptype    = ptype;   /* MPI element datatype for the I/O buffer */
    req->next     = NULL;
    req->subreqs     = NULL;
    req->num_subreqs = 0;
    req->iscontig_of_ptypes = iscontig_of_ptypes;
    req->need_swap_back_buf = need_swap_back_buf;
    req->use_abuf           = use_abuf;

    if (stride != NULL)
        req->stride = (MPI_Offset*) NCI_Malloc(varp->ndims*sizeof(MPI_Offset));
    else
        req->stride = NULL;

    for (i=0; i<varp->ndims; i++) {
        req->start[i] = start[i];
        req->count[i] = count[i];
        if (stride != NULL)
            req->stride[i] = stride[i];
    }
    /* get the starting file offset for this request */
    ncmpii_get_offset(ncp, varp, start, NULL, NULL, req->rw_flag, &req->offset_start);

    /* get the ending file offset for this request */
    ncmpii_get_offset(ncp, varp, start, count, stride, req->rw_flag, &req->offset_end);
    req->offset_end += varp->xsz - 1;

    /* check if this is a record varaible. if yes, split the request into
       subrequests, one iput request for a record access. Hereandafter,
       treat each request as a non-record variable request */

    /* check if this access is within one record, if yes, no need to create
       subrequests */
    if (IS_RECVAR(varp) && req->count[0] > 1) {
        MPI_Offset rec_bufcount = 1;
        for (i=1; i<varp->ndims; i++)
            rec_bufcount *= req->count[i];

        subreqs = (NC_req*) NCI_Malloc(req->count[0]*sizeof(NC_req));
        for (i=0; i<req->count[0]; i++) {
            MPI_Offset span;
            subreqs[i] = *req; /* inherit most attributes from req */

            /* each sub-request contains <= one record size */
            subreqs[i].start = (MPI_Offset*) NCI_Malloc(2*varp->ndims*sizeof(MPI_Offset));
            subreqs[i].count = subreqs[i].start + varp->ndims;
            if (stride != NULL) {
                subreqs[i].stride = (MPI_Offset*) NCI_Malloc(varp->ndims*sizeof(MPI_Offset));
                subreqs[i].start[0] = req->start[0] + stride[0] * i;
                subreqs[i].stride[0] = req->stride[0];
            } else {
                subreqs[i].stride = NULL;
                subreqs[i].start[0] = req->start[0] + i;
            }

            subreqs[i].count[0] = 1;
            subreqs[i].fnelems = 1;
            for (j=1; j<varp->ndims; j++) {
                subreqs[i].start[j]  = req->start[j];
                subreqs[i].count[j]  = req->count[j];
                subreqs[i].fnelems  *= subreqs[i].count[j];
                if (stride != NULL)
                    subreqs[i].stride[j] = req->stride[j];
            }
            ncmpii_get_offset(ncp, varp, subreqs[i].start, NULL, NULL,
                              subreqs[i].rw_flag, &subreqs[i].offset_start);
            ncmpii_get_offset(ncp, varp, subreqs[i].start,
                              subreqs[i].count, subreqs[i].stride,
                              subreqs[i].rw_flag, &subreqs[i].offset_end);
            subreqs[i].offset_end += varp->xsz - 1;

            span                = i*rec_bufcount*varp->xsz;
            subreqs[i].buf      = (char*)(req->buf)  + span;
            /* xbuf cannot be NULL    assert(req->xbuf != NULL); */
            subreqs[i].xbuf     = (char*)(req->xbuf) + span;
            subreqs[i].bufcount = rec_bufcount;
        }
        req->num_subreqs = req->count[0];
        req->subreqs     = subreqs;
    }

    return NC_NOERR;
}

