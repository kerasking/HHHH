/*
 *  接口类:ani帧接口IAniObj,图片接口IImageObj
 *  Copyright 2010 TQ Digital Entertainment. All rights reserved.
	MyBitmapCreate创建的CMyBitmap必须Release
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

class IImageObj;

//ani帧接口(管理Ani文件,创建完即对该Ani文件里的所有帧图片用CMyBitmap* m_pFrame[64]进行索引,最大帧数为64)
class IAniObj
{
public:
	virtual ~IAniObj() {};

	//显示(调用CMyBitmap显示)
	virtual bool Show(DWORD uFrame/*帧号*/, int x, int y, int alpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL) = 0;

	//调用此接口显示坐标将跟随当前场景位置显示，即物理坐标，其他的坐标为显示坐标，即视图坐标
	virtual bool ShowRelative(DWORD uFrame, int x, int y, int alpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL) = 0;

	virtual bool ShowEx(DWORD uFrame, int x, int y, CRect* lpSrc, DWORD dwWidth, DWORD dwHeight, int alpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL) = 0;

	//调用此接口显示坐标将跟随当前场景位置显示，即物理坐标，其他的坐标为显示坐标，即视图坐标
	virtual bool ShowExRelative(DWORD uFrame, int x, int y, CRect* lpSrc, DWORD dwWidth, DWORD dwHeight, int alpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL) = 0;

	//获取总帧数
	virtual int	GetFrameAmount() = 0;

	//获取所有帧的图片的长*宽的总和,没用的接口,删去
	//virtual DWORD GetSize() = 0;

	//获取某一帧的图片
	virtual IImageObj* GetImageObj(DWORD uFrameIndex/*帧号*/) = 0;

	//释放(做delete this操作)
	virtual void Release() = 0;
};

//图片接口(管理图片,保存并操作一个CMyBitmap*,是对CMyBitmap的二次封装)
class IImageObj
{
public:
    virtual ~IImageObj() {};

	//释放(对CMyBitmap进行Release,再delete this)
	virtual void Release()=0;

	//显示(调用CMyBitmap显示)
    virtual void Show(int x, int y, int nAlpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL) = 0;

	virtual void ShowEx(int x, int y, CRect *lpSrc, DWORD dwWidth, DWORD dwHeight, int nAlpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL, int nRotateAngle = 0) = 0;

    //调用此接口显示坐标将跟随当前场景位置显示，即物理坐标，其他的坐标为显示坐标，即视图坐标
    virtual void ShowRelative(int x, int y, int nAlpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL) = 0;

    //调用此接口显示坐标将跟随当前场景位置显示，即物理坐标，其他的坐标为显示坐标，即视图坐标
    virtual void ShowExRelative(int x, int y, CRect *lpSrc, DWORD dwWidth, DWORD dwHeight, int nAlpha = 0, DWORD dwShowWay = IMAGE_SHOWWAY_NORMAL, int nRotateAngle = 0) = 0;


    virtual void ShowBlendEx(int x, int y, CRect* lpSrc, DWORD dwWidth, DWORD dwHeight,
                             int nAlpha = 0, int nRotateAngle = 0) = 0;

    virtual void ShowToWorld(int x, int y) = 0;

	//获取图片大小
	virtual void GetSize(int& nWidth/*宽*/, int& nHeight/*高*/) = 0;

	//获取图片长*宽的值
	virtual DWORD GetSize() = 0;

	//获取图片宽度
    virtual int	GetWidth() = 0;

	//获取图片高度
    virtual int	GetHeight() = 0;

	//设置颜色
    virtual void SetColor(BYTE a, BYTE r, BYTE g, BYTE b) = 0;
//	virtual void SetSkew(float sx, float sy) = 0;
};

//获取Ani(返回的IAniObj必须Release())
IAniObj* CreateAniObject(const char* pszFile/*文件名*/, const char* pszIndex/*KEY名字*/);

//根据图片路径获取图片(返回的IImageObj必须先Release())
IImageObj* CreateImgObject(const char* pszImgFile/*图片路径*/);

//根据Ani获取图片(返回的IImageObj必须Release()删除)
IImageObj* CreateImgObjectByAni(const char* pszIndex/*Key名字*/, const char* pszFile="./ani/common.ani");

//载入多帧的动画(返回的IAniObj和获得的IImageObj*向量必须自己释放!)
IAniObj* CreateImgObjectByAniEx(const char* pszIndex/*Key名字*/,vector<IImageObj*>& vImages/*获取的多帧图片*/, const char* pszFile="./ani/common.ani");


#endif
