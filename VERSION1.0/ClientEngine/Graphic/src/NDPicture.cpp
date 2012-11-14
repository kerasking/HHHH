//
//  NDPicture.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-8.
//  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
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

using namespace cocos2d;

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDPicture, NDObject)
IMPLEMENT_CLASS(NDTexture,NDObject)

NDPicture::NDPicture(bool canGray/*=false*/)
{
	m_pkTexture = NULL;
	m_kCutRect = CGRectZero;
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
	CC_SAFE_RELEASE(m_pShaderProgram); //@shader
	CC_SAFE_RELEASE (m_pkTexture);
	if (m_bCanGray)
	{
		CC_SAFE_RELEASE (m_pkTextureGray);
	}
}

void NDPicture::Initialization(const char* imageFile)
{
	CC_SAFE_RELEASE_NULL (m_pkTexture);
	CC_SAFE_RELEASE_NULL (m_pkTextureGray);

	CCImage image;

	if (!image.initWithImageFile(imageFile) && imageFile)
	{
		//ScriptMgrObj.DebugOutPut("picture [%s] not exist", imageFile);
	}

	m_pkTexture = new CCTexture2D;
	m_pkTexture->initWithImage(&image);
	//m_pkTexture->initWithPalettePNG(imageFile);

	/*
	 if (m_canGray && image)
	 {
	 NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	 m_textureGray = [[CCTexture2D alloc] initWithImage:[image convertToGrayscale]];
	 [pool release];
	 }
	 */

	m_kCutRect = CGRectMake(0, 0, m_pkTexture->getContentSizeInPixels().width,
			m_pkTexture->getContentSizeInPixels().height);
	SetCoorinates();
	SetColor(ccc4(255, 255, 255, 255));

	if (imageFile)
	{
		m_strfile = imageFile;
	}
}

void NDPicture::Initialization(vector<const char*>& vImgFiles)
{
	// »ÒÉ«Í¼ todo
// 	if (vImgFiles.size() < 1) {
// 		return;
// 	}
// 	
// 	m_texture->release();
// 	
// 	vector<CCImage*> vImgs;
// 	for (uint i = 0; i < vImgFiles.size(); i++)
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
	
// 	for (uint i = 0; i < vImgs.size(); i++)
// 	{
// 		CCImage* img = vImgs.at(i);
// 		[img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
// 		[img release];
// 	}
	
	CCImage* resultImg = 0;//UIGraphicsGetImageFromCurrentImageContext(); ¹ùºÆ
	
	//UIGraphicsEndImageContext();
	
// 	m_texture = CCTexture2D::initWithImage(resultImg);
// 	
// 	m_cutRect = CGRectMake(0, 0, m_texture->getContentSizeInPixels().width, m_texture->getContentSizeInPixels().height);
// 	SetCoorinates();		
// 	SetColor(ccc4(255, 255, 255, 255));
}

void NDPicture::Initialization(vector<const char*>& vImgFiles, vector<CGRect>& vImgCustomRect, vector<CGPoint>&vOffsetPoint)
{
// 	if (vImgFiles.size() < 1 || vImgCustomRect.size() < 1 || vOffsetPoint.size() < 1
// 		|| vImgFiles.size() != vImgCustomRect.size() || vImgFiles.size() != vOffsetPoint.size())
// 		return;
// 	
// 	m_pkTexture->release();
// 	
// 	vector<CCTexture2D*> vImgs;
// 	for (uint i = 0; i < vImgFiles.size(); i++) {
// 		CCTexture2D* img = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:vImgFiles.at(i)]];
// 		CCTexture2D* imgCut = [img getSubImageFromWithRect:vImgCustomRect[i]];
// 		vImgs.push_back(imgCut);
// 		
// 		if (0 == i) {
// 			UIGraphicsBeginImageContext(imgCut.size);
// 		}
// 		
// 		[img release];
// 	}
// 	
// 	for (uint i = 0; i < vImgs.size(); i++) {
// 		UIImage* img = vImgs.at(i);
// 		[img drawInRect:CGRectMake(vOffsetPoint[i].x, vOffsetPoint[i].y, img.size.width, img.size.height)];
// 		//[img release];
// 	}
// 	
// 	UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
// 	
// 	UIGraphicsEndImageContext();
// 	
// 	m_texture = [[CCTexture2D alloc] initWithImage:resultImg];
// 	
// 	m_cutRect = CGRectMake(0, 0, m_texture->getContentSizeInPixels().width, m_texture->getContentSizeInPixels().height);
// 	SetCoorinates();		
// 	SetColor(ccc4(255, 255, 255, 255));	
	
}

void NDPicture::Initialization(const char* imageFile, int hrizontalPixel,
		int verticalPixel/*=0*/)
{
	CC_SAFE_RELEASE_NULL (m_pkTexture);
	CC_SAFE_RELEASE_NULL (m_pkTextureGray);

	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	CCImage image;
	bool bLoadImageSucess = true;
	if (!image.initWithImageFile(imageFile) && imageFile)
	{
		//ScriptMgrObj.DebugOutPut("picture [%s] not exist", imageFile);
		bLoadImageSucess = false;
	}

	bool bLoadStretchImageSucess = false;
	if ((!(hrizontalPixel < 0 || verticalPixel < 0)) && bLoadImageSucess)
	{		// todo
// 			CGSize sizeImg = image.getSize();
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
// 					CGSize newSize = CGSizeMake(hrizontalPixel, verticalPixel);
// 					
// 					UIGraphicsBeginImageContext(newSize);
// 					
// 					[tmpImg drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
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

	if (!bLoadStretchImageSucess)
	{
		m_pkTexture = new CCTexture2D;
		m_pkTexture->initWithImage(&image);
		//m_pkTexture->initWithPalettePNG(imageFile);
	}

	m_kCutRect = CGRectMake(0, 0, m_pkTexture->getContentSizeInPixels().width,
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


CCTexture2D *NDPicture::GetTexture()
{
	return m_pkTexture;
}

void NDPicture::SetTexture(CCTexture2D* tex)
{
	CC_SAFE_RETAIN(tex);
	CC_SAFE_RELEASE (m_pkTexture);
	m_pkTexture = tex;
	m_kCutRect = CGRectMake(0, 0, m_pkTexture->getContentSizeInPixels().width,
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
}

void NDPicture::SetVertices(CGRect drawRect)
{
	//CGSize winSize = NDEngine::NDDirector::DefaultDirector()->GetWinPoint();
	CGSize winSize = NDEngine::NDDirector::DefaultDirector()->GetWinSize();

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

void NDPicture::Cut(CGRect kRect)
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
			m_kCutRect.size = CGSizeMake(
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
	memcpy(pkPicture->m_pfVertices, m_pfVertices, sizeof(GLfloat) * 8);

	//»ÒÍ¼
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

void NDPicture::DrawInRect(CGRect kRect)
{
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

		SetVertices(kRect);

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
		glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, m_colors);
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

// 		glBindTexture(GL_TEXTURE_2D, pkTempTexture->getName());
// 
// 		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
// 		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
// 		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
// 		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
// 
// 		glVertexPointer(2, GL_FLOAT, 0, m_pfVertices);
// 		glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_colors);
// 		glTexCoordPointer(2, GL_FLOAT, 0, m_coordinates);
// 		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	}

	this->debugDraw();
}

CGSize NDPicture::GetSize()
{
	CGSize kSize = CGSizeZero;
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
// 				CGSize sizeImg = [image size];
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
// 						CGSize newSize = CGSizeMake(hrizontalPixel, verticalPixel);
// 						
// 						UIGraphicsBeginImageContext(newSize);
// 						
// 						[tmpImg drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
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

/////////////////////////////
IMPLEMENT_CLASS(NDPictureDictionary, NDDictionary)
void NDPictureDictionary::Recyle()
{
	if (NULL == m_nsDictionary)
	{
		return;
	}

	//std::vector<std::string> allKeys = m_nsDictionary->allKeys();
	CCArray* allKeys = m_nsDictionary->allKeys();

	if (allKeys && allKeys->count() == 0)
	{
		return;
	}

	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	//NSMutableArray *recyle = [[NSMutableArray alloc] init];
	std::vector<std::string> kRecyle;

	for (unsigned int i = 0; i < kRecyle.size(); i++)
	{
		std::string key = kRecyle[i];

		DictionaryObject *dictObj = (DictionaryObject*)m_nsDictionary->objectForKey(key);
		if (NULL == dictObj)
		{
			continue;
		}

		NDObject *object = dictObj->getNdObject();
		if (object && object->IsKindOfClass(RUNTIME_CLASS(NDPicture)))
		{
			NDPicture* pic = (NDPicture*)object;
			CCTexture2D *texture = pic->GetTexture();
#ifdef DEBUG
			if (texture)
			{
				//printf("\nfile name[%s] retaincount[%d]", [key UTF8String], [texture retainCount]);
			}
#endif
			if (texture && 1 >= texture->retainCount())
			{
				kRecyle.push_back(key);
			}
			else
			{
				//printf("\nfile name[%s] retaincount[%d]", [key UTF8String], [texture retainCount]);
			}

		}
	}

	for (unsigned int i = 0; i < kRecyle.size(); i++)
	{
		m_nsDictionary->removeObjectForKey(kRecyle[i]);
	}

	//[pool release];
}

/////////////////////////////
IMPLEMENT_CLASS(NDPicturePool, NDObject)

static NDPicturePool* NDPicturePool_DefaultPool = NULL;

NDPicturePool::NDPicturePool()
{
	NDAsssert(NDPicturePool_DefaultPool == NULL);
	m_pkTextures = new NDPictureDictionary();
}

NDPicturePool::~NDPicturePool()
{
	NDPicturePool_DefaultPool = NULL;
	delete m_pkTextures;
}

NDPicturePool* NDPicturePool::DefaultPool()
{
	if (NDPicturePool_DefaultPool == NULL)
	{
		NDPicturePool_DefaultPool = new NDPicturePool();
	}
	return NDPicturePool_DefaultPool;
}

void NDPicturePool::PurgeDefaultPool()
{
	delete NDPicturePool_DefaultPool;
}
void NDPicturePool::RemoveTexture(CCTexture2D* tex)
{
	std::map<CCTexture2D*, std::string>::iterator it = m_mapTex2Str.find(tex);
	if(it != m_mapTex2Str.end())
	{
		std::string str = it->second;
		m_mapTex2Str.erase(it);
		RemovePicture(str.c_str());
	}
}

NDPicture* NDPicturePool::AddPicture(const char* imageFile, bool gray/*=false*/)
{
	NDAsssert(imageFile != NULL);

	std::stringstream ss;
	ss << imageFile;

	NDPicture* pkPicture = (NDPicture *) m_pkTextures->Object(ss.str().c_str());

	if (!pkPicture)
	{
		pkPicture = new NDPicture(gray);
		pkPicture->Initialization(imageFile);

		m_pkTextures->SetObject(pkPicture, ss.str().c_str());

		CCTexture2D* tex = pkPicture->GetTexture();
		tex->setContainerType(ContainerTypeAddPic);
		m_mapTex2Str.insert(std::map<CCTexture2D*, std::string>::value_type(tex, imageFile));
	}

	return pkPicture->Copy();
}

NDPicture* NDPicturePool::AddPicture(const char* imageFile, int hrizontalPixel,
		int verticalPixel/*=0*/, bool gray/*=false*/)
{
	NDAsssert(imageFile != NULL);

	CGSize sizeImg = GetImageSize(imageFile ? imageFile : "");

	if (int(sizeImg.width) != 0 && int(sizeImg.height)
			&& int(sizeImg.width) == hrizontalPixel
			&& int(sizeImg.height) == verticalPixel)
	{
		return AddPicture(imageFile);
	}

	std::stringstream ss;
	ss << imageFile << "_" << hrizontalPixel << "_" << verticalPixel;

	NDPicture* pic = (NDPicture *) m_pkTextures->Object(ss.str().c_str());

	if (!pic)
	{
		pic = new NDPicture(gray);
		pic->Initialization(imageFile, hrizontalPixel, verticalPixel);
		m_pkTextures->SetObject(pic, ss.str().c_str());
		CCTexture2D* tex = pic->GetTexture();
		tex->setContainerType(ContainerTypeAddPic);	
		m_mapTex2Str.insert(std::map<CCTexture2D*, std::string>::value_type(tex, imageFile));

	}

	return pic->Copy();
}

void NDPicturePool::RemovePicture(const char* imageFile)
{
	NDAsssert(imageFile != NULL);

	m_pkTextures->RemoveObject(imageFile);
}

void NDPicturePool::Recyle()
{
	if (m_pkTextures)
	{
		m_pkTextures->Recyle();
	}
}

CGSize NDPicturePool::GetImageSize(std::string filename)
{
	if (filename.empty())
	{
		return CGSizeZero;
	}

	std::map<std::string, CGSize>::iterator it = m_mapStr2Size.find(filename);

	if (it != m_mapStr2Size.end())
	{
		return it->second;
	}
	CCImage image;

	if (!image.initWithImageFile(filename.c_str()))
	{
		return CGSizeZero;
	}

	//todo(zjh)
	CGSize size = CGSizeZero;
	size.width			= image.getWidth();
	size.height			= image.getHeight();

	m_mapStr2Size.insert(std::make_pair(filename, size));

	return size;
}

CCTexture2D* NDPicturePool::AddTexture( const char* pszImageFile )
{
	NDAsssert(0 != pszImageFile);

	stringstream kStream;
	kStream << pszImageFile;

	NDTexture* pkPicture = (NDTexture*)m_pkTextures->Object(kStream.str().c_str());

	if (0 == pkPicture)
	{
		NDTexture* pkNewPicture = new NDTexture();
		pkNewPicture->Initialization(pszImageFile);
		m_pkTextures->SetObject(pkNewPicture,kStream.str().c_str());
		CCTexture2D* pkTexture = pkNewPicture->getTexture();
		pkTexture->setContainerType(ContainerTypeAddPic);
		m_mapTex2Str.insert(MAP_STRING::value_type(pkTexture,string(pszImageFile)));
		pkPicture->GetTextureRetain();
	}

	return pkPicture->GetTextureRetain();
}


NDTexture::NDTexture()
{
	m_pkTexture = 0;
}

NDTexture::~NDTexture()
{
	m_pkTexture->release();
}

void NDTexture::Initialization( const char* pszImageFile )
{
	if (0 == pszImageFile || !*pszImageFile)
	{
		return;
	}

	if (m_pkTexture)
	{
		m_pkTexture->release();
		m_pkTexture = 0;
	}
}

CCTexture2D* NDTexture::GetTextureRetain()
{
	m_pkTexture->retain();
	return m_pkTexture;
}


NS_NDENGINE_END
