//
//  NDMapLayer.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDMapLayer.h"
#include "NDDirector.h"
#include "CCPointExtension.h"
#include "NDPath.h"
#include "NDNode.h"
#include "NDSprite.h"
#include "NDTile.h"
#include "CCNode.h"
#include "NDAnimationGroupPool.h"
//#include "NDBattlePet.h"
//#include "NDPlayer.h"
//#include "NDRidePet.h"
#include "NDConstant.h"
//#include "GameScene.h"
//#include "cpLog.h"
#include "cocos2dExt.h"
//#include "NDMapMgr.h"
//#include "Performance.h"
//#include "BattleMgr.h"

using namespace cocos2d;

#define IMAGE_PATH										\
				[NSString stringWithUTF8String:				\
				NDEngine::NDPath::GetImagePath().c_str()]

bool GetIntersectRect(CGRect first, CGRect second, CGRect& ret)
{
	if (!CGRectIntersectsRect(first, second))
	{
		return false;
	}
	
	//todo(zjh)
	//ret = CGRectIntersection(first, second);
	
	return true;
}

bool GetRectPercent(CGRect rect, CGRect subrect, CGRect& ret)
{
	/*
	if (!CGRectContainsRect(rect, subrect))
	{
		return false;
	}
	*/

	if (rect.origin.x > subrect.origin.x || rect.origin.y > subrect.origin.y ||
		rect.origin.x + rect.size.width < subrect.origin.x + subrect.size.width || 
		rect.origin.y + rect.size.height < subrect.origin.y + subrect.size.height )
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
		m_mapData = NULL;
		m_mapIndex = -1;
		m_picMap = NULL;
		//m_texMap = NULL;
		m_switchAniGroup = NULL;
		m_mapData = NULL;
		m_lbTime = NULL;
		m_lbTitle = NULL;
		m_lbTitleBg = NULL;
		m_pkOrders = CCArray::array();
		m_pkOrders->retain();
		m_pkOrdersOfMapscenesAndMapanimations = CCArray::array();
		m_pkOrdersOfMapscenesAndMapanimations->retain();
		m_frameRunRecordsOfMapAniGroups = new CCMutableArray< CCMutableArray<NDFrameRunRecord*>* >();
		m_frameRunRecordsOfMapSwitch = new CCMutableArray< NDFrameRunRecord* >();
		this->m_bBattleBackground = false;
		this->m_bNeedShow = true;
		this->m_ndBlockTimer = NULL;
		this->m_ndTitleTimer = NULL;
		//this->switchSpriteNode=NULL;
		//this->isAutoBossFight = false;
		roadBlockTimeCount=0;
		titleAlpha=0;
		subnode = NDNode::Node();
		subnode->SetContentSize(NDDirector::DefaultDirector()->GetWinSize());
//		m_blockTimerTag=-1;
//		m_titleTimerTag=-1;
		showTitle=false;
		//switch_type=SWITCH_NONE;
		m_TreasureBox=NULL;
		box_status=BOX_NONE;
		m_leRoadSign = NULL;
	}
	
	NDMapLayer::~NDMapLayer()
	{
		CC_SAFE_RELEASE(m_pkOrders);
		CC_SAFE_RELEASE(m_pkOrdersOfMapscenesAndMapanimations);
		CC_SAFE_RELEASE(m_frameRunRecordsOfMapAniGroups);
		CC_SAFE_RELEASE(m_frameRunRecordsOfMapSwitch);
		//CC_SAFE_RELEASE(m_texMap);
		CC_SAFE_RELEASE(m_mapData);
		CC_SAFE_RELEASE(m_switchAniGroup);
		CC_SAFE_RELEASE(m_pkOrders);
		CC_SAFE_RELEASE(m_pkOrders);
		CC_SAFE_RELEASE(m_pkOrders);
		
		delete m_picMap;
		CC_SAFE_DELETE(subnode);
		if(m_ndBlockTimer)
		{
			m_ndBlockTimer->KillTimer(this,blockTimerTag);
			CC_SAFE_DELETE(m_ndBlockTimer);
		}
						
		if(m_ndTitleTimer)
		{
			m_ndTitleTimer->KillTimer(this,titleTimerTag);
			CC_SAFE_DELETE(m_ndTitleTimer);
		}
		
// 		if(m_TreasureBox)
// 		{
// 			SAFE_DELETE(m_TreasureBox);
// 		}
		
		CC_SAFE_DELETE(m_leRoadSign);
	}
	
	void NDMapLayer::replaceMapData(int mapId,int center_x,int center_y)
	{
		CC_SAFE_RELEASE(m_mapData);
		CC_SAFE_RELEASE(m_pkOrders);
	
		m_pkOrders  = CCArray::array();
		m_pkOrders->retain();
		//CC_SAFE_RELEASE(m_texMap);

		delete m_picMap;
		
		char mapFile[256] = {0};
		sprintf(mapFile, "%smap_%d.map", NDPath::GetMapPath().c_str(), mapId);

		m_mapData = new NDMapData;
		m_mapData->initWithFile(mapFile);

		if (m_mapData) 
		{
			this->SetContentSize(CGSizeMake(m_mapData->getColumns() *
				m_mapData->getUnitSize(),
				m_mapData->getRows() *
				m_mapData->getUnitSize()));
			
			this->MakeOrdersOfMapscenesAndMapanimations();
			this->MakeFrameRunRecords();
						
			CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
			m_screenCenter = ccp(winSize.width / 2, this->GetContentSize().height - winSize.height / 2);
			this->m_ccNode->setPosition(0, 0);	
			
			/*
			m_texMap = [[CCTexture2D alloc] initWithContentSize:winSize];
			m_picMap = new NDPicture();
			m_picMap->SetTexture(m_texMap);
			
			this->ReflashMapTexture(ccp(-winSize.width / 2, -winSize.height / 2), m_screenCenter);
			m_areaCamarkSplit = IntersectionAreaNone;
			m_ptCamarkSplit = ccp(0, 0);
			*/
		}
		this->SetScreenCenter(ccp(center_x,center_y));
		
		ShowRoadSign(false);
	}
	
	void NDMapLayer::Initialization(const char* mapFile)
	{
		NDUILayer::Initialization();
		this->SetTouchEnabled(true);
		
		m_switchAniGroup = NDAnimationGroupPool::defaultPool()->addObjectWithModelId(8);
		
		m_mapData = new NDMapData;
		m_mapData->initWithFile(mapFile);
		if (m_mapData) 
		{
			this->SetContentSize(CGSizeMake(m_mapData->getColumns() *
				m_mapData->getUnitSize(),
				m_mapData->getRows() *
				m_mapData->getUnitSize()));
			
			this->MakeOrdersOfMapscenesAndMapanimations();
			this->MakeFrameRunRecords();
			
			
			CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
			m_screenCenter = ccp(winSize.width / 2, this->GetContentSize().height - winSize.height / 2);
			this->m_ccNode->setPosition(0, 0);	
			
			/*
			m_texMap = [CCTexture2D alloc] initWithContentSize:winSize];
			m_picMap = new NDPicture();
			m_picMap->SetTexture(m_texMap);
			
			this->ReflashMapTexture(ccp(-winSize.width / 2, -winSize.height / 2), m_screenCenter);
			m_areaCamarkSplit = IntersectionAreaNone;
			m_ptCamarkSplit = ccp(0, 0);*/
		}
		
		this->DidFinishLaunching();		
	}
	
	void NDMapLayer::Initialization(int mapIndex)
	{
		tq::CString strMapFile("%smap_%d.map", NDPath::GetFullMapPath().c_str(), mapIndex);
		m_mapIndex = mapIndex;
		this->Initialization((const char*)strMapFile);	
		titleAlpha = 0;
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
		if(m_lbTitle && m_lbTitleBg)
		{
			if(showTitle)
			{
				if(titleAlpha < 255)
				{
                    if(m_lbTitle && m_lbTitleBg)
					{
                        int x = NDDirector::DefaultDirector()->GetWinSize().width / 2 - 150;
                        int y = 60;
                        //NDLog("x:%d,y:%d",x,y);
                        m_lbTitleBg->SetFrameRect(CGRectMake(NDDirector::DefaultDirector()->
							GetWinSize().width / 2 - 210, y, 420, 60));
                        //m_lbTitleBg->draw();
                        m_lbTitle->SetFrameRect(CGRectMake(x, y, 300, 60));
                    

                        NDPicture* p1 = m_lbTitle->GetPicture();
                        
                        p1->SetColor(ccc4(titleAlpha,titleAlpha,titleAlpha,titleAlpha));
                        
                        NDPicture* p2 = m_lbTitleBg->GetPicture();
                        
                        p2->SetColor(ccc4(titleAlpha,titleAlpha,titleAlpha,titleAlpha));
                        
                        titleAlpha += 5;
                    }
				}
				else if(!m_ndTitleTimer)
				{
					this->m_ndTitleTimer = new NDTimer;
					this->m_ndTitleTimer->SetTimer(this, titleTimerTag, 3.0f);
				}
			}
			else
			{
				if(titleAlpha >= 0)
				{
                    if(m_lbTitle && m_lbTitleBg)
					{
                        int x = NDDirector::DefaultDirector()->GetWinSize().width / 2 - 150;
                        int y = 60;
                        //NDLog("x:%d,y:%d",x,y);
                        m_lbTitleBg->SetFrameRect(CGRectMake(NDDirector::DefaultDirector()->
							GetWinSize().width / 2 - 210, y, 420, 60));
                        //m_lbTitleBg->draw();
                        m_lbTitle->SetFrameRect(CGRectMake(x, y, 300, 60));
                        
                        
                        NDPicture* p1 = m_lbTitle->GetPicture();
                        
                        p1->SetColor(ccc4(titleAlpha,titleAlpha,titleAlpha,titleAlpha));
                        
                        NDPicture* p2 = m_lbTitleBg->GetPicture();
                        
                        p2->SetColor(ccc4(titleAlpha,titleAlpha,titleAlpha,titleAlpha));
                        
                        titleAlpha -= 15;
                    }
				}
				else
				{
                    m_lbTitle->RemoveFromParent(true);
                    m_lbTitleBg->RemoveFromParent(true);
                    m_lbTitle = NULL;
                    m_lbTitleBg = NULL;
                }
			}

		}
	}
	
	/*
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
	*/
	void NDMapLayer::ShowTitle(int name_row,int name_col)
	{
		showTitle=true;
		titleAlpha=0;
		if(!m_lbTitle)
		{
			m_lbTitle = new NDUIImage;
			m_lbTitle->Initialization();
			NDPicture* picture= NDPicturePool::DefaultPool()->
				AddPicture(tq::CString("%smap_title.png", NDEngine::NDPath::GetImagePath().c_str()));
			//picture->SetColor(ccc4(0, 0, 0,0));
			int col = name_col;
			int row = name_row;
			picture->Cut(CGRectMake(col * 300,row * 60,300,60));
			m_lbTitle->SetPicture(picture, true);
		}
		
		if(!m_lbTitleBg)
		{
			m_lbTitleBg = new NDUIImage;
			m_lbTitleBg->Initialization();
			NDPicture* bg = NDPicturePool::DefaultPool()->
				AddPicture(tq::CString("%map_title_bg.png", NDEngine::NDPath::GetImagePath().c_str()));
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

	////////////////////////////////////////////////////////////////////////////////////
	//pszSpriteFile:动画文件名称 nAniNo 动画文件中的动作编号 nPlayTimes 播放次数
	////////////////////////////////////////////////////////////////////////////////////
	void 
	NDMapLayer::PlayNDSprite(const char* pszSpriteFile, int nPosx, int nPosy, int nAniNo, int nPlayTimes)
	{
		NDSprite* pSprite = new NDSprite;
		//NSString* aniPath=[NSString stringWithUTF8String:NDEngine::NDPath::GetAnimationPath().c_str()];
		pSprite->Initialization(tq::CString("%s%s", NDEngine::NDPath::GetAnimationPath().c_str(), pszSpriteFile));
		pSprite->SetPosition(CGPointMake(nPosx+64,nPosy));
		pSprite->SetCurrentAnimation(0, false);        
		bool bSet = this->isMapRectIntersectScreen(pSprite->GetSpriteRect());
		pSprite->BeforeRunAnimation(bSet);

		if(bSet)
		{
			while (nPlayTimes>0)
			{
				pSprite->RunAnimation(pSprite->DrawEnabled());

				if (pSprite->IsAnimationComplete())
				{
					nPlayTimes--;
				}
			}
		}
	}
	
	/*
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
	*/
	void NDMapLayer::RefreshBoxAnimation()
	{
		if(m_TreasureBox)
		{
			if(box_status == BOX_SHOWING)
			{
				if (m_TreasureBox->IsAnimationComplete())
				{
					m_TreasureBox->SetCurrentAnimation(1, false);
					box_status = BOX_CLOSE;
				}
			}
			else if(box_status == BOX_OPENING)
			{
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
			//NDLog("start draw map");
			//PerformanceTestBeginName("地表");
			//draw map tiles.......
			//this->DrawMapTiles();
			//PerformanceTestEndName("背景");
			this->DrawBgs();
			//PerformanceTestBeginName("场景动画");
			//draw map scenes and animations......
			this->DrawScenesAndAnimations();
			//PerformanceTestEndName("场景动画");
			//NDLog("done draw map");
			//启用颜色数组
			//glEnableClientState(GL_COLOR_ARRAY);
			/*if(switchSpriteNode)
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

			}*/
			this->refreshTitle();
			this->RefreshBoxAnimation();
//			if(m_TreasureBox){
//				m_TreasureBox->RunAnimation(true);
//			}
			if (this->roadBlockTimeCount > 0 && !m_bBattleBackground) 
			{
				//NDLog("showTime");
				if(!m_lbTime)
				{
					m_lbTime = new NDUILabel;
					m_lbTime->Initialization();
					m_lbTime->SetFontSize(15);

				}

				int mi = this->roadBlockTimeCount / 60;
				tq::CString str_mi;

				if(mi < 10)
				{
					str_mi.Format("0%d",mi);
				}
				else
				{
					str_mi.Format("%d",mi);
				}

				int se = this->roadBlockTimeCount % 60;
				tq::CString str_se;

				if(se < 10)
				{
					str_se.Format("0%d",se);
				}
				else
				{
					str_se.Format("%d",se);
				}

				tq::CString str_time("%s:%s",str_mi,str_se);
				m_lbTime->SetText(str_time);

				CGSize size = getStringSize(str_time, 30);

				if (!m_lbTime->GetParent() && subnode)
				{
					subnode->AddChild(m_lbTime);
				}

				m_lbTime->SetFontColor(ccc4(255,0,0,255));
				m_lbTime->SetFontSize(30);

				int x = m_screenCenter.x - (size.width) / 2;
				int y = m_screenCenter.y - GetContentSize().height - (size.height) / 2 +
					NDDirector::DefaultDirector()->GetWinSize().height;
				//NDLog("x:%d,y:%d",x,y);
				m_lbTime->SetFrameRect(CGRectMake(x, y, size.width, size.height + 5));
				m_lbTime->draw();
			}
			
			if (m_leRoadSign)
			{
				m_leRoadSign->Run(this->GetContentSize());
			}
		}	
		
	}
	
// 	void NDMapLayer::SetBattleBackground(bool bBattleBackground)
// 	{
// 		this->m_bBattleBackground = bBattleBackground;
// 		GameScene* gameScene =  (GameScene*)this->GetParent();
// 		gameScene->SetMiniMapVisible(!bBattleBackground);
// 	}
// 	
// 	void NDMapLayer::SetNeedShowBackground(bool bNeedShow)
// 	{
// 		this->m_bNeedShow = bNeedShow;
// //		GameScene* gameScene =  (GameScene*)this->GetParent();
// //		gameScene->SetMiniMapVisible(!bBattleBackground);
// 	}
	
	void NDMapLayer::MapSwitchRefresh()
	{
		this->MakeOrdersOfMapscenesAndMapanimations();
		CC_SAFE_RELEASE(m_frameRunRecordsOfMapSwitch);
		
		m_frameRunRecordsOfMapSwitch = new cocos2d::CCMutableArray< NDFrameRunRecord* >();
		
		for (int i = 0; i < (int)m_mapData->getSwitchs()->count(); i++) 
		{
			NDFrameRunRecord *frameRunRecord = new NDFrameRunRecord;
			m_frameRunRecordsOfMapSwitch->addObject(frameRunRecord);
			frameRunRecord->release();
		}
	}
	
// 	void NDMapLayer::DrawMapTiles()
// 	{
// 		//draw map tile
// 		CGSize winSize =  NDDirector::DefaultDirector()->GetWinSize();	
// 		CGPoint ptDraw = ccp(m_screenCenter.x - winSize.width / 2, m_screenCenter.y + winSize.height / 2 - GetContentSize().height);
// 		if (m_areaCamarkSplit == IntersectionAreaNone) 
// 		{
// 			[m_texMap ndDrawInRect:CGRectMake(ptDraw.x, ptDraw.y, winSize.width, winSize.height)];
// 		}
// 		else 
// 		{
// 			CGRect rect1 = CGRectMake(0, 0, m_ptCamarkSplit.x, m_ptCamarkSplit.y);
// 			CGRect rect2 = CGRectMake(rect1.size.width, 0,  winSize.width - rect1.size.width, rect1.size.height);
// 			CGRect rect3 = CGRectMake(0, rect1.size.height, rect1.size.width, winSize.height - rect1.size.height);
// 			CGRect rect4 = CGRectMake(rect1.size.width, rect1.size.height, rect2.size.width, rect3.size.height);
// 			
// 			if (rect1.size.width != 0 && rect1.size.height != 0) 
// 			{
// 				m_picMap->Cut(rect1);
// 				m_picMap->DrawInRect(CGRectMake(ptDraw.x + winSize.width - m_ptCamarkSplit.x, ptDraw.y + winSize.height - m_ptCamarkSplit.y, rect1.size.width, rect1.size.height));			
// 			}
// 			if (rect2.size.width != 0 && rect2.size.height != 0) 
// 			{
// 				m_picMap->Cut(rect2);
// 				m_picMap->DrawInRect(CGRectMake(ptDraw.x, ptDraw.y + winSize.height - m_ptCamarkSplit.y, rect2.size.width + 1, rect2.size.height + 1));
// 			}
// 			if (rect3.size.width != 0 && rect3.size.height != 0) 
// 			{
// 				m_picMap->Cut(rect3);
// 				m_picMap->DrawInRect(CGRectMake(ptDraw.x + winSize.width - m_ptCamarkSplit.x, ptDraw.y, rect3.size.width, rect3.size.height + 1));
// 			}
// 			if (rect4.size.width != 0 && rect4.size.height != 0) 
// 			{
// 				m_picMap->Cut(rect4);
// 				m_picMap->DrawInRect(CGRectMake(ptDraw.x, ptDraw.y, rect4.size.width + 1, rect4.size.height + 1));
// 			}
// 		}
// 		
// //		DrawLine(ccp(ptDraw.x + 0, ptDraw.y + m_ptCamarkSplit.y), ccp(ptDraw.x + 480, ptDraw.y + m_ptCamarkSplit.y), ccc4(255, 0, 0, 255), 1);
// //		DrawLine(ccp(ptDraw.x + m_ptCamarkSplit.x, ptDraw.y + 0), ccp(ptDraw.x + m_ptCamarkSplit.x, ptDraw.y + 320), ccc4(255, 0, 0, 255), 1);		
// 	}
	
	void NDMapLayer::DrawBgs()
	{
		CGSize winSize			= NDDirector::DefaultDirector()->GetWinSize();
		CGRect scrRect			= CGRectMake(m_screenCenter.x - winSize.width / 2,
			m_screenCenter.y - winSize.height / 2, winSize.width, winSize.height);
		
		unsigned int orderCount = m_mapData->getBgTiles()->count();
		for (unsigned int i = 0; i < orderCount; i++) 
		{
			NDTile* pkTile = (NDTile*)m_mapData->getBgTiles()->objectAtIndex(i);
			if(pkTile && CGRectIntersectsRect(scrRect, pkTile->getDrawRect()))
			{
				draw();
// 				CGRect intersectRect	= CGRectZero;
// 				CGRect drawRect			= CGRectZero;
// 				if(GetIntersectRect(scrRect, tile.drawRect, intersectRect) &&
// 				   GetRectPercent(tile.drawRect, intersectRect, drawRect))
// 				{
// 					tile->drawSubRect(drawRect);
// 				}
			}
		}
	}
	
	void NDMapLayer::DrawScenesAndAnimations()
	{	
		this->MakeOrders();
		
		unsigned int orderCount = m_pkOrders->count(),
				   uiSceneTileCount = m_mapData->getSceneTiles()->count(),
				   aniGroupCount = m_mapData->getAnimationGroups()->count(),
				   switchCount = m_mapData->getSwitchs()->count();
	
		//PerformanceTestPerFrameBeginName(" NDMapLayer::DrawScenesAndAnimations");
		
		for (unsigned int i = 0; i < orderCount; i++) 
		{
			//PerformanceTestPerFrameBeginName(" NDMapLayer::DrawScenesAndAnimations inner");
			
			MAP_ORDER* pkDict = (MAP_ORDER *)m_pkOrders->objectAtIndex(i);
			unsigned int index = 0;
			if (pkDict)
			{
				std::map<std::string, int>::iterator it = pkDict->find("index");
				if (it != pkDict->end())
				{
					index = it->second;
				}
			}	
			
			if (index < uiSceneTileCount) //布景
			{
				//PerformanceTestPerFrameBeginName("布景");
				NDTile *tile = (NDTile *)m_mapData->getSceneTiles()->objectAtIndex(index);
				if (tile) 
				{
					if (this->isMapRectIntersectScreen(tile->getDrawRect())) 
					{
						tile->draw();
					}				
				}
				//PerformanceTestPerFrameEndName("布景");		
			}
// 			else if (m_bBattleBackground) // 战斗状态，不绘制其他地表元素
// 			{
// 				continue;
// 			}
			else if (index < uiSceneTileCount + aniGroupCount)//地表动画
			{
				//PerformanceTestPerFrameBeginName("地表动画");
				index -= uiSceneTileCount;
				
				NDAnimationGroup* aniGroup = (NDAnimationGroup* )m_mapData->getAnimationGroups()->objectAtIndex(index);
				CCMutableArray<NDFrameRunRecord*>* frameRunRecordList = m_frameRunRecordsOfMapAniGroups->getObjectAtIndex(index);
				
				aniGroup->setReverse(this->GetMapDataAniParamReverse(index));
				aniGroup->setPosition(this->GetMapDataAniParamPos(index));
				aniGroup->setRunningMapSize(this->GetMapDataAniParamMapSize(index));
				
				unsigned int aniCount = aniGroup->getAnimations()->count();
				
				for (unsigned int j = 0; j < aniCount; j++) 
				{
					NDFrameRunRecord *frameRunRecord = frameRunRecordList->getObjectAtIndex(j);
					NDAnimation *pkAnimation = (NDAnimation *)aniGroup->
						getAnimations()->objectAtIndex(j);
					
					if (this->isMapRectIntersectScreen(pkAnimation->getRect())) 
					{					
						pkAnimation->runWithRunFrameRecord(frameRunRecord, true);
					}
					else 
					{
						pkAnimation->runWithRunFrameRecord(frameRunRecord, false);
					}
				}	
				//PerformanceTestPerFrameEndName("地表动画");	
			}		
			else if (index < uiSceneTileCount + aniGroupCount + switchCount)//切屏点
			{
				//PerformanceTestPerFrameBeginName("切屏点");
				index -= m_mapData->getSceneTiles()->count() + m_mapData->getAnimationGroups()->count();
				
				NDMapSwitch *mapSwitch = (NDMapSwitch *)m_mapData->getSwitchs()->objectAtIndex(index);
				NDFrameRunRecord *frameRunRecord = m_frameRunRecordsOfMapSwitch->getObjectAtIndex(index);
				
				m_switchAniGroup->setReverse(false);
				
				CGPoint pos = ccp(mapSwitch->getX() * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
					mapSwitch->getY() * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET);
				
				m_switchAniGroup->setPosition(pos);

				m_switchAniGroup->setRunningMapSize(this->GetContentSize());
				
				if (m_switchAniGroup->getAnimations()->count() > 0) 
				{
					NDAnimation *animation = (NDAnimation *)m_switchAniGroup->getAnimations()->objectAtIndex(0);
					if (this->isMapRectIntersectScreen(animation->getRect())) 
					{					
						animation->runWithRunFrameRecord(frameRunRecord, true);
						mapSwitch->draw();
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
				index -= uiSceneTileCount + aniGroupCount + switchCount;
				
				if (index < 0 || index >= this->GetChildren().size()) 
					continue;
				
				NDNode* node = this->GetChildren().at(index);
				if (node->IsKindOfClass(RUNTIME_CLASS(NDSprite))) 
				{
					NDSprite* sprite = (NDSprite*)node;
					bool bSet = this->isMapRectIntersectScreen(sprite->GetSpriteRect());
					//NDManualRole* manualRole = NULL; 放到NDManualRole中处理
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
					
					if (true)//bSet)
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
	/*
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
	*/
	CGPoint NDMapLayer::ConvertToMapPoint(CGPoint screenPoint)
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		return ccpAdd(ccpSub(screenPoint, CGPointMake(winSize.width / 2,
			winSize.height / 2)), m_screenCenter);
	}
	
	bool NDMapLayer::isMapPointInScreen(CGPoint mapPoint)
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		return CGRectContainsPoint(CGRectMake(m_screenCenter.x - winSize.width / 2,
			m_screenCenter.y - winSize.height / 2,
			winSize.width, winSize.height), mapPoint);
	}
	
	bool NDMapLayer::isMapRectIntersectScreen(CGRect mapRect)
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		CGRect scrRect = CGRectMake(m_screenCenter.x - winSize.width / 2,
			m_screenCenter.y - winSize.height / 2,
			winSize.width, winSize.height);
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
		
		this->m_ccNode->setPositionInPixels(p);
	}
	
	bool NDMapLayer::SetScreenCenter(CGPoint p)
	{
// 		if(this->m_bBattleBackground){
// 			return false;
// 		}
		
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
		m_mapData->moveBackGround(backOff.x, backOff.y);	
		//[m_mapData moveBackGround:backOff.x,backOff.y];
		
		m_screenCenter = p;
		//NDLog("center:%f,%f",p.x,p.y);
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
			m_mapData->setRoadBlock(x, y);
		}
	}
	/*
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
			NDLog("boss:%d,%d",point.x,point.y);
			NDPlayer::defaultHero().Walk(point, SpriteSpeedStep4);
		}
	}
	*/
	void NDMapLayer::OnTimer(OBJID tag)
	{
		if(tag==blockTimerTag)
		{
			this->roadBlockTimeCount--;
			//NDLog("tag:%d,count:%d",tag,this->roadBlockTimeCount);
			if(this->roadBlockTimeCount<=0)
			{
				this->m_mapData->setRoadBlock(-1, -1);
				this->roadBlockTimeCount=0;
				this->m_ndBlockTimer->KillTimer(this, blockTimerTag);
				this->m_ndBlockTimer=NULL;
				
				/*if(this->isAutoBossFight)
				{
					this->walkToBoss();
				}*/
			}
		}else if(tag==titleTimerTag){
			this->m_ndTitleTimer->KillTimer(this, titleTimerTag);
			this->m_ndTitleTimer=NULL;
			//todo(zjh)
			/*if(NDMapMgrObj.GetMotherMapID()/100000000!=9){
				this->showTitle=false;
			}
			*/
		}
	}
	
// 	void NDMapLayer::ReplaceMapTexture(CCTexture2D* tex, CGRect replaceRect, CGRect tilesRect)
// 	{
// 		if (replaceRect.size.width == 0 || replaceRect.size.height == 0) 
// 			return;
// 		
// 		if (tex)//&& replaceRect.size == tileRect.size) 
// 		{
// 			int rowStart = tilesRect.origin.y / m_mapData.unitSize - 1;
// 			int rowEnd   = (tilesRect.origin.y + tilesRect.size.height) / m_mapData.unitSize + 1;
// 			int colStart = tilesRect.origin.x / m_mapData.unitSize - 1;
// 			int colEnd   = (tilesRect.origin.x + tilesRect.size.width) / m_mapData.unitSize + 1;			
// 			
// 			int x = replaceRect.origin.x;
// 			int y = replaceRect.origin.y;
// 			
// 			CustomCCTexture2D *newTile = [[CustomCCTexture2D alloc] init];
// 			for (int r = rowStart; r <= rowEnd; r++)
// 				for (int c = colStart; c <= colEnd; c++) 
// 				{
// 					CustomCCTexture2D *tile = [m_mapData getTileAtRow:r column:c];					 
// 					if (tile) 
// 					{
// 						newTile.texture = tile.texture;
// 						newTile.horizontalReverse = tile.horizontalReverse;
// 						newTile.reverseRect = tile.cutRect;
// 						
// 						CGRect rect; IntersectionArea area;
// 						RectIntersectionRect(tile.drawRect, tilesRect, rect, area);	
// 						if (area != IntersectionAreaNone) 
// 						{
// 							rect = CGRectMake(rect.origin.x - tile.drawRect.origin.x, rect.origin.y - tile.drawRect.origin.y, rect.size.width, rect.size.height);
// 							newTile.cutRect	= CGRectMake(tile.cutRect.origin.x + rect.origin.x, tile.cutRect.origin.y + rect.origin.y, rect.size.width, rect.size.height);
// 							newTile.drawRect = CGRectMake(x, y, rect.size.width, rect.size.height);
// 							[tex replaceWithCustomTexture:newTile commit:YES];
// 							
// 							x += rect.size.width;
// 							if (x >= replaceRect.origin.x + replaceRect.size.width) 
// 							{
// 								x = replaceRect.origin.x;
// 								y += rect.size.height;
// 							}
// 							
// 						}																
// 					}					
// 				}	
// 			[newTile release];
// 		}
// 	}
	
// 	void NDMapLayer::ReflashMapTexture(CGPoint oldScreenCenter, CGPoint newScreenCenter)
// 	{	
// 		if (oldScreenCenter.x == newScreenCenter.x && oldScreenCenter.y == newScreenCenter.y) 
// 			return;
// 		
// 		if (m_texMap) 
// 		{		
// 			CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
// 			
// 			CGRect oldRect = CGRectMake(oldScreenCenter.x - winSize.width / 2, oldScreenCenter.y - winSize.height / 2, 
// 										winSize.width, winSize.height);
// 			CGRect newRect = CGRectMake(newScreenCenter.x - winSize.width / 2, newScreenCenter.y - winSize.height / 2, 
// 										winSize.width, winSize.height);
// 			
// 			CGRect rect;
// 			RectIntersectionRect(oldRect, newRect, rect, m_areaCamarkSplit);
// 			if (m_areaCamarkSplit == IntersectionAreaNone) 
// 			{
// 				m_ptCamarkSplit = ccp(0, 0);
// 				ReplaceMapTexture(m_texMap, 
// 								  CGRectMake(0, 0, winSize.width, winSize.height), 
// 								  CGRectMake(newRect.origin.x, newRect.origin.y, winSize.width, winSize.height));
// 			}
// 			else 
// 			{
// 				CGRect nRect = CGRectZero;
// 				if (newScreenCenter.x > oldScreenCenter.x) 
// 				{
// 					nRect = CGRectMake(oldScreenCenter.x + winSize.width / 2, 
// 									   oldScreenCenter.y - winSize.height / 2, 
// 									   newScreenCenter.x - oldScreenCenter.x, winSize.height);
// 				}
// 				else 
// 				{
// 					nRect = CGRectMake(newScreenCenter.x - winSize.width / 2, 
// 									   oldScreenCenter.y - winSize.height / 2, 
// 									   oldScreenCenter.x - newScreenCenter.x, winSize.height);
// 				}
// 				ScrollHorizontal(newScreenCenter.x - oldScreenCenter.x, nRect);
// 				
// 				if (newScreenCenter.y > oldScreenCenter.y) 
// 				{
// 					nRect = CGRectMake(newScreenCenter.x - winSize.width / 2, 
// 									   oldScreenCenter.y + winSize.height / 2, 
// 									   winSize.width, newScreenCenter.y - oldScreenCenter.y);
// 				}
// 				else 
// 				{
// 					nRect = CGRectMake(newScreenCenter.x - winSize.width / 2, 
// 									   newScreenCenter.y - winSize.height / 2, 
// 									   winSize.width, oldScreenCenter.y - newScreenCenter.y);
// 				}
// 				ScrollVertical(newScreenCenter.y - oldScreenCenter.y, nRect);			
// 				
// 			}
// 		}
// 	}
	
// 	void NDMapLayer::ScrollSplit(int x, int y)
// 	{
// 		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
// 		
// 		m_ptCamarkSplit.x += x;
// 		if (m_ptCamarkSplit.x < 0) 
// 			m_ptCamarkSplit.x += winSize.width;
// 		if (m_ptCamarkSplit.x >= winSize.width) 
// 			m_ptCamarkSplit.x -= winSize.width;
// 		
// 		m_ptCamarkSplit.y += y;
// 		if (m_ptCamarkSplit.y < 0) 
// 			m_ptCamarkSplit.y += winSize.height;
// 		if (m_ptCamarkSplit.y >= winSize.height) 
// 			m_ptCamarkSplit.y -= winSize.height;
// 	}
	
// 	void NDMapLayer::ScrollVertical(int y, CGRect newRect)
// 	{
// 		if (y == 0)	return;
// 		
// 		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
// 		
// 		if (y < 0 && abs(y) > m_ptCamarkSplit.y && m_ptCamarkSplit.y > 0 && m_ptCamarkSplit.y < winSize.height) 
// 		{
// 			int y1 = -m_ptCamarkSplit.y;
// 			int y2 = m_ptCamarkSplit.y + y;
// 			
// 			CGRect newRect1 = CGRectMake(newRect.origin.x, newRect.origin.y - y2, newRect.size.width, -y1);
// 			ScrollVertical(y1, newRect1);
// 			
// 			CGRect newRect2 = CGRectMake(newRect.origin.x, newRect.origin.y, newRect.size.width, y2);
// 			ScrollVertical(y2, newRect2);
// 			
// 			return ;
// 		}
// 		
// 		if (y > 0 && abs(y) > winSize.height - m_ptCamarkSplit.y && m_ptCamarkSplit.y > 0 && m_ptCamarkSplit.y < winSize.height) 
// 		{
// 			int y1 = winSize.height - m_ptCamarkSplit.y;
// 			int y2 = y - y1;
// 			
// 			CGRect newRect1 = CGRectMake(newRect.origin.x, newRect.origin.y, newRect.size.width, y1);
// 			ScrollVertical(y1, newRect1);
// 			
// 			CGRect newRect2 = CGRectMake(newRect.origin.x, newRect.origin.y + y1, newRect.size.width, y2);
// 			ScrollVertical(y2, newRect2);
// 			
// 			return;
// 		}
// 		
// 		if (y < 0) 
// 			ScrollSplit(0, y);
// 		
// 		ReplaceMapTexture(m_texMap, 
// 						  CGRectMake(0, m_ptCamarkSplit.y, m_ptCamarkSplit.x, abs(y)), 
// 						  CGRectMake(newRect.origin.x + winSize.width - m_ptCamarkSplit.x, newRect.origin.y, m_ptCamarkSplit.x, abs(y)));
// 		ReplaceMapTexture(m_texMap, 
// 						  CGRectMake(m_ptCamarkSplit.x, m_ptCamarkSplit.y, winSize.width - m_ptCamarkSplit.x, abs(y)), 
// 						  CGRectMake(newRect.origin.x, newRect.origin.y, winSize.width - m_ptCamarkSplit.x, abs(y)));
// 		
// 		if (y > 0) 
// 			ScrollSplit(0, y);		
// 	}
// 	
// 	void NDMapLayer::ScrollHorizontal(int x, CGRect newRect)
// 	{
// 		if (x == 0) return ;
// 		
// 		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
// 		
// 		if (x < 0 && abs(x) > m_ptCamarkSplit.x && m_ptCamarkSplit.x > 0 && m_ptCamarkSplit.x < winSize.width) 
// 		{
// 			int x1 = -m_ptCamarkSplit.x;
// 			int x2 = m_ptCamarkSplit.x + x;
// 			
// 			CGRect newRect1 = CGRectMake(newRect.origin.x - x2, newRect.origin.y, -x1, newRect.size.height);
// 			ScrollHorizontal(x1, newRect1);
// 			
// 			CGRect newRect2 = CGRectMake(newRect.origin.x, newRect.origin.y, -x2, newRect.size.height);
// 			ScrollHorizontal(x2, newRect2);
// 			
// 			return;
// 		}
// 		
// 		if (x > 0 && abs(x) > winSize.width - m_ptCamarkSplit.x && m_ptCamarkSplit.x > 0 && m_ptCamarkSplit.x < winSize.width) 
// 		{
// 			int x1 = winSize.width - m_ptCamarkSplit.x;
// 			int x2 = x - x1;
// 			
// 			CGRect newRect1 = CGRectMake(newRect.origin.x, newRect.origin.y, x1, newRect.size.height);
// 			ScrollHorizontal(x1, newRect1);
// 			
// 			CGRect newRect2 = CGRectMake(newRect.origin.x + x1, newRect.origin.y, x2, newRect.size.height);
// 			ScrollHorizontal(x2, newRect2);
// 			
// 			return;
// 		}
// 		
// 		
// 		if (x < 0) 	
// 			ScrollSplit(x, 0);
// 		
// 		ReplaceMapTexture(m_texMap, 
// 						  CGRectMake(m_ptCamarkSplit.x, 0, abs(x), m_ptCamarkSplit.y), 
// 						  CGRectMake(newRect.origin.x, newRect.origin.y + winSize.height - m_ptCamarkSplit.y, abs(x), m_ptCamarkSplit.y));
// 		ReplaceMapTexture(m_texMap, 
// 						  CGRectMake(m_ptCamarkSplit.x, m_ptCamarkSplit.y, abs(x), winSize.height - m_ptCamarkSplit.y), 
// 						  CGRectMake(newRect.origin.x, newRect.origin.y, abs(x), winSize.height - m_ptCamarkSplit.y));
// 						  
// 		if (x > 0)						  
// 			ScrollSplit(x, 0);
// 	}
	
// 	void NDMapLayer::RectIntersectionRect(CGRect rect1, CGRect rect2, CGRect& intersectionRect, IntersectionArea& intersectionArea)
// 	{
// 		intersectionRect = CGRectIntersection(rect1, rect2);
// 		if (intersectionRect.size.width == 0 || intersectionRect.size.height == 0) 
// 		{
// 			intersectionArea = IntersectionAreaNone;
// 		}
// 		else 
// 		{
// 			if (rect1.origin.x >= rect2.origin.x && rect1.origin.y >= rect2.origin.y) 
// 				intersectionArea = IntersectionAreaLT;
// 			else if (rect1.origin.x >= rect2.origin.x && rect1.origin.y <= rect2.origin.y)
// 				intersectionArea = IntersectionAreaLB;
// 			else if (rect1.origin.x <= rect2.origin.x && rect1.origin.y >= rect2.origin.y)
// 				intersectionArea = IntersectionAreaRT;
// 			else 
// 				intersectionArea = IntersectionAreaRB;
// 
// 		}
// 	}
	
	void NDMapLayer::MakeOrders()
	{
		m_pkOrders->removeAllObjects();
		m_pkOrders->addObjectsFromArray(m_pkOrdersOfMapscenesAndMapanimations);
		const std::vector<NDNode*>& cld = this->GetChildren();
		std::map<int, NDNode*> mapDrawlast;
		//std::map<unsigned int, NDManualRole*> mapRoleCell;
		for (int i = 0; i < (int)cld.size(); i++) 
		{
 			NDNode *node = cld.at(i);
			CCLog(node->GetRuntimeClass()->className);
// 			if (node->IsKindOfClass(RUNTIME_CLASS(NDManualRole))) 
// 			{
// 				NDManualRole* role = (NDManualRole*)node;
// 				if (role->IsInState(USERSTATE_FLY) && NDMapMgrObj.canFly()) 
// 				{
// 					mapDrawlast[i] = node;
// 					continue;
// 				}
// 			}			
			
			if (node->IsKindOfClass(RUNTIME_CLASS(NDSprite))) 
			{
				NDSprite* sprite = (NDSprite*)node;
				
				int index = this->InsertIndex(sprite->GetOrder(), m_pkOrders);	
				
				MAP_ORDER *dict = new MAP_ORDER;
				
				(*dict)["index"]	= i + m_mapData->getSceneTiles()->count() + 0 + m_mapData->getSwitchs()->count();///< 临时性注释 郭浩 原：m_mapData->getAnimationGroups()->count()
				(*dict)["orderId"]	= sprite->GetOrder();
				//[dict setObject:[NSNumber numberWithInt:i + [m_mapData.sceneTiles count]+ [m_mapData.animationGroups count] + [m_mapData.switchs count]] forKey:@"index"];
				//[dict setObject:[NSNumber numberWithInt:sprite->GetOrder()] forKey:@"orderId"];
				
				m_pkOrders->insertObject(dict, index);
				dict->release();
				
			}
		}
		
// 		for (int i = 0; i < (int)cld.size(); i++) 
// 		{
// 			NDNode *node = cld.at(i);
// 			if (node->IsKindOfClass(RUNTIME_CLASS(NDManualRole))) 
// 			{
// 				NDManualRole *role = (NDManualRole*)node;
// 				role->EnableDraw(true);
// 				int serverX = (role->GetPosition().x-DISPLAY_POS_X_OFFSET)/m_mapData.unitSize;
// 				int serverY = (role->GetPosition().y-DISPLAY_POS_Y_OFFSET)/m_mapData.unitSize;
// 				unsigned int key = (((unsigned int )(serverX)) << 16) + serverY;
// 				//int64_t key = role->GetServerX() << 32 + role->GetServerY();
// 				std::map<unsigned int, NDManualRole*>::iterator it = mapRoleCell.find(key);
// 				if (it != mapRoleCell.end()) 
// 				{
// 					NDManualRole *roleInMap = it->second;
// 					if (roleInMap->IsHighPriorDrawLvl(role)) 
// 					{
// 						roleInMap->EnableDraw(false);
// 						mapRoleCell[key] = role;
// 					}
// 					else
// 					{
// 						role->EnableDraw(false);
// 					}
// 				}
// 				else 
// 				{
// 					mapRoleCell.insert(std::pair<unsigned int, NDManualRole*>(key, role));
// 				}
// 			}
// 		}
		
		if (mapDrawlast.size() == 0) return;
		
		CCArray*flySpriteOrder = CCArray::array();
		flySpriteOrder->retain();
		
		unsigned int orderCount = int(m_pkOrders->count());
		
		if (orderCount > 0) orderCount -= 1;
		
		for (std::map<int, NDNode*>::iterator it = mapDrawlast.begin(); it != mapDrawlast.end(); it++) 
		{
			NDNode *node = it->second;
			
			if (node->IsKindOfClass(RUNTIME_CLASS(NDSprite))) 
			{
				NDSprite* sprite = (NDSprite*)node;		
				
				MAP_ORDER *dict = new MAP_ORDER;

				(*dict)["index"]	= it->first + m_mapData->getSceneTiles()->count() + 0 + m_mapData->getSwitchs()->count();///< 临时性注释 郭浩 m_mapData->getAnimationGroups()->count()
				(*dict)["orderId"]	= sprite->GetOrder();

				//NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
				
				//[dict setObject:[NSNumber numberWithInt:it->first + [m_mapData.sceneTiles count] + [m_mapData.animationGroups count] + [m_mapData.switchs count]] forKey:@"index"];
				//[dict setObject:[NSNumber numberWithInt:sprite->GetOrder()] forKey:@"orderId"];
				
				if (it != mapDrawlast.begin()) 
				{
					unsigned index = this->InsertIndex(sprite->GetOrder(), flySpriteOrder);	
					m_pkOrders->insertObject(dict, index+orderCount);
					flySpriteOrder->insertObject(dict, index);
				}
				else
				{
					flySpriteOrder->addObject(dict);
					
					m_pkOrders->addObject(dict);
				}
				
				dict->release();
			}
		}
		
		flySpriteOrder->release();
	}
	
	void NDMapLayer::MakeOrdersOfMapscenesAndMapanimations()
	{	
		m_pkOrdersOfMapscenesAndMapanimations->removeAllObjects();
		for (int i = 0; i < (int)m_mapData->getSceneTiles()->count(); i++) 
		{
			NDSceneTile *sceneTile = (NDSceneTile *)m_mapData->getSceneTiles()->objectAtIndex(i);
			
			int orderId = sceneTile->getOrderID();

			MAP_ORDER *dict = new MAP_ORDER;

			(*dict)["index"]	= i;
			(*dict)["orderId"]	= orderId;
			
			//NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
			
			//[dict setObject:[NSNumber numberWithInt:i] forKey:@"index"];
			//[dict setObject:[NSNumber numberWithInt:orderId] forKey:@"orderId"];
			
			m_pkOrdersOfMapscenesAndMapanimations->addObject(dict);
			dict->release();
		}
		for (int i = 0; i < (int)m_mapData->getAniGroupParams()->count(); i++) 
		{		
			//NSDictionary *dictAniGroupParam = [m_mapData.aniGroupParams objectAtIndex:i];
			int orderId = this->GetMapDataAniParamOrderId(i);
			
			MAP_ORDER *dict = new MAP_ORDER;

			(*dict)["index"]	= i + m_mapData->getSceneTiles()->count();
			(*dict)["orderId"]	= orderId;

			//NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
			//[dict setObject:[NSNumber numberWithInt:i + [m_mapData.sceneTiles count]] forKey:@"index"];
			//[dict setObject:[NSNumber numberWithInt:orderId] forKey:@"orderId"];
			
			m_pkOrdersOfMapscenesAndMapanimations->addObject(dict);
			dict->release();
		}
		for (int i = 0; i < (int)m_mapData->getSwitchs()->count(); i++) 
		{		
			if (/* 临时性注释 郭浩 m_switchAniGroup->getAnimations()->count()*/0 > 0) 
			{
				//NDAnimation *animation = [m_switchAniGroup.animations objectAtIndex:0];
				NDMapSwitch *mapSwitch = (NDMapSwitch *)m_mapData->getSwitchs()->objectAtIndex(i);
				//int orderId = mapSwitch.y * m_mapData.unitSize; 
				
				int orderId = mapSwitch->getY() * m_mapData->getUnitSize() ;//+ 32 ; 
				
				MAP_ORDER *dict = new MAP_ORDER;

				(*dict)["index"]	= i + m_mapData->getSceneTiles()->count() + m_mapData->getAniGroupParams()->count();
				(*dict)["orderId"]	= orderId;

				//NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
				//[dict setObject:[NSNumber numberWithInt:i + [m_mapData.sceneTiles count] + [m_mapData.aniGroupParams count]] forKey:@"index"];
				//[dict setObject:[NSNumber numberWithInt:orderId] forKey:@"orderId"];
				
				m_pkOrdersOfMapscenesAndMapanimations->addObject(dict);
				dict->release();
			}		
		}
		
		this->QuickSort(m_pkOrdersOfMapscenesAndMapanimations, 0, m_pkOrdersOfMapscenesAndMapanimations->count() - 1);
	}
	
	int NDMapLayer::InsertIndex(int order, cocos2d::CCArray*/*<MAP_ORDER*>*/inArray)
	{	
		int low = 0;
		int high = inArray->count() - 1;
		
		int mid = 0;
		int midOrder;
		MAP_ORDER *dict;	
		
		while (low < high) 
		{

			dict = (MAP_ORDER *)inArray->objectAtIndex(high);
			int highOrder = this->GetMapOrderId(dict);
		
			//[[dict objectForKey:@"orderId"] intValue];
			if (order > highOrder) 
			{
				return high + 1;
			}
			
			dict = (MAP_ORDER *)inArray->objectAtIndex(low);
			int lowOrder = this->GetMapOrderId(dict);
			if (order < lowOrder) 
			{
				return low;
			}			
			
			mid = (low + high) / 2;		
			dict = (MAP_ORDER *)inArray->objectAtIndex(mid);
			midOrder = this->GetMapOrderId(dict);			
			if (midOrder == order) 
			{
				return mid;
			}
			
			if (midOrder < order) 
				low = mid + 1;
			else 
				high = mid - 1;		
		}
		
		if (inArray->count() > 0) 
		{
			dict = (MAP_ORDER *)inArray->objectAtIndex(mid);
			midOrder = this->GetMapOrderId(dict);
			if (midOrder > order) 
				return mid;
			else 
				return mid + 1;
		}
		
		return 0;	
	}
	
	void NDMapLayer::QuickSort(cocos2d::CCArray*/*<MAP_ORDER*>*/array, int low, int high)
	{
		if (low < high) 
		{
			int pivotloc = this->Partition(array, low, high);
			this->QuickSort(array, low, pivotloc);
			this->QuickSort(array, pivotloc+1, high);
		}
	}
	
	int NDMapLayer::Partition(cocos2d::CCArray*/*<MAP_ORDER*>*/array, int low, int high)
	{
		MAP_ORDER *dict = (MAP_ORDER *)array->objectAtIndex(low);
		int pivotkey = this->GetMapOrderId(dict);
		
		while (low < high) 
		{				
			dict = (MAP_ORDER *)array->objectAtIndex(high);
			int curKey = this->GetMapOrderId(dict);
			
			while (low < high && curKey >= pivotkey)
			{
				dict = (MAP_ORDER *)array->objectAtIndex(--high);
				curKey = this->GetMapOrderId(dict);
			}
			if (low != high) 
				array->exchangeObjectAtIndex(low,high);			
			
			dict = (MAP_ORDER *)array->objectAtIndex(low);
			curKey = this->GetMapOrderId(dict);
			while (low < high && curKey <= pivotkey) 
			{
				dict = (MAP_ORDER *)array->objectAtIndex(++low);
				curKey = this->GetMapOrderId(dict);
			}
			if (low != high) 
				array->exchangeObjectAtIndex(low, high);		
		}
		
		return low;
	}
	
	void NDMapLayer::MakeFrameRunRecords()
	{
		for (int i = 0; i < 0;/* 临时性注释 郭浩 (int)m_mapData->getAnimationGroups()->count();*/ i++) 
		{
			NDAnimationGroup *aniGroup = 0;//(NDAnimationGroup *)m_mapData->getAnimationGroups()->objectAtIndex(i); ///< 临时性注释 郭浩
			
			cocos2d::CCMutableArray<NDFrameRunRecord*>*runFrameRecordList = new cocos2d::CCMutableArray<NDFrameRunRecord*>();
			
			for (int j = 0; j < 0;/*临时性注释 郭浩 (int)aniGroup->getAnimations()->count();*/ j++) 
			{
				NDFrameRunRecord *frameRunRecord = new NDFrameRunRecord;
				runFrameRecordList->addObject(frameRunRecord);
				frameRunRecord->release();
			}
			
			m_frameRunRecordsOfMapAniGroups->addObject(runFrameRecordList);
			runFrameRecordList->release();
		}
		
		for (int i = 0; i < (int)m_mapData->getSwitchs()->count(); i++) 
		{
			NDFrameRunRecord *frameRunRecord = new NDFrameRunRecord;
			m_frameRunRecordsOfMapSwitch->addObject(frameRunRecord);
			frameRunRecord->release();
		}
	}
	
	void NDMapLayer::ShowRoadSign(bool bShow, int nX /*=0*/, int nY /*=0*/)
	{
		if (!bShow)
		{
			CC_SAFE_DELETE(m_leRoadSign);
			
			return;
		}
		
		if (!m_leRoadSign)
		{
			m_leRoadSign = new NDLightEffect;
			m_leRoadSign->Initialization(tq::CString("%sbutton.spr", NDPath::GetAnimationPath().c_str()));
			m_leRoadSign->SetLightId(0, false);
		}
		
		m_leRoadSign->SetPosition(ccp(nX*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, nY*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET));
	}

	bool NDMapLayer::GetMapDataAniParamReverse(int nIndex)
	{
		anigroup_param *dictAniGroupParam = (anigroup_param *)m_mapData->getAniGroupParams()->objectAtIndex(nIndex);
		bool bReverse	= false;
		if (dictAniGroupParam)
		{
			std::map<std::string, int>::iterator it = dictAniGroupParam->find("reverse");
			if (it != dictAniGroupParam->end())
			{
				bReverse = it->second;
			}
		}

		return bReverse;
	}

	CGPoint NDMapLayer::GetMapDataAniParamPos(int nIndex)
	{
		anigroup_param *dictAniGroupParam = (anigroup_param *)m_mapData->getAniGroupParams()->objectAtIndex(nIndex);
		CGPoint pos		= CGPointZero;	
		if (dictAniGroupParam)
		{
			std::map<std::string, int>::iterator it = dictAniGroupParam->find("positionX");
			if (it != dictAniGroupParam->end())
			{
				pos.x = it->second;
			}
			it = dictAniGroupParam->find("positionY");
			if (it != dictAniGroupParam->end())
			{
				pos.y = it->second;
			}
		}
		return pos;
	}

	CGSize NDMapLayer::GetMapDataAniParamMapSize(int nIndex)
	{
		anigroup_param *dictAniGroupParam = (anigroup_param *)m_mapData->
			getAniGroupParams()->objectAtIndex(nIndex);
		CGSize size	= CGSizeZero;
		if (dictAniGroupParam)
		{
			std::map<std::string, int>::iterator it = dictAniGroupParam->find("mapSizeW");
			if (it != dictAniGroupParam->end())
			{
				size.width = it->second;
			}
			it = dictAniGroupParam->find("mapSizeH");
			if (it != dictAniGroupParam->end())
			{
				size.height = it->second;
			}
		}
		return size;
	}

	int NDMapLayer::GetMapDataAniParamOrderId(int nIndex)
	{
		anigroup_param *dictAniGroupParam = (anigroup_param *)m_mapData->
			getAniGroupParams()->objectAtIndex(nIndex);

		int nOrderId	= 0;
		if (dictAniGroupParam)
		{
			std::map<std::string, int>::iterator it = dictAniGroupParam->find("orderId");
			if (it != dictAniGroupParam->end())
			{
				nOrderId = it->second;
			}
		}

		return nOrderId;
	}

	int NDMapLayer::GetMapOrderId(MAP_ORDER * dict)
	{
		int nOrderId = 0;
		if (dict)
		{
			std::map<std::string, int>::iterator it = dict->find("orderId");
			if (it != dict->end())
			{
				nOrderId = it->second;
			}
		}
		return nOrderId;
	}

	void NDMapLayer::AddChild( NDNode* node, int z, int tag )
	{
		NDNode::AddChild(node,z,tag);
	}
}






