#include <ctype.h>
#include "Kathy.h"


int compareNoCase(const char *str1, const char *str2, int len)
{
	for (int i = 0; i < len; i++)
	{
		if ( toupper(*str1) < toupper(*str2) )
		{
			return -1;
		}
		if ( toupper(*str1) > toupper(*str2) )
		{
			return 1;
		}
		str1++;
		str2++;
	}
	return 0;
}

bool ascBcd(const char *ascstr, unsigned char *bcdstr, int bcdlen)
{
	int i, j, m, n;
	
	j = bcdlen * 2 - 1;
	for (i = j/2; i >= 0; i--)
	{
		if (j <= 0)
			return false;
		else
		{
			m = ascCharToInt( ascstr[j-1] );
			n = ascCharToInt( ascstr[j] );
			if(m == -1 || n == -1)
				return false; 
			bcdstr[i] = (m<<4) | n;
			j -= 2;
		}
	}
	return true;
}

int ascCharToInt(unsigned char asc)
{
	if (asc <= '9' && asc >= '0')
        return asc - '0';
    else if (asc <= 'F' && asc >= 'A')
        return asc - 'A' + 0x0A;
    else if (asc <= 'f' && asc >= 'a')
        return asc - 'a' + 0x0A;
    else
        return -1;
}

KData convertToHex(const unsigned char *src, int len)
{
    KData data;
    unsigned char temp;
	
    int i;
    for ( i = 0; i < len; i++ )
    {
        temp = src[i];
		
        int hi = (temp & 0xf0) / 16;
        int low = (temp & 0xf);
		
        char buf[4];
        buf[0] = '\0';
		
        sprintf( buf, "%x%x", hi, low );
        data += buf;
    }
    return data;
}

