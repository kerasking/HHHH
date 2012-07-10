//
//  NDMapLayer.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDMapLayer.h"
#import "NDDirector.h"
#import "CGPointExtension.h"
#import "NDPath.h"
#import "NDNode.h"
#import "NDSprite.h"
#import "NDMapDataPool.h"
#import "NDTile.h"
#import "CCNode.h"
#import "NDAnimationGroupPool.h"
#import "NDBattlePet.h"
#import "NDPlayer.h"
#import "NDRidePet.h"
#import "NDConstant.h"
#import "GameScene.h"
#import "cpLog.h"
#import "cocos2dExt.h"
#import "NDUtility.h"
#import "NDMapMgr.h"
#import "Performance.h"
#import "BattleMgr.h"


#define IMAGE_PATH										\
				[NSString stringWithUTF8String:				\
				NDEngine::NDPath::GetImagePath().c_str()]

bool GetIntersectRect(CGRect first, CGRect second, CGRect& ret)
{
	if (!CGRectIntersectsRect(first, second))
	{
		return false;
	}
	
	ret = CGRectIntersection(first, second);
	
	return true;
}

bool GetRectPercent(CGRect rect, CGRect subrect, CGRect& ret)
{
	if (!CGRectContainsRect(rect, subrect))
	{
		return false;
	}
	
	ret.origin.x = (subrect.origin.x - rect.origin.x) / rect.size.width;
	ret.origin.y = (subrect.origin.y - rect.origin.y) / rect.size.height;
	
	ret.size.width	= subrect.size.width / rect.size.width;
	ret.size.height	= subrect.size.height / rect.size.height;
	
	return true;
}

namespace NDEngine
{
	IMPLEMENT_CLASS(NDMapLayer, NDLayer)
	
	NDMapLayer::NDMapLayer()
	{
		m_mapData = nil;
		m_mapIndex = -1;
		m_picMap = NULL;
		m_texMap = nil;
		m_switchAniGroup = nil;
		m_mapData = nil;
		m_lbTime = NULL;
		m_lbTitle = NULL;
		m_lbTitleBg = NULL;
		m_orders = [[NSMutableArray alloc] init];
		m_ordersOfMapscenesAndMapanimations = [[NSMutableArray alloc] init];
		m_frameRunRecordsOfMapAniGroups = [[NSMutableArray alloc] init];
		m_frameRunRecordsOfMapSwitch = [[NSMutableArray alloc] init];
		this->m_bBattleBackground = false;
		this->m_bNeedShow = true;
		this->m_ndBlockTimer = NULL;
		this->m_ndTitleTimer = NULL;
		this->switchSpriteNode=NULL;
		this->isAutoBossFight = false;
		roadBlockTimeCount=0;
		titleAlpha=0;
		subnode = NDNode::Node();
		subnode->SetContentSize(NDDirector::DefaultDirector()->GetWinSize());
//		m_blockTimerTag=-1;
//		m_titleTimerTag=-1;
		showTitle=false;
		switch_type=SWITCH_NONE;
		m_TreasureBox=NULL;
		box_status=BOX_NONE;
		m_leRoadSign = NULL;
	}
	
	NDMapLayer::~NDMapLayer()
	{
		[m_orders release];
		[m_ordersOfMapscenesAndMapanimations release];
		[m_frameRunRecordsOfMapAniGroups release];
		[m_frameRunRecordsOfMapSwitch release];
		[m_texMap release];
		[m_mapData release];
		[m_switchAniGroup release];
		delete m_picMap;
		SAFE_DELETE(subnode);
		if(m_ndBlockTimer)
		{
			m_ndBlockTimer->KillTimer(this,blockTimerTag);
			SAFE_DELETE(m_ndBlockTimer);
		}
						
		if(m_ndTitleTimer)
		{
			m_ndTitleTimer->KillTimer(this,titleTimerTag);
			SAFE_DELETE(m_ndTitleTimer);
		}
		
		if(m_TreasureBox)
		{
			SAFE_DELETE(m_TreasureBox);
		}
		
		SAFE_DELETE(m_leRoadSign);
	}
	
	void NDMapLayer::replaceMapData(int mapId,int center_x,int center_y)
	{
		[m_mapData release];
		[m_orders release];
		m_orders = [[NSMutableArray alloc] init];
		[m_texMap release];

		delete m_picMap;
		NSString *mapPath = [NSString stringWithUTF8String:NDPath::GetMapPath().c_str()]; 
		NSString *mapFile = [NSString stringWithFormat:@"%@map_%d.map", mapPath, mapId];
		
		m_mapData = [[NDMapData alloc] initWithFile:[NSString stringWithUTF8String:[mapFile UTF8String]]];
		if (m_mapData) 
		{
			this->SetContentSize(CGSizeMake(m_mapData.columns * m_mapData.unitSize, m_mapData.rows * m_mapData.unitSize));
			
			this->MakeOrdersOfMapscenesAndMapanimations();
			this->MakeFrameRunRecords();
						
			CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
			m_screenCenter = ccp(winSize.width / 2, this->GetContentSize().height - winSize.height / 2);
			[this->m_ccNode setPosition:ccp(0, 0)];	
			
			
			m_texMap = [[CCTexture2D alloc] initWithContentSize:winSize];
			m_picMap = new NDPicture();
			m_picMap->SetTexture(m_texMap);
			
			this->ReflashMapTexture(ccp(-winSize.width / 2, -winSize.height / 2), m_screenCenter);
			m_areaCamarkSplit = IntersectionAreaNone;
			m_ptCamarkSplit = ccp(0, 0);
		}
		this->SetScreenCenter(ccp(center_x,center_y));
		
		ShowRoadSign(false);
	}
	
	void NDMapLayer::Initialization(const char* mapFile)
	{
		NDLayer::Initialization();
		this->SetTouchEnabled(true);
		
		m_switchAniGroup = [[NDAnimationGroupPool defaultPool] addObjectWithModelId:8];
		
		m_mapData = [[NDMapData alloc] initWithFile:[NSString stringWithUTF8String:mapFile]];
		if (m_mapData) 
		{
			this->SetContentSize(CGSizeMake(m_mapData.columns * m_mapData.unitSize, m_mapData.rows * m_mapData.unitSize));
			
			this->MakeOrdersOfMapscenesAndMapanimations();
			this->MakeFrameRunRecords();
			
			
			CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
			m_screenCenter = ccp(winSize.width / 2, this->GetContentSize().height - winSize.height / 2);
			[this->m_ccNode setPosition:ccp(0, 0)];	
			
			
			m_texMap = [[CCTexture2D alloc] initWithContentSize:winSize];
			m_picMap = new NDPicture();
			m_picMap->SetTexture(m_texMap);
			
			this->ReflashMapTexture(ccp(-winSize.width / 2, -winSize.height / 2), m_screenCenter);
			m_areaCamarkSplit = IntersectionAreaNone;
			m_ptCamarkSplit = ccp(0, 0);
		}
		
		this->DidFinishLaunching();		
	}
	
	void NDMapLayer::Initialization(int mapIndex)
	{
		m_mapIndex = mapIndex;
		NSString *mapPath = [NSString stringWithUTF8String:NDPath::GetMapPath().c_str()]; 
		NSString *mapFile = [NSString stringWithFormat:@"%@map_%d.map", mapPath, mapIndex];
		this->Initialization([mapFile UTF8String]);	
		titleAlpha=0;
	}
	
	int NDMapLayer::GetMapIndex()
	{
		return m_mapIndex;
	}
	
	void NDMapLayer::DidFinishLaunching()
	{
		//cpLog(LOG_DEBUG, "load map data complete!");
	}
	
	void NDMapLayer::refreshTitle()
	{
		if(m_lbTitle&&m_lbTitleBg)
		{
			if(showTitle){
				if(titleAlpha<255){
                    if(m_lbTitle&&m_lbTitleBg){
                        int x=NDDirector::DefaultDirector()->GetWinSize().width/2-150;
                        int y=60;
                        //NDLog(@"x:%d,y:%d",x,y);
                        m_lbTitleBg->SetFrameRect(CGRectMake(NDDirector::DefaultDirector()->GetWinSize().width/2-210, y, 420, 60));
                        //m_lbTitleBg->draw();
                        m_lbTitle->SetFrameRect(CGRectMake(x, y, 300, 60));
                    

                        NDPicture* p1 = m_lbTitle->GetPicture();
                        
                        p1->SetColor(ccc4(titleAlpha,titleAlpha,titleAlpha,titleAlpha));
                        
                        NDPicture* p2 = m_lbTitleBg->GetPicture();
                        
                        p2->SetColor(ccc4(titleAlpha,titleAlpha,titleAlpha,titleAlpha));
                        
                        titleAlpha+=5;
                    }
				}else if(!m_ndTitleTimer) {
					this->m_ndTitleTimer = new NDTimer;
					this->m_ndTitleTimer->SetTimer(this, titleTimerTag, 3.0f);

				}
			}else {
				if(titleAlpha>=0){
                    if(m_lbTitle&&m_lbTitleBg){
                        int x=NDDirector::DefaultDirector()->GetWinSize().width/2-150;
                        int y=60;
                        //NDLog(@"x:%d,y:%d",x,y);
                        m_lbTitleBg->SetFrameRect(CGRectMake(NDDirector::DefaultDirector()->GetWinSize().width/2-210, y, 420, 60));
                        //m_lbTitleBg->draw();
                        m_lbTitle->SetFrameRect(CGRectMake(x, y, 300, 60));
                        
                        
                        NDPicture* p1 = m_lbTitle->GetPicture();
                        
                        p1->SetColor(ccc4(titleAlpha,titleAlpha,titleAlpha,titleAlpha));
                        
                        NDPicture* p2 = m_lbTitleBg->GetPicture();
                        
                        p2->SetColor(ccc4(titleAlpha,titleAlpha,titleAlpha,titleAlpha));
                        
                        titleAlpha-=15;
                    }
				}else{
                    m_lbTitle->RemoveFromParent(true);
                    m_lbTitleBg->RemoveFromParent(true);
                    m_lbTitle=NULL;
                    m_lbTitleBg=NULL;
                }
			}

		}
	}
	
	
	void NDMapLayer::ShowTreasureBox()
	{
		if(!m_TreasureBox)
		{
			box_status=BOX_SHOWING;
			m_TreasureBox = new NDSprite;
			NSString* aniPath=[NSString stringWithUTF8String:NDEngine::NDPath::GetAnimationPath().c_str()];
			m_TreasureBox->Initialization([[NSString stringWithFormat:@"%@treasure_box.spr", aniPath] UTF8String]);
			m_TreasureBox->SetPosition(CGPointMake(NDPlayer::defaultHero().GetPosition().x+64,NDPlayer::defaultHero().GetPosition().y));

			m_TreasureBox->SetCurrentAnimation(0, false);
			this->AddChild(m_TreasureBox);
		}
	}
	
	void NDMapLayer::OpenTreasureBox()
	{
		if(m_TreasureBox)
		{
			NDTransData data(_MSG_INSTANCING_BOX_AWARD_LIST);

			NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
			
			m_TreasureBox->SetCurrentAnimation(2, false);
			box_status=BOX_OPENING;
		}
	}
	
	void NDMapLayer::ShowTitle(int name_row,int name_col)
	{
		showTitle=true;
		titleAlpha=0;
		if(!m_lbTitle)
		{
			m_lbTitle = new NDUIImage;
			m_lbTitle->Initialization();
			NDPicture* picture= NDPicturePool::DefaultPool()->AddPicture([[NSString stringWithFormat:@"%@map_title.png", IMAGE_PATH] UTF8String]);
			//picture->SetColor(ccc4(0, 0, 0,0));
			int col=name_col;
			int row=name_row;
			picture->Cut(CGRectMake(col*300,row*60,300,60));
			m_lbTitle->SetPicture(picture, true);
		}
		
		if(!m_lbTitleBg)
		{
			m_lbTitleBg = new NDUIImage;
			m_lbTitleBg->Initialization();
			NDPicture* bg = NDPicturePool::DefaultPool()->AddPicture([[NSString stringWithFormat:@"%@map_title_bg.png", IMAGE_PATH] UTF8String]);
			m_lbTitleBg->SetPicture(bg, true);
		}
		
		if (!m_lbTitleBg->GetParent()) 
		{
			this->GetParent()->AddChild(m_lbTitleBg);
		}

		if (!m_lbTitle->GetParent()) 
		{
			this->GetParent()->AddChild(m_lbTitle);
		}
		//m_lbTitle->draw();
	}
	
	void NDMapLayer::showSwitchSprite(MAP_SWITCH_TYPE type)
	{
		this->switch_type=type;
		NSString* aniPath=[NSString stringWithUTF8String:NDEngine::NDPath::GetAnimationPath().c_str()];
		if(switchSpriteNode){
			switchSpriteNode->RemoveFromParent(true);
			switchSpriteNode=NULL;
		}
		switchSpriteNode = new CUISpriteNode;
		switchSpriteNode->Initialization();
		switchSpriteNode->ChangeSprite([[NSString stringWithFormat:@"%@scene_switch.spr", aniPath] UTF8String]);
		switchSpriteNode->SetFrameRect(CGRectMake(0,0,NDDirector::DefaultDirector()->GetWinSize().width,NDDirector::DefaultDirector()->GetWinSize().height));
		this->GetParent()->AddChild(switchSpriteNode);	
	}
	bool NDMapLayer::isTouchTreasureBox(CGPoint touchPoint){
		if(m_TreasureBox)
		{
			CGRect rect=CGRectMake(m_TreasureBox->GetPosition().x-m_TreasureBox->GetWidth()/2, m_TreasureBox->GetPosition().y-m_TreasureBox->GetHeight(), m_TreasureBox->GetWidth(), m_TreasureBox->GetHeight());
			if (touchPoint.x>=rect.origin.x
				&&touchPoint.x<=rect.origin.x+rect.size.width
				&&touchPoint.y>=rect.origin.y
				&&touchPoint.y<=rect.origin.y+rect.size.height)
			{
				return true;
			}else{
				return false;
			}
		}else{
			return false;
		}
	}
	void NDMapLayer::RefreshBoxAnimation()
	{
		if(m_TreasureBox)
		{
			if(box_status==BOX_SHOWING){
				if (m_TreasureBox->IsAnimationComplete())
				{
					m_TreasureBox->SetCurrentAnimation(1, false);
					box_status=BOX_CLOSE;
				}
			}else if(box_status==BOX_OPENING){
				if (m_TreasureBox->IsAnimationComplete())
				{
					m_TreasureBox->SetCurrentAnimation(3, false);
					box_status=BOX_OPENED;
				}
			}
		}
	}
	
	void NDMapLayer::draw()
	{
		//PerformanceTestName("地图层draw");
		
		if (m_mapData && m_bNeedShow) 
		{
			//COCOS2D场景渲染时颜色数组默认被设置启用
			//在此要关闭
			//glDisableClientState(GL_COLOR_ARRAY);
			//NDLog(@"start draw map");
			//PerformanceTestBeginName("地表");
			//draw map tiles.......
			this->DrawMapTiles();
			//PerformanceTestEndName("背景");
			this->DrawBgs();
			//PerformanceTestBeginName("场景动画");
			//draw map scenes and animations......
			this->DrawScenesAndAnimations();
			//PerformanceTestEndName("场景动画");
			//NDLog(@"done draw map");
			//启用颜色数组
			//glEnableClientState(GL_COLOR_ARRAY);
			if(switchSpriteNode)
			{
				if (switchSpriteNode->isAnimationComplete())
				{
					switchSpriteNode->RemoveFromParent(true);
					switchSpriteNode=NULL;
					switch(switch_type){
						case SWITCH_NONE:
							break;
						case SWITCH_TO_BATTLE:
							BattleMgrObj.showBattleScene();
							break;
						case SWITCH_BACK_FROM_BATTLE:
							break;
					}
					switch_type=SWITCH_NONE;
				}

			}
			this->refreshTitle();
			this->RefreshBoxAnimation();
//			if(m_TreasureBox){
//				m_TreasureBox->RunAnimation(true);
//			}
			if (this->roadBlockTimeCount>0&&!m_bBattleBackground) 
			{
				//NDLog(@"showTime");
				if(!m_lbTime)
				{
					m_lbTime = new NDUILabel;
					m_lbTime->Initialization();
					m_lbTime->SetFontSize(15);

				}
				int mi=this->roadBlockTimeCount/60;
				NSString* str_mi;
				if(mi<10)
				{
					str_mi = [NSString stringWithFormat:@"0%d",mi];
				}else {
					str_mi = [NSString stringWithFormat:@"%d",mi];
				}

				int se=this->roadBlockTimeCount%60;
				NSString* str_se;
				if(se<10)
				{
					str_se = [NSString stringWithFormat:@"0%d",se];
				}else {
					str_se = [NSString stringWithFormat:@"%d",se];
				}
				NSString* str_time=[NSString stringWithFormat:@"%@:%@",str_mi,str_se];
				m_lbTime->SetText([str_time UTF8String]);

				CGSize size = getStringSize([str_time UTF8String], 30);
				if (!m_lbTime->GetParent()&&subnode) 
				{
					subnode->AddChild(m_lbTime);
				}
				
				m_lbTime->SetFontColor(ccc4(255,0,0,255));
				m_lbTime->SetFontSize(30);
				int x=m_screenCenter.x-(size.width)/2;
				int y=m_screenCenter.y - GetContentSize().height-(size.height)/2+NDDirector::DefaultDirector()->GetWinSize().height;
				//NDLog(@"x:%d,y:%d",x,y);
				m_lbTime->SetFrameRect(CGRectMake(x, y, size.width, size.height+5));
				m_lbTime->draw();
				
			}
			
			if (m_leRoadSign)
			{
				m_leRoadSign->Run(this->GetContentSize());
			}
		}	
		
	}
	
	void NDMapLayer::SetBattleBackground(bool bBattleBackground)
	{
		this->m_bBattleBackground = bBattleBackground;
		GameScene* gameScene =  (GameScene*)this->GetParent();
		gameScene->SetMiniMapVisible(!bBattleBackground);
	}
	
	void NDMapLayer::SetNeedShowBackground(bool bNeedShow)
	{
		this->m_bNeedShow = bNeedShow;
//		GameScene* gameScene =  (GameScene*)this->GetParent();
//		gameScene->SetMiniMapVisible(!bBattleBackground);
	}
	
	void NDMapLayer::MapSwitchRefresh()
	{
		this->MakeOrdersOfMapscenesAndMapanimations();
		
		[m_frameRunRecordsOfMapSwitch release];
		
		m_frameRunRecordsOfMapSwitch = [[NSMutableArray alloc] init];
		
		for (int i = 0; i < (int)[m_mapData.switchs count]; i++) 
		{
			NDFrameRunRecord *frameRunRecord = [[NDFrameRunRecord alloc] init];
			[m_frameRunRecordsOfMapSwitch addObject:frameRunRecord];
			[frameRunRecord release];
		}
	}
	
	void NDMapLayer::DrawMapTiles()
	{
		//draw map tile
		CGSize winSize =  NDDirector::DefaultDirector()->GetWinSize();	
		CGPoint ptDraw = ccp(m_screenCenter.x - winSize.width / 2, m_screenCenter.y + winSize.height / 2 - GetContentSize().height);
		if (m_areaCamarkSplit == IntersectionAreaNone) 
		{
			[m_texMap ndDrawInRect:CGRectMake(ptDraw.x, ptDraw.y, winSize.width, winSize.height)];
		}
		else 
		{
			CGRect rect1 = CGRectMake(0, 0, m_ptCamarkSplit.x, m_ptCamarkSplit.y);
			CGRect rect2 = CGRectMake(rect1.size.width, 0,  winSize.width - rect1.size.width, rect1.size.height);
			CGRect rect3 = CGRectMake(0, rect1.size.height, rect1.size.width, winSize.height - rect1.size.height);
			CGRect rect4 = CGRectMake(rect1.size.width, rect1.size.height, rect2.size.width, rect3.size.height);
			
			if (rect1.size.width != 0 && rect1.size.height != 0) 
			{
				m_picMap->Cut(rect1);
				m_picMap->DrawInRect(CGRectMake(ptDraw.x + winSize.width - m_ptCamarkSplit.x, ptDraw.y + winSize.height - m_ptCamarkSplit.y, rect1.size.width, rect1.size.height));			
			}
			if (rect2.size.width != 0 && rect2.size.height != 0) 
			{
				m_picMap->Cut(rect2);
				m_picMap->DrawInRect(CGRectMake(ptDraw.x, ptDraw.y + winSize.height - m_ptCamarkSplit.y, rect2.size.width + 1, rect2.size.height + 1));
			}
			if (rect3.size.width != 0 && rect3.size.height != 0) 
			{
				m_picMap->Cut(rect3);
				m_picMap->DrawInRect(CGRectMake(ptDraw.x + winSize.width - m_ptCamarkSplit.x, ptDraw.y, rect3.size.width, rect3.size.height + 1));
			}
			if (rect4.size.width != 0 && rect4.size.height != 0) 
			{
				m_picMap->Cut(rect4);
				m_picMap->DrawInRect(CGRectMake(ptDraw.x, ptDraw.y, rect4.size.width + 1, rect4.size.height + 1));
			}
		}
		
//		DrawLine(ccp(ptDraw.x + 0, ptDraw.y + m_ptCamarkSplit.y), ccp(ptDraw.x + 480, ptDraw.y + m_ptCamarkSplit.y), ccc4(255, 0, 0, 255), 1);
//		DrawLine(ccp(ptDraw.x + m_ptCamarkSplit.x, ptDraw.y + 0), ccp(ptDraw.x + m_ptCamarkSplit.x, ptDraw.y + 320), ccc4(255, 0, 0, 255), 1);		
	}
	
	void NDMapLayer::DrawBgs()
	{
		CGSize winSize			= NDDirector::DefaultDirector()->GetWinSize();
		CGRect scrRect			= CGRectMake(m_screenCenter.x - winSize.width / 2, m_screenCenter.y - winSize.height / 2, winSize.width, winSize.height);
		
		NSUInteger orderCount = [m_mapData.bgTiles count];
		for (NSUInteger i = 0; i < orderCount; i++) 
		{
			NDTile *tile = [m_mapData.bgTiles objectAtIndex:i];
			if(tile)
			{
				CGRect intersectRect	= CGRectZero;
				CGRect drawRect			= CGRectZero;
				if(GetIntersectRect(scrRect, tile.drawRect, intersectRect) &&
				   GetRectPercent(tile.drawRect, intersectRect, drawRect))
				{
					[tile drawSubRect:drawRect];
				}
			}
		}
	}
	
	void NDMapLayer::DrawScenesAndAnimations()
	{	
		this->MakeOrders();
		
		NSUInteger orderCount = [m_orders count],
				   sceneTileCount = [m_mapData.sceneTiles count],
				   aniGroupCount = [m_mapData.animationGroups count],
				   switchCount = [m_mapData.switchs count];
	
		//PerformanceTestPerFrameBeginName(" NDMapLayer::DrawScenesAndAnimations");
		
		for (NSUInteger i = 0; i < orderCount; i++) 
		{
			//PerformanceTestPerFrameBeginName(" NDMapLayer::DrawScenesAndAnimations inner");
			
			NSDictionary *dict = [m_orders objectAtIndex:i];
			NSUInteger index = (NSUInteger)[[dict objectForKey:@"index"] intValue];		
			
			if (index < sceneTileCount) //布景
			{
				//PerformanceTestPerFrameBeginName("布景");
				NDTile *tile = [m_mapData.sceneTiles objectAtIndex:index];
				if (tile) 
				{
					if (this->isMapRectIntersectScreen(tile.drawRect)) 
					{
						[tile draw];
					}				
				}
				//PerformanceTestPerFrameEndName("布景");		
			}
			else if (m_bBattleBackground) // 战斗状态，不绘制其他地表元素
			{
				continue;
			}
			else if (index < sceneTileCount + aniGroupCount)//地表动画
			{
				//PerformanceTestPerFrameBeginName("地表动画");
				index -= sceneTileCount;
				
				NSDictionary *dictAniGroupParam = [m_mapData.aniGroupParams objectAtIndex:index];
				NDAnimationGroup *aniGroup = [m_mapData.animationGroups objectAtIndex:index];
				NSArray *frameRunRecordList = [m_frameRunRecordsOfMapAniGroups objectAtIndex:index];
				
				aniGroup.reverse = [[dictAniGroupParam objectForKey:@"reverse"] boolValue];
				aniGroup.position = ccp([[dictAniGroupParam objectForKey:@"positionX"] intValue], [[dictAniGroupParam objectForKey:@"positionY"] intValue]);
				aniGroup.runningMapSize = CGSizeMake([[dictAniGroupParam objectForKey:@"mapSizeW"] intValue], [[dictAniGroupParam objectForKey:@"mapSizeH"] intValue]);
				
				NSUInteger aniCount = [aniGroup.animations count];
				
				for (NSUInteger j = 0; j < aniCount; j++) 
				{
					NDFrameRunRecord *frameRunRecord = [frameRunRecordList objectAtIndex:j];
					NDAnimation *animation = [aniGroup.animations objectAtIndex:j];
					
					if (this->isMapRectIntersectScreen([animation getRect])) 
					{					
						[animation runWithRunFrameRecord:frameRunRecord draw:YES];
					}
					else 
					{
						[animation runWithRunFrameRecord:frameRunRecord draw:NO];
					}
				}	
				//PerformanceTestPerFrameEndName("地表动画");	
			}		
			else if (index < sceneTileCount + aniGroupCount + switchCount)//切屏点
			{
				//PerformanceTestPerFrameBeginName("切屏点");
				index -= [m_mapData.sceneTiles count] + [m_mapData.animationGroups count];
				
				NDMapSwitch *mapSwitch = [m_mapData.switchs objectAtIndex:index];
				NDFrameRunRecord *frameRunRecord = [m_frameRunRecordsOfMapSwitch objectAtIndex:index];
				
				m_switchAniGroup.reverse = NO;
				
				CGPoint pos = ccp(mapSwitch.x * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET, mapSwitch.y * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET);
				
				m_switchAniGroup.position = pos;

				m_switchAniGroup.runningMapSize = this->GetContentSize();
				
				if ([m_switchAniGroup.animations count] > 0) 
				{
					NDAnimation *animation = [m_switchAniGroup.animations objectAtIndex:0];
					if (this->isMapRectIntersectScreen([animation getRect])) 
					{					
						[animation runWithRunFrameRecord:frameRunRecord draw:YES];
						[mapSwitch draw];
					}
					else 
					{
						//[animation runWithRunFrameRecord:frameRunRecord draw:NO];
					}
				}	
				//PerformanceTestPerFrameEndName("切屏点");
			}
			else //精灵
			{
				//PerformanceTestPerFrameBeginName("精灵");
				index -= sceneTileCount + aniGroupCount + switchCount;
				
				if (index < 0 || index >= this->GetChildren().size()) 
					continue;
				
				NDNode* node = this->GetChildren().at(index);
				if (node->IsKindOfClass(RUNTIME_CLASS(NDSprite))) 
				{
					NDSprite* sprite = (NDSprite*)node;
					bool bSet = this->isMapRectIntersectScreen(sprite->GetSpriteRect());
					//NDManualRole* manualRole = nil; 放到NDManualRole中处理
//					
//					if (sprite->IsKindOfClass(RUNTIME_CLASS(NDManualRole))) 
//					{
//						manualRole = (NDManualRole*)node;
//						bSet = !manualRole->IsInState(USERSTATE_STEALTH);
//						if (bSet) 
//						{ // 未隐身
//							if (manualRole->isTransformed()) 
//							{
//								bSet = false;
//							}
//						}			
//						
//					}
					
					sprite->BeforeRunAnimation(bSet);
					
					if (bSet)
					{
						sprite->RunAnimation(sprite->DrawEnabled());						
					}
					//sprite->RunAnimation(bSet);
				}
				//PerformanceTestPerFrameEndName("精灵");
			}
			
			//PerformanceTestPerFrameEndName(" NDMapLayer::DrawScenesAndAnimations inner");
		}
		
		//PerformanceTestPerFrameEndName(" NDMapLayer::DrawScenesAndAnimations");
	}	
	
	bool NDMapLayer::TouchBegin(NDTouch* touch)
	{
		return true;
	}
	
	void NDMapLayer::TouchEnd(NDTouch* touch)
	{	
		
	}
	
	void NDMapLayer::TouchCancelled(NDTouch* touch)
	{
		
	}
	
	void NDMapLayer::TouchMoved(NDTouch* touch)
	{
		
	}
	
	CGPoint NDMapLayer::ConvertToMapPoint(CGPoint screenPoint)
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		return ccpAdd(ccpSub(screenPoint, CGPointMake(winSize.width / 2, winSize.height / 2)), m_screenCenter);
	}
	
	bool NDMapLayer::isMapPointInScreen(CGPoint mapPoint)
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		return CGRectContainsPoint(CGRectMake(m_screenCenter.x - winSize.width / 2, m_screenCenter.y - winSize.height / 2, winSize.width, winSize.height), mapPoint);
	}
	
	bool NDMapLayer::isMapRectIntersectScreen(CGRect mapRect)
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		CGRect scrRect = CGRectMake(m_screenCenter.x - winSize.width / 2, m_screenCenter.y - winSize.height / 2, winSize.width, winSize.height);
		return CGRectIntersectsRect(scrRect, mapRect);
	}
	
	void NDMapLayer::SetPosition(CGPoint p)
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		if (p.x > 0)
			p.x = 0;
		if (p.x < winSize.width - this->GetContentSize().width)
			p.x = winSize.width - this->GetContentSize().width;
		
		if (p.y > 0) 
			p.y = 0;
		if (p.y < winSize.height - this->GetContentSize().height) 
			p.y = winSize.height - this->GetContentSize().height;
		
		[this->m_ccNode setPositionInPixels:p];
	}
	
	bool NDMapLayer::SetScreenCenter(CGPoint p)
	{
		if(this->m_bBattleBackground){
			return false;
		}
		
		bool bOverBoder = false;
		int width = this->GetContentSize().width;
		int height = this->GetContentSize().height;
		
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		if (p.x > width - winSize.width / 2)
		{
			p.x = width - winSize.width / 2;
			bOverBoder = true;
		}
		if (p.x < winSize.width / 2)
		{
			p.x = winSize.width / 2;
			bOverBoder = true;
		}
		
		if (p.y > height - winSize.height / 2)
		{
			p.y = height - winSize.height / 2;
			bOverBoder = true;
		}
		if (p.y < winSize.height / 2)
		{
			p.y = winSize.height / 2;
			bOverBoder = true;
		}
		
		//this->ReflashMapTexture(m_screenCenter, p);
		
		//modify yay
		CGPoint backOff = ccpSub(p,m_screenCenter);
		[m_mapData moveBackGround:backOff.x moveY:backOff.y];	
		//[m_mapData moveBackGround:backOff.x,backOff.y];
		
		m_screenCenter = p;
		//NDLog(@"center:%f,%f",p.x,p.y);
		this->SetPosition(CGPointMake(winSize.width / 2 - p.x, winSize.height / 2 + p.y - height));
		
		return bOverBoder;
	}	
	
	CGPoint NDMapLayer::GetScreenCenter()
	{
		return m_screenCenter;
	}
	
	NDMapData *NDMapLayer::GetMapData()
	{
		return m_mapData;
	}
	
	void NDMapLayer::setStartRoadBlockTimer(int time,int x,int y)
	{
		if(!m_ndBlockTimer){
			this->m_ndBlockTimer = new NDTimer;
		}
		this->m_ndBlockTimer->SetTimer(this, blockTimerTag, 1.0f);
		this->roadBlockTimeCount=time;
		
		if(m_mapData)
		{
			[m_mapData setRoadBlock:x roadBlockY:y];
		}
	}
	
	void NDMapLayer::setAutoBossFight(bool isAuto)
	{
		this->isAutoBossFight = isAuto;
		if(isAuto)
		{
			this->walkToBoss();
		}else {
			NDPlayer::defaultHero().stopMoving(false, false);
		}

	}
	
	void NDMapLayer::walkToBoss()
	{
		NDMonster* boss = NDMapMgrObj.GetBoss();
		if (boss!=NULL)
		{
			CGPoint point = boss->GetPosition();
			NDLog(@"boss:%d,%d",point.x,point.y);
			NDPlayer::defaultHero().Walk(point, SpriteSpeedStep4);
		}
	}
	
	void NDMapLayer::OnTimer(OBJID tag)
	{
		if(tag==blockTimerTag)
		{
			this->roadBlockTimeCount--;
			//NDLog(@"tag:%d,count:%d",tag,this->roadBlockTimeCount);
			if(this->roadBlockTimeCount<=0)
			{
				[this->m_mapData setRoadBlock:-1 roadBlockY:-1];
				this->roadBlockTimeCount=0;
				this->m_ndBlockTimer->KillTimer(this, blockTimerTag);
				this->m_ndBlockTimer=NULL;
				
				if(this->isAutoBossFight)
				{
					this->walkToBoss();
				}
			}
		}else if(tag==titleTimerTag){
			this->m_ndTitleTimer->KillTimer(this, titleTimerTag);
			this->m_ndTitleTimer=NULL;
			if(NDMapMgrObj.GetMotherMapID()/100000000!=9){
				this->showTitle=false;
			}
		}
	}
	
	void NDMapLayer::ReplaceMapTexture(CCTexture2D* tex, CGRect replaceRect, CGRect tilesRect)
	{
		if (replaceRect.size.width == 0 || replaceRect.size.height == 0) 
			return;
		
		if (tex)//&& replaceRect.size == tileRect.size) 
		{
			int rowStart = tilesRect.origin.y / m_mapData.unitSize - 1;
			int rowEnd   = (tilesRect.origin.y + tilesRect.size.height) / m_mapData.unitSize + 1;
			int colStart = tilesRect.origin.x / m_mapData.unitSize - 1;
			int colEnd   = (tilesRect.origin.x + tilesRect.size.width) / m_mapData.unitSize + 1;			
			
			int x = replaceRect.origin.x;
			int y = replaceRect.origin.y;
			
			CustomCCTexture2D *newTile = [[CustomCCTexture2D alloc] init];
			for (int r = rowStart; r <= rowEnd; r++)
				for (int c = colStart; c <= colEnd; c++) 
				{
					CustomCCTexture2D *tile = [m_mapData getTileAtRow:r column:c];					 
					if (tile) 
					{
						newTile.texture = tile.texture;
						newTile.horizontalReverse = tile.horizontalReverse;
						newTile.reverseRect = tile.cutRect;
						
						CGRect rect; IntersectionArea area;
						RectIntersectionRect(tile.drawRect, tilesRect, rect, area);	
						if (area != IntersectionAreaNone) 
						{
							rect = CGRectMake(rect.origin.x - tile.drawRect.origin.x, rect.origin.y - tile.drawRect.origin.y, rect.size.width, rect.size.height);
							newTile.cutRect	= CGRectMake(tile.cutRect.origin.x + rect.origin.x, tile.cutRect.origin.y + rect.origin.y, rect.size.width, rect.size.height);
							newTile.drawRect = CGRectMake(x, y, rect.size.width, rect.size.height);
							[tex replaceWithCustomTexture:newTile commit:YES];
							
							x += rect.size.width;
							if (x >= replaceRect.origin.x + replaceRect.size.width) 
							{
								x = replaceRect.origin.x;
								y += rect.size.height;
							}
							
						}																
					}					
				}	
			[newTile release];
		}
	}
	
	void NDMapLayer::ReflashMapTexture(CGPoint oldScreenCenter, CGPoint newScreenCenter)
	{	
		if (oldScreenCenter.x == newScreenCenter.x && oldScreenCenter.y == newScreenCenter.y) 
			return;
		
		if (m_texMap) 
		{		
			CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
			
			CGRect oldRect = CGRectMake(oldScreenCenter.x - winSize.width / 2, oldScreenCenter.y - winSize.height / 2, 
										winSize.width, winSize.height);
			CGRect newRect = CGRectMake(newScreenCenter.x - winSize.width / 2, newScreenCenter.y - winSize.height / 2, 
										winSize.width, winSize.height);
			
			CGRect rect;
			RectIntersectionRect(oldRect, newRect, rect, m_areaCamarkSplit);
			if (m_areaCamarkSplit == IntersectionAreaNone) 
			{
				m_ptCamarkSplit = ccp(0, 0);
				ReplaceMapTexture(m_texMap, 
								  CGRectMake(0, 0, winSize.width, winSize.height), 
								  CGRectMake(newRect.origin.x, newRect.origin.y, winSize.width, winSize.height));
			}
			else 
			{
				CGRect nRect = CGRectZero;
				if (newScreenCenter.x > oldScreenCenter.x) 
				{
					nRect = CGRectMake(oldScreenCenter.x + winSize.width / 2, 
									   oldScreenCenter.y - winSize.height / 2, 
									   newScreenCenter.x - oldScreenCenter.x, winSize.height);
				}
				else 
				{
					nRect = CGRectMake(newScreenCenter.x - winSize.width / 2, 
									   oldScreenCenter.y - winSize.height / 2, 
									   oldScreenCenter.x - newScreenCenter.x, winSize.height);
				}
				ScrollHorizontal(newScreenCenter.x - oldScreenCenter.x, nRect);
				
				if (newScreenCenter.y > oldScreenCenter.y) 
				{
					nRect = CGRectMake(newScreenCenter.x - winSize.width / 2, 
									   oldScreenCenter.y + winSize.height / 2, 
									   winSize.width, newScreenCenter.y - oldScreenCenter.y);
				}
				else 
				{
					nRect = CGRectMake(newScreenCenter.x - winSize.width / 2, 
									   newScreenCenter.y - winSize.height / 2, 
									   winSize.width, oldScreenCenter.y - newScreenCenter.y);
				}
				ScrollVertical(newScreenCenter.y - oldScreenCenter.y, nRect);			
				
			}
		}
	}
	
	void NDMapLayer::ScrollSplit(int x, int y)
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		m_ptCamarkSplit.x += x;
		if (m_ptCamarkSplit.x < 0) 
			m_ptCamarkSplit.x += winSize.width;
		if (m_ptCamarkSplit.x >= winSize.width) 
			m_ptCamarkSplit.x -= winSize.width;
		
		m_ptCamarkSplit.y += y;
		if (m_ptCamarkSplit.y < 0) 
			m_ptCamarkSplit.y += winSize.height;
		if (m_ptCamarkSplit.y >= winSize.height) 
			m_ptCamarkSplit.y -= winSize.height;
	}
	
	void NDMapLayer::ScrollVertical(int y, CGRect newRect)
	{
		if (y == 0)	return;
		
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		if (y < 0 && abs(y) > m_ptCamarkSplit.y && m_ptCamarkSplit.y > 0 && m_ptCamarkSplit.y < winSize.height) 
		{
			int y1 = -m_ptCamarkSplit.y;
			int y2 = m_ptCamarkSplit.y + y;
			
			CGRect newRect1 = CGRectMake(newRect.origin.x, newRect.origin.y - y2, newRect.size.width, -y1);
			ScrollVertical(y1, newRect1);
			
			CGRect newRect2 = CGRectMake(newRect.origin.x, newRect.origin.y, newRect.size.width, y2);
			ScrollVertical(y2, newRect2);
			
			return ;
		}
		
		if (y > 0 && abs(y) > winSize.height - m_ptCamarkSplit.y && m_ptCamarkSplit.y > 0 && m_ptCamarkSplit.y < winSize.height) 
		{
			int y1 = winSize.height - m_ptCamarkSplit.y;
			int y2 = y - y1;
			
			CGRect newRect1 = CGRectMake(newRect.origin.x, newRect.origin.y, newRect.size.width, y1);
			ScrollVertical(y1, newRect1);
			
			CGRect newRect2 = CGRectMake(newRect.origin.x, newRect.origin.y + y1, newRect.size.width, y2);
			ScrollVertical(y2, newRect2);
			
			return;
		}
		
		if (y < 0) 
			ScrollSplit(0, y);
		
		ReplaceMapTexture(m_texMap, 
						  CGRectMake(0, m_ptCamarkSplit.y, m_ptCamarkSplit.x, abs(y)), 
						  CGRectMake(newRect.origin.x + winSize.width - m_ptCamarkSplit.x, newRect.origin.y, m_ptCamarkSplit.x, abs(y)));
		ReplaceMapTexture(m_texMap, 
						  CGRectMake(m_ptCamarkSplit.x, m_ptCamarkSplit.y, winSize.width - m_ptCamarkSplit.x, abs(y)), 
						  CGRectMake(newRect.origin.x, newRect.origin.y, winSize.width - m_ptCamarkSplit.x, abs(y)));
		
		if (y > 0) 
			ScrollSplit(0, y);		
	}
	
	void NDMapLayer::ScrollHorizontal(int x, CGRect newRect)
	{
		if (x == 0) return ;
		
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		if (x < 0 && abs(x) > m_ptCamarkSplit.x && m_ptCamarkSplit.x > 0 && m_ptCamarkSplit.x < winSize.width) 
		{
			int x1 = -m_ptCamarkSplit.x;
			int x2 = m_ptCamarkSplit.x + x;
			
			CGRect newRect1 = CGRectMake(newRect.origin.x - x2, newRect.origin.y, -x1, newRect.size.height);
			ScrollHorizontal(x1, newRect1);
			
			CGRect newRect2 = CGRectMake(newRect.origin.x, newRect.origin.y, -x2, newRect.size.height);
			ScrollHorizontal(x2, newRect2);
			
			return;
		}
		
		if (x > 0 && abs(x) > winSize.width - m_ptCamarkSplit.x && m_ptCamarkSplit.x > 0 && m_ptCamarkSplit.x < winSize.width) 
		{
			int x1 = winSize.width - m_ptCamarkSplit.x;
			int x2 = x - x1;
			
			CGRect newRect1 = CGRectMake(newRect.origin.x, newRect.origin.y, x1, newRect.size.height);
			ScrollHorizontal(x1, newRect1);
			
			CGRect newRect2 = CGRectMake(newRect.origin.x + x1, newRect.origin.y, x2, newRect.size.height);
			ScrollHorizontal(x2, newRect2);
			
			return;
		}
		
		
		if (x < 0) 	
			ScrollSplit(x, 0);
		
		ReplaceMapTexture(m_texMap, 
						  CGRectMake(m_ptCamarkSplit.x, 0, abs(x), m_ptCamarkSplit.y), 
						  CGRectMake(newRect.origin.x, newRect.origin.y + winSize.height - m_ptCamarkSplit.y, abs(x), m_ptCamarkSplit.y));
		ReplaceMapTexture(m_texMap, 
						  CGRectMake(m_ptCamarkSplit.x, m_ptCamarkSplit.y, abs(x), winSize.height - m_ptCamarkSplit.y), 
						  CGRectMake(newRect.origin.x, newRect.origin.y, abs(x), winSize.height - m_ptCamarkSplit.y));
						  
		if (x > 0)						  
			ScrollSplit(x, 0);
	}
	
	void NDMapLayer::RectIntersectionRect(CGRect rect1, CGRect rect2, CGRect& intersectionRect, IntersectionArea& intersectionArea)
	{
		intersectionRect = CGRectIntersection(rect1, rect2);
		if (intersectionRect.size.width == 0 || intersectionRect.size.height == 0) 
		{
			intersectionArea = IntersectionAreaNone;
		}
		else 
		{
			if (rect1.origin.x >= rect2.origin.x && rect1.origin.y >= rect2.origin.y) 
				intersectionArea = IntersectionAreaLT;
			else if (rect1.origin.x >= rect2.origin.x && rect1.origin.y <= rect2.origin.y)
				intersectionArea = IntersectionAreaLB;
			else if (rect1.origin.x <= rect2.origin.x && rect1.origin.y >= rect2.origin.y)
				intersectionArea = IntersectionAreaRT;
			else 
				intersectionArea = IntersectionAreaRB;

		}
	}
	
	void NDMapLayer::MakeOrders()
	{
		[m_orders removeAllObjects];
		[m_orders addObjectsFromArray:m_ordersOfMapscenesAndMapanimations];
		const std::vector<NDNode*>& cld = this->GetChildren();
		std::map<int, NDNode*> mapDrawlast;
		std::map<unsigned int, NDManualRole*> mapRoleCell;
		for (int i = 0; i < (int)cld.size(); i++) 
		{
			NDNode *node = cld.at(i);
			if (node->IsKindOfClass(RUNTIME_CLASS(NDManualRole))) 
			{
				NDManualRole* role = (NDManualRole*)node;
				if (role->IsInState(USERSTATE_FLY) && NDMapMgrObj.canFly()) 
				{
					mapDrawlast[i] = node;
					continue;
				}
			}			
			
			if (node->IsKindOfClass(RUNTIME_CLASS(NDSprite))) 
			{
				NDSprite* sprite = (NDSprite*)node;
				
				int index = this->InsertIndex(sprite->GetOrder(), m_orders);	
				
				NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
				
				[dict setObject:[NSNumber numberWithInt:i + [m_mapData.sceneTiles count]+ [m_mapData.animationGroups count] + [m_mapData.switchs count]] forKey:@"index"];
				[dict setObject:[NSNumber numberWithInt:sprite->GetOrder()] forKey:@"orderId"];
				
				[m_orders insertObject:dict atIndex:index];
				[dict release];
				
			}
		}
		
		for (int i = 0; i < (int)cld.size(); i++) 
		{
			NDNode *node = cld.at(i);
			if (node->IsKindOfClass(RUNTIME_CLASS(NDManualRole))) 
			{
				NDManualRole *role = (NDManualRole*)node;
				role->EnableDraw(true);
				int serverX = (role->GetPosition().x-DISPLAY_POS_X_OFFSET)/m_mapData.unitSize;
				int serverY = (role->GetPosition().y-DISPLAY_POS_Y_OFFSET)/m_mapData.unitSize;
				unsigned int key = (((unsigned int )(serverX)) << 16) + serverY;
				//int64_t key = role->GetServerX() << 32 + role->GetServerY();
				std::map<unsigned int, NDManualRole*>::iterator it = mapRoleCell.find(key);
				if (it != mapRoleCell.end()) 
				{
					NDManualRole *roleInMap = it->second;
					if (roleInMap->IsHighPriorDrawLvl(role)) 
					{
						roleInMap->EnableDraw(false);
						mapRoleCell[key] = role;
					}
					else
					{
						role->EnableDraw(false);
					}
				}
				else 
				{
					mapRoleCell.insert(std::pair<unsigned int, NDManualRole*>(key, role));
				}
			}
		}
		
		if (mapDrawlast.size() == 0) return;
		
		NSMutableArray *flySpriteOrder = [[NSMutableArray alloc] init];
		
		NSInteger orderCount = int([m_orders count]);
		
		if (orderCount > 0) orderCount -= 1;
		
		for (std::map<int, NDNode*>::iterator it = mapDrawlast.begin(); it != mapDrawlast.end(); it++) 
		{
			NDNode *node = it->second;
			
			if (node->IsKindOfClass(RUNTIME_CLASS(NDSprite))) 
			{
				NDSprite* sprite = (NDSprite*)node;		
				
				NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
				
				[dict setObject:[NSNumber numberWithInt:it->first + [m_mapData.sceneTiles count] + [m_mapData.animationGroups count] + [m_mapData.switchs count]] forKey:@"index"];
				[dict setObject:[NSNumber numberWithInt:sprite->GetOrder()] forKey:@"orderId"];
				
				if (it != mapDrawlast.begin()) 
				{
					NSInteger index = this->InsertIndex(sprite->GetOrder(), flySpriteOrder);	
					[m_orders insertObject:dict atIndex:index+orderCount];
					[flySpriteOrder insertObject:dict atIndex:index];
				}
				else
				{
					[flySpriteOrder addObject:dict];
					
					[m_orders addObject:dict];
				}
				
				[dict release];
			}
		}
		
		[flySpriteOrder release];
	}
	
	void NDMapLayer::MakeOrdersOfMapscenesAndMapanimations()
	{	
		[m_ordersOfMapscenesAndMapanimations removeAllObjects];
		for (int i = 0; i < (int)[m_mapData.sceneTiles count]; i++) 
		{
			NDSceneTile *sceneTile = [m_mapData.sceneTiles objectAtIndex:i];
			
			int orderId = sceneTile.orderID;
			
			NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
			
			[dict setObject:[NSNumber numberWithInt:i] forKey:@"index"];
			[dict setObject:[NSNumber numberWithInt:orderId] forKey:@"orderId"];
			
			[m_ordersOfMapscenesAndMapanimations addObject:dict];
			[dict release];
		}
		for (int i = 0; i < (int)[m_mapData.aniGroupParams count]; i++) 
		{		
			NSDictionary *dictAniGroupParam = [m_mapData.aniGroupParams objectAtIndex:i];
			int orderId = [[dictAniGroupParam objectForKey:@"orderId"] intValue];
			
			NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
			[dict setObject:[NSNumber numberWithInt:i + [m_mapData.sceneTiles count]] forKey:@"index"];
			[dict setObject:[NSNumber numberWithInt:orderId] forKey:@"orderId"];
			
			[m_ordersOfMapscenesAndMapanimations addObject:dict];
			[dict release];
		}
		for (int i = 0; i < (int)[m_mapData.switchs count]; i++) 
		{		
			if ([m_switchAniGroup.animations count] > 0) 
			{
				//NDAnimation *animation = [m_switchAniGroup.animations objectAtIndex:0];
				NDMapSwitch *mapSwitch = [m_mapData.switchs objectAtIndex:i];
				//int orderId = mapSwitch.y * m_mapData.unitSize; 
				
				int orderId = mapSwitch.y * m_mapData.unitSize ;//+ 32 ; 
				
				NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
				[dict setObject:[NSNumber numberWithInt:i + [m_mapData.sceneTiles count] + [m_mapData.aniGroupParams count]] forKey:@"index"];
				[dict setObject:[NSNumber numberWithInt:orderId] forKey:@"orderId"];
				
				[m_ordersOfMapscenesAndMapanimations addObject:dict];
				[dict release];
			}		
		}
		
		this->QuickSort(m_ordersOfMapscenesAndMapanimations, 0, [m_ordersOfMapscenesAndMapanimations count] - 1);
	}
	
	int NDMapLayer::InsertIndex(int order, NSArray *inArray)
	{	
		int low = 0;
		int high = [inArray count] - 1;
		
		int mid = 0;
		int midOrder;
		NSDictionary *dict;	
		
		while (low < high) 
		{
			dict = [inArray objectAtIndex:high];
			int highOrder = [[dict objectForKey:@"orderId"] intValue];
			if (order > highOrder) 
			{
				return high + 1;
			}
			
			dict = [inArray objectAtIndex:low];
			int lowOrder = [[dict objectForKey:@"orderId"] intValue];
			if (order < lowOrder) 
			{
				return low;
			}			
			
			mid = (low + high) / 2;		
			dict = [inArray objectAtIndex:mid];
			midOrder = [[dict objectForKey:@"orderId"] intValue];			
			if (midOrder == order) 
			{
				return mid;
			}
			
			if (midOrder < order) 
				low = mid + 1;
			else 
				high = mid - 1;		
		}
		
		if ([inArray count] > 0) 
		{
			dict = [inArray objectAtIndex:mid];
			midOrder = [[dict objectForKey:@"orderId"] intValue];
			if (midOrder > order) 
				return mid;
			else 
				return mid + 1;
		}
		
		return 0;	
	}
	
	void NDMapLayer::QuickSort(NSMutableArray *array, int low, int high)
	{
		if (low < high) 
		{
			int pivotloc = this->Partition(array, low, high);
			this->QuickSort(array, low, pivotloc);
			this->QuickSort(array, pivotloc+1, high);
		}
	}
	
	int NDMapLayer::Partition(NSMutableArray *array, int low, int high)
	{
		NSDictionary *dict = [array objectAtIndex:low];
		int pivotkey = [[dict objectForKey:@"orderId"] intValue];
		
		while (low < high) 
		{				
			dict = [array objectAtIndex:high];
			int curKey = [[dict objectForKey:@"orderId"] intValue];
			
			while (low < high && curKey >= pivotkey)
			{
				dict = [array objectAtIndex:--high];
				curKey = [[dict objectForKey:@"orderId"] intValue];
			}
			if (low != high) 
				[array exchangeObjectAtIndex:low withObjectAtIndex:high];			
			
			dict = [array objectAtIndex:low];
			curKey = [[dict objectForKey:@"orderId"] intValue];
			while (low < high && curKey <= pivotkey) 
			{
				dict = [array objectAtIndex:++low];
				curKey = [[dict objectForKey:@"orderId"] intValue];
			}
			if (low != high) 
				[array exchangeObjectAtIndex:low withObjectAtIndex:high];		
		}
		
		return low;
	}
	
	void NDMapLayer::MakeFrameRunRecords()
	{
		for (int i = 0; i < (int)[m_mapData.animationGroups count]; i++) 
		{
			NDAnimationGroup *aniGroup = [m_mapData.animationGroups objectAtIndex:i];
			
			NSMutableArray *runFrameRecordList = [[NSMutableArray alloc] init];
			
			for (int j = 0; j < (int)[aniGroup.animations count]; j++) 
			{
				NDFrameRunRecord *frameRunRecord = [[NDFrameRunRecord alloc] init];
				[runFrameRecordList addObject:frameRunRecord];
				[frameRunRecord release];
			}
			
			[m_frameRunRecordsOfMapAniGroups addObject:runFrameRecordList];
			[runFrameRecordList release];
		}
		
		for (int i = 0; i < (int)[m_mapData.switchs count]; i++) 
		{
			NDFrameRunRecord *frameRunRecord = [[NDFrameRunRecord alloc] init];
			[m_frameRunRecordsOfMapSwitch addObject:frameRunRecord];
			[frameRunRecord release];
		}
	}
	
	void NDMapLayer::ShowRoadSign(bool bShow, int nX /*=0*/, int nY /*=0*/)
	{
		if (!bShow)
		{
			SAFE_DELETE(m_leRoadSign);
			
			return;
		}
		
		if (!m_leRoadSign)
		{
			m_leRoadSign = new NDLightEffect;
			m_leRoadSign->Initialization(GetAniPath("button.spr"));
			m_leRoadSign->SetLightId(0, false);
		}
		
		m_leRoadSign->SetPosition(ccp(nX*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, nY*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET));
	}

}






