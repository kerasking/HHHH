/*
 *  tools.h
 *	常用函数工具
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 */

#ifndef __TOOLS_H__
#define __TOOLS_H__

#include "uitypes.h"
#include <vector>
#include <string>
#include "C3BaseFuncInternal.h"



extern UITypes::FONT_SET_INFO *GetFontSetInfo(void);

//换行前把文本切割
extern int SplitText2MLine(const char *lpszText,
						   const char *lpszFont,
						   int iFontSize,
						   int nPixelPerLine,
						   std::vector<std::string> *pvecString,//多行文本列表
						   const char *pszVersionInfo,
						   char cKey = ' ',
						   bool bCutDBCSLeadByte = true, 
						   bool bEmotionType = false);

//是否是数字
extern bool IsDigit(char c);

extern void ReplaceString(char* pszString, char cFind, char cReplace);

extern void GetDirectoryFontFace(std::string &strPath, const char *pszFontDirectory);

extern void Split(const std::string &strText, std::vector<std::string> &vecString, const char *pszSplitChar);

//Log文件输出
// extern void	LogMsg(const char* fmt, ...);

void log_msg(const char *type,
					const char *str,
					const char *file,
					int line);

extern int IniDataGet(const char *pszFileName, const char *pszTitle, const char *pszSubTitle, int &iData, int bCritical=false);

extern bool IsSystemKeyPressed(int key);

extern char *itoaext(long long i64, char* buf, int radix);

extern void GetCursorPos(CPoint* lpPoint);

extern void MouseInit(void);

extern void MouseSet(int x, int y, int event);

extern int MouseCheck(int& iMouseX, int& iMouseY);

extern int MouseCheckNotConvert(int& iMouseX, int& iMouseY);

extern void MouseProcess(void);

//读取一行文本(以换行结束)
extern int MemTxtLineGetEx(const char* pBuf/*读取的文本*/, DWORD dwBufSize, DWORD& dwOffset, char* szLine/*得到的文本*/, DWORD dwLineSize/*最大一行文本长度*/);

//编码转换(出错返回false,而不是-1)
extern bool Code_Convert(const char* from_chartset, const  char* to_chartset,const  char* pSrc,int srcLen,char* lpRec, int recSize);

#	define WritePrivateProfileStringA(...)
#	define WritePrivateProfileStructA(...)
#	define WritePrivateProfileSectionA(...)
#ifndef WritePrivateProfileString
#	define WritePrivateProfileString
#endif
#ifndef ShellExecute
#	define ShellExecute(...)
#endif

#ifndef SAFE_DELETE
	#if defined(_DEBUG) || defined(NOEXCEPTION)
		#define SAFE_DELETE(p) { if(p) delete p; p=NULL; }
	#else
		#define SAFE_DELETE(p) { if(p){ try{ delete p; } catch(...){ \
			LogMsg("CATCH: *** SAFE_DELETE(%s) in %s %d", #p, __FILE__, __LINE__); \
		} p=NULL; }}
	#endif
#endif

#ifndef SAFE_DELETE_EX
	#if defined(_DEBUG) || defined(NOEXCEPTION)
		#define SAFE_DELETE_EX(p) { if(p) delete [] p; p=NULL; }
	#else
		#define SAFE_DELETE_EX(p) { if(p){ try{ delete [] p; } catch(...){ \
			LogMsg("CATCH: *** SAFE_DELETE_EX(%s) in %s %d", #p, __FILE__, __LINE__); \
		} p=NULL; }}
	#endif
#endif

#undef	SAFE_RELEASE

#if defined(_DEBUG) || defined(NOEXCEPTION)
#define SAFE_RELEASE(ptr)	ptr->Release(); ptr = 0; }
#else
#define SAFE_RELEASE(ptr)	{ if(ptr){ try{ ptr->Release(); }catch(...){ \
	LogMsg("CATCH: *** SAFE_RELEASE(%s) in %s %d", #ptr, __FILE__, __LINE__); \
} ptr = 0; } }
#endif




#ifndef MYASSERT
	#ifdef _DEBUG
	#define MYASSERT(x) \
		(void)((x) || (log_msg("ASSERT", #x, __FILE__, __LINE__) /* , assert(!(#x)), 0) */)
	#else
	#define MYASSERT(x) \
		(void)((x) || (log_msg("ASSERT", #x, __FILE__, __LINE__), 0))
	#endif
#endif


#ifdef _DEBUG
#define CHECK(x) \
	do \
	{ \
		if (!(x)) { \
			log_msg("CHECK", #x, __FILE__, __LINE__) /* , assert(!(#x)) */; \
			return; \
		} \
	} while (0)
#else
#define CHECK(x) \
	do \
	{ \
		if (!(x)) { \
			log_msg("CHECK", #x, __FILE__, __LINE__); \
			return; \
		} \
	} while (0)
#endif


#ifdef _DEBUG
#define CHECKC(x) \
	if (!(x)) { \
		log_msg("CHECK", #x, __FILE__, __LINE__) /* , assert(!(#x)) */; \
		continue; \
	}
#else
#define CHECKC(x) \
	if (!(x)) { \
		log_msg("CHECK", #x, __FILE__, __LINE__); \
		continue; \
	}
#endif


#ifdef _DEBUG
#define CHECKF(x) \
	do \
	{ \
		if (!(x)) { \
			log_msg("CHECKF", #x, __FILE__, __LINE__) /* , assert(!(#x)) */; \
			return 0; \
		} \
	} while (0)
#else
#define CHECKF(x) \
	do \
	{ \
		if (!(x)) { \
			log_msg("CHECKF", #x, __FILE__, __LINE__); \
			return 0; \
		} \
	} while (0)
#endif

#ifdef _DEBUG
#define CHECKS(x,T) \
	do \
	{ \
		if (!(x)) { \
			log_msg("CHECKS", #x, __FILE__, __LINE__) /* , assert(!(#x)) */ ; \
			return T(); \
		} \
	} while (0)
#else
#define CHECKS(x,T) \
	do \
	{ \
		if (!(x)) { \
			log_msg("CHECKS", #x, __FILE__, __LINE__); \
			return T(); \
		} \
	} while (0)
#endif


#ifndef IF_SUC
	#ifdef _DEBUG
		#define	IF_SUC(x)  if( ((x)) ? true : ( /* assert(!("IF_SUC: " #x)), */ false ) )
	#else
		#define	IF_SUC(x)  if( ((x)) ? true : ( LogMsg("IF_SUC(%s) failed in %s, %d", #x, __FILE__, __LINE__), false ) )
	#endif
#endif

#define IF_TRUE	IF_SUC
#define IF_YES	IF_SUC
#define IF_OK	IF_SUC


#ifndef IF_NOT
	#ifdef _DEBUG
		#define	IF_NOT(x)  if( (!(x)) ? ( /* assert(!("IF_NOT: " #x)), */ 1 ) : 0 )
	#else
		#define	IF_NOT(x)  if( (!(x)) ? ( LogMsg("IF_NOT(%s) in %s, %d", #x, __FILE__, __LINE__),1 ) : 0 )
	#endif
#endif
#endif
