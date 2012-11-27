#ifndef _BASE_TYPE_H_
#define _BASE_TYPE_H_

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <math.h>
#include <time.h>
//#include "C3Primitive.h"
#include "CCConfiguration.h"
#include "TQPlatform.h"

#ifdef IOS
#define _vstprintf vsprintf
#define _access	access
#elif ANDROID
#include <unistd.h>
#define _vstprintf vsprintf
#define sleep usleep
#define _access	access
#endif

#ifndef CONST
#define CONST	const
#endif

#ifndef FALSE
#define FALSE	0
#endif

#ifndef TRUE
#define TRUE	1
#endif

#ifndef WIN32
typedef signed char		BOOL; 
#endif

#ifdef WIN32 
#define sleep Sleep
#else
#undef IN
#define IN

#undef OUT
#define OUT

#ifndef BOOLENABLE

#endif
typedef int					INT;
typedef unsigned int		UINT;

typedef unsigned int		DWORD;
typedef unsigned short		WORD;
typedef float				FLOAT;
typedef long long			__int64;
typedef unsigned long long	ULONGLONG;
typedef __int64				_INT64;
typedef __int64				INT64;
typedef unsigned long long	UINT64;
typedef unsigned int		UINT32;
typedef unsigned char		UINT8;
typedef unsigned short		UINT16;
typedef long				LONG;
typedef unsigned long		ULONG;
typedef unsigned char		BYTE;
typedef unsigned char		_TUCHAR;
typedef double				DOUBLE;

#define WM_USER	0x0400

typedef char CHAR;
typedef unsigned char UCHAR;
typedef char TCHAR;
typedef short SHORT;
typedef unsigned short USHORT;
typedef long LONG;

typedef CONST CHAR *LPCSTR, *PCSTR;
typedef LPCSTR PCTSTR, LPCTSTR, PCUTSTR, LPCUTSTR;

typedef CHAR *LPSTR, *PSTR;
typedef LPSTR PTSTR, LPTSTR, PUTSTR, LPUTSTR;

UINT GetPrivateProfileInt(LPCTSTR lpAppName, LPCTSTR lpKeyName, INT nDefalut, LPCSTR lpFileName);
DWORD GetPrivateProfileString(LPCTSTR lpAppName, LPCTSTR lpKeyName, LPCTSTR lpDefault, LPTSTR lpReturnedString, DWORD nSize, LPCTSTR lpFileName);

typedef void *HANDLE;

char *_itoa(int n, char* pBuffer, int nLength);
char *_i64toa(__int64 n, char* pBuffer, int nLength);
__int64 _atoi64(const char *pBuffer);
char *ltoa(int n, char* pBuffer, int nLength);

#ifndef WIN32
//MAC系统下没有这个函数，这个不是标准C++函数。目前只支持8/10/16，3种进制
#define itoa(n, pBuffer, nLength) __itoa((n), (pBuffer), (nLength))
#endif

#define _snprintf snprintf

#define __stdcall pascal

#define RtlZeroMemory(Destination, Length) memset((Destination), 0, (Length))
#define ZeroMemory RtlZeroMemory

int lstrlen(LPCSTR lpString);
LPTSTR lstrcpy(LPTSTR lpString1, LPCTSTR lpString2);
LPTSTR lstrcat(LPTSTR lpString1, LPCTSTR lpString2);
int lstrcmp(LPCTSTR lpString1, LPCTSTR lpString2);
void _tcsupr(char* pszString);
void _tcslwr(char* pszString);
#define stricmp(p1, p2) strcasecmp((p1), (p2))
#define _stricmp(p1, p2) strcasecmp((p1), (p2))
#define _mbschr(p1, p2) strchr((p1), (p2))
#define _tcschr(p1, p2) strchr((p1), (p2))
#define _tcspbrk(p1, p2) strpbrk((p1), (p2))
#define _tcsstr(p1, p2) strstr((p1), (p2))
#define _tcscmp(p1, p2) strcmp((p1), (p2))
#define _tcsicmp(p1, p2) _stricmp((p1), (p2))

#ifndef __max
#define __max(a, b) (((a) > (b)) ? (a) : (b))
#endif
#ifndef __min
#define __min(a, b) (((a) < (b)) ? (a) : (b))
#endif

#ifndef _MAX_PATH
#define _MAX_PATH	260
#endif

#define _MAX_DRIVE	3
#define _MAX_DIR	256
#define _MAX_FNAME	256
#define _MAX_EXT	256

typedef unsigned int	WPARAM;
typedef long			LPARAM;

typedef void VOID;
#ifndef DECLARE_HANDLE
#define DECLARE_HANDLE(name) struct name##__ { int unused; }; typedef struct name##__ *name
DECLARE_HANDLE(HWND);
#endif
//typedef struct tagRECT
//{
//	LONG	left;
//	LONG	top;
//	LONG	right;
//	LONG	bottom;
//} RECT, *PRECT;

typedef struct tagPOINT
{
	LONG x;
	LONG y;
}POINT, *PPOINT;

DWORD timeGetTime();


#endif








#include <map>
#include <list>
#include <deque>
#include <string>
#include <vector>
#include <set>
#include <algorithm>
#include <fstream>
#include <iostream>
using namespace std;

#undef OUT
#define OUT

#undef IN_OUT
#define IN_OUT

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
typedef unsigned __int64 EID;
typedef unsigned long       DWORD;
//typedef UINT64 EID;
const EID EID_NONE = 0;
#else
typedef UINT64 EID;
const EID EID_NONE = 0;
#endif

typedef std::vector<int> INT_VEC;
typedef std::set<int> INT_SET;
typedef std::vector<std::string> STRING_VEC;
typedef std::set<std::string> STRING_SET;
typedef std::map<int, int> INT_INT_MAP;
typedef std::map<int, std::string> INT_STR_MAP;
typedef std::map<std::string, std::string> STR_STR_MAP;
typedef std::vector<DWORD> DWORD_VEC;
#if 0

class CPos2D
{
public:
	CPos2D()
	{
		ZeroMemory(this, sizeof(CPos2D));
	}

	CPos2D(float _x, float _y)
	{
		x = _x; y = _y;
	}

	float x, y;
};

class CPos3D
{
public:
	CPos3D()
	{
		ZeroMemory(this, sizeof(CPos3D));
	}

	CPos3D(float _x, float _y, float _z)
	{
		x = _x; y = _y; z = _z;
	}

	float x, y, z;
};

struct MatrixData{
	float m[4][4];

	MatrixData(){
		for (int i=0; i<4; i++)
		{
			for (int j=0; j<4; j++)
				m[i][j] = 0.0;
		}
	};

	MatrixData(float _11, float _12, float _13, float _14,
		float _21, float _22, float _23, float _24,
		float _31, float _32, float _33, float _34,
		float _41, float _42, float _43, float _44)
	{
		m[0][0] = _11;	m[0][1] = _12;	m[0][2] = _13;	m[0][3] = _14;
		m[1][0] = _21;	m[1][1] = _22;	m[1][2] = _23;	m[1][3] = _24;
		m[2][0] = _31;	m[2][1] = _32;	m[2][2] = _33;	m[2][3] = _34;
		m[3][0] = _41;	m[3][1] = _42;	m[3][2] = _43;	m[3][3] = _44;
	};
};

typedef std::deque<CPos3D>  DEQ_POS3D;


struct  NODE_RUN_TIME_INFO
{
	int nCmdType;					
	int nState;						
	int nNodeIndex;					
};


struct FONT_INFO
{
	char pszKey[256];
	char pszName[256];
	int nSize;

	FONT_INFO(){}
};
#endif




// #ifndef OBJID
// typedef unsigned int OBJID;
// #endif 

#define _UINT64 UINT64
#define _INT64 INT64





#endif
