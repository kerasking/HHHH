//
//  UIImageCombiner.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-1.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
//

#include "UIImageCombiner.h"
/*
#include "basedefine.h"
#include "cpLog.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(UIImageCombiner, NDObject)
	
	UIImageCombiner::UIImageCombiner()
	{
		
	}
	
	UIImageCombiner::~UIImageCombiner()
	{
		this->ClearUIImages();
	}
	
	void UIImageCombiner::AddUIImage(UIImageStruct* imageStruct)
	{
		m_images.push_back(imageStruct);
	}
	
	void UIImageCombiner::ClearUIImages()
	{
		std::vector<UIImageStruct*>::iterator iter;
		for (iter = m_images.begin(); iter != m_images.end();) 
		{
			UIImageStruct* uiImage = *iter;
			[uiImage->image release];
			delete uiImage;
			m_images.erase(iter);
		}
	}
	
	UIImage4* UIImageCombiner::Combine(CGSize imageSize)
	{
		UIImage4* result = new UIImage4();
		result->leftTop = NULL;
		result->rightTop = NULL;
		result->leftBottom = NULL;
		result->rightBottom = NULL;
		
		return result;
		
		cpLog(LOG_DEBUG, "image combine begin......");
		std::vector<UIImageStruct*>::iterator iter;		
		NSAutoreleasePool *pool = NULL;
		
		//TEST//
		pool = [[NSAutoreleasePool alloc] init];
		//TEST//

		for (iter = m_images.begin(); iter != m_images.end(); iter++) 
		{
			UIImageStruct* uiImage = *iter;
			
			if (uiImage->reverse || uiImage->rotation != 0) 
			{
				UIGraphicsBeginImageContext(uiImage->cutRect.size);
				CGContextRef contextSingle = UIGraphicsGetCurrentContext();
				CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, uiImage->cutRect.size.height); //垂直翻转
				CGContextConcatCTM(contextSingle, flipVertical);
				
				if (uiImage->reverse) 
				{
					CGAffineTransform flipHorizontal = CGAffineTransformMake(-1, 0, 0, 1, uiImage->cutRect.size.width, 0); //水平翻转
					CGContextConcatCTM(contextSingle, flipHorizontal);
				}
				
				if (uiImage->rotation != 0) 
				{					
					CGContextTranslateCTM(contextSingle, uiImage->cutRect.size.width / 2, uiImage->cutRect.size.height / 2);
					CGContextRotateCTM(contextSingle, degreesToRadian(360 - uiImage->rotation));
					CGContextTranslateCTM(contextSingle, -uiImage->cutRect.size.width / 2, -uiImage->cutRect.size.height / 2);				
				}
				
				CGImageRef cgImage = CGImageCreateWithImageInRect([uiImage->image CGImage], uiImage->cutRect);
				CGContextDrawImage(contextSingle, CGRectMake(0, 0, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage)), cgImage);	
				CGImageRelease(cgImage);
				
				[uiImage->image release];
				uiImage->image = [UIGraphicsGetImageFromCurrentImageContext() retain];
				UIGraphicsEndImageContext();
				
				uiImage->bReset = true;
			}
			else 
				uiImage->bReset = false;
		}	
		//TEST//
		[pool release];
		 //TEST//


		//TEST//
		pool = [[NSAutoreleasePool alloc] init];
		//TEST//
		
		//make left top image	
		CGSize ltImageSize;
		ltImageSize.width = imageSize.width < 1024 ? imageSize.width : 1024;
		ltImageSize.height = imageSize.height < 1024 ? imageSize.height : 1024;
		UIGraphicsBeginImageContext(ltImageSize);
		CGContextRef ltContext = UIGraphicsGetCurrentContext();
		CGAffineTransform ltVertical = CGAffineTransformMake(1, 0, 0, -1, 0, ltImageSize.height); //垂直翻转
		CGContextConcatCTM(ltContext, ltVertical);		
		for (iter = m_images.begin(); iter != m_images.end(); iter++) 
		{
			UIImageStruct* uiImage = *iter;	
			
			if (uiImage->drawPoint.x + uiImage->cutRect.size.width <= 1024 
				&& uiImage->drawPoint.y + uiImage->cutRect.size.height <= 1024)
			{
				CGImageRef cgImage;
				if (uiImage->bReset) 
					cgImage = CGImageCreateWithImageInRect([uiImage->image CGImage], CGRectMake(0, 0, uiImage->cutRect.size.width, uiImage->cutRect.size.height));
				else
					cgImage = CGImageCreateWithImageInRect([uiImage->image CGImage], uiImage->cutRect);
				CGContextDrawImage(ltContext, 
								   CGRectMake(uiImage->drawPoint.x, 
											  ltImageSize.height - uiImage->drawPoint.y - CGImageGetHeight(cgImage), 
											  CGImageGetWidth(cgImage), 
											  CGImageGetHeight(cgImage)), 
								   cgImage);
				CGImageRelease(cgImage);
			}				
		}	
		result->leftTop = [UIGraphicsGetImageFromCurrentImageContext() retain];
		UIGraphicsEndImageContext();		
		
		NSData *data = UIImagePNGRepresentation( result->leftTop );
		[data writeToFile:@"/tmp/a.png" atomically:YES];
		//TEST//
		[pool release];
		//TEST//
		
		//TEST//
		pool = [[NSAutoreleasePool alloc] init];
		//TEST//
		
		
		
		//make right top image	
		if (imageSize.width > 1024) 
		{
			CGSize rtImageSize;
			rtImageSize.width = imageSize.width - 1024;
			rtImageSize.height = imageSize.height < 1024 ? imageSize.height : 1024;
			UIGraphicsBeginImageContext(rtImageSize);
			CGContextRef rtContext = UIGraphicsGetCurrentContext();
			CGAffineTransform rtVertical = CGAffineTransformMake(1, 0, 0, -1, 0, rtImageSize.height); //垂直翻转
			CGContextConcatCTM(rtContext, rtVertical);	
			for (iter = m_images.begin(); iter != m_images.end(); iter++) 
			{
				UIImageStruct* uiImage = *iter;	
				
				if (uiImage->drawPoint.x + uiImage->cutRect.size.width > 1024 
					&& uiImage->drawPoint.y + uiImage->cutRect.size.height <= 1024) 
				{
					CGImageRef cgImage;
					if (uiImage->bReset) 
						cgImage = CGImageCreateWithImageInRect([uiImage->image CGImage], CGRectMake(0, 0, uiImage->cutRect.size.width, uiImage->cutRect.size.height));
					else
						cgImage = CGImageCreateWithImageInRect([uiImage->image CGImage], uiImage->cutRect);
					CGContextDrawImage(rtContext, 
									   CGRectMake(uiImage->drawPoint.x - 1024, 
												  rtImageSize.height - uiImage->drawPoint.y - CGImageGetHeight(cgImage), 
												  CGImageGetWidth(cgImage), 
												  CGImageGetHeight(cgImage)), 
									   cgImage);	
					CGImageRelease(cgImage);
				}			
			}	
			result->rightTop = [UIGraphicsGetImageFromCurrentImageContext() retain];
			UIGraphicsEndImageContext();
		}			
		
		//TEST//
		[pool release];
		//TEST//
		//TEST//
		pool = [[NSAutoreleasePool alloc] init];
		//TEST//
		
		
		//make left bottom image
		if (imageSize.height > 1024) 
		{
			CGSize lbImageSize;
			lbImageSize.width = imageSize.width < 1024 ? imageSize.width : 1024;
			lbImageSize.height = imageSize.height - 1024;
			UIGraphicsBeginImageContext(lbImageSize);
			CGContextRef lbContext = UIGraphicsGetCurrentContext();
			CGAffineTransform lbVertical = CGAffineTransformMake(1, 0, 0, -1, 0, lbImageSize.height); //垂直翻转
			CGContextConcatCTM(lbContext, lbVertical);			
			for (iter = m_images.begin(); iter != m_images.end(); iter++) 
			{
				UIImageStruct* uiImage = *iter;	
				
				if (uiImage->drawPoint.x + uiImage->cutRect.size.width <= 1024 
					&& uiImage->drawPoint.y + uiImage->cutRect.size.height > 1024)
				{
					CGImageRef cgImage;
					if (uiImage->bReset) 
						cgImage = CGImageCreateWithImageInRect([uiImage->image CGImage], CGRectMake(0, 0, uiImage->cutRect.size.width, uiImage->cutRect.size.height));
					else
						cgImage = CGImageCreateWithImageInRect([uiImage->image CGImage], uiImage->cutRect);
					CGContextDrawImage(lbContext, 
									   CGRectMake(uiImage->drawPoint.x, 
												  lbImageSize.height + 1024 - uiImage->drawPoint.y - CGImageGetHeight(cgImage), 
												  CGImageGetWidth(cgImage), CGImageGetHeight(cgImage)), 
									   cgImage);
					CGImageRelease(cgImage);
				}
					
			}			
			result->leftBottom = [UIGraphicsGetImageFromCurrentImageContext() retain];
			UIGraphicsEndImageContext();
		}

		//TEST//
		[pool release];
		//TEST//
		//TEST//
		pool = [[NSAutoreleasePool alloc] init];
		//TEST//
		
		
		//make right bottom image
		if (imageSize.height > 1024 && imageSize.width > 1024) 
		{
			CGSize rbImageSize;
			rbImageSize.width = imageSize.width - 1024;
			rbImageSize.height = imageSize.height - 1024;
			UIGraphicsBeginImageContext(rbImageSize);
			CGContextRef rbContext = UIGraphicsGetCurrentContext();
			CGAffineTransform rbVertical = CGAffineTransformMake(1, 0, 0, -1, 0, rbImageSize.height); //垂直翻转
			CGContextConcatCTM(rbContext, rbVertical);			
			for (iter = m_images.begin(); iter != m_images.end(); iter++) 
			{
				UIImageStruct* uiImage = *iter;	
				
				if (uiImage->drawPoint.x + uiImage->cutRect.size.width > 1024 
					&& uiImage->drawPoint.y + uiImage->cutRect.size.height > 1024)
				{
					CGImageRef cgImage;
					if (uiImage->bReset) 
						cgImage = CGImageCreateWithImageInRect([uiImage->image CGImage], CGRectMake(0, 0, uiImage->cutRect.size.width, uiImage->cutRect.size.height));
					else
						cgImage = CGImageCreateWithImageInRect([uiImage->image CGImage], uiImage->cutRect);
					CGContextDrawImage(rbContext, 
									   CGRectMake(uiImage->drawPoint.x - 1024, 
												  rbImageSize.height + 1024 - uiImage->drawPoint.y - CGImageGetHeight(cgImage), 
												  CGImageGetWidth(cgImage), 
												  CGImageGetHeight(cgImage)), 
									   cgImage);
					CGImageRelease(cgImage);
				}
					
			}			
			result->rightBottom = [UIGraphicsGetImageFromCurrentImageContext() retain];
			UIGraphicsEndImageContext();
		}	
		
		//TEST//
		[pool release];
		//TEST//
		
		cpLog(LOG_DEBUG, "image combine complete!, imagesize=%0.2f * %0.2f",imageSize.width, imageSize.height);
		return result;	
	}
}


*/