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
#include "Des.h"
#include "sys/stat.h"
#include "NDString.h"
#include "I_Analyst.h"

UIImage* GetUIImageFromFile_depng(const char* pszPngFile);
//#define USE_PVR
std::string ReplacePng2Pvr(const char* text)
{
	if (NULL == text)
	{
		return "";
	}
	NDEngine::NDString src(text);
	src.replace(".png", ".pvr.ccz");
	return std::string(src.getDataBuf());
}
const unsigned char g_dekey[] = {0x80,0x12,0x97,0x67,0x24,0x88,0x89,0x98,0x55,0x34,0xBD,0x33,0x34,0x80,0x12,0x97,0x67,0x24,0x88,0x89,0x98,0x55,0x34,0xBD};
namespace NDEngine
{
    IMPLEMENT_CLASS(NDTexture, NDObject)
    NDTexture::NDTexture()
	{
		m_texture = nil;
	}
	NDTexture::~NDTexture()
	{
		[m_texture release];
	}
    void NDTexture::Initialization(const char* imageFile)
	{
		if (m_texture)
		{
			[m_texture release];
			m_texture = nil;
		}
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//        UIImage* image = this->GetUIImageFromFile(imageFile);
//		if (nil == image && imageFile)
//		{
//			ScriptMgrObj.DebugOutPut("picture [%s] not exist", imageFile);
//		}
//		m_texture = [[CCTexture2D alloc] initWithImage:image];
		m_texture = [[CCTexture2D alloc] initWithPalettePNG:imageFile];
		[pool release];
        printf("[m_texture retainCount][%d]",[m_texture retainCount]);
	}
    UIImage*
    NDTexture::GetUIImageFromFile(const char* pszPngFile)
    {
        //printf("NDPicture::GetUIImageFromFile[%s]",pszPngFile);
        /*HJQ MOD*/
//#ifndef UPDATE_RES
        NSString *nsfile = [NSString stringWithUTF8String:pszPngFile];
		UIImage *image = [UIImage imageWithContentsOfFile:nsfile];
        return image;
/*
#else
        FILE* fp=NULL;
        fp = fopen(pszPngFile, "rb");
        if (!fp) {
            return NULL;
        }
        struct stat sb;
        stat(pszPngFile, &sb);
        unsigned char btData[1024] = {0x00};
        int nEncryptLen = 0;
        int nImageDataLen=0;
        int nReadLen = 0;
        unsigned char* btImageData = new unsigned char[sb.st_size];
        while (!feof(fp)) {
            ::memset(btData, 0x00, sizeof(btData));
            if (nImageDataLen==0) {
                unsigned int nOutLen = 0;
                unsigned char btDeData[2048] = {0x00};
                nEncryptLen = fread(&nOutLen,1,sizeof(unsigned int),fp);
                nReadLen = fread(btData, 1, nOutLen, fp);
                //解密
                CDes::Decrypt_Pad_PKCS_7( (const char *)g_dekey,
                                         24,
                                         (char*)btData,
                                         nReadLen,
                                         (char*)btDeData,
                                         nOutLen);
                ::memcpy(btImageData+nImageDataLen, btDeData, nOutLen);
                nImageDataLen+=nOutLen;
            }else{
                nReadLen =fread(btData, 1, sizeof(btData), fp);
                ::memcpy(btImageData+nImageDataLen, btData, nReadLen);
                nImageDataLen+=nReadLen;
            }
        }
        NSData *data = [NSData dataWithBytes:btImageData length:nImageDataLen];
        UIImage *image=[UIImage imageWithData:data];
        fclose(fp);
        delete []btImageData;
        return image;
#endif
 */
    }
    CCTexture2D *NDTexture::GetTextureRetain()
	{
        //[m_texture retain];
		return m_texture;
	}
    CCTexture2D *NDTexture::GetTexture()
	{
		return m_texture;
	}
	IMPLEMENT_CLASS(NDPicture, NDObject)
	
	NDPicture::NDPicture(bool canGray/*=false*/)
    :m_fScale(1.0f)
	{
		m_cutRect = CGRectZero;
		m_reverse = false;
		m_rotation = PictureRotation0;
		
		m_canGray = true;
		m_stateGray = false;
        m_bIsTran   = false;
		m_textureGray = nil;
		
		m_hrizontalPixel = 0;
		m_verticalPixel = 0;
	}
	
	NDPicture::~NDPicture()
	{
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
		
#ifdef USE_PVR
		NSString *nsfile = [NSString stringWithUTF8String:ReplacePng2Pvr(imageFile).c_str()];
		m_texture = [[CCTexture2D alloc] initWithPVRFile:nsfile];
#endif
		if (nil == m_texture)
		{
//			UIImage* image = this->GetUIImageFromFile(imageFile);
//		
//            if (nil == image && imageFile)
//            {
//                ScriptMgrObj.DebugOutPut("picture [%s] not exist", imageFile);
//            }
//            
//            m_texture = [[CCTexture2D alloc] initWithImage:image];
            m_texture = [[CCTexture2D alloc] initWithPalettePNG:imageFile];
		}
    
		/*
		if (m_canGray && image) 
		{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
			m_textureGray = [[CCTexture2D alloc] initWithImage:[image convertToGrayscale]];
			[pool release];
		}
		*/
        
		//[image release];
		
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
		
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		vector<UIImage*> vImgs;
		for (uint i = 0; i < vImgFiles.size(); i++) {
            UIImage* img = GetUIImageFromFile_depng(vImgFiles.at(i));//this->GetUIImageFromFile(vImgFiles.at(i));//++Guosen 2012.8.24
			//UIImage *img = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:vImgFiles.at(i)]];
			vImgs.push_back(img);
			
			if (0 == i) {
				UIGraphicsBeginImageContext(img.size);
			}
		}
		
		for (uint i = 0; i < vImgs.size(); i++) {
			UIImage* img = vImgs.at(i);
			[img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
			//[img release];
		}
		
		UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
		
		UIGraphicsEndImageContext();
		
		m_texture = [[CCTexture2D alloc] initWithImage:resultImg];
		
		m_cutRect = CGRectMake(0, 0, m_texture.contentSizeInPixels.width, m_texture.contentSizeInPixels.height);
		this->SetCoorinates();		
		this->SetColor(ccc4(255, 255, 255, 255));
        [pool release];
	}
    /////////////////////////////////////////////////////////////////////
    void NDPicture::SetScale(float fScale)
    {
        m_fScale = fScale;
	}
    void NDPicture::SetIsTran(bool bFlag)
    {
        m_bIsTran = bFlag;
	}
	
	void NDPicture::Initialization(vector<const char*>& vImgFiles, vector<CGRect>& vImgCustomRect, vector<CGPoint>&vOffsetPoint)
	{
		if (vImgFiles.size() < 1 || vImgCustomRect.size() < 1 || vOffsetPoint.size() < 1
			|| vImgFiles.size() != vImgCustomRect.size() || vImgFiles.size() != vOffsetPoint.size())
			return;
		
		[m_texture release];
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		vector<UIImage*> vImgs;
		for (uint i = 0; i < vImgFiles.size(); i++) {
            UIImage* img = GetUIImageFromFile_depng(vImgFiles.at(i));//this->GetUIImageFromFile(vImgFiles.at(i));//++Guosen 2012.8.24
			//UIImage *img = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:vImgFiles.at(i)]];
			UIImage *imgCut = [img getSubImageFromWithRect:vImgCustomRect[i]];
			vImgs.push_back(imgCut);
			
			if (0 == i) {
				UIGraphicsBeginImageContext(imgCut.size);
			}
			
			//[img release];
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
		[pool release];
	}
	
	void NDPicture::Initialization(const char* imageFile, int hrizontalPixel, int verticalPixel/*=0*/)
	{
		//this->Initialization(imageFile);
		//return;
		[m_texture release];
		m_texture = nil;
		
		if (m_canGray) {
			[m_textureGray release];
			m_textureGray = nil;
		}
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
		UIImage* image = GetUIImageFromFile_depng(imageFile);//this->GetUIImageFromFile(imageFile);//++Guosen 2012.8.24
		//UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:imageFile]];
		
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
		
		//[image release];
		
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
        //[m_texture dealloc];
        
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
            TICK_ANALYST(ANALYST_NDPicture);	
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
			this->SetVertices(rect);
            //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);//Guosen 2012.7.28//此代码令图像渲染时变黑，偶尔正常，先注释起来
			
            //** chh 2012-08-01 设置图片可完全透明问题 **//
            if(m_bIsTran){
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            }
            
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
            size.width *= m_fScale;            size.height *= m_fScale;
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
			if (object && object->IsKindOfClass(RUNTIME_CLASS(NDTexture)))
			{
				NDTexture* pic			= (NDTexture*)object;
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
            //邱博威测试
			else if (object && object->IsKindOfClass(RUNTIME_CLASS(NDPicture)))
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
            //邱博威测试
		}
		
		if (0 < [recyle count])
		{
			[m_nsDictionary removeObjectsForKeys:recyle];
		}
		
		[recyle release];
		[pool release];
	}
	int NDPictureDictionary::Statistics(bool bNotPrintLog)
	{
		if (nil == m_nsDictionary)
		{
			return 0;
		}
		NSArray * allKeys = [m_nsDictionary allKeys];
		if (nil == allKeys)
		{
			return 0;
		}
		unsigned int nSize	= 0;
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
				if (texture)
				{
					unsigned int n		= (unsigned int)[texture GetPixelMemory];
					if (!bNotPrintLog)
					{
						NSLog(@"\n[%@]retaincount[%d]size[%u] [%d] kbyte [%d] MByte \n", key, [texture retainCount], n, n / 1024, n / (1024 * 1024));
					}
					nSize				+= n;	
				}
			}
            //邱博威测试
            else if (object && object->IsKindOfClass(RUNTIME_CLASS(NDTexture)))
			{
				NDTexture* pic			= (NDTexture*)object;
				CCTexture2D *texture	= pic->GetTexture();
				if (texture)
				{
					unsigned int n		= (unsigned int)[texture GetPixelMemory];
					if (!bNotPrintLog)
					{
						NSLog(@"\n[%@]retaincount[%d]size[%u] [%d] kbyte [%d] MByte \n", key, [texture retainCount], n, n / 1024, n / (1024 * 1024));
					}
					nSize				+= n;	
				}
			}  
            ///
		}
		if (!bNotPrintLog)
		{
			NSLog(@"NDPicturePool texture size [%d] kbyte [%d] MByte", nSize / 1024, nSize / (1024 * 1024));
		}
		return nSize;
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
		
		//std::stringstream ss;
		//ss << imageFile;
		
		NDPicture* pic = (NDPicture *)m_textures->Object(imageFile);
        
		if (!pic)
		{
			pic = new NDPicture(gray);
			pic->Initialization(imageFile);
			
			m_textures->SetObject(pic, imageFile);	
            CCTexture2D* tex = pic->GetTexture();
            tex.ContainerType = ContainerTypeAddPic;
            m_mapTex2Str.insert(std::map<CCTexture2D*, std::string>::value_type(tex, imageFile));
		}
		
		return pic->Copy();		
	}
    ////
    UIImage*
    NDPicture::GetUIImageFromFile(const char* pszPngFile)
    {
        //printf("NDPicture::GetUIImageFromFile[%s]",pszPngFile);
        /*HJQ MOD*/
//#ifndef UPDATE_RES
        NSString *nsfile = [NSString stringWithUTF8String:pszPngFile];
		UIImage *image = [UIImage imageWithContentsOfFile:nsfile];
        return image;
        /*
#else
        FILE* fp=NULL;
        fp = fopen(pszPngFile, "rb");
        if (!fp) {
            return NULL;
        }
        struct stat sb;
        stat(pszPngFile, &sb);
        unsigned char btData[1024] = {0x00};
        int nEncryptLen = 0;
        int nImageDataLen=0;
        int nReadLen = 0;
        unsigned char* btImageData = new unsigned char[sb.st_size];
        while (!feof(fp)) {
            ::memset(btData, 0x00, sizeof(btData));
            if (nImageDataLen==0) {
                unsigned int nOutLen = 0;
                unsigned char btDeData[2048] = {0x00};
                nEncryptLen = fread(&nOutLen,1,sizeof(unsigned int),fp);
                nReadLen = fread(btData, 1, nOutLen, fp);
                //解密
                CDes::Decrypt_Pad_PKCS_7( (const char *)g_dekey,
                                         24,
                                         (char*)btData,
                                         nReadLen,
                                         (char*)btDeData,
                                         nOutLen);
                ::memcpy(btImageData+nImageDataLen, btDeData, nOutLen);
                nImageDataLen+=nOutLen;
            }else{
                nReadLen =fread(btData, 1, sizeof(btData), fp);
                ::memcpy(btImageData+nImageDataLen, btData, nReadLen);
                nImageDataLen+=nReadLen;
            }
        }
        NSData *data = [NSData dataWithBytes:btImageData length:nImageDataLen];
        UIImage *image=[UIImage imageWithData:data];
        fclose(fp);
        delete []btImageData;
        return image;
#endif*/
    }
    
	NDPicture* NDPicturePool::AddPicture(const char* imageFile, int hrizontalPixel, int verticalPixel/*=0*/, bool gray/*=false*/)
	{
		//return this->AddPicture(imageFile);
		NDAsssert(imageFile != NULL);
        
		CGSize sizeImg	= GetPngImageSize(imageFile ? imageFile : "");
		
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
            CCTexture2D* tex = pic->GetTexture();
            tex.ContainerType = ContainerTypeAddPic;	
            m_mapTex2Str.insert(std::map<CCTexture2D*, std::string>::value_type(tex, imageFile));
		}
		
		return pic->Copy();	
	}
    //////////////////////////////////////////////////////
    CCTexture2D* NDPicturePool::AddTexture(const char* imageFile)
    {
        NDAsssert(imageFile != NULL);
	
		std::stringstream ss;
		ss << imageFile;
		NDTexture* pic = (NDTexture *)m_textures->Object(ss.str().c_str());
		if (!pic)
		{
			NDTexture* pNewPic = new NDTexture(); 
			pNewPic->Initialization(imageFile);
			m_textures->SetObject(pNewPic, ss.str().c_str());
            CCTexture2D* tex = pNewPic->GetTexture();
            tex.ContainerType = ContainerTypeAddPic;	
            m_mapTex2Str.insert(std::map<CCTexture2D*, std::string>::value_type(tex, imageFile));
			return pNewPic->GetTextureRetain();
		}
		return pic->GetTextureRetain();
    }
	/*
	CCTexture2D* NDPicturePool::GetTexture(const char* imageFile)
	{
		if (NULL == imageFile)
		{
			return nil;
		}
		NDAsssert(imageFile != NULL);
		std::stringstream ss;
		ss << imageFile;
		std::map<std::string, NDPicture*>::iterator it = m_textures.find(ss.str());
		NDPicture* pic =  it == m_textures.end() ? NULL : it->second;
		if (!pic) 
		{
			pic = new NDPicture();
			pic->Initialization(imageFile);
			m_textures[ss.str()] = pic;			
		}
		return pic->GetTexture();
	}
	*/
	void NDPicturePool::RemovePicture(const char* imageFile)
	{
		NDAsssert(imageFile != NULL);
		
		m_textures->RemoveObject(imageFile);
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
	
	void NDPicturePool::Recyle()
	{
		if (m_textures)
		{
			m_textures->Recyle();
		}
	}
	int NDPicturePool::Statistics(bool bNotPrintLog)
	{
        /*
		int nSize = 0;
		std::map<std::string, NDPicture*>::iterator it = m_textures.begin();
		for (; it != m_textures.end(); it++) 
		{
			NDPicture* pic			= it->second;
			if (!pic)
			{
				continue;
			}
			CCTexture2D *texture	= pic->GetTexture();
			if (texture)
			{
				unsigned int n		= (unsigned int)[texture GetPixelMemory];
				if (!bNotPrintLog)
				{
					NSLog(@"\n[%@]retaincount[%d]size[%u] [%d] kbyte [%d] MByte \n", 
						  [NSString stringWithUTF8String:it->first.c_str()], 
						  [texture retainCount], n, n / 1024, n / (1024 * 1024));
				}
				nSize				+= n;	
			}
		}
		return nSize;*/
        return m_textures->Statistics(bNotPrintLog);
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
	CGSize NDPicturePool::GetPngImageSize(std::string filename)
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
		
        UIImage * image	= GetUIImageFromFile_depng( filename.c_str() );
		if (nil == image)
		{
			return CGSizeZero;
		}
		
		CGSize size			= [image size];
		
		m_mapStr2Size.insert(std::make_pair(filename, size));
		
		return size;
	}
}

//++Guosen 2012.8.24
//解密
void Decrypt( unsigned char * tBuffer )
{
	unsigned long nCode[3];
	nCode[0] = 0x6E643931;
	nCode[1] = 0x64656E61;
	nCode[2] = 0;
	unsigned char * szEncrypt = (unsigned char * )nCode;

	for ( unsigned int i = 0; i < 8; ++i )
	{
		unsigned char cXor = szEncrypt[i];
		unsigned char cOpt = tBuffer[i];
		cOpt = (cOpt >> 4) | ( (cOpt & 0x0f) * 0x10 );
		tBuffer[i] = cOpt ^ cXor;
	}
}
UIImage* GetUIImageFromFile_depng(const char* pszPngFile)
{
	NSString *	nsFile	= [NSString stringWithUTF8String: pszPngFile];
    NSData * 	nsData	= [NSData dataWithContentsOfFile: nsFile]; 
    Byte *		tBuffer = (Byte *)[nsData bytes];

	char pngHead[8] = { 0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a };
	if ( 0 == memcmp( tBuffer, pngHead, 8 ) )
	{//PNG格式
    	if ( tBuffer[0x1a] != 0 )
		{  //加密
				Decrypt( &tBuffer[0x12] );
				tBuffer[0x1a] = 0;
				unsigned long Width = tBuffer[16] * 0x1000000 + tBuffer[17] * 0x10000 + tBuffer[18] * 0x100 + tBuffer[19];
				Width -= 0x400;//宽度减去1024
				tBuffer[16] = ( Width / 0x1000000 ) & 0xff;
				tBuffer[17] = ( Width / 0x10000 ) & 0xff;
				tBuffer[18] = ( Width / 0x100 ) & 0xff;
				tBuffer[19] = ( Width / 0x1 ) & 0xff;
		}
	}
	UIImage *	image	= [UIImage imageWithData: nsData];
	return image;
}

