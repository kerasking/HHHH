/*
封装数据转换类
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
*/
#ifndef __DATACONVER__HEADER__
#define __DATACONVER__HEADER__

#pragma once

#include "BaseType.h"

class CDataConvert
{
public:
	CDataConvert(void);
	~CDataConvert(void);

	CDataConvert(int nValue);
	CDataConvert(float fValue);
	CDataConvert(double dValue);
	CDataConvert(char* pValue);
	CDataConvert(const char* pcValue);

	operator char*();
	operator const char*();
	operator int();
	operator float();
	operator double();
	
	int		ToInt(const char* pValue);
	float	ToFloat(const char* pValue);
	double	ToDouble(const char* pValue);

	char*	ToString(int nValue);
	char*	ToString(float fValue);
	char*	toString(double dValue);

	char*	Format(const char* pcFormat, ...);

	char*	UTF8ToUnicode(const char* pcUTF8Value);
	char*	UTF8ToGB(const char* pcUTF8Value);
	
	char*	UnicodeToUTF8(const char* pcUniValue);
	char*	UnicodeToGB(const char* pcUniValue);

	char*	GBToUTF8(const char* pcGBValue);
	char*	GBToUnicode(const char* pcGBValue);
	
	char*	CharSet_Conver(const char* pSrc, const char* pSrcCharSet, const char* pDstCharSet);

	void	SetBuffSize(int nSize);
	void	ResetBuff();
protected:
	
	void	Init();
	char	m_szBuff[1000];

	int		m_nBigBuffSize;
	char*	m_pBigBuff;
};
#endif