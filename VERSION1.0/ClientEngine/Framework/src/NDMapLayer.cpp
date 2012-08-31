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

bool GetRectPercent(CGRect kRect, CGRect kSubRect, CGRect& kRet)
{
	/*
	 if (!CGRectContainsRect(rect, subrect))
	 {
	 return false;
	 }
	 */

	if (kRect.origin.x > kSubRect.origin.x || kRect.origin.y > kSubRect.origin.y
			|| kRect.origin.x + kRect.size.width
					< kSubRect.origin.x + kSubRect.size.width
			|| kRect.origin.y + kRect.size.height
					< kSubRect.origin.y + kSubRect.size.height)
	{
		return false;
	}

	kRet.origin.x = (kSubRect.origin.x - kRect.origin.x) / kRect.size.width;
	kRet.origin.y = (kSubRect.origin.y - kRect.origin.y) / kRect.size.height;

	kRet.size.width = kSubRect.size.width / kRect.size.width;
	kRet.size.height = kSubRect.size.height / kRect.size.height;

	return true;
}

namespace NDEngine
{
IMPLEMENT_CLASS(NDMapLayer, NDLayer)

NDMapLayer::NDMapLayer()
{
	m_pkMapData = NULL;
	m_nMapIndex = -1;
	m_pkPicMap = NULL;
	//m_texMap = NULL;
	m_pkSwitchAniGroup = NULL;
	m_pkMapData = NULL;
	m_lbTime = NULL;
	m_lbTitle = NULL;
	m_lbTitleBg = NULL;
	m_pkOrders = CCArray::array();
	m_pkOrders->retain();
	m_pkOrdersOfMapscenesAndMapanimations = CCArray::array();
	m_pkOrdersOfMapscenesAndMapanimations->retain();
	m_pkFrameRunRecordsOfMapAniGroups = new CCMutableArray< CCMutableArray<NDFrameRunRecord*>* >();
	m_pkFrameRunRecordsOfMapSwitch = new CCMutableArray< NDFrameRunRecord* >();
	this->m_bBattleBackground = false;
	this->m_bNeedShow = true;
	this->m_ndBlockTimer = NULL;
	this->m_ndTitleTimer = NULL;
	//this->switchSpriteNode=NULL;
	//this->isAutoBossFight = false;
	m_nRoadBlockTimeCount = 0;
	m_nTitleAlpha = 0;
	m_pkSubNode = NDNode::Node();
	m_pkSubNode->SetContentSize(NDDirector::DefaultDirector()->GetWinSize());
//		m_blockTimerTag=-1;
//		m_titleTimerTag=-1;
	m_bShowTitle = false;
	//switch_type=SWITCH_NONE;
	m_pkTreasureBox = NULL;
	m_eBoxStatus = BOX_NONE;
	m_pkRoadSignLightEffect = NULL;
}

NDMapLayer::~NDMapLayer()
{
	CC_SAFE_RELEASE (m_pkOrders);
	CC_SAFE_RELEASE (m_pkOrdersOfMapscenesAndMapanimations);
	CC_SAFE_RELEASE (m_pkFrameRunRecordsOfMapAniGroups);
	CC_SAFE_RELEASE (m_pkFrameRunRecordsOfMapSwitch);
	//CC_SAFE_RELEASE(m_texMap);
	CC_SAFE_RELEASE (m_pkMapData);
	CC_SAFE_RELEASE (m_pkSwitchAniGroup);
	CC_SAFE_RELEASE(m_pkOrders);
	CC_SAFE_RELEASE(m_pkOrders);
	CC_SAFE_RELEASE(m_pkOrders);

	delete m_pkPicMap;
	CC_SAFE_DELETE (m_pkSubNode);
	if (m_ndBlockTimer)
	{
		m_ndBlockTimer->KillTimer(this, blockTimerTag);
		CC_SAFE_DELETE (m_ndBlockTimer);
	}

	if (m_ndTitleTimer)
	{
		m_ndTitleTimer->KillTimer(this, titleTimerTag);
		CC_SAFE_DELETE (m_ndTitleTimer);
	}

// 		if(m_TreasureBox)
// 		{
// 			SAFE_DELETE(m_TreasureBox);
// 		}

	CC_SAFE_DELETE (m_pkRoadSignLightEffect);
}

void NDMapLayer::replaceMapData(int mapId, int center_x, int center_y)
{
	CC_SAFE_RELEASE (m_pkMapData);
	CC_SAFE_RELEASE (m_pkOrders);

	m_pkOrders = CCArray::array();
	m_pkOrders->retain();
	//CC_SAFE_RELEASE(m_texMap);

	delete m_pkPicMap;

	char pszMapFile[256] =
	{ 0 };
	sprintf(pszMapFile, "%smap_%d.map", NDPath::GetMapPath().c_str(), mapId);

	m_pkMapData = new NDMapData;
	m_pkMapData->initWithFile(pszMapFile);

	if (m_pkMapData)
	{
		this->SetContentSize(
				CGSizeMake(
						m_pkMapData->getColumns() * m_pkMapData->getUnitSize(),
						m_pkMapData->getRows() * m_pkMapData->getUnitSize()));

		this->MakeOrdersOfMapscenesAndMapanimations();
		this->MakeFrameRunRecords();

		CGSize kWinSize = NDDirector::DefaultDirector()->GetWinSize();
		m_kScreenCenter = ccp(kWinSize.width / 2,
				this->GetContentSize().height - kWinSize.height / 2);
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
	this->SetScreenCenter(ccp(center_x, center_y));

	ShowRoadSign(false);
}

void NDMapLayer::Initialization(const char* mapFile)
{
	NDUILayer::Initialization();
	this->SetTouchEnabled(true);

	m_pkSwitchAniGroup =
			NDAnimationGroupPool::defaultPool()->addObjectWithModelId(1);

	m_pkMapData = new NDMapData;
	m_pkMapData->initWithFile(mapFile);

	if (m_pkMapData)
	{
		this->SetContentSize(
				CGSizeMake(
						m_pkMapData->getColumns() * m_pkMapData->getUnitSize(),
						m_pkMapData->getRows() * m_pkMapData->getUnitSize()));

		this->MakeOrdersOfMapscenesAndMapanimations();
		this->MakeFrameRunRecords();

		CGSize kWinSize = NDDirector::DefaultDirector()->GetWinSize();
		m_kScreenCenter = ccp(kWinSize.width / 2,
				this->GetContentSize().height - kWinSize.height / 2);
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
	tq::CString strMapFile("%smap_%d.map", NDPath::GetFullMapPath().c_str(),
			mapIndex);
	m_nMapIndex = mapIndex;
	this->Initialization((const char*) strMapFile);
	m_nTitleAlpha = 0;
}

int NDMapLayer::GetMapIndex()
{
	return m_nMapIndex;
}

void NDMapLayer::DidFinishLaunching()
{
	//cpLog(LOG_DEBUG, "load map data complete!");
}

void NDMapLayer::refreshTitle()
{
	if (m_lbTitle && m_lbTitleBg)
	{
		if(m_bShowTitle)
		{
			if(m_nTitleAlpha < 255)
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

					NDPicture* pkPicture1 = m_lbTitle->GetPicture();

					pkPicture1->SetColor(ccc4(m_nTitleAlpha,m_nTitleAlpha,m_nTitleAlpha,m_nTitleAlpha));

					NDPicture* pkPicture2 = m_lbTitleBg->GetPicture();

					pkPicture2->SetColor(ccc4(m_nTitleAlpha,m_nTitleAlpha,m_nTitleAlpha,m_nTitleAlpha));

					m_nTitleAlpha += 5;
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
			if(m_nTitleAlpha >= 0)
			{
				if(m_lbTitle && m_lbTitleBg)
				{
					int nX = NDDirector::DefaultDirector()->GetWinSize().width / 2 - 150;
					int nY = 60;
					//NDLog("x:%d,y:%d",x,y);
					m_lbTitleBg->SetFrameRect(CGRectMake(NDDirector::DefaultDirector()->
							GetWinSize().width / 2 - 210, nY, 420, 60));
					//m_lbTitleBg->draw();
					m_lbTitle->SetFrameRect(CGRectMake(nX, nY, 300, 60));

					NDPicture* pkPicture_1 = m_lbTitle->GetPicture();

					pkPicture_1->SetColor(ccc4(m_nTitleAlpha,m_nTitleAlpha,m_nTitleAlpha,m_nTitleAlpha));

					NDPicture* pkPicture_2 = m_lbTitleBg->GetPicture();

					pkPicture_2->SetColor(ccc4(m_nTitleAlpha,m_nTitleAlpha,m_nTitleAlpha,m_nTitleAlpha));

					m_nTitleAlpha -= 15;
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
void NDMapLayer::ShowTitle(int name_row, int name_col)
{
	m_bShowTitle = true;
	m_nTitleAlpha = 0;
	if (!m_lbTitle)
	{
		m_lbTitle = new NDUIImage;
		m_lbTitle->Initialization();
		NDPicture* picture = NDPicturePool::DefaultPool()->AddPicture(
				tq::CString("%smap_title.png",
						NDEngine::NDPath::GetImagePath().c_str()));
		//picture->SetColor(ccc4(0, 0, 0,0));
		int col = name_col;
		int row = name_row;
		picture->Cut(CGRectMake(col * 300, row * 60, 300, 60));
		m_lbTitle->SetPicture(picture, true);
	}

	if (!m_lbTitleBg)
	{
		m_lbTitleBg = new NDUIImage;
		m_lbTitleBg->Initialization();
		NDPicture* bg = NDPicturePool::DefaultPool()->AddPicture(
				tq::CString("%map_title_bg.png",
						NDEngine::NDPath::GetImagePath().c_str()));
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
void NDMapLayer::PlayNDSprite(const char* pszSpriteFile, int nPosx, int nPosy,
		int nAniNo, int nPlayTimes)
{
	NDSprite* pSprite = new NDSprite;
	//NSString* aniPath=[NSString stringWithUTF8String:NDEngine::NDPath::GetAnimationPath().c_str()];
	pSprite->Initialization(
			tq::CString("%s%s", NDEngine::NDPath::GetAnimationPath().c_str(),
					pszSpriteFile));
	pSprite->SetPosition(CGPointMake(nPosx + 64, nPosy));
	pSprite->SetCurrentAnimation(0, false);
	bool bSet = this->isMapRectIntersectScreen(pSprite->GetSpriteRect());
	pSprite->BeforeRunAnimation(bSet);

	if (bSet)
	{
		while (nPlayTimes > 0)
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
	if (m_pkTreasureBox)
	{
		if (m_eBoxStatus == BOX_SHOWING)
		{
			if (m_pkTreasureBox->IsAnimationComplete())
			{
				m_pkTreasureBox->SetCurrentAnimation(1, false);
				m_eBoxStatus = BOX_CLOSE;
			}
		}
		else if (m_eBoxStatus == BOX_OPENING)
		{
			if (m_pkTreasureBox->IsAnimationComplete())
			{
				m_pkTreasureBox->SetCurrentAnimation(3, false);
				m_eBoxStatus = BOX_OPENED;
			}
		}
	}
}

void NDMapLayer::draw()
{
	//PerformanceTestName("地图层draw");

	if (m_pkMapData && m_bNeedShow)
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
		if (this->m_nRoadBlockTimeCount > 0 && !m_bBattleBackground)
		{
			//NDLog("showTime");
			if(!m_lbTime)
			{
				m_lbTime = new NDUILabel;
				m_lbTime->Initialization();
				m_lbTime->SetFontSize(15);

			}

			int mi = this->m_nRoadBlockTimeCount / 60;
			tq::CString str_mi;

			if(mi < 10)
			{
				str_mi.Format("0%d",mi);
			}
			else
			{
				str_mi.Format("%d",mi);
			}

			int se = this->m_nRoadBlockTimeCount % 60;
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

			CGSize kSize = getStringSize(str_time, 30);

			if (!m_lbTime->GetParent() && m_pkSubNode)
			{
				m_pkSubNode->AddChild(m_lbTime);
			}

			m_lbTime->SetFontColor(ccc4(255,0,0,255));
			m_lbTime->SetFontSize(30);

			int x = m_kScreenCenter.x - (kSize.width) / 2;
			int y = m_kScreenCenter.y - GetContentSize().height - (kSize.height) / 2 +
			NDDirector::DefaultDirector()->GetWinSize().height;
			//NDLog("x:%d,y:%d",x,y);
			m_lbTime->SetFrameRect(CGRectMake(x, y, kSize.width, kSize.height + 5));
			m_lbTime->draw();
		}

		if (m_pkRoadSignLightEffect)
		{
			m_pkRoadSignLightEffect->Run(this->GetContentSize());
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
	CC_SAFE_RELEASE (m_pkFrameRunRecordsOfMapSwitch);

	m_pkFrameRunRecordsOfMapSwitch = new cocos2d::CCMutableArray<
			NDFrameRunRecord*>();

	for (int i = 0; i < (int) m_pkMapData->getSwitchs()->count(); i++)
	{
		NDFrameRunRecord *pkFrameRunRecord = new NDFrameRunRecord;
		m_pkFrameRunRecordsOfMapSwitch->addObject(pkFrameRunRecord);
		pkFrameRunRecord->release();
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
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	CGRect scrRect = CGRectMake(m_kScreenCenter.x - winSize.width / 2,
			m_kScreenCenter.y - winSize.height / 2, winSize.width,
			winSize.height);

	unsigned int orderCount = m_pkMapData->getBgTiles()->count();
	for (unsigned int i = 0; i < orderCount; i++)
	{
		NDTile* pkTile = (NDTile*) m_pkMapData->getBgTiles()->objectAtIndex(i);
		if (pkTile && CGRectIntersectsRect(scrRect, pkTile->getDrawRect()))
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
	MakeOrders();

	unsigned int orderCount = m_pkOrders->count(), uiSceneTileCount =
			m_pkMapData->getSceneTiles()->count(), aniGroupCount =
			m_pkMapData->getAnimationGroups()->count(), switchCount =
			m_pkMapData->getSwitchs()->count();

	//PerformanceTestPerFrameBeginName(" NDMapLayer::DrawScenesAndAnimations");

	for (unsigned int i = 0; i < orderCount; i++)
	{
		//PerformanceTestPerFrameBeginName(" NDMapLayer::DrawScenesAndAnimations inner");

		MAP_ORDER* pkDict = (MAP_ORDER*) m_pkOrders->objectAtIndex(i);
		unsigned int uiIndex = 0;
		if (pkDict)
		{
			std::map<std::string, int>::iterator it = pkDict->find("index");
			if (it != pkDict->end())
			{
				uiIndex = it->second;
			}
		}

		if (uiIndex < uiSceneTileCount) //布景
		{
			//PerformanceTestPerFrameBeginName("布景");
			NDTile *pkTile =
					(NDTile *) m_pkMapData->getSceneTiles()->objectAtIndex(
							uiIndex);

			if (pkTile)
			{
				if (isMapRectIntersectScreen(pkTile->getDrawRect()))
				{
					pkTile->draw();
				}
			}
			//PerformanceTestPerFrameEndName("布景");
		}

// 			else if (m_bBattleBackground) // 战斗状态，不绘制其他地表元素
// 			{
// 				continue;
// 			}
		else if (uiIndex < uiSceneTileCount + aniGroupCount) //地表动画
		{
			//PerformanceTestPerFrameBeginName("地表动画");
			uiIndex -= uiSceneTileCount;

			NDAnimationGroup* pkAniGroup =
					(NDAnimationGroup*) m_pkMapData->getAnimationGroups()->objectAtIndex(
							uiIndex);
			CCMutableArray<NDFrameRunRecord*>* pkFrameRunRecordList =
					m_pkFrameRunRecordsOfMapAniGroups->getObjectAtIndex(
							uiIndex);

			pkAniGroup->setReverse(this->GetMapDataAniParamReverse(uiIndex));
			pkAniGroup->setPosition(this->GetMapDataAniParamPos(uiIndex));
			pkAniGroup->setRunningMapSize(GetMapDataAniParamMapSize(uiIndex));

			unsigned int uiAniCount = pkAniGroup->getAnimations()->count();

			for (unsigned int j = 0; j < uiAniCount; j++)
			{
				NDFrameRunRecord *pkFrameRunRecord =
						pkFrameRunRecordList->getObjectAtIndex(j);
				NDAnimation *pkAnimation =
						(NDAnimation *) pkAniGroup->getAnimations()->objectAtIndex(
								j);

				if (this->isMapRectIntersectScreen(pkAnimation->getRect()))
				{
					pkAnimation->runWithRunFrameRecord(pkFrameRunRecord, true);
				}
				else
				{
					pkAnimation->runWithRunFrameRecord(pkFrameRunRecord, false);
				}
			}
			//PerformanceTestPerFrameEndName("地表动画");
		}
		else if (uiIndex < uiSceneTileCount + aniGroupCount + switchCount) //切屏点
		{
			//PerformanceTestPerFrameBeginName("切屏点");
			uiIndex -= m_pkMapData->getSceneTiles()->count()
					+ m_pkMapData->getAnimationGroups()->count();

			NDMapSwitch *pkMapSwitch =
					(NDMapSwitch *) m_pkMapData->getSwitchs()->objectAtIndex(
							uiIndex);
			NDFrameRunRecord *pkFrameRunRecord =
					m_pkFrameRunRecordsOfMapSwitch->getObjectAtIndex(uiIndex);

			m_pkSwitchAniGroup->setReverse(false);

			CGPoint kPos = ccp(
					pkMapSwitch->getX() * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
					pkMapSwitch->getY() * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET);

			m_pkSwitchAniGroup->setPosition(kPos);

			m_pkSwitchAniGroup->setRunningMapSize(GetContentSize());

			if (m_pkSwitchAniGroup->getAnimations()->count() > 0)
			{
				NDAnimation *pkAnimation =
						(NDAnimation *) m_pkSwitchAniGroup->getAnimations()->objectAtIndex(
								0);

				if (this->isMapRectIntersectScreen(pkAnimation->getRect()))
				{
					pkAnimation->runWithRunFrameRecord(pkFrameRunRecord, true);
					pkMapSwitch->draw();
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
			uiIndex -= uiSceneTileCount + aniGroupCount + switchCount;

			if (uiIndex < 0 || uiIndex >= this->GetChildren().size())
			{
				continue;
			}

			NDNode* pkNode = this->GetChildren().at(uiIndex);
			if (pkNode->IsKindOfClass(RUNTIME_CLASS(NDSprite)))
			{
				NDSprite* pkSprite = (NDSprite*) pkNode;
				bool bSet = this->isMapRectIntersectScreen(
						pkSprite->GetSpriteRect());
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

				pkSprite->BeforeRunAnimation(bSet);

				if (true) //bSet)
				{
					pkSprite->RunAnimation(pkSprite->DrawEnabled());
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
	return ccpAdd(
			ccpSub(screenPoint,
					CGPointMake(winSize.width / 2, winSize.height / 2)),
			m_kScreenCenter);
}

bool NDMapLayer::isMapPointInScreen(CGPoint mapPoint)
{
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	return CGRectContainsPoint(
			CGRectMake(m_kScreenCenter.x - winSize.width / 2,
					m_kScreenCenter.y - winSize.height / 2, winSize.width,
					winSize.height), mapPoint);
}

bool NDMapLayer::isMapRectIntersectScreen(CGRect mapRect)
{
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	CGRect scrRect = CGRectMake(m_kScreenCenter.x - winSize.width / 2,
			m_kScreenCenter.y - winSize.height / 2, winSize.width,
			winSize.height);
	return CGRectIntersectsRect(scrRect, mapRect);
}

void NDMapLayer::SetPosition(CGPoint kPosition)
{
	CGSize kWinSize = NDDirector::DefaultDirector()->GetWinSize();

	if (kPosition.x > 0)
	{
		kPosition.x = 0;
	}

	if (kPosition.x < kWinSize.width - this->GetContentSize().width)
	{
		kPosition.x = kWinSize.width - this->GetContentSize().width;
	}

	if (kPosition.y > 0)
	{
		kPosition.y = 0;
	}

	if (kPosition.y < kWinSize.height - this->GetContentSize().height)
	{
		kPosition.y = kWinSize.height - this->GetContentSize().height;
	}

	this->m_ccNode->setPositionInPixels(kPosition);
}

bool NDMapLayer::SetScreenCenter(CGPoint kPoint)
{
// 		if(this->m_bBattleBackground){
// 			return false;
// 		}

	bool bOverBoder = false;
	int width = this->GetContentSize().width;
	int height = this->GetContentSize().height;

	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();

	if (kPoint.x > width - winSize.width / 2)
	{
		kPoint.x = width - winSize.width / 2;
		bOverBoder = true;
	}
	if (kPoint.x < winSize.width / 2)
	{
		kPoint.x = winSize.width / 2;
		bOverBoder = true;
	}

	if (kPoint.y > height - winSize.height / 2)
	{
		kPoint.y = height - winSize.height / 2;
		bOverBoder = true;
	}
	if (kPoint.y < winSize.height / 2)
	{
		kPoint.y = winSize.height / 2;
		bOverBoder = true;
	}

	//this->ReflashMapTexture(m_screenCenter, p);

	//modify yay
	CGPoint backOff = ccpSub(kPoint, m_kScreenCenter);
	m_pkMapData->moveBackGround(backOff.x, backOff.y);
	//[m_mapData moveBackGround:backOff.x,backOff.y];

	m_kScreenCenter = kPoint;
	//NDLog("center:%f,%f",p.x,p.y);
	this->SetPosition(
			CGPointMake(winSize.width / 2 - kPoint.x,
					winSize.height / 2 + kPoint.y - height));

	return bOverBoder;
}

CGPoint NDMapLayer::GetScreenCenter()
{
	return m_kScreenCenter;
}

NDMapData *NDMapLayer::GetMapData()
{
	return m_pkMapData;
}

void NDMapLayer::setStartRoadBlockTimer(int time, int x, int y)
{
	if (!m_ndBlockTimer)
	{
		this->m_ndBlockTimer = new NDTimer;
	}

	this->m_ndBlockTimer->SetTimer(this, blockTimerTag, 1.0f);
	this->m_nRoadBlockTimeCount = time;

	if (m_pkMapData)
	{
		m_pkMapData->setRoadBlock(x, y);
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
	if (blockTimerTag == tag)
	{
		this->m_nRoadBlockTimeCount--;
		//NDLog("tag:%d,count:%d",tag,this->roadBlockTimeCount);
		if (m_nRoadBlockTimeCount <= 0)
		{
			m_pkMapData->setRoadBlock(-1, -1);
			m_nRoadBlockTimeCount = 0;
			m_ndBlockTimer->KillTimer(this, blockTimerTag);
			m_ndBlockTimer = NULL;

			/*if(this->isAutoBossFight)
			 {
			 this->walkToBoss();
			 }*/
		}
	}
	else if (tag == titleTimerTag)
	{
		this->m_ndTitleTimer->KillTimer(this, titleTimerTag);
		this->m_ndTitleTimer = NULL;
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
	const std::vector<NDNode*>& kCLD = this->GetChildren();
	std::map<int, NDNode*> kMapDrawlast;
	//std::map<unsigned int, NDManualRole*> mapRoleCell;
	for (int i = 0; i < (int) kCLD.size(); i++)
	{
		NDNode* pkNode = kCLD.at(i);
// 			if (node->IsKindOfClass(RUNTIME_CLASS(NDManualRole))) 
// 			{
// 				NDManualRole* role = (NDManualRole*)node;
// 				if (role->IsInState(USERSTATE_FLY) && NDMapMgrObj.canFly()) 
// 				{
// 					mapDrawlast[i] = node;
// 					continue;
// 				}
// 			}			

		if (pkNode->IsKindOfClass(RUNTIME_CLASS(NDSprite)))
		{
			NDSprite* pkSprite = (NDSprite*) pkNode;

			int nIndex = InsertIndex(pkSprite->GetOrder(), m_pkOrders);

			MAP_ORDER* pkDict = new MAP_ORDER;

			(*pkDict)["index"] = i + m_pkMapData->getSceneTiles()->count()
					+ m_pkMapData->getAnimationGroups()->count()
					+ m_pkMapData->getSwitchs()->count();

			(*pkDict)["orderId"] = pkSprite->GetOrder();

			//[dict setObject:[NSNumber numberWithInt:i + [m_mapData.sceneTiles count]+ [m_mapData.animationGroups count] + [m_mapData.switchs count]] forKey:@"index"];
			//[dict setObject:[NSNumber numberWithInt:sprite->GetOrder()] forKey:@"orderId"];

			m_pkOrders->insertObject(pkDict, nIndex);
			pkDict->release();

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

	if (kMapDrawlast.size() == 0)
	{
		return;
	}

	CCArray* pkFlySpriteOrder = CCArray::array();
	pkFlySpriteOrder->retain();

	unsigned int uiOrderCount = int(m_pkOrders->count());

	if (uiOrderCount > 0)
	{
		uiOrderCount -= 1;
	}

	for (std::map<int, NDNode*>::iterator it = kMapDrawlast.begin();
			it != kMapDrawlast.end(); it++)
	{
		NDNode *pkNode = it->second;

		if (pkNode->IsKindOfClass(RUNTIME_CLASS(NDSprite)))
		{
			NDSprite* pkSprite = (NDSprite*) pkNode;

			MAP_ORDER* pkDict = new MAP_ORDER;

			(*pkDict)["index"] = it->first
					+ m_pkMapData->getSceneTiles()->count()
					+ m_pkMapData->getAnimationGroups()->count()
					+ m_pkMapData->getSwitchs()->count();

			(*pkDict)["orderId"] = pkSprite->GetOrder();

			//NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

			//[dict setObject:[NSNumber numberWithInt:it->first + [m_mapData.sceneTiles count] + [m_mapData.animationGroups count] + [m_mapData.switchs count]] forKey:@"index"];
			//[dict setObject:[NSNumber numberWithInt:sprite->GetOrder()] forKey:@"orderId"];

			if (it != kMapDrawlast.begin())
			{
				unsigned index = this->InsertIndex(pkSprite->GetOrder(),
						pkFlySpriteOrder);
				m_pkOrders->insertObject(pkDict, index + uiOrderCount);
				pkFlySpriteOrder->insertObject(pkDict, index);
			}
			else
			{
				pkFlySpriteOrder->addObject(pkDict);

				m_pkOrders->addObject(pkDict);
			}

			pkDict->release();
		}
	}

	pkFlySpriteOrder->release();
}

void NDMapLayer::MakeOrdersOfMapscenesAndMapanimations()
{
	m_pkOrdersOfMapscenesAndMapanimations->removeAllObjects();
	for (int i = 0; i < (int) m_pkMapData->getSceneTiles()->count(); i++)
	{
		NDSceneTile *pkSceneTile =
				(NDSceneTile *) m_pkMapData->getSceneTiles()->objectAtIndex(i);

		int orderId = 0;//pkSceneTile->getOrderID();

		MAP_ORDER *dict = new MAP_ORDER;

		(*dict)["index"] = i;
		(*dict)["orderId"] = orderId;

		//NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

		//[dict setObject:[NSNumber numberWithInt:i] forKey:@"index"];
		//[dict setObject:[NSNumber numberWithInt:orderId] forKey:@"orderId"];

		m_pkOrdersOfMapscenesAndMapanimations->addObject(dict);
		dict->release();
	}
	for (int i = 0; i < (int) m_pkMapData->getAniGroupParams()->count(); i++)
	{
		//NSDictionary *dictAniGroupParam = [m_mapData.aniGroupParams objectAtIndex:i];
		int nOrderID = this->GetMapDataAniParamOrderId(i);

		MAP_ORDER *pkDict = new MAP_ORDER;

		(*pkDict)["index"] = i + m_pkMapData->getSceneTiles()->count();
		(*pkDict)["orderId"] = nOrderID;

		//NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		//[dict setObject:[NSNumber numberWithInt:i + [m_mapData.sceneTiles count]] forKey:@"index"];
		//[dict setObject:[NSNumber numberWithInt:orderId] forKey:@"orderId"];

		m_pkOrdersOfMapscenesAndMapanimations->addObject(pkDict);
		pkDict->release();
	}
	for (int i = 0; i < (int) m_pkMapData->getSwitchs()->count(); i++)
	{
		if (m_pkSwitchAniGroup->getAnimations()->count() > 0)
		{
			//NDAnimation *animation = [m_switchAniGroup.animations objectAtIndex:0];
			NDMapSwitch *pkMapSwitch =
					(NDMapSwitch *) m_pkMapData->getSwitchs()->objectAtIndex(i);
			//int orderId = mapSwitch.y * m_mapData.unitSize;

			int orderId = pkMapSwitch->getY() * m_pkMapData->getUnitSize();	//+ 32 ;

			MAP_ORDER *dict = new MAP_ORDER;

			(*dict)["index"] = i + m_pkMapData->getSceneTiles()->count()
					+ m_pkMapData->getAniGroupParams()->count();
			(*dict)["orderId"] = orderId;

			//NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
			//[dict setObject:[NSNumber numberWithInt:i + [m_mapData.sceneTiles count] + [m_mapData.aniGroupParams count]] forKey:@"index"];
			//[dict setObject:[NSNumber numberWithInt:orderId] forKey:@"orderId"];

			m_pkOrdersOfMapscenesAndMapanimations->addObject(dict);
			dict->release();
		}
	}

	this->QuickSort(m_pkOrdersOfMapscenesAndMapanimations, 0,
			m_pkOrdersOfMapscenesAndMapanimations->count() - 1);
}

int NDMapLayer::InsertIndex(int order, cocos2d::CCArray*/*<MAP_ORDER*>*/inArray)
{
	int nLow = 0;
	int nHigh = inArray->count() - 1;

	int nMid = 0;
	int nMidOrder;
	MAP_ORDER *pkDict;

	while (nLow < nHigh)
	{

		pkDict = (MAP_ORDER *) inArray->objectAtIndex(nHigh);
		int highOrder = this->GetMapOrderId(pkDict);

		//[[dict objectForKey:@"orderId"] intValue];
		if (order > highOrder)
		{
			return nHigh + 1;
		}

		pkDict = (MAP_ORDER *) inArray->objectAtIndex(nLow);
		int lowOrder = this->GetMapOrderId(pkDict);
		if (order < lowOrder)
		{
			return nLow;
		}

		nMid = (nLow + nHigh) / 2;
		pkDict = (MAP_ORDER *) inArray->objectAtIndex(nMid);
		nMidOrder = this->GetMapOrderId(pkDict);
		if (nMidOrder == order)
		{
			return nMid;
		}

		if (nMidOrder < order)
			nLow = nMid + 1;
		else
			nHigh = nMid - 1;
	}

	if (inArray->count() > 0)
	{
		pkDict = (MAP_ORDER *) inArray->objectAtIndex(nMid);
		nMidOrder = this->GetMapOrderId(pkDict);
		if (nMidOrder > order)
			return nMid;
		else
			return nMid + 1;
	}

	return 0;
}

void NDMapLayer::QuickSort(cocos2d::CCArray*/*<MAP_ORDER*>*/array, int low,
		int high)
{
	if (low < high)
	{
		int pivotloc = this->Partition(array, low, high);
		this->QuickSort(array, low, pivotloc);
		this->QuickSort(array, pivotloc + 1, high);
	}
}

int NDMapLayer::Partition(cocos2d::CCArray*/*<MAP_ORDER*>*/array, int low,
		int high)
{
	MAP_ORDER *dict = (MAP_ORDER *) array->objectAtIndex(low);
	int nPivotkey = this->GetMapOrderId(dict);

	while (low < high)
	{
		dict = (MAP_ORDER *) array->objectAtIndex(high);
		int curKey = this->GetMapOrderId(dict);

		while (low < high && curKey >= nPivotkey)
		{
			dict = (MAP_ORDER *) array->objectAtIndex(--high);
			curKey = this->GetMapOrderId(dict);
		}
		if (low != high)
			array->exchangeObjectAtIndex(low, high);

		dict = (MAP_ORDER *) array->objectAtIndex(low);
		curKey = this->GetMapOrderId(dict);
		while (low < high && curKey <= nPivotkey)
		{
			dict = (MAP_ORDER *) array->objectAtIndex(++low);
			curKey = this->GetMapOrderId(dict);
		}
		if (low != high)
			array->exchangeObjectAtIndex(low, high);
	}

	return low;
}

void NDMapLayer::MakeFrameRunRecords()
{
	for (int i = 0; i < (int) m_pkMapData->getAnimationGroups()->count(); i++)
	{
		NDAnimationGroup *pkAniGroup =
				(NDAnimationGroup *) m_pkMapData->getAnimationGroups()->objectAtIndex(
						i);

		cocos2d::CCMutableArray<NDFrameRunRecord*>* pkRunFrameRecordList =
				new cocos2d::CCMutableArray<NDFrameRunRecord*>();

		for (int j = 0; j < (int) pkAniGroup->getAnimations()->count(); j++)
		{
			NDFrameRunRecord *pkFrameRunRecord = new NDFrameRunRecord;
			pkRunFrameRecordList->addObject(pkFrameRunRecord);
			pkFrameRunRecord->release();
		}

		m_pkFrameRunRecordsOfMapAniGroups->addObject(pkRunFrameRecordList);
		pkRunFrameRecordList->release();
	}

	for (int i = 0; i < (int) m_pkMapData->getSwitchs()->count(); i++)
	{
		NDFrameRunRecord *pkFrameRunRecord = new NDFrameRunRecord;
		m_pkFrameRunRecordsOfMapSwitch->addObject(pkFrameRunRecord);
		pkFrameRunRecord->release();
	}
}

void NDMapLayer::ShowRoadSign(bool bShow, int nX /*=0*/, int nY /*=0*/)
{
	if (!bShow)
	{
		CC_SAFE_DELETE (m_pkRoadSignLightEffect);

		return;
	}

	if (!m_pkRoadSignLightEffect)
	{
		m_pkRoadSignLightEffect = new NDLightEffect;
		m_pkRoadSignLightEffect->Initialization(
				tq::CString("%sbutton.spr",
						NDPath::GetAnimationPath().c_str()));
		m_pkRoadSignLightEffect->SetLightId(0, false);
	}

	m_pkRoadSignLightEffect->SetPosition(
			ccp(nX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
					nY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
}

bool NDMapLayer::GetMapDataAniParamReverse(int nIndex)
{
	anigroup_param *dictAniGroupParam =
			(anigroup_param *) m_pkMapData->getAniGroupParams()->objectAtIndex(
					nIndex);
	bool bReverse = false;
	if (dictAniGroupParam)
	{
		std::map<std::string, int>::iterator it = dictAniGroupParam->find(
				"reverse");
		if (it != dictAniGroupParam->end())
		{
			bReverse = it->second;
		}
	}

	return bReverse;
}

CGPoint NDMapLayer::GetMapDataAniParamPos(int nIndex)
{
	anigroup_param *dictAniGroupParam =
			(anigroup_param *) m_pkMapData->getAniGroupParams()->objectAtIndex(
					nIndex);
	CGPoint pos = CGPointZero;
	if (dictAniGroupParam)
	{
		std::map<std::string, int>::iterator it = dictAniGroupParam->find(
				"positionX");
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
	anigroup_param *dictAniGroupParam =
			(anigroup_param *) m_pkMapData->getAniGroupParams()->objectAtIndex(
					nIndex);
	CGSize size = CGSizeZero;
	if (dictAniGroupParam)
	{
		std::map<std::string, int>::iterator it = dictAniGroupParam->find(
				"mapSizeW");
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
	anigroup_param *dictAniGroupParam =
			(anigroup_param *) m_pkMapData->getAniGroupParams()->objectAtIndex(
					nIndex);

	int nOrderId = 0;
	if (dictAniGroupParam)
	{
		std::map<std::string, int>::iterator it = dictAniGroupParam->find(
				"orderId");
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

void NDMapLayer::AddChild(NDNode* node, int z, int tag)
{
	NDNode::AddChild(node, z, tag);
}
}

