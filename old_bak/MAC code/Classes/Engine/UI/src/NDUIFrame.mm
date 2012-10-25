//
//  NDUIFrame.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-4.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NDUIFrame.h"
#import "NDDirector.h"
#import "CCTextureCache.h"
#import "NDUtility.h"
#include "NDPath.h"
#include "I_Analyst.h"


namespace NDEngine
{
	IMPLEMENT_CLASS(NDUIFrame, NDUILayer)
	
#define side_image [NSString stringWithFormat:@"%s", NDPath::GetImgPath("frame_coner.png")]
	
	NDUIFrame::NDUIFrame()
	{
		m_tileLeftTop = [[NDTile alloc] init];
		m_tileRightTop = [[NDTile alloc] init];
		m_tileLeftBottom = [[NDTile alloc] init];
		m_tileRightBottom = [[NDTile alloc] init];
	}
	
	NDUIFrame::~NDUIFrame()
	{
		[m_tileLeftTop release];
		[m_tileRightTop release];
		[m_tileLeftBottom release];
		[m_tileRightBottom release];
	}
	
	void NDUIFrame::draw()
	{
        TICK_ANALYST(ANALYST_NDUIFrame);
		NDUILayer::draw();
		
		if (this->IsVisibled()) 
		{
			this->drawBackground();
			
			DrawPolygon(this->GetScreenRect(), ccc4(24, 85, 82, 255), 3);
			//glDisableClientState(GL_COLOR_ARRAY);
			[m_tileLeftTop draw];
			[m_tileRightTop draw];
			[m_tileLeftBottom draw];
			[m_tileRightBottom draw];
			//glEnableClientState(GL_COLOR_ARRAY);
		}		
	}
	
	void NDUIFrame::OnFrameRectChange(CGRect srcRect, CGRect dstRect)
	{
		this->Make();
	}
	
	void NDUIFrame::Make()
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		CGRect scrRect = this->GetScreenRect();
		
        NDPicture* ptexpic = NDPicturePool::DefaultPool()->AddPicture([side_image UTF8String]);
		//m_tileLeftTop.texture = [[CCTextureCache sharedTextureCache] addImage:side_image];
        m_tileLeftTop.texture = ptexpic->GetTexture();
        SAFE_DELETE(ptexpic);
		m_tileLeftTop.cutRect = CGRectMake(0, 0, m_tileLeftTop.texture.maxS * m_tileLeftTop.texture.pixelsWide, m_tileLeftTop.texture.maxT * m_tileLeftTop.texture.pixelsHigh);
		m_tileLeftTop.drawRect = CGRectMake(scrRect.origin.x, 
											scrRect.origin.y, 
											m_tileLeftTop.texture.maxS * m_tileLeftTop.texture.pixelsWide, 
											m_tileLeftTop.texture.maxT * m_tileLeftTop.texture.pixelsHigh);
		m_tileLeftTop.reverse = NO;
		m_tileLeftTop.rotation = NDRotationEnumRotation0;
		m_tileLeftTop.mapSize = CGSizeMake(winSize.width, winSize.height);		
		[m_tileLeftTop make];
		
		
		NDPicture* ppic = NDPicturePool::DefaultPool()->AddPicture([side_image UTF8String]);
		//m_tileRightTop.texture = [[CCTextureCache sharedTextureCache] addImage:side_image];
        m_tileLeftTop.texture = ppic->GetTexture();
        SAFE_DELETE(ppic);
		m_tileRightTop.cutRect = CGRectMake(0, 0, m_tileRightTop.texture.maxS * m_tileRightTop.texture.pixelsWide, m_tileRightTop.texture.maxT * m_tileRightTop.texture.pixelsHigh);
		m_tileRightTop.drawRect = CGRectMake(scrRect.origin.x + scrRect.size.width - m_tileRightTop.texture.maxT * m_tileRightTop.texture.pixelsHigh, 
											 scrRect.origin.y, 
											 m_tileRightTop.texture.maxT * m_tileRightTop.texture.pixelsHigh, 
											 m_tileRightTop.texture.maxS * m_tileRightTop.texture.pixelsWide);
		m_tileRightTop.reverse = NO;
		m_tileRightTop.rotation = NDRotationEnumRotation90;
		m_tileRightTop.mapSize = CGSizeMake(winSize.width, winSize.height);		
		[m_tileRightTop make];
		
		
		
		NDPicture* pleftpic = NDPicturePool::DefaultPool()->AddPicture([side_image UTF8String]);
		//m_tileLeftBottom.texture = [[CCTextureCache sharedTextureCache] addImage:side_image];
        m_tileLeftBottom.texture = pleftpic->GetTexture();
        SAFE_DELETE(pleftpic);
		m_tileLeftBottom.cutRect = CGRectMake(0, 0, m_tileLeftBottom.texture.maxS * m_tileLeftBottom.texture.pixelsWide, 
											  m_tileLeftBottom.texture.maxT * m_tileLeftBottom.texture.pixelsHigh);
		m_tileLeftBottom.drawRect = CGRectMake(scrRect.origin.x, 
											   scrRect.origin.y + scrRect.size.height - m_tileLeftBottom.texture.maxS * m_tileLeftBottom.texture.pixelsWide , 
											   m_tileLeftBottom.texture.maxS * m_tileLeftBottom.texture.pixelsWide, 
											   m_tileLeftBottom.texture.maxT * m_tileLeftBottom.texture.pixelsHigh);
		m_tileLeftBottom.reverse = NO;
		m_tileLeftBottom.rotation = NDRotationEnumRotation270;
		m_tileLeftBottom.mapSize = CGSizeMake(winSize.width, winSize.height);		
		[m_tileLeftBottom make];
		
		
		
		NDPicture* prightpic = NDPicturePool::DefaultPool()->AddPicture([side_image UTF8String]);
		//m_tileRightBottom.texture = [[CCTextureCache sharedTextureCache] addImage:side_image];
        m_tileRightBottom.texture = prightpic->GetTexture();
        SAFE_DELETE(prightpic);
		m_tileRightBottom.cutRect = CGRectMake(0, 0, m_tileRightBottom.texture.maxS * m_tileRightBottom.texture.pixelsWide, 
											   m_tileRightBottom.texture.maxT * m_tileRightBottom.texture.pixelsHigh);
		m_tileRightBottom.drawRect = CGRectMake(scrRect.origin.x + scrRect.size.width - m_tileRightBottom.texture.maxS * m_tileRightBottom.texture.pixelsWide, 
												scrRect.origin.y + scrRect.size.height - m_tileRightBottom.texture.maxT * m_tileRightBottom.texture.pixelsHigh, 
												m_tileRightBottom.texture.maxT * m_tileRightBottom.texture.pixelsHigh, 
												m_tileRightBottom.texture.maxS * m_tileRightBottom.texture.pixelsWide);
		m_tileRightBottom.reverse = NO;
		m_tileRightBottom.rotation = NDRotationEnumRotation180;
		m_tileRightBottom.mapSize = CGSizeMake(winSize.width, winSize.height);		
		[m_tileRightBottom make];
	}
	
	void NDUIFrame::drawBackground()
	{
		CGRect rect = this->GetScreenRect();
		DrawRecttangle(rect, ccc4(228, 219, 169, 255));
	}
}