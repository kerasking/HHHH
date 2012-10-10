//
//  NDPicture.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-8.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NDPicture.h"
#import "CCTextureCache.h"
#import "NDDirector.h"
#include "cpLog.h"
#include "NDUtility.h"
#include "define.h"
#include <sstream>

namespace NDEngine
{
	IMPLEMENT_CLASS(NDPicture, NDObject)
	
	NDPicture::NDPicture(bool canGray/*=false*/)
	{
		m_texture = nil;
		m_cutRect = CGRectZero;
		m_reverse = false;
		m_rotation = PictureRotation0;
		
		m_canGray = true;
		m_stateGray = false;
		m_textureGray = nil;
		
		m_hrizontalPixel = 0;
		m_verticalPixel = 0;
	}
	
	NDPicture::~NDPicture()
	{
		[m_texture release];
		if (m_canGray) {
			[m_textureGray release];
		}
	}
	
	void NDPicture::Initialization(const char* imageFile)
	{
		if (m_texture)
		{
			[m_texture release];
			m_texture = nil;
		}
		
		if (m_textureGray) 
		{
			[m_textureGray release];
			
			m_textureGray = nil;
		}
		
		NSString *nsfile = [NSString stringWithUTF8String:imageFile];
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:nsfile];
		
		if (nil == image && imageFile)
		{
			ScriptMgrObj.DebugOutPut("picture [%s] not exist", imageFile);
		}
		
		m_texture = [[CCTexture2D alloc] initWithImage:image];
		
		/*
		if (m_canGray && image) 
		{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
			m_textureGray = [[CCTexture2D alloc] initWithImage:[image convertToGrayscale]];
			[pool release];
		}
		*/
		
		[image release];
		
		m_cutRect = CGRectMake(0, 0, m_texture.contentSizeInPixels.width, m_texture.contentSizeInPixels.height);
		this->SetCoorinates();		
		this->SetColor(ccc4(255, 255, 255, 255));
		
		if (imageFile)
		{
			m_strfile	= imageFile;
		}
	}
	
	void NDPicture::Initialization(vector<const char*>& vImgFiles)
	{
		// 灰色图 todo
		if (vImgFiles.size() < 1) {
			return;
		}
		
		[m_texture release];
		
		vector<UIImage*> vImgs;
		for (uint i = 0; i < vImgFiles.size(); i++) {
			UIImage *img = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:vImgFiles.at(i)]];
			vImgs.push_back(img);
			
			if (0 == i) {
				UIGraphicsBeginImageContext(img.size);
			}
		}
		
		for (uint i = 0; i < vImgs.size(); i++) {
			UIImage* img = vImgs.at(i);
			[img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
			[img release];
		}
		
		UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
		
		UIGraphicsEndImageContext();
		
		m_texture = [[CCTexture2D alloc] initWithImage:resultImg];
		
		m_cutRect = CGRectMake(0, 0, m_texture.contentSizeInPixels.width, m_texture.contentSizeInPixels.height);
		this->SetCoorinates();		
		this->SetColor(ccc4(255, 255, 255, 255));
	}
	
	void NDPicture::Initialization(vector<const char*>& vImgFiles, vector<CGRect>& vImgCustomRect, vector<CGPoint>&vOffsetPoint)
	{
		if (vImgFiles.size() < 1 || vImgCustomRect.size() < 1 || vOffsetPoint.size() < 1
			|| vImgFiles.size() != vImgCustomRect.size() || vImgFiles.size() != vOffsetPoint.size())
			return;
		
		[m_texture release];
		
		vector<UIImage*> vImgs;
		for (uint i = 0; i < vImgFiles.size(); i++) {
			UIImage *img = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:vImgFiles.at(i)]];
			UIImage *imgCut = [img getSubImageFromWithRect:vImgCustomRect[i]];
			vImgs.push_back(imgCut);
			
			if (0 == i) {
				UIGraphicsBeginImageContext(imgCut.size);
			}
			
			[img release];
		}
		
		for (uint i = 0; i < vImgs.size(); i++) {
			UIImage* img = vImgs.at(i);
			[img drawInRect:CGRectMake(vOffsetPoint[i].x, vOffsetPoint[i].y, img.size.width, img.size.height)];
			//[img release];
		}
		
		UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
		
		UIGraphicsEndImageContext();
		
		m_texture = [[CCTexture2D alloc] initWithImage:resultImg];
		
		m_cutRect = CGRectMake(0, 0, m_texture.contentSizeInPixels.width, m_texture.contentSizeInPixels.height);
		this->SetCoorinates();		
		this->SetColor(ccc4(255, 255, 255, 255));	
		
	}
	
	void NDPicture::Initialization(const char* imageFile, int hrizontalPixel, int verticalPixel/*=0*/)
	{
		[m_texture release];
		m_texture = nil;
		
		if (m_canGray) {
			[m_textureGray release];
			m_textureGray = nil;
		}
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
		
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:imageFile]];
		
		if (nil == image && imageFile)
		{
			ScriptMgrObj.DebugOutPut("picture [%s] not exist", imageFile);
		}
		
		UIImage *stretchImage = nil;
		
		if ((!(hrizontalPixel < 0 || verticalPixel < 0)) && image) 
		{			
			CGSize sizeImg = [image size];
			
			//if (hrizontalPixel > sizeImg.width || verticalPixel > sizeImg.height) 
			{
				int leftCapWidth = hrizontalPixel == 0 ? 0 : sizeImg.width/2;
				
				int topCapHeight = verticalPixel == 0 ? 0 : sizeImg.height/2;
				
				if (hrizontalPixel <= sizeImg.width)
				{
					leftCapWidth = 0;
				}
				
				if (verticalPixel <= sizeImg. height)
				{
					topCapHeight = 0;
				}
				
				UIImage *tmpImg = [image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
				
				if (tmpImg)
				{
					if (hrizontalPixel == 0) hrizontalPixel = sizeImg.width;
					
					if (verticalPixel == 0) verticalPixel = sizeImg.height;
					
					CGSize newSize = CGSizeMake(hrizontalPixel, verticalPixel);
					
					UIGraphicsBeginImageContext(newSize);
					
					[tmpImg drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
					
					stretchImage = UIGraphicsGetImageFromCurrentImageContext();
					
					if (stretchImage != nil) 
					{
						m_texture = [[CCTexture2D alloc] initWithImage:stretchImage];
						/*
						 if (m_canGray) 
						 {
						 m_textureGray = [[CCTexture2D alloc] initWithImage:[stretchImage convertToGrayscale]];
						 }
						 */
					}
					
					UIGraphicsEndImageContext();
				}
			}
		}
		
		//if (stretchImage != nil) 
		//{
		//	m_texture = [[CCTexture2D alloc] initWithImage:stretchImage];
			/*
			if (m_canGray) 
			{
				m_textureGray = [[CCTexture2D alloc] initWithImage:[stretchImage convertToGrayscale]];
			}
			*/
		//}
		//else
		if (stretchImage == nil) 
		{
			[m_texture release];
			m_texture = [[CCTexture2D alloc] initWithImage:image];
			/*
			if (m_canGray) 
			{
				m_textureGray = [[CCTexture2D alloc] initWithImage:[image convertToGrayscale]];
			}
			*/
		}
		
		[image release];
		
		m_cutRect = CGRectMake(0, 0, m_texture.contentSizeInPixels.width, m_texture.contentSizeInPixels.height);
		this->SetCoorinates();		
		this->SetColor(ccc4(255, 255, 255, 255));
		
		[pool release];
		
		if (imageFile)
		{
			m_strfile			= imageFile;
			m_hrizontalPixel	= hrizontalPixel;
			m_verticalPixel		= verticalPixel;
		}
	}
						  
    CCTexture2D *NDPicture::GetTexture()
	{
		return m_texture;
	}
	
	void NDPicture::SetTexture(CCTexture2D* tex)
	{
		[tex retain];
		[m_texture release];
		m_texture = tex;
		m_cutRect = CGRectMake(0, 0, m_texture.contentSizeInPixels.width, m_texture.contentSizeInPixels.height);
		this->SetCoorinates();		
		this->SetColor(ccc4(255, 255, 255, 255));
	}
	
	void NDPicture::SetCoorinates()
	{
		if (m_texture) 
		{
			if (m_reverse) 
			{
				m_coordinates[0] = (m_cutRect.origin.x + m_cutRect.size.width) / m_texture.pixelsWide;
				m_coordinates[1] = (m_cutRect.origin.y + m_cutRect.size.height) / m_texture.pixelsHigh;
				m_coordinates[2] = m_cutRect.origin.x / m_texture.pixelsWide;
				m_coordinates[3] = m_coordinates[1];
				m_coordinates[4] = m_coordinates[0];
				m_coordinates[5] = m_cutRect.origin.y / m_texture.pixelsHigh;
				m_coordinates[6] = m_coordinates[2];
				m_coordinates[7] = m_coordinates[5];
			}
			else 
			{
				m_coordinates[0] = m_cutRect.origin.x / m_texture.pixelsWide;
				m_coordinates[1] = (m_cutRect.origin.y + m_cutRect.size.height) / m_texture.pixelsHigh;
				m_coordinates[2] = (m_cutRect.origin.x + m_cutRect.size.width) / m_texture.pixelsWide;
				m_coordinates[3] = m_coordinates[1];
				m_coordinates[4] = m_coordinates[0];
				m_coordinates[5] = m_cutRect.origin.y / m_texture.pixelsHigh;
				m_coordinates[6] = m_coordinates[2];
				m_coordinates[7] = m_coordinates[5];
			}
		}		
	}
	
	void NDPicture::SetVertices(CGRect drawRect)
	{
		CGSize winSize = NDEngine::NDDirector::DefaultDirector()->GetWinSize();
		
		switch (m_rotation) {
			case PictureRotation0:
				m_vertices[0]		=	drawRect.origin.x;
				m_vertices[1]		=	winSize.height - drawRect.origin.y - drawRect.size.height;
				m_vertices[2]		=	drawRect.origin.x + drawRect.size.width;
				m_vertices[3]		=	m_vertices[1];
				m_vertices[4]		=	drawRect.origin.x;
				m_vertices[5]		=	winSize.height - drawRect.origin.y;
				m_vertices[6]		=	m_vertices[2];
				m_vertices[7]		=	m_vertices[5];
				break;
			case PictureRotation90:							
				m_vertices[0]		=	drawRect.origin.x;
				m_vertices[1]		=	winSize.height - drawRect.origin.y; 
				m_vertices[2]		=	m_vertices[0];
				m_vertices[3]		=	m_vertices[1] - drawRect.size.height;
				m_vertices[4]		=	m_vertices[0] + drawRect.size.width;
				m_vertices[5]		=	m_vertices[1];
				m_vertices[6]		=	m_vertices[4];
				m_vertices[7]		=	m_vertices[3];
				break;
			case PictureRotation180:
				m_vertices[0]		=	drawRect.origin.x + drawRect.size.width;
				m_vertices[1]		=	winSize.height - drawRect.origin.y;
				m_vertices[2]		=	drawRect.origin.x;
				m_vertices[3]		=	m_vertices[1];
				m_vertices[4]		=	m_vertices[0];
				m_vertices[5]		=	winSize.height - drawRect.origin.y -  drawRect.size.height;
				m_vertices[6]		=	m_vertices[2];
				m_vertices[7]		=	m_vertices[5];
				break;
			case PictureRotation270:									
				m_vertices[0]		=	drawRect.origin.x + drawRect.size.width;
				m_vertices[1]		=	winSize.height - (drawRect.origin.y + drawRect.size.height);
				m_vertices[2]		=	m_vertices[0];
				m_vertices[3]		=	m_vertices[1] + drawRect.size.height;
				m_vertices[4]		=	m_vertices[0] - drawRect.size.width;
				m_vertices[5]		=	m_vertices[1];
				m_vertices[6]		=	m_vertices[4];
				m_vertices[7]		=	m_vertices[3];
				break;
			default:
				break;
		}
	}
	
	void NDPicture::Cut(CGRect rect)
	{
		if (m_texture) 
		{
			bool bCutSucess = false;
			
			if (rect.origin.x + rect.size.width <= m_texture.contentSizeInPixels.width && 
				rect.origin.y + rect.size.height <= m_texture.contentSizeInPixels.height) 
			{
				bCutSucess = true;
				m_cutRect = rect;
			}
			else if (rect.origin.x < m_texture.contentSizeInPixels.width &&
					 rect.origin.y < m_texture.contentSizeInPixels.height)
			{
				bCutSucess = true;
				m_cutRect.origin = rect.origin;
				m_cutRect.size = CGSizeMake(m_texture.contentSizeInPixels.width-rect.origin.x, m_texture.contentSizeInPixels.height-rect.origin.y);
			}
			
			if (bCutSucess) this->SetCoorinates();
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
		
		pic->m_texture = [m_texture retain];
		pic->m_reverse = m_reverse;
		pic->m_cutRect = m_cutRect;
		pic->m_rotation = m_rotation;
		pic->m_bAdvance = m_bAdvance;
		pic->m_hrizontalPixel	= m_hrizontalPixel;
		pic->m_verticalPixel	= m_verticalPixel;
		memcpy(pic->m_coordinates, m_coordinates, sizeof(GLfloat) * 8);
		memcpy(pic->m_colors, m_colors, sizeof(GLbyte) * 16);
		memcpy(pic->m_vertices, m_vertices, sizeof(GLfloat) * 8);
		
		//灰图
		pic->m_canGray = m_canGray;
		pic->m_stateGray = m_stateGray;
		pic->m_strfile = m_strfile;
		if (m_canGray)
			pic->m_textureGray = [m_textureGray retain];
		else
			pic->m_textureGray = NULL;
		
		return pic;		
	}
	
	void NDPicture::DrawInRect(CGRect rect)
	{
		CCTexture2D *tmpTexture = nil;
		
		if (m_canGray && m_stateGray) 
			tmpTexture = m_textureGray;
		else
			tmpTexture = m_texture;
		
		if (tmpTexture) 
		{
			this->SetVertices(rect);
			
			glBindTexture(GL_TEXTURE_2D, tmpTexture.name);
			glVertexPointer(2, GL_FLOAT, 0, m_vertices);
			glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_colors);
			glTexCoordPointer(2, GL_FLOAT, 0, m_coordinates);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);			
		}
	}	
	
	CGSize NDPicture::GetSize()
	{
		CGSize size = CGSizeZero;
		if (m_texture) 
		{
			size = m_cutRect.size;
			if (size.width > m_texture.contentSizeInPixels.width) 
			{
				size.width = m_texture.contentSizeInPixels.width;
			}
			if (size.height > m_texture.contentSizeInPixels.height) 
			{
				size.height = m_texture.contentSizeInPixels.height;
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
		
		if (gray && nil == m_textureGray && !m_strfile.empty())
		{
			
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
			
			UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:m_strfile.c_str()]];
			
			UIImage *stretchImage = nil;
			
			if ((!(m_hrizontalPixel < 0 || m_verticalPixel < 0)) && image) 
			{			
				CGSize sizeImg = [image size];
				
				//if (hrizontalPixel > sizeImg.width || verticalPixel > sizeImg.height) 
				{
					int leftCapWidth = m_hrizontalPixel == 0 ? 0 : sizeImg.width/2;
					
					int topCapHeight = m_verticalPixel == 0 ? 0 : sizeImg.height/2;
					
					if (m_hrizontalPixel <= sizeImg.width)
					{
						leftCapWidth = 0;
					}
					
					if (m_verticalPixel <= sizeImg. height)
					{
						topCapHeight = 0;
					}
					
					UIImage *tmpImg = [image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
					
					if (tmpImg)
					{
						int hrizontalPixel	= m_hrizontalPixel;
						int verticalPixel	= m_verticalPixel;
						
						if (hrizontalPixel == 0) hrizontalPixel = sizeImg.width;
						if (verticalPixel == 0) verticalPixel = sizeImg.height;
						
						CGSize newSize = CGSizeMake(hrizontalPixel, verticalPixel);
						
						UIGraphicsBeginImageContext(newSize);
						
						[tmpImg drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
						
						stretchImage = UIGraphicsGetImageFromCurrentImageContext();
						
						if (stretchImage != nil) 
						{
							m_textureGray = [[CCTexture2D alloc] initWithImage:[stretchImage convertToGrayscale]];
						}
						
						UIGraphicsEndImageContext();
					}
				}
			}
			
			if (stretchImage == nil) 
			{
				[m_textureGray release];
				m_textureGray = [[CCTexture2D alloc] initWithImage:[image convertToGrayscale]];
			}
			
			[image release];
			
			[pool release];
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
		if (nil == m_nsDictionary)
		{
			return;
		}
		
		NSArray * allKeys = [m_nsDictionary allKeys];
		
		if (nil == allKeys)
		{
			return;
		}
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSMutableArray *recyle = [[NSMutableArray alloc] init];
		
		for (NSUInteger i = 0; i < [allKeys count]; i++) 
		{
			NSString* key	= [allKeys objectAtIndex:i];
			if (nil == key)
			{
				continue;
			}
			
			DictionaryObject *dictObj = [m_nsDictionary objectForKey:key];
			if (nil == dictObj)
			{
				continue;
			}
			
			NDObject *object	= dictObj.ndObject;
			if (object && object->IsKindOfClass(RUNTIME_CLASS(NDPicture)))
			{
				NDPicture* pic			= (NDPicture*)object;
				CCTexture2D *texture	= pic->GetTexture();
				#ifdef DEBUG
				if (texture)
				{
					//printf("\nfile name[%s] retaincount[%d]", [key UTF8String], [texture retainCount]);
				}
				#endif
				if (texture && 1 >= [texture retainCount])
				{
					[recyle addObject:key];
				}
				else 
				{
					//printf("\nfile name[%s] retaincount[%d]", [key UTF8String], [texture retainCount]);
				}

			}
		}
		
		if (0 < [recyle count])
		{
			[m_nsDictionary removeObjectsForKeys:recyle];
		}
		
		[recyle release];
		[pool release];
	}
	
	/////////////////////////////
	IMPLEMENT_CLASS(NDPicturePool, NDObject)
	
	static NDPicturePool* NDPicturePool_DefaultPool = NULL;
	
	NDPicturePool::NDPicturePool()
	{
		NDAsssert(NDPicturePool_DefaultPool == NULL);
		m_textures = new NDPictureDictionary();
	}
	
	
	NDPicturePool::~NDPicturePool()
	{
		NDPicturePool_DefaultPool = NULL;
		delete m_textures;
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
		
		NDPicture* pic = (NDPicture *)m_textures->Object(ss.str().c_str());
		
		if (!pic) 
		{
			pic = new NDPicture(gray);
			pic->Initialization(imageFile);
			
			m_textures->SetObject(pic, ss.str().c_str());			
		}
		
		return pic->Copy();		
	}
	
	NDPicture* NDPicturePool::AddPicture(const char* imageFile, int hrizontalPixel, int verticalPixel/*=0*/, bool gray/*=false*/)
	{
		NDAsssert(imageFile != NULL);
		
		CGSize sizeImg	= GetImageSize(imageFile ? imageFile : "");
		
		if (int(sizeImg.width) != 0 && int(sizeImg.height) &&
			int(sizeImg.width) == hrizontalPixel && int(sizeImg.height) == verticalPixel)
		{
			return this->AddPicture(imageFile);
		}
		
		std::stringstream ss;
		ss << imageFile << "_" << hrizontalPixel << "_" << verticalPixel;
		
		NDPicture* pic = (NDPicture *)m_textures->Object(ss.str().c_str());
		
		if (!pic) 
		{
			pic = new NDPicture(gray);
			pic->Initialization(imageFile, hrizontalPixel, verticalPixel);
			
			m_textures->SetObject(pic, ss.str().c_str());			
		}
		
		return pic->Copy();	
	}
	
	void NDPicturePool::RemovePicture(const char* imageFile)
	{
		NDAsssert(imageFile != NULL);
		
		m_textures->RemoveObject(imageFile);
	}
	
	void NDPicturePool::Recyle()
	{
		if (m_textures)
		{
			m_textures->Recyle();
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
		
		NSString *nsfile	= [NSString stringWithUTF8String:filename.c_str()];
		UIImage *image		= [[UIImage alloc] initWithContentsOfFile:nsfile];
		
		if (nil == image)
		{
			return CGSizeZero;
		}
		
		CGSize size			= [image size];
		[image release];
		
		m_mapStr2Size.insert(std::make_pair(filename, size));
		
		return size;
	}
}



