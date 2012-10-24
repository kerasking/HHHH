//
//  NDPicture.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-8.
//  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDPicture.h"
#include "CCTextureCache.h"
#include "NDDirector.h"
#include "CCImage.h"
#include <sstream>

using namespace cocos2d;

namespace NDEngine
{
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
}

NDPicture::~NDPicture()
{
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
	this->SetCoorinates();
	this->SetColor(ccc4(255, 255, 255, 255));

	if (imageFile)
	{
		m_strfile = imageFile;
	}
}

// 	void NDPicture::Initialization(vector<const char*>& vImgFiles)
// 	{
// 		// »ÒÉ«Í¼ todo
// 		if (vImgFiles.size() < 1) {
// 			return;
// 		}
// 		
// 		[m_texture release];
// 		
// 		vector<UIImage*> vImgs;
// 		for (uint i = 0; i < vImgFiles.size(); i++) {
// 			UIImage *img = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:vImgFiles.at(i)]];
// 			vImgs.push_back(img);
// 			
// 			if (0 == i) {
// 				UIGraphicsBeginImageContext(img.size);
// 			}
// 		}
// 		
// 		for (uint i = 0; i < vImgs.size(); i++) {
// 			UIImage* img = vImgs.at(i);
// 			[img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
// 			[img release];
// 		}
// 		
// 		UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
// 		
// 		UIGraphicsEndImageContext();
// 		
// 		m_texture = [[CCTexture2D alloc] initWithImage:resultImg];
// 		
// 		m_cutRect = CGRectMake(0, 0, m_texture->getContentSizeInPixels().width, m_texture->getContentSizeInPixels().height);
// 		this->SetCoorinates();		
// 		this->SetColor(ccc4(255, 255, 255, 255));
// 	}

// 	void NDPicture::Initialization(vector<const char*>& vImgFiles, vector<CGRect>& vImgCustomRect, vector<CGPoint>&vOffsetPoint)
// 	{
// 		if (vImgFiles.size() < 1 || vImgCustomRect.size() < 1 || vOffsetPoint.size() < 1
// 			|| vImgFiles.size() != vImgCustomRect.size() || vImgFiles.size() != vOffsetPoint.size())
// 			return;
// 		
// 		[m_texture release];
// 		
// 		vector<UIImage*> vImgs;
// 		for (uint i = 0; i < vImgFiles.size(); i++) {
// 			UIImage *img = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:vImgFiles.at(i)]];
// 			UIImage *imgCut = [img getSubImageFromWithRect:vImgCustomRect[i]];
// 			vImgs.push_back(imgCut);
// 			
// 			if (0 == i) {
// 				UIGraphicsBeginImageContext(imgCut.size);
// 			}
// 			
// 			[img release];
// 		}
// 		
// 		for (uint i = 0; i < vImgs.size(); i++) {
// 			UIImage* img = vImgs.at(i);
// 			[img drawInRect:CGRectMake(vOffsetPoint[i].x, vOffsetPoint[i].y, img.size.width, img.size.height)];
// 			//[img release];
// 		}
// 		
// 		UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
// 		
// 		UIGraphicsEndImageContext();
// 		
// 		m_texture = [[CCTexture2D alloc] initWithImage:resultImg];
// 		
// 		m_cutRect = CGRectMake(0, 0, m_texture->getContentSizeInPixels().width, m_texture->getContentSizeInPixels().height);
// 		this->SetCoorinates();		
// 		this->SetColor(ccc4(255, 255, 255, 255));	
// 		
// 	}

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
	}

	m_kCutRect = CGRectMake(0, 0, m_pkTexture->getContentSizeInPixels().width,
			m_pkTexture->getContentSizeInPixels().height);
	this->SetCoorinates();
	this->SetColor(ccc4(255, 255, 255, 255));

	//[pool release];

	if (imageFile)
	{
		m_strfile = imageFile;
		m_hrizontalPixel = hrizontalPixel;
		m_verticalPixel = verticalPixel;
	}
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
	this->SetCoorinates();
	this->SetColor(ccc4(255, 255, 255, 255));
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
	CGSize winSize = NDEngine::NDDirector::DefaultDirector()->GetWinSize();

	switch (m_kRotation)
	{
	case PictureRotation0:
		m_pfVertices[0] = drawRect.origin.x;
		m_pfVertices[1] = winSize.height - drawRect.origin.y
				- drawRect.size.height;
		m_pfVertices[2] = drawRect.origin.x + drawRect.size.width;
		m_pfVertices[3] = m_pfVertices[1];
		m_pfVertices[4] = drawRect.origin.x;
		m_pfVertices[5] = winSize.height - drawRect.origin.y;
		m_pfVertices[6] = m_pfVertices[2];
		m_pfVertices[7] = m_pfVertices[5];
		break;
	case PictureRotation90:
		m_pfVertices[0] = drawRect.origin.x;
		m_pfVertices[1] = winSize.height - drawRect.origin.y;
		m_pfVertices[2] = m_pfVertices[0];
		m_pfVertices[3] = m_pfVertices[1] - drawRect.size.height;
		m_pfVertices[4] = m_pfVertices[0] + drawRect.size.width;
		m_pfVertices[5] = m_pfVertices[1];
		m_pfVertices[6] = m_pfVertices[4];
		m_pfVertices[7] = m_pfVertices[3];
		break;
	case PictureRotation180:
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
	case PictureRotation270:
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
			this->SetCoorinates();
		}
	}
}

void NDPicture::SetReverse(bool reverse)
{
	m_bReverse = reverse;
	this->SetCoorinates();
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

void NDPicture::DrawInRect(CGRect rect)
{
	CCTexture2D *tmpTexture = NULL;

	if (m_bCanGray && m_bStateGray)
	tmpTexture = m_pkTextureGray;
	else
	tmpTexture = m_pkTexture;

	if (tmpTexture)
	{
		this->SetVertices(rect);

		glBindTexture(GL_TEXTURE_2D, tmpTexture->getName());
		glVertexPointer(2, GL_FLOAT, 0, m_pfVertices);
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_colors);
		glTexCoordPointer(2, GL_FLOAT, 0, m_coordinates);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
}

CGSize NDPicture::GetSize()
{
	CGSize size = CGSizeZero;
	if (m_pkTexture)
	{
		size = m_kCutRect.size;
		if (size.width > m_pkTexture->getContentSizeInPixels().width)
		{
			size.width = m_pkTexture->getContentSizeInPixels().width;
		}
		if (size.height > m_pkTexture->getContentSizeInPixels().height)
		{
			size.height = m_pkTexture->getContentSizeInPixels().height;
		}

		if (m_kRotation == PictureRotation90 || m_kRotation == PictureRotation270)
		{
			CGFloat temp = size.width;
			size.width = size.height;
			size.height = temp;
		}
	}

	return size;
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

/////////////////////////////
IMPLEMENT_CLASS(NDPictureDictionary, NDDictionary)
void NDPictureDictionary::Recyle()
{
	if (NULL == m_nsDictionary)
	{
		return;
	}

	std::vector<std::string> allKeys = m_nsDictionary->allKeys();

	if (allKeys.empty())
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
		return this->AddPicture(imageFile);
	}

	std::stringstream ss;
	ss << imageFile << "_" << hrizontalPixel << "_" << verticalPixel;

	NDPicture* pic = (NDPicture *) m_pkTextures->Object(ss.str().c_str());

	if (!pic)
	{
		pic = new NDPicture(gray);
		pic->Initialization(imageFile, hrizontalPixel, verticalPixel);

		m_pkTextures->SetObject(pic, ss.str().c_str());
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
	//CGSize size			= image.getSize();

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
		pkPicture->getTexture();
	}

	return pkPicture->getTexture();
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

unsigned int NDTexture::GetTextureRetain()
{
	return m_pkTexture->retainCount();
}

}