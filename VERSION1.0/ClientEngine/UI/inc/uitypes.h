/*
 *  uitypes.h
 *	UI类型定义
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 */
#ifndef __UI_TYPES_H__
#define __UI_TYPES_H__

#define CQ_PLATFORM 1
#define CQ_PLATFORM_MAC 1
#define CQ_PLATFORM_WIN32 2

#include <deque>
//#include <C3Primitive.h>
#include "BaseType.h"
#ifdef ANDROID
extern void LogI(const char* pFormat, ...);
#define  printf LogI
#endif


typedef int DLG_HANDLE;  //对话框句柄
typedef int DLG_IDD;	//对话框ID 

#ifndef WIN32
typedef unsigned int		UINT;
typedef unsigned int	WPARAM;
typedef long			LPARAM;
#define _atoi64             atoll
#define _snprintf           snprintf
#define _vsnprintf          vsnprintf
#define _strdup             strdup	
#define _strlwr             strlwr	
//#define _int64              I64
//#define __int64             I64		
#define _ASSERT(x)          assert(x)

#define INVALID_SOCKET      -1
#define SOCKET_ERROR        -1
#define WSAEWOULDBLOCK      EWOULDBLOCK
#define _MAX_FNAME          256
#define LOWORD(l)           (WORD)(((DWORD)(l)) & 0xFFFF)
#define HIWORD(l)           (WORD)(((DWORD)(l) >> 16) & 0xFFFF)
#define LOBYTE(w)           (BYTE)(((WORD)(w)) & 0xFF)
#define HIBYTE(w)           (BYTE)(((WORD)(w) >> 8) & 0xFF)
//将两个16位的数联合成一个无符号的32位数: MAKELONG(32位数的低16位,32位数的高16位)
#define MAKELONG(a, b)      ((LONG)(((DWORD)(a) & 0xFFFF) | ((DWORD)(b) & 0xFFFF) << 16))
#define MAKEWORD(a, b)      ((WORD)(((WORD)(a) & 0xFF) | ((WORD)(b) & 0xFF) << 8))
#endif



#ifdef WIN32
#define snprintf _snprintf

#ifdef CreateDirectory 
#undef CreateDirectory 
#endif

#ifdef CreateDialog
	#undef CreateDialog
#endif

#ifdef SendMessage
	#undef SendMessage
#endif

#endif

typedef const wchar_t* LPCWSTR;
typedef LONG LRESULT;

typedef struct
{
	int	x;
	int   y;
}	C3_POS;

typedef struct
{
	int  iWidth;
	int  iHeight;
}	C3_SIZE;

typedef struct
{
	int left;
	int top;
	int right;
	int bottom;
}	C3_RECT;

typedef struct
{
	float fHorizontal;
	float fVertical;
}	C3_DIR;
//大小
class CSize : public C3_SIZE
{
public:
	//默认是大小是0
	CSize();

	CSize(int iWidth, int iHeight);

	CSize(C3_SIZE initSize) 
	{
		*(C3_SIZE*)this = initSize; 
	}

	CSize(C3_POS initPt) 
	{ 
		*(C3_POS*)this = initPt; 
	}

	CSize(DWORD dwSize) 
	{
		iWidth = (short)LOWORD(dwSize);
		iHeight = (short)HIWORD(dwSize);
	}

	//operator C3_SIZE& ();
	
	//C3_SIZE转CSize
	CSize& operator =(const C3_SIZE& size) 
	{
		if (this != &size) {
			iWidth = size.iWidth;
			iHeight = size.iHeight;
		}

		return *this;
	}

	//设置大小
	void SetSize(int nWidth, int nHeight);	
};

#ifndef GET_X_LPARAM
	#define GET_X_LPARAM(lParam)	((int)(short)LOWORD(lParam))
#endif
#ifndef GET_Y_LPARAM
	#define GET_Y_LPARAM(lParam)	((int)(short)HIWORD(lParam))
#endif
//坐标 - A 2-D point
class CPoint : public C3_POS 
{
public:
	CPoint() {
		x = 0;
		y = 0;
	}

	CPoint(int cx, int cy) {
		x = cx;
		y = cy;
	}

	CPoint(C3_POS initPt) 
	{
		*(C3_POS*)this = initPt;
	}

	CPoint(C3_SIZE initSize) 
	{
		*(C3_SIZE*)this = initSize;
	}

	//WPARAM转CPoint
	CPoint (const WPARAM& wParam) 
	{
		x = GET_X_LPARAM(wParam);
		y = GET_Y_LPARAM(wParam);
	}

	//C3_POS转CPoint
	CPoint& operator =(const C3_POS& pos)
	{
		if (this != &pos) {
			x = pos.x;
			y = pos.y;
		}

		return *this;
	}

	//CPoint转C3_POS
	/*C3_POS& operator =(const CPoint& pos)
	{
		if (this != &pos) {
			x = pos.x;
			y = pos.y;
		}
		return *this;
	}*/

	//是否相等
	bool operator ==(const CPoint& other) const
	{
		return (x == other.x && y == other.y);
	}

	//是否不等
	bool operator !=(const CPoint& other) const
	{
		return (x != other.x || y != other.y);
	}

	CPoint& operator +=(const CPoint& rhs) 
	{
		x += rhs.x;
		y += rhs.y;
		return *this;
	}

	CPoint& operator -=(const CPoint& rhs)
	{
		x -= rhs.x;
		y -= rhs.y;
		return *this;
	}

	const CPoint operator +(const CPoint& rhs) const 
	{
		CPoint tmp = *this;
		tmp += rhs;
		return tmp;
	}

	const CPoint operator -(const CPoint& rhs) const 
	{
		CPoint tmp = *this;
		tmp -= rhs;
		return tmp;
	}

	CPoint operator-() const 
	{ return CPoint(-x, -y); }


	void Offset(int xOffset, int yOffset) 
	{ x += xOffset; y += yOffset; }

	void Offset(CPoint& point)
	{ x += point.x; y += point.y; }

	void Offset(CSize& size) 
	{ x += size.iWidth; y += size.iHeight; }

	void SetPoint(int X, int Y)
	{ x = X; y = Y; }


};

//区域(CRect(left,top,right,bottom))
class CRect : public C3_RECT {
public:
	CRect() {
		left = top = right = bottom = 0;
	}

	CRect(int l, int t, int r, int b) {
		left = l;
		top = t;
		right = r;
		bottom = b;
	}

	CRect(const C3_RECT& rc) {
		left = rc.left;
		top = rc.top;
		right = rc.right;
		bottom = rc.bottom;
	}

	//获取宽度
	int Width() const;

	//获取高度
	int Height() const;

	//CRect转C3_RECT
	operator C3_RECT*() {
		return this;
	}

	//CRect转const C3_RECT
	operator const C3_RECT*() {
		return this;
	}

	//C3_RECT转CRect
	//CRect& operator =(const C3_RECT& rc/*原C3_RECT的值*/) {
	//	if (this != &rc) {
	//		left = rc.left;
	//		top = rc.top;
	//		right = rc.right;
	//		bottom = rc.bottom;
	//	}
	//	return *this;
	//}

	// convert between CRect and LPRECT/LPCRECT (no need for &)
	/*operator *C3_RECT()
	{
		return this;
	}

	operator const *C3_RECT() const
	{
		return this;
	}*/

	//设置区域
	void SetRect(int x1, int y1, int x2, int y2);

	void NormalizeRect() throw()
	{
		int nTemp;
		if (left > right)
		{
			nTemp = left;
			left = right;
			right = nTemp;
		}
		if (top > bottom)
		{
			nTemp = top;
			top = bottom;
			bottom = nTemp;
		}
	}

	bool UnionRect(CRect*  lprc1, const CRect* lprc2) {
		left = __min(lprc1->left, lprc2->left);
		right = __max(lprc1->right, lprc2->right);
		top = __min(lprc1->top, lprc2->top);
		bottom = __max(lprc1->bottom, lprc2->bottom);
		return left < right && top < bottom;
	}

	//偏移大小(左右X坐标同时向右移动,上下Y坐标同时向下移动)
	void OffsetRect(int x/*偏移X坐标*/, int y/*偏移Y坐标*/);

	//偏移大小(OffsetRect(point.x, point.y))
	void OffsetRect(CPoint& point/*偏移的坐标*/);

	//偏移大小
	void OffsetRect(CSize& size/*大小*/);

	//宽度的绝对值
	int GetAbsWidth();

	//高度的绝对值
	int GetAbsHeight();
	
	//反向高度(top-bottom)
	int RevokeHeight();

	//置空区域(top=left=bottom=right=0)
	void SetRectEmpty();

	//区域是否为空((left > right )  || (top>bottom))
	bool IsRectEmpty();

	//区域是否不存在(top,left,right,bottom都为0时返回真)
	bool IsRectNull();

	//坐标是否在本区域内(左开右闭:若rect.left<=point.x<rect.right 且 rect.top<=point.y<rect.bottom 则point在rect内)
	bool PtInRect(CPoint pt/*坐标*/);

	/*增大或减小指定矩形的宽和高。(InflateRect函数在矩形的左和右增加dx,在矩形的上下增加dy。 dx和dy参数是有符号值。正数增加宽和高，负数减小。) */
	void InflateRect( int dx, int dy);
	
	void InflateRect(const CRect* lpRect) 
	{
		left -= lpRect->left;		top -= lpRect->top;
		right += lpRect->right;		bottom += lpRect->bottom;
	}	
	
	void InflateRect(int l, int t, int r, int b) throw()
	{
		left -= l;			top -= t;
		right += r;			bottom += b;
	}	
	
	void DeflateRect(const CRect* lpRect) throw()
	{
		left += lpRect->left;	top += lpRect->top;
		right -= lpRect->right;	bottom -= lpRect->bottom;
	}

	//缩小矩形的边长
	void DeflateRect(int l, int t, int r, int b) throw()
	{
		left += l;	
		top += t;
		right -= r;	
		bottom -= b;
	}

	//缩小矩形的边长
	void DeflateRect(int x/*左右的大小都减小*/, int y/*上下的大小都减小*/)
	{
		left += x;	
		top += y;
		right -= x;	
		bottom -= y;
	}

};

//位置置中,把小窗口放在大窗口正中间(_w大窗口,_i小窗口)
#define CALLCENTER(_w,_i) ((int)(((float)(_w) -(float)(_i))/2.0))

//方向
class CDir : public C3_DIR
{
public:
	CDir();
	CDir(float fHorizontal,float fVertical);

	operator C3_DIR& ();
};

//3D坐标顶点(int类型)
typedef struct 
{
	int	x, y, z;
}C3DPos;

//坐标顶点(float类型)
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

//3D坐标顶点(float类型)
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
		memset(&m,0,sizeof(m));
		/*for (int i=0; i<4; i++)
		{
			for (int j=0; j<4; j++)
				m[i][j] = 0.0;
		}*/
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

typedef std::deque<CPos3D>  DEQ_STEP;
typedef std::deque<CPoint>  DEQ_STEP_2DPOS;



namespace UITypes
{
	typedef void* HICON;
	typedef void* HCURSOR;
	typedef void* HBITMAP;
	typedef void* HBRUSH;
	typedef void* HHOOK;
	typedef void* HRGN;
	typedef void* HTREEITEM;

#ifndef DECLARE_HANDLE
	#define DECLARE_HANDLE(name) struct name##__ { int unused; }; typedef struct name##__ *name
#endif
	DECLARE_HANDLE(HWND);
#ifndef __max
	#define __max(a, b) (((a) > (b)) ? (a) : (b))
#endif
	
#ifndef __min
	#define __min(a, b) (((a) < (b)) ? (a) : (b))
#endif
	
	typedef struct tagRGBQUAD
	{
		BYTE	rgbBlue;
		BYTE	rgbGreen;
		BYTE	rgbRed;
		BYTE	rgbReserved;
	}	RGBQUAD;

	const int _MAX_STRING	 = 256;
	const int _MAX_LONG_STRING = 1024;
	const int _MAX_NAMESIZE	 = 16;
	const int _MAX_TEAMNAME_SIZE = 32;
	const int _MAX_NAMESIZE_CLI = 32;
	const int _MAX_FULLNAMESIZE = 64;
	const int _MAX_LONGNAMESIZE = 36;
	const int _MAX_TITLESIZE = 128;
	const int _MAX_ITEM_NAMESIZE = 36;
	const int _MAX_MAGIC_NAMESIZE = 36;
	const int _MAX_MAP_NAMESIZE = 36;
	const int _MAX_NPC_NAMESIZE = 36;
	const int _MAX_SYNDICATE_NAMESIZE = 36;
	const int _MAX_MACSIZE = 41;
	const int _MAX_SYNENEMYSIZE = 5;		
	const int _MAX_SYNALLYSIZE = 5;			
	const int _EMOTION_WIDTH = 21;
	const int _MAX_USER_ATTRIBUTE = 128;	
	const int _MAX_CLIENT_USER_STATUS = 16;	
	
	
	
#if 0
	typedef struct tagMSG
	{
		HWND	hwnd;
		UINT	message;
		WPARAM	wParam;
		LPARAM	lParam;
		DWORD	time;
		C3_POS	pt;
	} MSG, *PMSG, *LPMSG;

	const int ACTTYPE_NONE = 0;
	const int ACTTYPE_FIRE = 1;
	const int ACTTYPE_RED = 2;
	const int ACTTYPE_BLUE = 3;
	const int ACTTYPE_ROYALBLUE = 4;
	const int ACTTYPE_GEM = 5;
	const int ACTTYPE_YELLOW = 6;
#endif
	
	const float PI = 3.1415926f;
	
	typedef unsigned char       BYTE;
	typedef unsigned short      WORD;
	typedef unsigned int       DWORD;
//	typedef unsigned int OBJID;
	typedef long long           I64;
	typedef unsigned long long  UI64;
	typedef long long           INT64;
	typedef DWORD               D3DCOLOR;
	
	const int	DEFAULT_EQUIP_COLOR = 3;
	const int	EQUIP_COLOR_MIN = 3;
	const int	EQUIP_COLOR_MAX = 9;
	
	
	#define _SOUND_DISABLE
	#ifdef _SOUND_DISABLE
	#define DXPlaySound 
	#endif

	
	
	
	#define WM_USER 0x0400
	#define WM_QUIT 0x0012
	#define SW_HIDE 0
	#define SW_SHOW 5
	#define CB_ERR (-1)
	#define SB_LINEUP 0
	#define SB_LINEDOWN 1
	#define SB_ENDSCROLL 8
	#define LB_OKAY 0
	
	#define SB_LEFT 6
	#define SB_TOP 6
	#define SB_RIGHT 7
	#define SB_BOTTOM 7
	
	#define CP_ACP 0
	
	
	#define VK_LBUTTON        0x01
	#define VK_RBUTTON        0x02
	#define VK_CANCEL         0x03
	#define VK_MBUTTON        0x04    /* NOT contiguous with L & RBUTTON */
	
	#define VK_BACK           0x08
	#define VK_TAB            0x09
	
	#define VK_CLEAR          0x0C
	#define VK_RETURN         0x0D
	
	#define VK_SHIFT          0x10
	#define VK_CONTROL        0x11
	#define VK_MENU           0x12
	#define VK_PAUSE          0x13
	#define VK_CAPITAL        0x14
	
	#define VK_KANA           0x15
	#define VK_HANGEUL        0x15  /* old name - should be here for compatibility */
	#define VK_HANGUL         0x15
	#define VK_JUNJA          0x17
	#define VK_FINAL          0x18
	#define VK_HANJA          0x19
	#define VK_KANJI          0x19
	
	#define VK_ESCAPE         0x1B
	
	#define VK_CONVERT        0x1C
	#define VK_NONCONVERT     0x1D
	#define VK_ACCEPT         0x1E
	#define VK_MODECHANGE     0x1F
	
	#define VK_SPACE          0x20
	#define VK_PRIOR          0x21
	#define VK_NEXT           0x22
	#define VK_END            0x23
	#define VK_HOME           0x24
	#define VK_LEFT           0x25
	#define VK_UP             0x26
	#define VK_RIGHT          0x27
	#define VK_DOWN           0x28
	#define VK_SELECT         0x29
	#define VK_PRINT          0x2A
	#define VK_EXECUTE        0x2B
	#define VK_SNAPSHOT       0x2C
	#define VK_INSERT         0x2D
	#define VK_DELETE         0x2E
	#define VK_HELP           0x2F
	
#ifndef _MAX_PATH	
	#define _MAX_PATH 255
	const int LB_ERR = -1;
#endif
		
	const int LIST_TRUNCATIONLEN = 15;
	
	
	enum {
		_MOUSE_NONE			= 0,
		_MOUSE_CLICK		= 10,
		_MOUSE_DOWN			= 01,
		_MOUSE_HOLD			= 11,
		_MOUSE_RIGHTCLICK	= -10,
		_MOUSE_RIGHTDOWN	= -01,
		_MOUSE_RIGHTHOLD	= -11,
		_MOUSE_ON			= 20,
		_MOUSE_DOWN_WITH_CTRL = 101,		
	};
	
	
	//字体属性
	struct FONT_SET_INFO
	{
		int nChatFontSize;//字体大小(默认14)
		int nTextStyle;//文字风格(默认RENDER_TEXT_SIMPLE)
		bool bAntialias;
		bool bGuiFontShadow;
		char szChatFont[_MAX_STRING];//字体2
		char szGuiFont[_MAX_STRING];//字体
		DWORD dwChatFontShadowColor;
		DWORD dwGuiFontShadowColor;
		C3_POS posShadow;
		FONT_SET_INFO(void);
	};
	
	struct ITEM_CONTROL_INFO
	{
		int m_nAddLev;
		int m_nNum;
		bool m_bMySelf;
		bool m_bTotemReg;
		ITEM_CONTROL_INFO()
		:
		m_nAddLev(0),
		m_nNum(0),
		m_bMySelf(true),
		m_bTotemReg(false) {
		}
	};
	struct CMouseInfo{
		int iPosX, iPosY;
		int iEvent;
		DWORD dwDownTime;
	};
	struct FLASH_VAR_INFO {
		char szVariable[64];
		char szArgs[1024];
		FLASH_VAR_INFO(void)
		{
			szVariable[0] = szArgs[0] = 0;
		}
	};
	
	struct MY_SSCANF_FORMAT_DATA
	{
		bool bSkip;
		int iWidth;
		const char* pszModifier;
		char cType;
	};
}

//九宫格配置参数
typedef struct  
{
	/*C3_SIZE	WndRect;*/
	C3_SIZE lefttopRect; //left-top Rect 
	C3_SIZE topRect;
	C3_SIZE righttopRect;
	C3_SIZE leftRect;
	C3_SIZE centerRect; //center Rect
	C3_SIZE rightRect;
	C3_SIZE leftbottomRect;
	C3_SIZE bottomRect;
	C3_SIZE rightbottomRect; //right-bottom Rect  
}	C3_NINESQUARE_RECT;

#endif
