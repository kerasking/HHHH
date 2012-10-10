#ifndef __KT_KATHY_H
#define __KT_KATHY_H

#include "KData.h"

int compareNoCase(const char *str1, const char *str2, int len);

bool ascBcd(const char *ascstr, unsigned char *bcdstr, int bcdlen);
int ascCharToInt(unsigned char asc);

KData convertToHex(const unsigned char *src, int len);

#endif
