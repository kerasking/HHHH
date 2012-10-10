//
//  NDUIMenuLayer.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDUIMenuLayer.h"
#import "NDTile.h"
#import "CCTextureCache.h"
#import "NDDirector.h"
#import "CGPointExtension.h"
#import "CCTextureCache.h"
#import "cocos2dExt.h"
#import "NDUtility.h"
#include "GameScene.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDUIMenuLayer, NDUILayer)
	
	
#define title_height 28
#define bottom_height 42
#define context_height NDDirector::DefaultDirector()->GetWinSize().height - title_height - bottom_height
#define left_top_image [NSString stringWithFormat:@"%s", GetImgPath("w3.png")]
#define right_bottom_image [NSString stringWithFormat:@"%s", GetImgPath("w4.png")] 
//#define back_button_image [NSString stringWithFormat:@"%@/res/image/btnBack_up.png", [[NSBundle mainBundle] resourcePath]] 
//#define back_button_down_image [NSString stringWithFormat:@"%@/res/image/btnBack_down.png", [[NSBundle mainBundle] resourcePath]] 	
#define back_button_Rect CGRectMake(15, NDDirector::DefaultDirector()->GetWinSize().height - bottom_height + 5, 40, 22)	
#define ok_button_Rect CGRectMake(NDDirector::DefaultDirector()->GetWinSize().width - 50, NDDirector::DefaultDirector()->GetWinSize().height - bottom_height + 5, 35, 37)	
//#define back_button_down_interval 10
	
	//static int backButtonInterval = 0;

	NDUIMenuLayer::NDUIMenuLayer()
	{
		m_tiles = [[NSMutableArray alloc] init];
		m_btnCancel = NULL;
		m_btnOk = NULL;
		m_picCancel = NULL;
		m_picOk = NULL;
	}
	
	NDUIMenuLayer::~NDUIMenuLayer()
	{
		[m_tiles release];
		delete m_picCancel;
		delete m_picOk;
	}
	
	void NDUIMenuLayer::Initialization()
	{
		NDUILayer::Initialization();		
		NDUILayer::SetFrameRect(CGRectMake(0, 0, NDDirector::DefaultDirector()->GetWinSize().width, NDDirector::DefaultDirector()->GetWinSize().height));
		
		this->SetDelegate(this);
		
		m_btnCancel = new NDUIButton();
		m_btnCancel->Initialization();
		m_picCancel = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
		if (m_picCancel)
		{
			m_picCancel->Cut(CGRectMake(120, 0, 40, 20));
			m_btnCancel->SetImage(m_picCancel);
		}
		m_btnCancel->SetFrameRect(CGRectMake(NDDirector::DefaultDirector()->GetWinSize().width - 50, 
											 NDDirector::DefaultDirector()->GetWinSize().height - bottom_height + 8, 
											 m_picCancel->GetSize().width, m_picCancel->GetSize().height));
		this->AddChild(m_btnCancel);
		
		this->MakeLeftTopTile();
		this->MakeRightTopTile();
		this->MakeLeftBottomTile();
		this->MakeRightBottomTile();				
	}
	
	void NDUIMenuLayer::ShowOkBtn()
	{
		if (!m_btnOk) {
			m_btnOk = new NDUIButton();
			m_btnOk->Initialization();
			m_picOk = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
			if (m_picOk)
			{
				m_picOk->Cut(CGRectMake(80, 0, 40, 20));
				m_btnOk->SetImage(m_picOk);
			}
			m_btnOk->SetFrameRect(CGRectMake(15, 
							 NDDirector::DefaultDirector()->GetWinSize().height - bottom_height + 8, 
							 m_picOk->GetSize().width, m_picOk->GetSize().height));
			this->AddChild(m_btnOk);
		}
	}
	
	unsigned int NDUIMenuLayer::GetTitleHeight()
	{
		return title_height;
	}
	
	unsigned int NDUIMenuLayer::GetOperationHeight()
	{
		return bottom_height;
	}
	
	unsigned int NDUIMenuLayer::GetTextHeight()
	{
		return context_height;
	}
	
	void NDUIMenuLayer::draw()
	{		
		NDUILayer::draw();
		
		if (this->IsVisibled()) 
		{
			this->drawBackground();
			
			//glDisableClientState(GL_COLOR_ARRAY);			
			for (int i = 0; i < (int)[m_tiles count]; i++) 
			{
				NDTile *tile = [m_tiles objectAtIndex:i];
				[tile draw];
			}			
			//glEnableClientState(GL_COLOR_ARRAY);
		}	
		
	}
	
	void NDUIMenuLayer::OnBeforeNodeRemoveFromParent(NDNode* node, bool bCleanUp)
	{
		if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
		{
			((GameScene*)(this->GetParent()))->SetUIShow(false);
		}
	}
	
	void NDUIMenuLayer::drawBackground()
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		//draw title recttangle
		DrawRecttangle(CGRectMake(0, 0, winSize.width, title_height), ccc4(49, 146, 189, 255));

		//draw context recttangle
		DrawRecttangle(CGRectMake(0, title_height, winSize.width, context_height), ccc4(165, 178, 156, 255));
		
		//draw bottom recttangle
		DrawRecttangle(CGRectMake(0, title_height + context_height, winSize.width, bottom_height), ccc4(16, 56, 66, 255));
		
		//draw left frame
		DrawLine(ccp(0, 0), ccp(0, winSize.height), ccc4(8,	32,		16,		255), 1);
		DrawLine(ccp(1, 0), ccp(1, winSize.height), ccc4(107,	158,	156,	255), 1);
		DrawLine(ccp(2, 0), ccp(2, winSize.height), ccc4(24,	85,		82,		255), 1);
		
		//draw right frame 
		DrawLine(ccp(winSize.width-1, 0), ccp(winSize.width-1, winSize.height), ccc4(8,	32,		16,		255), 1);
		DrawLine(ccp(winSize.width-2, 0), ccp(winSize.width-2, winSize.height), ccc4(107,	158,	156,	255), 1);
		DrawLine(ccp(winSize.width-3, 0), ccp(winSize.width-3, winSize.height), ccc4(24,	85,		82,		255), 1);
		
		//draw top frame
		DrawLine(ccp(0, 0), ccp(winSize.width, 0), ccc4(8,	32,		16,		255), 1);
		DrawLine(ccp(0, 1), ccp(winSize.width, 1), ccc4(107,	158,	156,	255), 1);
		DrawLine(ccp(0, 2), ccp(winSize.width, 2), ccc4(24,	85,		82,		255), 1);
		
		//draw right frame 
		DrawLine(ccp(0, winSize.height-1), ccp(winSize.width, winSize.height-1), ccc4(8,	32,		16,		255), 1);
		DrawLine(ccp(0, winSize.height-2), ccp(winSize.width, winSize.height-2), ccc4(107,	158,	156,	255), 1);
		DrawLine(ccp(0, winSize.height-3), ccp(winSize.width, winSize.height-3), ccc4(24,	85,		82,		255), 1);
		
		//draw split line between title and context
		DrawLine(ccp(0, title_height), ccp(winSize.width, title_height), ccc4(24,	85,		82,		255), 1);
		
		//draw split line between context and bottom
		DrawLine(ccp(0, title_height+context_height), ccp(winSize.width, title_height+context_height), ccc4(107,	158,	156,	255), 2);
	}
	
	void NDUIMenuLayer::MakeLeftTopTile()
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		NDTile* tile = [[NDTile alloc] init];
		tile.texture = [[CCTextureCache sharedTextureCache] addImage:left_top_image];
		tile.cutRect = CGRectMake(0, 0, tile.texture.maxS * tile.texture.pixelsWide, tile.texture.maxT * tile.texture.pixelsHigh);
		tile.drawRect = CGRectMake(0, 0, 16, 16);
		tile.reverse = NO;
		tile.rotation = NDRotationEnumRotation0;
		tile.mapSize = CGSizeMake(winSize.width, winSize.height);
		
		[tile make];
		
		[m_tiles addObject:tile];
		[tile release];
	}
	
	void NDUIMenuLayer::MakeRightTopTile()
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		NDTile* tile = [[NDTile alloc] init];
		tile.texture = [[CCTextureCache sharedTextureCache] addImage:left_top_image];
		tile.cutRect = CGRectMake(0, 0, tile.texture.maxS * tile.texture.pixelsWide, tile.texture.maxT * tile.texture.pixelsHigh);
		tile.drawRect = CGRectMake(winSize.width - tile.cutRect.size.width , 0, 16, 16);
		tile.reverse = YES;
		tile.rotation = NDRotationEnumRotation0;
		tile.mapSize = CGSizeMake(winSize.width, winSize.height);
		
		[tile make];
		
		[m_tiles addObject:tile];
		[tile release];
	}
	
	void NDUIMenuLayer::MakeLeftBottomTile()
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		NDTile* tile = [[NDTile alloc] init];
		tile.texture = [[CCTextureCache sharedTextureCache] addImage:right_bottom_image];
		tile.cutRect = CGRectMake(0, 0, tile.texture.maxS * tile.texture.pixelsWide, tile.texture.maxT * tile.texture.pixelsHigh);
		tile.drawRect = CGRectMake(0, winSize.height - tile.cutRect.size.height , 8, 8);
		tile.reverse = YES;
		tile.rotation = NDRotationEnumRotation0;
		tile.mapSize = CGSizeMake(winSize.width, winSize.height);
		
		[tile make];
		
		[m_tiles addObject:tile];
		[tile release];
	}
	
	void NDUIMenuLayer::MakeRightBottomTile()
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		NDTile* tile = [[NDTile alloc] init];
		tile.texture = [[CCTextureCache sharedTextureCache] addImage:right_bottom_image];
		tile.cutRect = CGRectMake(0, 0, tile.texture.maxS * tile.texture.pixelsWide, tile.texture.maxT * tile.texture.pixelsHigh);
		tile.drawRect = CGRectMake(winSize.width - tile.cutRect.size.width, winSize.height - tile.cutRect.size.height , 8, 8);
		tile.reverse = NO;
		tile.rotation = NDRotationEnumRotation0;
		tile.mapSize = CGSizeMake(winSize.width, winSize.height);
		
		[tile make];
		
		[m_tiles addObject:tile];
		[tile release];
	}
}
