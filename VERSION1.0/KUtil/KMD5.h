#ifndef __KMD5_H
#define __KMD5_H

#include "KData.h"

#ifndef u_int32_t
typedef unsigned int  u_int32_t;
#endif

#ifndef u_int16_t
typedef unsigned short  u_int16_t;
#endif

#ifndef u_int8_t
typedef unsigned char  u_int8_t;
#endif

#ifdef __cplusplus
extern "C"
{
#endif

#define md5byte unsigned char

    struct MD5Context
    {
        u_int32_t buf[4];
        u_int32_t bytes[2];
        u_int32_t in[16];
    };

    void MD5Init(struct MD5Context *context);
    void MD5Update(struct MD5Context *context, md5byte const *buf, unsigned len);
    void MD5Final(unsigned char digest[16], struct MD5Context *context);
    void MD5Transform(u_int32_t buf[4], u_int32_t const in[16]);

#ifdef __cplusplus
}
#endif


const KData getMd5String(const KData & buf);

void getMd5Digit(const unsigned char *buf, unsigned char *ret, int len);

#endif
