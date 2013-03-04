//
//  NDPicture.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-8.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
//

#include "NDPicture.h"
#include "CCTextureCache.h"
#include "shaders/CCShaderCache.h"
#include "NDDirector.h"
#include "CCImage.h"
#include "CCPointExtension.h"
#include <sstream>
#include <NDDebugOpt.h>
#include <CCDrawingPrimitives.h>
#include <UsePointPls.h>
#include "CCCommon.h"
#include "CCPlatformConfig.h"
#include "ObjectTracker.h"
#include "MD5checksum.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

using namespace cocos2d;
using namespace Encrypt;

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDPicture, NDObject)

NDPicture::NDPicture(bool canGray/*=false*/)
{
	INC_NDOBJ_RTCLS

	m_pkTexture = NULL;
	m_kCutRect = CCRectZero;
	m_bReverse = false;
	m_kRotation = PictureRotation0;

	m_bCanGray = true;
	m_bStateGray = false;
	m_pkTextureGray = NULL;

	m_hrizontalPixel = 0;
	m_verticalPixel = 0;
	m_fScale = 1.0f;
	m_bIsTran = false;

	m_pShaderProgram = NULL; //@shader
	m_glServerState = CC_GL_BLEND;
}

NDPicture::~NDPicture()
{
	DEC_NDOBJ_RTCLS
	
	destroy();
}

void NDPicture::destroy()
{
	CC_SAFE_RELEASE (m_pShaderProgram); //@shader
 	CC_SAFE_RELEASE (m_pkTexture);
 	CC_SAFE_RELEASE (m_pkTextureGray);
	m_pkTexture = NULL;
	m_pkTextureGray = NULL;
}

//@@
void NDPicture::Initialization(const char* imageFile)
{
	if (!imageFile) return;

	destroy();
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || !ENABLE_PAL_MODE)
	CCImage image;

	if (!image.initWithImageFile(imageFile) && imageFile)
	{
		//ScriptMgrObj.DebugOutPut("picture [%s] not exist", imageFile);
	}
#endif

	//m_pkTexture = new CCTexture2D;
	m_pkTexture = CCTexture2D::create();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || !ENABLE_PAL_MODE)
	m_pkTexture->initWithImage(&image);
#else
	m_pkTexture->initWithPalettePNG(imageFile);
#endif

	/*
	 if (m_canGray && image)
	 {
	 NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	 m_textureGray = [[CCTexture2D alloc] initWithImage:[image convertToGrayscale]];
	 [pool release];
	 }
	 */

	// set cut rect
	m_kCutRect = CCRectMake(0, 0, 
		m_pkTexture->getContentSizeInPixels().width,
			m_pkTexture->getContentSizeInPixels().height);

	SetCoorinates();
	SetColor(ccc4(255, 255, 255, 255));

	if (imageFile)
	{
		m_strfile = imageFile;
	}
}

//@@
void NDPicture::Initialization(const char* imageFile, int hrizontalPixel, int verticalPixel/*=0*/)
{
	if (!imageFile) return;

	this->destroy();
    
	bool bLoadImageSucess = true;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || !ENABLE_PAL_MODE)
	CCImage image;
	if (!image.initWithImageFile(imageFile) && imageFile)
	{
		bLoadImageSucess = false;
		return;
	}
#endif

	bool bLoadStretchImageSucess = false;
	if ((!(hrizontalPixel < 0 || verticalPixel < 0)) && bLoadImageSucess)
	{		// todo
		// 			CCSize sizeImg = image.getSize();
		// 			
		// 			//if (hrizontalPixel > sizeImg.width || verticalPixel > sizeImg.height) 
		// 			{
		// 				int leftCapWidth = hrizontalPixel == 0 ? 0 : sizeImg.width/2;
		// 				
		// 				int topCapHeight = verticalPixel == 0 ? 0 : sizeImg.height/2;
		// 				
		// 				if (hrizontalPixel <= sizeImg.width)
		// 				{
		// 					leftCapWidth = 0;
		// 				}
		// 				
		// 				if (verticalPixel <= sizeImg. height)
		// 				{
		// 					topCapHeight = 0;
		// 				}
		// 				
		// 				UIImage *tmpImg = [image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
		// 				
		// 				if (tmpImg)
		// 				{
		// 					if (hrizontalPixel == 0) hrizontalPixel = sizeImg.width;
		// 					
		// 					if (verticalPixel == 0) verticalPixel = sizeImg.height;
		// 					
		// 					CCSize newSize = CCSizeMake(hrizontalPixel, verticalPixel);
		// 					
		// 					UIGraphicsBeginImageContext(newSize);
		// 					
		// 					[tmpImg drawInRect:CCRectMake(0, 0, newSize.width, newSize.height)];
		// 					
		// 					stretchImage = UIGraphicsGetImageFromCurrentImageContext();
		// 					
		// 					if (stretchImage != NULL) 
		// 					{
		// 						m_texture = [[CCTexture2D alloc] initWithImage:stretchImage];
		// 						/*
		// 						 if (m_canGray) 
		// 						 {
		// 						 m_textureGray = [[CCTexture2D alloc] initWithImage:[stretchImage convertToGrayscale]];
		// 						 }
		// 						 */
		// 					}
		// 					
		// 					UIGraphicsEndImageContext();
		// 				}
		// 			}
	}

	// init tex
	if (!bLoadStretchImageSucess)
	{
		//m_pkTexture = new CCTexture2D;
		m_pkTexture = CCTexture2D::create();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || !ENABLE_PAL_MODE)
		m_pkTexture->initWithImage(&image);
#else
		m_pkTexture->initWithPalettePNG(imageFile);
#endif
	}

	m_kCutRect = CCRectMake(0, 0,
		m_pkTexture->getContentSizeInPixels().width,
		m_pkTexture->getContentSizeInPixels().height);

	SetCoorinates();
	SetColor(ccc4(255, 255, 255, 255));

	//[pool release];

	if (imageFile)
	{
		m_strfile = imageFile;
		m_hrizontalPixel = hrizontalPixel;
		m_verticalPixel = verticalPixel;
	}
}

void NDPicture::Initialization(vector<const char*>& vImgFiles)
{
	// 灰色图 todo
// 	if (vImgFiles.size() < 1) {
// 		return;
// 	}
// 	
// 	m_texture->release();
// 	
// 	vector<CCImage*> vImgs;
// 	for (unsigned int i = 0; i < vImgFiles.size(); i++)
// 	{
// 		CCTexture2D* img = new CCTexture2D;
// 		if (!img->initWithPVRFile(vImgFiles.at(i)))
// 		{
// 			continue;
// 		}
// 		vImgs.push_back(img);
		
// 		if (0 == i)
// 		{
// 			UIGraphicsBeginImageContext(img.size);
// 		}
//	}
	
// 	for (unsigned int i = 0; i < vImgs.size(); i++)
// 	{
// 		CCImage* img = vImgs.at(i);
// 		[img drawInRect:CCRectMake(0, 0, img.size.width, img.size.height)];
// 		[img release];
// 	}
	
//	CCImage* resultImg = 0;//UIGraphicsGetImageFromCurrentImageContext(); 郭浩
	
	//UIGraphicsEndImageContext();
	
// 	m_texture = CCTexture2D::initWithImage(resultImg);
// 	
// 	m_cutRect = CCRectMake(0, 0, m_texture->getContentSizeInPixels().width, m_texture->getContentSizeInPixels().height);
// 	SetCoorinates();		
// 	SetColor(ccc4(255, 255, 255, 255));
}

void NDPicture::Initialization(vector<const char*>& vImgFiles, vector<CCRect>& vImgCustomRect, vector<CCPoint>&vOffsetPoint)
{
	
}

void NDPicture::Initialization( unsigned char* pszBuffer,unsigned int uiSize )
{
	if (0 == pszBuffer || 0 == uiSize)
	{
		return;
	}

	//if (!imageFile) return;

	destroy();
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || !ENABLE_PAL_MODE)
	CCImage kImage;

	if (!kImage.initWithImageData((void*)pszBuffer,uiSize))
	{
		//LOGERROR("picture [%s] not exist", imageFile);
	}
#endif

	//m_pkTexture = new CCTexture2D;
	m_pkTexture = CCTexture2D::create();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || !ENABLE_PAL_MODE)
	m_pkTexture->initWithImage(&kImage);
#else
	m_pkTexture->initWithPalettePNG(imageFile);
#endif

	LOGD("m_pkTexture->getContentSizeInPixels().width is %d,m_pkTexture->getContentSizeInPixels().height is %d",
		m_pkTexture->getContentSizeInPixels().width,m_pkTexture->getContentSizeInPixels().height);

	m_kCutRect = CCRectMake(0, 0, 
		m_pkTexture->getContentSizeInPixels().width,
			m_pkTexture->getContentSizeInPixels().height);

	SetCoorinates();
	SetColor(ccc4(255, 255, 255, 255));

// 	if (imageFile)
// 	{
// 		m_strfile = imageFile;
// 	}
}

//@shader
void NDPicture::DrawSetup( const char* shaderType /*=kCCShader_PositionTexture_uColor*/ )
{
	if (getShaderProgram() == NULL)
	{
		setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(shaderType));
	}

	ccGLEnable( m_glServerState );
	CCAssert(getShaderProgram(), "No shader program set for this node");

	getShaderProgram()->use();
	getShaderProgram()->setUniformForModelViewProjectionMatrix();
}

void NDPicture::SetTexture(CCTexture2D* tex)
{
	if (!tex) return;

	CC_SAFE_RETAIN(tex);
	CC_SAFE_RELEASE(m_pkTexture);

	m_pkTexture = tex;

	m_kCutRect = CCRectMake(0, 0, 
		m_pkTexture->getContentSizeInPixels().width,
			m_pkTexture->getContentSizeInPixels().height);

	SetCoorinates();
	SetColor(ccc4(255, 255, 255, 255));
}

void NDPicture::SetCoorinates()
{
	if (m_pkTexture)
	{
		if (m_bReverse)
		{
			m_coordinates[0] = (m_kCutRect.origin.x + m_kCutRect.size.width)
					/ m_pkTexture->getPixelsWide();
			m_coordinates[1] = (m_kCutRect.origin.y + m_kCutRect.size.height)
					/ m_pkTexture->getPixelsHigh();
			m_coordinates[2] = m_kCutRect.origin.x / m_pkTexture->getPixelsWide();
			m_coordinates[3] = m_coordinates[1];
			m_coordinates[4] = m_coordinates[0];
			m_coordinates[5] = m_kCutRect.origin.y / m_pkTexture->getPixelsHigh();
			m_coordinates[6] = m_coordinates[2];
			m_coordinates[7] = m_coordinates[5];
		}
		else
		{
			m_coordinates[0] = m_kCutRect.origin.x / m_pkTexture->getPixelsWide();
			m_coordinates[1] = (m_kCutRect.origin.y + m_kCutRect.size.height)
					/ m_pkTexture->getPixelsHigh();
			m_coordinates[2] = (m_kCutRect.origin.x + m_kCutRect.size.width)
					/ m_pkTexture->getPixelsWide();
			m_coordinates[3] = m_coordinates[1];
			m_coordinates[4] = m_coordinates[0];
			m_coordinates[5] = m_kCutRect.origin.y / m_pkTexture->getPixelsHigh();
			m_coordinates[6] = m_coordinates[2];
			m_coordinates[7] = m_coordinates[5];
		}
	}

	//clamp
	for (int i = 0; i < 8; i++)
	{
		float& f = m_coordinates[i];
		if (f > 1.0f)		f = 1.0f;
		else if (f < 0.0f)	f = 0.0f;
	}
}

void NDPicture::SetVertices(CCRect drawRect)
{
	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();

	switch (m_kRotation)
	{
	case PictureRotation0://@todo @check
// 		m_pfVertices[0] = drawRect.origin.x;
// 		m_pfVertices[1] = winSize.height - drawRect.origin.y - drawRect.size.height;
// 		m_pfVertices[2] = drawRect.origin.x + drawRect.size.width;
// 		m_pfVertices[3] = m_pfVertices[1];
// 		m_pfVertices[4] = drawRect.origin.x;
// 		m_pfVertices[5] = winSize.height - drawRect.origin.y;
// 		m_pfVertices[6] = m_pfVertices[2];
// 		m_pfVertices[7] = m_pfVertices[5];

		{
			float l,r,t,b;
			SCREEN2GL_RECT(drawRect,l,r,t,b);

			m_pfVertices[0] = l;
			m_pfVertices[1] = b;
			m_pfVertices[2] = r;
			m_pfVertices[3] = b;
			m_pfVertices[4] = l;
			m_pfVertices[5] = t;
			m_pfVertices[6] = r;
			m_pfVertices[7] = t;
		}
		break;
	case PictureRotation90://@todo
		m_pfVertices[0] = drawRect.origin.x;
		m_pfVertices[1] = winSize.height - drawRect.origin.y;
		m_pfVertices[2] = m_pfVertices[0];
		m_pfVertices[3] = m_pfVertices[1] - drawRect.size.height;
		m_pfVertices[4] = m_pfVertices[0] + drawRect.size.width;
		m_pfVertices[5] = m_pfVertices[1];
		m_pfVertices[6] = m_pfVertices[4];
		m_pfVertices[7] = m_pfVertices[3];
		break;
	case PictureRotation180://@todo
		m_pfVertices[0] = drawRect.origin.x + drawRect.size.width;
		m_pfVertices[1] = winSize.height - drawRect.origin.y;
		m_pfVertices[2] = drawRect.origin.x;
		m_pfVertices[3] = m_pfVertices[1];
		m_pfVertices[4] = m_pfVertices[0];
		m_pfVertices[5] = winSize.height - drawRect.origin.y
				- drawRect.size.height;
		m_pfVertices[6] = m_pfVertices[2];
		m_pfVertices[7] = m_pfVertices[5];
		break;
	case PictureRotation270://@todo
		m_pfVertices[0] = drawRect.origin.x + drawRect.size.width;
		m_pfVertices[1] = winSize.height
				- (drawRect.origin.y + drawRect.size.height);
		m_pfVertices[2] = m_pfVertices[0];
		m_pfVertices[3] = m_pfVertices[1] + drawRect.size.height;
		m_pfVertices[4] = m_pfVertices[0] - drawRect.size.width;
		m_pfVertices[5] = m_pfVertices[1];
		m_pfVertices[6] = m_pfVertices[4];
		m_pfVertices[7] = m_pfVertices[3];
		break;
	default:
		break;
	}
}

void NDPicture::Cut(CCRect kRect)
{
	if (m_pkTexture)
	{
		bool bCutSucess = false;

		if (kRect.origin.x + kRect.size.width
				<= m_pkTexture->getContentSizeInPixels().width
				&& kRect.origin.y + kRect.size.height
						<= m_pkTexture->getContentSizeInPixels().height)
		{
			bCutSucess = true;
			m_kCutRect = kRect;
		}
		else if (kRect.origin.x < m_pkTexture->getContentSizeInPixels().width
				&& kRect.origin.y < m_pkTexture->getContentSizeInPixels().height)
		{
			bCutSucess = true;
			m_kCutRect.origin = kRect.origin;
			m_kCutRect.size = CCSizeMake(
					m_pkTexture->getContentSizeInPixels().width - kRect.origin.x,
					m_pkTexture->getContentSizeInPixels().height - kRect.origin.y);
		}

		if (bCutSucess)
		{
			SetCoorinates();
		}
	}
}

void NDPicture::SetReverse(bool reverse)
{
	m_bReverse = reverse;
	SetCoorinates();
}

void NDPicture::Rotation(PictureRotation rotation)
{
	m_kRotation = rotation;
}

NDPicture* NDPicture::Copy()
{
	NDPicture* pkPicture = new NDPicture();
	CC_SAFE_RETAIN (m_pkTexture);

	pkPicture->m_pkTexture = m_pkTexture;
	pkPicture->m_bReverse = m_bReverse;
	pkPicture->m_kCutRect = m_kCutRect;
	pkPicture->m_kRotation = m_kRotation;
	pkPicture->m_bAdvance = m_bAdvance;
	pkPicture->m_hrizontalPixel = m_hrizontalPixel;
	pkPicture->m_verticalPixel = m_verticalPixel;

	memcpy(pkPicture->m_coordinates, m_coordinates, sizeof(GLfloat) * 8);
	memcpy(pkPicture->m_colors, m_colors, sizeof(GLbyte) * 16);
	memcpy(pkPicture->m_colorsHighlight, m_colorsHighlight, sizeof(GLbyte) * 16);
	memcpy(pkPicture->m_pfVertices, m_pfVertices, sizeof(GLfloat) * 8);

	//灰图
	pkPicture->m_bCanGray = m_bCanGray;
	pkPicture->m_bStateGray = m_bStateGray;
	pkPicture->m_strfile = m_strfile;

	if (m_bCanGray)
	{
		CC_SAFE_RETAIN (m_pkTextureGray);
		pkPicture->m_pkTextureGray = m_pkTextureGray;
	}
	else
	{
		pkPicture->m_pkTextureGray = NULL;
	}

	return pkPicture;
}

void NDPicture::DrawInRect(CCRect kRect, bool bHighlight)
{
	//ND上层传来的都是基于像素，转成基于点的
	ConvertUtil::convertToPointCoord( kRect );

	CCTexture2D *pkTempTexture = NULL;

	if (m_bCanGray && m_bStateGray)
	{
		pkTempTexture = m_pkTextureGray;
	}
	else
	{
		pkTempTexture = m_pkTexture;
	}

	if (pkTempTexture)
	{
		DrawSetup( kCCShader_PositionTextureColor );

		SetVertices( kRect);

		if (m_bIsTran)
		{
			ccGLBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
		}

		ccGLBindTexture2D(pkTempTexture->getName());

		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );

		// attribute
		ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );

		glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, m_pfVertices);
		glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, m_coordinates);
		glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, bHighlight ? m_colorsHighlight : m_colors);
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		// restore blend state
		if(m_bIsTran)
		{
			ccGLBlendFunc( CC_BLEND_SRC, CC_BLEND_DST );
		}
	}

	this->debugDraw();
}

CCSize NDPicture::GetSize()
{
	CCSize kSize = CCSizeZero;
	if (m_pkTexture)
	{
		kSize = m_kCutRect.size;
		kSize.width *= m_fScale;
		kSize.height *= m_fScale;

		if (kSize.width > m_pkTexture->getContentSizeInPixels().width)
		{
			kSize.width = m_pkTexture->getContentSizeInPixels().width;
		}
		if (kSize.height > m_pkTexture->getContentSizeInPixels().height)
		{
			kSize.height = m_pkTexture->getContentSizeInPixels().height;
		}

		if (m_kRotation == PictureRotation90 || m_kRotation == PictureRotation270)
		{
			CGFloat fTemp = kSize.width;
			kSize.width = kSize.height;
			kSize.height = fTemp;
		}
	}

	return kSize;
}

void NDPicture::SetColor(ccColor4B color)
{
	m_colors[0] = color.r;
	m_colors[1] = color.g;
	m_colors[2] = color.b;
	m_colors[3] = color.a;

	m_colors[4] = color.r;
	m_colors[5] = color.g;
	m_colors[6] = color.b;
	m_colors[7] = color.a;

	m_colors[8] = color.r;
	m_colors[9] = color.g;
	m_colors[10] = color.b;
	m_colors[11] = color.a;

	m_colors[12] = color.r;
	m_colors[13] = color.g;
	m_colors[14] = color.b;
	m_colors[15] = color.a;

	// fill highlight color
	memcpy( m_colorsHighlight, m_colors, sizeof(m_colors));
	m_colorsHighlight[3] 
		= m_colorsHighlight[7] 
		= m_colorsHighlight[11]
		= m_colorsHighlight[15]
		= 125;
}

bool NDPicture::SetGrayState(bool gray)
{
	//if (!m_canGray) return false;

	if (gray && NULL == m_pkTextureGray && !m_strfile.empty())
	{
		// totdo
// 			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
// 			
// 			UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:m_strfile.c_str()]];
// 			
// 			UIImage *stretchImage = NULL;
// 			
// 			if ((!(m_hrizontalPixel < 0 || m_verticalPixel < 0)) && image) 
// 			{			
// 				CCSize sizeImg = [image size];
// 				
// 				//if (hrizontalPixel > sizeImg.width || verticalPixel > sizeImg.height) 
// 				{
// 					int leftCapWidth = m_hrizontalPixel == 0 ? 0 : sizeImg.width/2;
// 					
// 					int topCapHeight = m_verticalPixel == 0 ? 0 : sizeImg.height/2;
// 					
// 					if (m_hrizontalPixel <= sizeImg.width)
// 					{
// 						leftCapWidth = 0;
// 					}
// 					
// 					if (m_verticalPixel <= sizeImg. height)
// 					{
// 						topCapHeight = 0;
// 					}
// 					
// 					UIImage *tmpImg = [image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
// 					
// 					if (tmpImg)
// 					{
// 						int hrizontalPixel	= m_hrizontalPixel;
// 						int verticalPixel	= m_verticalPixel;
// 						
// 						if (hrizontalPixel == 0) hrizontalPixel = sizeImg.width;
// 						if (verticalPixel == 0) verticalPixel = sizeImg.height;
// 						
// 						CCSize newSize = CCSizeMake(hrizontalPixel, verticalPixel);
// 						
// 						UIGraphicsBeginImageContext(newSize);
// 						
// 						[tmpImg drawInRect:CCRectMake(0, 0, newSize.width, newSize.height)];
// 						
// 						stretchImage = UIGraphicsGetImageFromCurrentImageContext();
// 						
// 						if (stretchImage != NULL) 
// 						{
// 							m_textureGray = [[CCTexture2D alloc] initWithImage:[stretchImage convertToGrayscale]];
// 						}
// 						
// 						UIGraphicsEndImageContext();
// 					}
// 				}
// 			}
// 			
// 			if (stretchImage == NULL) 
// 			{
// 				[m_textureGray release];
// 				m_textureGray = [[CCTexture2D alloc] initWithImage:[image convertToGrayscale]];
// 			}
// 			
// 			[image release];
// 			
// 			[pool release];
	}

	m_bStateGray = gray;

	return true;
}

bool NDPicture::IsGrayState()
{
	//if (!m_canGray) return false;

	return m_bStateGray;
}

void NDPicture::debugDraw()
{
	if (!NDDebugOpt::getDrawDebugEnabled()) return;

	glLineWidth(1);
	ccDrawColor4F(1,0,0,1);
	CCPoint lb = ccp(m_pfVertices[0],m_pfVertices[1]);
	CCPoint rt = ccp(m_pfVertices[6],m_pfVertices[7]);
	ccDrawRect( lb, rt );
}

//////////////////////////////////////////////////////////////////////////////////

//图片资源垃圾回收
void NDPicturePool::Recyle()
{
	if (NULL == m_pkPicturesDict)
	{
		return;
	}

	// get all keys
	CCArray* allKeys = m_pkPicturesDict->AllKeys();
	if (!allKeys || allKeys->count() == 0)
	{
		return;
	}

	// walk through all keys 
	for (unsigned int i = 0; i < allKeys->count(); i++)
	{
		CCString* strKey = (CCString*)allKeys->objectAtIndex(i);
		if (NULL == strKey) continue;

		NDPicture* pic = (NDPicture*)m_pkPicturesDict->Object( strKey->getCString());
		if (!pic) continue;

		CCTexture2D *texture = pic->GetTexture();
		if (texture && 1 >= texture->retainCount())
		{
			m_pkPicturesDict->RemoveObject( strKey->getCString() );
		}
	}
}

/////////////////////////////
IMPLEMENT_CLASS(NDPicturePool, NDObject)

NDPicturePool::NDPicturePool()
{
	INC_NDOBJ_RTCLS;

	m_pkPicturesDict = new NDDictionary();
}

NDPicturePool* NDPicturePool::DefaultPool()
{
	static NDPicturePool s_obj;
	return &s_obj;
}

NDPicturePool::~NDPicturePool()
{
	DEC_NDOBJ_RTCLS;

	PurgeDefaultPool();
}

void NDPicturePool::PurgeDefaultPool()
{	
	//m_mapTexture不会增加引用计数
	m_mapTexture.clear();

	//字典会增加引用计数
	if (m_pkPicturesDict)
	{
		m_pkPicturesDict->RemoveAllObjects();
	}
}

//@@
NDPicture* NDPicturePool::AddPicture(const char* imageFile, bool gray/*=false*/)
{
	if (!imageFile) return NULL;
	NDPicture* pic = (NDPicture *) m_pkPicturesDict->Object(imageFile);

	if (!pic)
	{
		pic = new NDPicture(gray);
		pic->Initialization(imageFile);
		m_pkPicturesDict->SetObject(pic, imageFile);

		CCTexture2D* tex = pic->GetTexture();
		m_mapTexture.insert(std::map<CCTexture2D*, std::string>::value_type(tex, imageFile));
	}

	return pic->Copy();
}

//@@
NDPicture* NDPicturePool::AddPicture(const char* imageFile, int hrizontalPixel,
		int verticalPixel/*=0*/, bool gray/*=false*/)
{
	if (!imageFile || !imageFile[0]) return NULL;
	

	CCSize sizeImg = GetImageSize(imageFile);

	if (int(sizeImg.width) != 0 && int(sizeImg.height)
			&& int(sizeImg.width) == hrizontalPixel
			&& int(sizeImg.height) == verticalPixel)
	{
		return AddPicture(imageFile);
	}

	std::stringstream ss;
	ss << imageFile << "_" << hrizontalPixel << "_" << verticalPixel;

	NDPicture* pic = (NDPicture *) m_pkPicturesDict->Object(ss.str().c_str());

	if (!pic)
	{
		pic = new NDPicture(gray);
		pic->Initialization(imageFile, hrizontalPixel, verticalPixel);
		m_pkPicturesDict->SetObject(pic, ss.str().c_str());

		CCTexture2D* tex = pic->GetTexture();
		m_mapTexture.insert(std::map<CCTexture2D*, std::string>::value_type(tex, imageFile));
	}

	return pic->Copy();
}

NDPicture* NDPicturePool::AddPicture(unsigned int uiSize,
									 unsigned char* pszBuffer,
									 bool bGray /*= false*/ )
{
	if (0 == pszBuffer || !*pszBuffer || 0 == uiSize)
	{
		return 0;
	}

	CMD5Checksum kMD5;
	string strMD5;

	strMD5 = kMD5.GetMD5(pszBuffer,uiSize);

	LOGD("Get the buffer MD5 value:%s",strMD5.c_str());

	NDPicture* pkPicture = (NDPicture *) m_pkPicturesDict->Object(strMD5.c_str());

	if (!pkPicture)
	{
		pkPicture = new NDPicture(bGray);
		pkPicture->Initialization(pszBuffer,uiSize);
		m_pkPicturesDict->SetObject(pkPicture, strMD5.c_str());

		CCTexture2D* pkTexture = pkPicture->GetTexture();
		m_mapTexture.insert(std::map<CCTexture2D*,
			std::string>::value_type(pkTexture,strMD5.c_str()));
	}

	return pkPicture->Copy();
}

NDPicture* NDPicturePool::AddPicture( const string& imageFile,
									 bool gray /*= false*/ )
{
	return AddPicture(imageFile.c_str(), gray);
}

NDPicture* NDPicturePool::AddPicture( const string& imageFile,
									 int hrizontalPixel,
									 int verticalPixel /*= 0*/,
									 bool gray /*= false*/ )
{
	return 	AddPicture(imageFile.c_str(), hrizontalPixel, verticalPixel, gray );
}

//通过tex删除pic
void NDPicturePool::RemovePictureByTex(CCTexture2D* tex)
{
	if (!tex) return;
	std::map<CCTexture2D*, std::string>::iterator it = m_mapTexture.find(tex);
	if(it != m_mapTexture.end())
	{
		RemovePicture( it->second.c_str());
		m_mapTexture.erase(it);
	}
}

//从字典删除pic，内部调用delete.
void NDPicturePool::RemovePicture(const char* imageFile)
{
	if (imageFile)
	{
		m_pkPicturesDict->RemoveObject(imageFile);
	}
}

//取缓存下来的图片尺寸（按需加载图片）
CCSize NDPicturePool::GetImageSize( const std::string& filename )
{
	if (filename.empty())
	{
		return CCSizeZero;
	}

	std::map<std::string, CCSize>::iterator it = m_mapImageSize.find(filename);

	if (it != m_mapImageSize.end())
	{
		return it->second;
	}

	CCImage image;

	if (!image.initWithImageFile(filename.c_str()))
	{
		return CCSizeZero;
	}

	CCSize size = CCSizeZero;
	size.width		= image.getWidth();
	size.height		= image.getHeight();

	m_mapImageSize.insert(std::make_pair(filename, size));

	return size;
}

string NDPicturePool::dump()
{
	int index = 0;
	int totalBytes = 0;
	int count = 0;
	
	string total;
	char line[200] = "";

	for (map<CCTexture2D*,string>::iterator iter = m_mapTexture.begin();
			iter != m_mapTexture.end(); ++iter)
	{
		CCTexture2D* tex = iter->first;
		if (!tex) continue;

		// Each texture takes up width * height * bytesPerPixel bytes.
		unsigned int bpp = tex->bitsPerPixelForFormat();
		unsigned int bytes = tex->getPixelsWide() * tex->getPixelsHigh() * bpp / 8;
		totalBytes += bytes;
		count++;

		// format file size
		char picSize[20] = "";
		sprintf( picSize, "[%.1fK]", float(bytes)/1024 );

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		sprintf( line, "@@ NDPicturePool[%02d]: %-10s ref=%d %s\r\n", index++, picSize, tex->retainCount(), iter->second.c_str());
		total += line;
#else
		CCLog( "@@ NDPicturePool[%02d]: %-10s %s", index++, picSize, iter->second.c_str());
#endif
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	sprintf( line, "@@ NDPicturePool, total %d tex, total %.1fM.\r\n", count, float(totalBytes)/(1024*1024));
	total += line;
#else
	CCLog( "@@ NDPicturePool, total %d tex, total %.1fM.", count, float(totalBytes)/(1024*1024));
#endif
	return total;
}

NS_NDENGINE_END
