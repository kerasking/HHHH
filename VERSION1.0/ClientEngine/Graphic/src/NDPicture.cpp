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
	m_cutRect = CGRectZero;
	m_reverse = false;
	m_rotation = PictureRotation0;

	m_canGray = true;
	m_stateGray = false;
	m_textureGray = NULL;

	m_hrizontalPixel = 0;
	m_verticalPixel = 0;
}

NDPicture::~NDPicture()
{
	CC_SAFE_RELEASE (m_pkTexture);
	if (m_canGray)
	{
		CC_SAFE_RELEASE (m_textureGray);
	}
}

void NDPicture::Initialization(const char* imageFile)
{
	CC_SAFE_RELEASE_NULL (m_pkTexture);
	CC_SAFE_RELEASE_NULL (m_textureGray);

	CCImage image;

	if (!image.initWithImageFile(imageFile) && imageFile)
	{
		//ScriptMgrObj.DebugOutPut("picture [%s] not exist", imageFile);
	}

	m_pkTexture = new CCTexture2D;
	m_pkTexture->initWithPalettePNG(imageFile);

	/*
	 if (m_canGray && image)
	 {
	 NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	 m_textureGray = [[CCTexture2D alloc] initWithImage:[image convertToGrayscale]];
	 [pool release];
	 }
	 */

	m_cutRect = CGRectMake(0, 0, m_pkTexture->getContentSizeInPixels().width,
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
	CC_SAFE_RELEASE_NULL (m_textureGray);

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

	m_cutRect = CGRectMake(0, 0, m_pkTexture->getContentSizeInPixels().width,
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
	m_cutRect = CGRectMake(0, 0, m_pkTexture->getContentSizeInPixels().width,
			m_pkTexture->getContentSizeInPixels().height);
	this->SetCoorinates();
	this->SetColor(ccc4(255, 255, 255, 255));
}

void NDPicture::SetCoorinates()
{
	if (m_pkTexture)
	{
		if (m_reverse)
		{
			m_coordinates[0] = (m_cutRect.origin.x + m_cutRect.size.width)
					/ m_pkTexture->getPixelsWide();
			m_coordinates[1] = (m_cutRect.origin.y + m_cutRect.size.height)
					/ m_pkTexture->getPixelsHigh();
			m_coordinates[2] = m_cutRect.origin.x / m_pkTexture->getPixelsWide();
			m_coordinates[3] = m_coordinates[1];
			m_coordinates[4] = m_coordinates[0];
			m_coordinates[5] = m_cutRect.origin.y / m_pkTexture->getPixelsHigh();
			m_coordinates[6] = m_coordinates[2];
			m_coordinates[7] = m_coordinates[5];
		}
		else
		{
			m_coordinates[0] = m_cutRect.origin.x / m_pkTexture->getPixelsWide();
			m_coordinates[1] = (m_cutRect.origin.y + m_cutRect.size.height)
					/ m_pkTexture->getPixelsHigh();
			m_coordinates[2] = (m_cutRect.origin.x + m_cutRect.size.width)
					/ m_pkTexture->getPixelsWide();
			m_coordinates[3] = m_coordinates[1];
			m_coordinates[4] = m_coordinates[0];
			m_coordinates[5] = m_cutRect.origin.y / m_pkTexture->getPixelsHigh();
			m_coordinates[6] = m_coordinates[2];
			m_coordinates[7] = m_coordinates[5];
		}
	}
}

void NDPicture::SetVertices(CGRect drawRect)
{
	CGSize winSize = NDEngine::NDDirector::DefaultDirector()->GetWinSize();

	switch (m_rotation)
	{
	case PictureRotation0:
		m_vertices[0] = drawRect.origin.x;
		m_vertices[1] = winSize.height - drawRect.origin.y
				- drawRect.size.height;
		m_vertices[2] = drawRect.origin.x + drawRect.size.width;
		m_vertices[3] = m_vertices[1];
		m_vertices[4] = drawRect.origin.x;
		m_vertices[5] = winSize.height - drawRect.origin.y;
		m_vertices[6] = m_vertices[2];
		m_vertices[7] = m_vertices[5];
		break;
	case PictureRotation90:
		m_vertices[0] = drawRect.origin.x;
		m_vertices[1] = winSize.height - drawRect.origin.y;
		m_vertices[2] = m_vertices[0];
		m_vertices[3] = m_vertices[1] - drawRect.size.height;
		m_vertices[4] = m_vertices[0] + drawRect.size.width;
		m_vertices[5] = m_vertices[1];
		m_vertices[6] = m_vertices[4];
		m_vertices[7] = m_vertices[3];
		break;
	case PictureRotation180:
		m_vertices[0] = drawRect.origin.x + drawRect.size.width;
		m_vertices[1] = winSize.height - drawRect.origin.y;
		m_vertices[2] = drawRect.origin.x;
		m_vertices[3] = m_vertices[1];
		m_vertices[4] = m_vertices[0];
		m_vertices[5] = winSize.height - drawRect.origin.y
				- drawRect.size.height;
		m_vertices[6] = m_vertices[2];
		m_vertices[7] = m_vertices[5];
		break;
	case PictureRotation270:
		m_vertices[0] = drawRect.origin.x + drawRect.size.width;
		m_vertices[1] = winSize.height
				- (drawRect.origin.y + drawRect.size.height);
		m_vertices[2] = m_vertices[0];
		m_vertices[3] = m_vertices[1] + drawRect.size.height;
		m_vertices[4] = m_vertices[0] - drawRect.size.width;
		m_vertices[5] = m_vertices[1];
		m_vertices[6] = m_vertices[4];
		m_vertices[7] = m_vertices[3];
		break;
	default:
		break;
	}
}

void NDPicture::Cut(CGRect rect)
{
	if (m_pkTexture)
	{
		bool bCutSucess = false;

		if (rect.origin.x + rect.size.width
				<= m_pkTexture->getContentSizeInPixels().width
				&& rect.origin.y + rect.size.height
						<= m_pkTexture->getContentSizeInPixels().height)
		{
			bCutSucess = true;
			m_cutRect = rect;
		}
		else if (rect.origin.x < m_pkTexture->getContentSizeInPixels().width
				&& rect.origin.y < m_pkTexture->getContentSizeInPixels().height)
		{
			bCutSucess = true;
			m_cutRect.origin = rect.origin;
			m_cutRect.size = CGSizeMake(
					m_pkTexture->getContentSizeInPixels().width - rect.origin.x,
					m_pkTexture->getContentSizeInPixels().height - rect.origin.y);
		}

		if (bCutSucess)
		{
			this->SetCoorinates();
		}
	}
}

void NDPicture::SetReverse(bool reverse)
{
	m_reverse = reverse;
	this->SetCoorinates();
}

void NDPicture::Rotation(PictureRotation rotation)
{
	m_rotation = rotation;
}

NDPicture* NDPicture::Copy()
{
	NDPicture* pic = new NDPicture();
	CC_SAFE_RETAIN (m_pkTexture);
	pic->m_pkTexture = m_pkTexture;
	pic->m_reverse = m_reverse;
	pic->m_cutRect = m_cutRect;
	pic->m_rotation = m_rotation;
	pic->m_bAdvance = m_bAdvance;
	pic->m_hrizontalPixel = m_hrizontalPixel;
	pic->m_verticalPixel = m_verticalPixel;
	memcpy(pic->m_coordinates, m_coordinates, sizeof(GLfloat) * 8);
	memcpy(pic->m_colors, m_colors, sizeof(GLbyte) * 16);
	memcpy(pic->m_vertices, m_vertices, sizeof(GLfloat) * 8);

	//»ÒÍ¼
	pic->m_canGray = m_canGray;
	pic->m_stateGray = m_stateGray;
	pic->m_strfile = m_strfile;
	if (m_canGray)
	{
		CC_SAFE_RETAIN (m_textureGray);
		pic->m_textureGray = m_textureGray;
	}
	else
	{
		pic->m_textureGray = NULL;
	}

	return pic;
}

void NDPicture::DrawInRect(CGRect rect)
{
	CCTexture2D *tmpTexture = NULL;

	if (m_canGray && m_stateGray)
	tmpTexture = m_textureGray;
	else
	tmpTexture = m_pkTexture;

	if (tmpTexture)
	{
		this->SetVertices(rect);

		glBindTexture(GL_TEXTURE_2D, tmpTexture->getName());
		glVertexPointer(2, GL_FLOAT, 0, m_vertices);
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
		size = m_cutRect.size;
		if (size.width > m_pkTexture->getContentSizeInPixels().width)
		{
			size.width = m_pkTexture->getContentSizeInPixels().width;
		}
		if (size.height > m_pkTexture->getContentSizeInPixels().height)
		{
			size.height = m_pkTexture->getContentSizeInPixels().height;
		}

		if (m_rotation == PictureRotation90 || m_rotation == PictureRotation270)
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

	if (gray && NULL == m_textureGray && !m_strfile.empty())
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

	m_stateGray = gray;

	return true;
}

bool NDPicture::IsGrayState()
{
	//if (!m_canGray) return false;

	return m_stateGray;
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
	std::vector<std::string> recyle;

	for (unsigned int i = 0; i < recyle.size(); i++)
	{
		std::string key = recyle[i];

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
				recyle.push_back(key);
			}
			else
			{
				//printf("\nfile name[%s] retaincount[%d]", [key UTF8String], [texture retainCount]);
			}

		}
	}

	for (unsigned int i = 0; i < recyle.size(); i++)
	{
		m_nsDictionary->removeObjectForKey(recyle[i]);
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
	return 0;
}


NDTexture::NDTexture()
{
	m_pkTexture = 0;
}

NDTexture::~NDTexture()
{

}

void NDTexture::Initialization( const char* pszImageFile )
{

}

CCTexture2D* NDTexture::GetTexture()
{
	return 0;
}

CCTexture2D* NDTexture::GetTextureRetain()
{
	return 0;
}

}