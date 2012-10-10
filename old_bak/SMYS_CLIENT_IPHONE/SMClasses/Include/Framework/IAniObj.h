/*
 *  IAni.h
 *  Copyright 2010 TQ Digital Entertainment. All rights reserved.
 */

#ifndef _I_ANI_H
#define _I_ANI_H

#include "BaseType.h"
#include "uitypes.h"


enum
{
	IMAGE_SHOWWAY_NORMAL  = 0,
	IMAGE_SHOWWAY_ADDITIVE = 1,
};

//图片接口
class IImageObj
{
public:
	virtual ~IImageObj(){};
	
	virtual void Show(int x, int y, int nAlpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL) = 0;
	
	//调用此接口显示坐标将跟随当前场景位置显示，即物理坐标，其他的坐标为显示坐标，即视图坐标。
	virtual void ShowRelative(int x, int y, int nAlpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL) = 0;

	virtual void ShowEx(int x, int y, CRect *lpSrc, DWORD dwWidth, DWORD dwHeight, int nAlpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL, int nRotateAngle = 0) = 0;

	//调用此接口显示坐标将跟随当前场景位置显示，即物理坐标，其他的坐标为显示坐标，即视图坐标。
	virtual void ShowExRelative(int x, int y, CRect *lpSrc, DWORD dwWidth, DWORD dwHeight, int nAlpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL, int nRotateAngle = 0) = 0;

	virtual void ShowBlendEx(int x, int y, CRect* lpSrc, DWORD dwWidth, DWORD dwHeight, 
							 int nAlpha = 0, int nRotateAngle = 0) = 0;
	virtual void ShowToWorld(int x, int y) = 0;
	virtual void GetSize(int& nWidth, int& nHeight) = 0;
	virtual DWORD GetSize() = 0;
	
	virtual int	GetWidth() = 0;
	virtual int	GetHeight() = 0;
	
	virtual void SetColor(BYTE a, BYTE r, BYTE g, BYTE b) = 0;
//	virtual void SetSkew(float sx, float sy) = 0;
};

//ani图片接口
class IAniObj 
{
public:
	virtual ~IAniObj(){};

	virtual bool Show(DWORD uFrame, int x, int y, int alpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL) = 0;

	//调用此接口显示坐标将跟随当前场景位置显示，即物理坐标，其他的坐标为显示坐标，即视图坐标
	virtual bool ShowRelative(DWORD uFrame, int x, int y, int alpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL) = 0;

	virtual bool ShowEx(DWORD uFrame, int x, int y, CRect* lpSrc, DWORD dwWidth, DWORD dwHeight, int alpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL) = 0;

	//调用此接口显示坐标将跟随当前场景位置显示，即物理坐标，其他的坐标为显示坐标，即视图坐标
	virtual bool ShowExRelative(DWORD uFrame, int x, int y, CRect* lpSrc, DWORD dwWidth, DWORD dwHeight, int alpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL) = 0;

	//总帧数
	virtual int	GetFrameAmount() = 0;

	virtual DWORD GetSize() = 0;

	virtual IImageObj* GetImageObj(DWORD uFrameIndex) = 0;

	virtual void Release() = 0;
};


IAniObj* CreateAniObject(const char* pszFile, const char* pszIndex);

//不推荐使用此接口,会有内存泄漏
IImageObj* CreateImgObject(const char* pszImgFile);

//获得图片(返回的IImageObj必须自己释放)
IImageObj* CreateImgObjectByAni(const char* pszIndex, const char* pszFile="./ani/common.ani");

//载入多帧的动画
BOOL CreateImgObjectByAniEx(const char* pszIndex,vector<IImageObj*>& vImages, const char* pszFile="./ani/common.ani");


#endif
