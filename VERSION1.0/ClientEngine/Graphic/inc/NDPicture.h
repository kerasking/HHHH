//
//  NDPicture.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-8.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
//
//	－－介绍－－
//	NDPicture是专门针对本地图片的操作
//	如果需要共享图片资源可以通过NDPicturePool获取NDPicture对象

#ifndef __NDPicture_H
#define __NDPicture_H

#include "NDObject.h"
#include "NDDictionary.h"
#include "CCTexture2D.h"
#include "CCGeometry.h"
#include "ccTypes.h"
#include "shaders/ccGLStateCache.h"
#include "shaders/ccGLProgram.h"
#include "NDTimer.h"

#include <vector>
#include <map>
#include <string>

using namespace cocos2d;
using namespace std;

NS_NDENGINE_BGN

typedef enum
{
	PictureRotation0,
	PictureRotation90,
	PictureRotation180,
	PictureRotation270
} PictureRotation;


//-------------------------------------------------------------------------
//图片资源：对应一张贴图，或者贴图中的裁剪部分.
class NDPicture : public NDObject
{
	DECLARE_CLASS (NDPicture)
	NDPicture(bool canGray = false);
	~NDPicture();

public:
	CC_SYNTHESIZE(float,m_fScale,Scale);
	CC_SYNTHESIZE(bool,m_bIsTran,IsTran);

	//@shader
	CC_SYNTHESIZE_RETAIN(CCGLProgram*, m_pShaderProgram, ShaderProgram);
	CC_SYNTHESIZE(ccGLServerState, m_glServerState, GLServerState);

public:

	void Initialization(const char* imageFile);
	void Initialization(unsigned char* pszBuffer,unsigned int uiSize);
	void Initialization(vector<const char*>& vImgFiles);
	void Initialization(vector<const char*>& vImgFiles, vector<CCRect>& vImgCustomRect, vector<CCPoint>&vOffsetPoint);
	void Initialization(const char* imageFile, int hrizontalPixel,int verticalPixel = 0);

	void DrawInRect(CCRect kRect, bool bHighlight = false);
	void Cut(CCRect kRect);

	void SetReverse(bool reverse);
	void Rotation(PictureRotation rotation);
	void SetColor(cocos2d::ccColor4B color);
	CCSize GetSize();
	
	bool SetGrayState(bool gray);
	bool IsGrayState();

public:
	cocos2d::CCTexture2D *GetTexture() { return m_pkTexture; }
	void SetTexture(cocos2d::CCTexture2D* tex);

public:
	NDPicture* Copy();

protected:
	void DrawSetup( const char* shaderType = kCCShader_PositionTexture_uColor );
	virtual void debugDraw();

private:
	void SetCoorinates();
	void SetVertices(CCRect drawRect);
	void destroy();

private:
	cocos2d::CCTexture2D* m_pkTexture;
	CCRect m_kCutRect;
	bool m_bReverse;
	bool m_bAdvance;
	PictureRotation m_kRotation;

	// 变灰
	bool m_bCanGray;
	bool m_bStateGray;
	cocos2d::CCTexture2D *m_pkTextureGray;

	GLfloat m_coordinates[8];
	GLubyte m_colors[16];
	GLubyte m_colorsHighlight[16];
	GLfloat m_pfVertices[8];

	string m_strfile;
	int m_hrizontalPixel;
	int m_verticalPixel;
};


//-------------------------------------------------------------------------
class NDPicturePool : public NDObject
{
	DECLARE_CLASS (NDPicturePool)
	NDPicturePool();
	~NDPicturePool();

public:
	static NDPicturePool* DefaultPool();
	
public:

	NDPicture* AddPicture(unsigned int uiSize,
		unsigned char* pszBuffer,bool bGray = false);

	NDPicture* AddPicture(const string& imageFile, bool gray = false);

	NDPicture* AddPicture(const string& imageFile, int hrizontalPixel,
		int verticalPixel = 0, bool gray = false);

	NDPicture* AddPicture(const char* imageFile, bool gray = false);

	NDPicture* AddPicture(const char* imageFile, int hrizontalPixel,
		int verticalPixel = 0, bool gray = false);

public:
	void RemovePicture(const char* imageFile);
	void RemovePictureByTex(CCTexture2D* tex);

public:
	void PurgeDefaultPool();
	void Recyle();

public:
	string dump();

private:
	NDDictionary*				m_pkPicturesDict;	//缓存NDPicture* [NDPicture*,string]
	map<CCTexture2D*,string>	m_mapTexture;		//缓存CCTexture2D*

private: //缓冲图片尺寸
	map<string, CCSize>	m_mapImageSize;
	CCSize GetImageSize( const string& filename );
};

NS_NDENGINE_END

#endif
