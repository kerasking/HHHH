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
//#include "NDUtil.h"
#include "NDDebugOpt.h"
#include "NDDataTransThread.h"
#include "NDMsgDefine.h"
//#include "NDMonster.h"
//#include "BattleMgr.h"//
#include "NDBaseScriptMgr.h"
#include "NDSharedPtr.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "NDConsole.h"
#endif
#include "UsePointPls.h"
#include "TQString.h"
#include "TQPlatform.h"
#include "NDUtil.h"
#include "NDBaseBattleMgr.h"

using namespace cocos2d;

#define IMAGE_PATH										\
				[NSString stringWithUTF8String:				\
				NDEngine::NDPath::GetImagePath().c_str()]

#define MAP_NAME_SIZE_BIG (30*NDDirector::DefaultDirector()->GetScaleFactor())
#define MAP_NAME_SIZE_SMALL (15*NDDirector::DefaultDirector()->GetScaleFactor())


extern NDMapLayer* g_pMapLayer = NULL; //for debug only.

bool GetIntersectRect(CCRect first, CCRect second, CCRect& ret)
{
	if (!cocos2d::CCRect::CCRectIntersectsRect(first, second))
	{
		return false;
	}

	//todo(zjh)
	//ret = CCRectIntersection(first, second);

	return true;
}

bool GetRectPercent(CCRect kRect, CCRect kSubRect, CCRect& kRet)
{
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


//////////////////////////////////////////////////////////////////////////////////////////////
NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDMapLayer, NDLayer)

NDMapLayer::NDMapLayer()
{
//	WriteCon( "NDMapLayer::NDMapLayer()\r\n"); ///< 调用Logic的东西 郭浩

	m_pkMapData = NULL;
	m_nMapIndex = -1;
	m_pkPicMap = NULL;
	m_nBattleType = 0;
	m_pkSwitchAniGroup = NULL;
	m_lbTime = NULL;
	m_lbTitle = NULL;
	m_lbTitleBg = NULL;
	m_pkSwitchSpriteNode = 0;

	m_pkOrders = CCArray::array();
	m_pkOrders->retain();
	m_pkOrdersOfMapscenesAndMapanimations = CCArray::array();
	m_pkOrdersOfMapscenesAndMapanimations->retain();

	//m_pkFrameRunRecordsOfMapAniGroups = new CCMutableArray< CCMutableArray<NDFrameRunRecord*>* >();
	//m_pkFrameRunRecordsOfMapSwitch = new CCMutableArray< NDFrameRunRecord* >();
	m_pkFrameRunRecordsOfMapAniGroups = new CCArray();
	m_pkFrameRunRecordsOfMapSwitch = new CCArray();
	m_pkFrameRunRecordsOfMapSwitch->retain();
	m_pkFrameRunRecordsOfMapAniGroups->retain();
	m_bBattleBackground = false;
	m_bNeedShow = true;
	m_ndBlockTimer = NULL;
	m_ndTitleTimer = NULL;
	//m_pkSwitchSpriteNode=NULL;
	//isAutoBossFight = false;
	m_nRoadBlockTimeCount = 0;
	m_nTitleAlpha = 0;
	m_pkSubNode = NDNode::Node();
	m_pkSubNode->SetContentSize( CCDirector::sharedDirector()->getWinSizeInPixels());
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
//	WriteCon( "NDMapLayer::~NDMapLayer()\r\n"); ///< 调用Logic的东西 郭浩

	CC_SAFE_RELEASE (m_pkOrders);
	CC_SAFE_RELEASE (m_pkOrdersOfMapscenesAndMapanimations);
	CC_SAFE_RELEASE (m_pkFrameRunRecordsOfMapAniGroups);
	CC_SAFE_RELEASE (m_pkFrameRunRecordsOfMapSwitch);
	//CC_SAFE_RELEASE(m_texMap);
	CC_SAFE_RELEASE (m_pkMapData);
	CC_SAFE_RELEASE (m_pkSwitchAniGroup);

	CC_SAFE_DELETE(m_pkPicMap);
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

// 		if(m_pkTreasureBox)
// 		{
// 			SAFE_DELETE(m_pkTreasureBox);
// 		}

	CC_SAFE_DELETE (m_pkRoadSignLightEffect);

	g_pMapLayer = NULL;
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
		SetContentSize(
				CCSizeMake(
						m_pkMapData->getColumns() * m_pkMapData->getUnitSize(),
						m_pkMapData->getRows() * m_pkMapData->getUnitSize()));

		MakeOrdersOfMapscenesAndMapanimations();
		MakeFrameRunRecords();

		CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();
		m_kScreenCenter = ccp(kWinSize.width / 2,
				GetContentSize().height - kWinSize.height / 2);
		m_ccNode->setPosition(0, 0);

		/*
		 m_texMap = [[CCTexture2D alloc] initWithContentSize:winSize];
		 m_picMap = new NDPicture();
		 m_picMap->SetTexture(m_texMap);

		 ReflashMapTexture(ccp(-winSize.width / 2, -winSize.height / 2), m_screenCenter);
		 m_areaCamarkSplit = IntersectionAreaNone;
		 m_ptCamarkSplit = ccp(0, 0);
		 */
	}
	SetScreenCenter(ccp(center_x, center_y));

	ShowRoadSign(false);
}

//@check
void NDMapLayer::Initialization(const char* mapFile)
{
	NDLayer::Initialization();
	SetTouchEnabled(true);

	m_pkSwitchAniGroup = NDAnimationGroupPool::defaultPool()->addObjectWithModelId(switch_ani_modelId);

	m_pkMapData = new NDMapData;
	ND_ASSERT_NO_RETURN(NULL == m_pkMapData);
	m_pkMapData->initWithFile(mapFile);

	SetContentSize(CCSizeMake(m_pkMapData->getColumns() * m_pkMapData->getUnitSize(),
		                    m_pkMapData->getRows() * m_pkMapData->getUnitSize()));

	MakeOrdersOfMapscenesAndMapanimations();
	MakeFrameRunRecords();

	CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	m_kScreenCenter = ccp(kWinSize.width / 2,
			GetContentSize().height - kWinSize.height / 2);
	m_ccNode->setPosition(0, 0);

	g_pMapLayer = this;
}

void NDMapLayer::Initialization(int mapIndex)
{
	tq::CString strMapFile("%smap_%d.map", NDPath::GetMapPath().c_str(), mapIndex);
	m_nMapIndex = mapIndex;
	Initialization((const char*) strMapFile);
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
					int x = CCDirector::sharedDirector()->getWinSizeInPixels().width / 2 - 150;
					int y = 60;
					//NDLog("x:%d,y:%d",x,y);
					m_lbTitleBg->SetFrameRect(CCRectMake(
						CCDirector::sharedDirector()->getWinSizeInPixels().width / 2 - 210, 
							y, 420, 60));

					//m_lbTitleBg->draw();
					m_lbTitle->SetFrameRect(CCRectMake(x, y, 300, 60));

					NDPicture* pkPicture1 = m_lbTitle->GetPicture();

					pkPicture1->SetColor(ccc4(m_nTitleAlpha,m_nTitleAlpha,m_nTitleAlpha,m_nTitleAlpha));

					NDPicture* pkPicture2 = m_lbTitleBg->GetPicture();

					pkPicture2->SetColor(ccc4(m_nTitleAlpha,m_nTitleAlpha,m_nTitleAlpha,m_nTitleAlpha));

					m_nTitleAlpha += 5;
				}
			}
			else if(!m_ndTitleTimer)
			{
				m_ndTitleTimer = new NDTimer;
				m_ndTitleTimer->SetTimer(this, titleTimerTag, 3.0f);
			}
		}
		else
		{
			if(m_nTitleAlpha >= 0)
			{
				if(m_lbTitle && m_lbTitleBg)
				{
					int nX = CCDirector::sharedDirector()->getWinSizeInPixels().width / 2 - 150;
					int nY = 60;
					//NDLog("x:%d,y:%d",x,y);
					m_lbTitleBg->SetFrameRect(
						CCRectMake(CCDirector::sharedDirector()->getWinSizeInPixels().width / 2 - 210, nY, 420, 60));

					//m_lbTitleBg->draw();
					m_lbTitle->SetFrameRect(CCRectMake(nX, nY, 300, 60));

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
 if(!m_pkTreasureBox)
 {
 box_status=BOX_SHOWING;
 m_pkTreasureBox = new NDSprite;
 NSString aniPath=[CCString::stringWithUTF8String:NDEngine::NDPath::GetAnimationPath().c_str()];
 m_pkTreasureBox->Initialization([[NSString stringWithFormat:@"%@treasure_box.spr", aniPath] UTF8String]);
 m_pkTreasureBox->SetPosition(CCPointMake(NDPlayer::defaultHero().GetPosition().x+64,NDPlayer::defaultHero().GetPosition().y));

 m_pkTreasureBox->SetCurrentAnimation(0, false);
 AddChild(m_pkTreasureBox);
 }
 }

 void NDMapLayer::OpenTreasureBox()
 {
 if(m_pkTreasureBox)
 {
 NDTransData data(_MSG_INSTANCING_BOX_AWARD_LIST);

 NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);

 m_pkTreasureBox->SetCurrentAnimation(2, false);
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
		picture->Cut(CCRectMake(col * 300, row * 60, 300, 60));
		m_lbTitle->SetPicture(picture, true);
	}

	if (!m_lbTitleBg)
	{
		m_lbTitleBg = new NDUIImage;
		m_lbTitleBg->Initialization();
		NDPicture* bg = NDPicturePool::DefaultPool()->AddPicture(
				tq::CString("%smap_title_bg.png",
						NDEngine::NDPath::GetImagePath().c_str()));
		m_lbTitleBg->SetPicture(bg, true);
	}

	if (!m_lbTitleBg->GetParent())
	{
		GetParent()->AddChild(m_lbTitleBg);
	}

	if (!m_lbTitle->GetParent())
	{
		GetParent()->AddChild(m_lbTitle);
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
	//NSString aniPath=[NSString stringWithUTF8String:NDEngine::NDPath::GetAnimationPath().c_str()];
	pSprite->Initialization(
			tq::CString("%s%s", NDEngine::NDPath::GetAnimationPath().c_str(),
					pszSpriteFile));
	pSprite->SetPosition(CCPointMake(nPosx + 64, nPosy));
	pSprite->SetCurrentAnimation(0, false);
	bool bSet = isMapRectIntersectScreen(pSprite->GetSpriteRect());
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

void NDMapLayer::showSwitchSprite(MAP_SWITCH_TYPE type)
{
	m_eSwitchType = type;

	if (m_pkSwitchSpriteNode)
	{
		m_pkSwitchSpriteNode->RemoveFromParent(true);
		m_pkSwitchSpriteNode = NULL;
	}

	m_pkSwitchSpriteNode = new CUISpriteNode;
	m_pkSwitchSpriteNode->Initialization();
	char * szAniFile = NULL;

	switch (m_eSwitchType)
	{
	case SWITCH_NONE:
		break;
	case SWITCH_TO_BATTLE:
		szAniFile = "switchmask01.spr";
		break;
	case SWITCH_BACK_FROM_BATTLE:
		break;
	case SWITCH_START_BATTLE:
		szAniFile = "switchmask02.spr";
		break;
	default:
		szAniFile = "switchmask03.spr";
		break;
	}

	std::string aniPath = NDPath::GetAnimationPath() + szAniFile;

	m_pkSwitchSpriteNode->ChangeSprite(aniPath.c_str());
	m_pkSwitchSpriteNode->SetFrameRect(
		CCRectMake(0, 0, 
					CCDirector::sharedDirector()->getWinSizeInPixels().width,
					CCDirector::sharedDirector()->getWinSizeInPixels().height
					)); //++Guosen 2012.7.6

	m_pkSwitchSpriteNode->SetScale(2.0); //原 480×320 => 960×640 //@todo
	this->GetParent()->AddChild(m_pkSwitchSpriteNode, ZORDER_MASK_ANI);
}

bool NDMapLayer::isTouchTreasureBox(CCPoint touchPoint)
{
	if (m_pkTreasureBox)
	{
		CCRect kRect = CCRectMake(
				m_pkTreasureBox->GetPosition().x
						- m_pkTreasureBox->GetWidth() / 2,
				m_pkTreasureBox->GetPosition().y - m_pkTreasureBox->GetHeight(),
				m_pkTreasureBox->GetWidth(), m_pkTreasureBox->GetHeight());
		if (touchPoint.x >= kRect.origin.x
				&& touchPoint.x <= kRect.origin.x + kRect.size.width
				&& touchPoint.y >= kRect.origin.y
				&& touchPoint.y <= kRect.origin.y + kRect.size.height)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		return false;
	}
}

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
	if (!NDDebugOpt::getDrawMapEnabled()) return;

	if (m_pkMapData && m_bNeedShow)
	{
		DrawBgs();
		DrawScenesAndAnimations();
		DrawSwitch();

		refreshTitle();

		RefreshBoxAnimation();

		DrawLabelRoadBlockTime();

		if (m_pkRoadSignLightEffect)
		{
			m_pkRoadSignLightEffect->Run(GetContentSize());
		}
	}

	debugDraw();
}

void NDMapLayer::DrawLabelRoadBlockTime()
{
	if (m_nRoadBlockTimeCount > 0 && !m_bBattleBackground)
	{
		if(!m_lbTime)
		{
			m_lbTime = new NDUILabel;
			m_lbTime->Initialization();
			m_lbTime->SetFontSize(/*15*/MAP_NAME_SIZE_SMALL);

		}

		int mi = m_nRoadBlockTimeCount / 60;
		CCStringRef str_mi = 0;

		if(mi < 10)
		{
			str_mi = CCString::stringWithFormat("%0d",mi);
		}
		else
		{
			str_mi = CCString::stringWithFormat("%d",mi);
		}

		int se = m_nRoadBlockTimeCount % 60;
		CCStringRef str_se = 0;

		if(se < 10)
		{
			str_se = CCString::stringWithFormat("%0d",mi);
		}
		else
		{
			str_se = CCString::stringWithFormat("%d",mi);
		}

		CCStringRef str_time = CCString::stringWithFormat("%s:%s",
			str_mi->toStdString().c_str(),str_se->toStdString().c_str());
		m_lbTime->SetText(str_time->toStdString().c_str());

		CCSize size = getStringSize(str_time->toStdString().c_str(), 30);

		if (!m_lbTime->GetParent() && m_pkSubNode)
		{
			m_pkSubNode->AddChild(m_lbTime);
		}

		m_lbTime->SetFontColor(ccc4(255,0,0,255));
		m_lbTime->SetFontSize(MAP_NAME_SIZE_BIG/*30*/);
		int x = m_kScreenCenter.x - (size.width) / 2;
		int y = m_kScreenCenter.y - GetContentSize().height - (size.height) / 2 
					+ CCDirector::sharedDirector()->getWinSizeInPixels().height;

		m_lbTime->SetFrameRect(CCRectMake(x, y, size.width, size.height + 5));
		m_lbTime->draw();
	}
}

void NDMapLayer::DrawSwitch()//绘制切屏点
{
	if(!m_pkSwitchSpriteNode || !m_pkSwitchSpriteNode->IsAnimationComplete()) return;
	
	m_pkSwitchSpriteNode->RemoveFromParent(true);
	m_pkSwitchSpriteNode = NULL;

	switch(m_eSwitchType)
	{
	case SWITCH_NONE:
		break;

	case SWITCH_TO_BATTLE:
		{
			NDBattleBaseMgrObj.showBattleScene();
			BaseScriptMgrObj.excuteLuaFunc("Hide", "NormalBossListUI",0);//调用Hide方法后，调用Redisplay恢复

			//切换音效
			BaseScriptMgrObj.excuteLuaFunc("PlayEffectSound", "Music",3);

			//等于3为竞技场挑战
			if(m_nBattleType != 3)
			{
				int nIsRank = BaseScriptMgrObj.excuteLuaFuncRetN("GetIsBattleRank", "NormalBossListUI");

				//等于1表示副本已经打通过
				if (1 == nIsRank)
				{
					//显示速战速决按钮
					BaseScriptMgrObj.excuteLuaFunc("LoadUI", "BattleMapCtrl");
				}
			}
			else
			{
				//显示速战速决按钮
				BaseScriptMgrObj.excuteLuaFunc("LoadUI", "BattleMapCtrl");
			}

			showSwitchSprite(SWITCH_START_BATTLE);
		}
		break;
	case SWITCH_BACK_FROM_BATTLE:
		break;
	case SWITCH_START_BATTLE:
		break;
	default:
		break;
	}

	m_eSwitchType = SWITCH_NONE;
}

 	void NDMapLayer::SetBattleBackground(bool bBattleBackground)
 	{
 		m_bBattleBackground = bBattleBackground;
 		//GameScene* gameScene =  (GameScene*)GetParent();
 		//gameScene->SetMiniMapVisible(!bBattleBackground);
 	}
//
// 	void NDMapLayer::SetNeedShowBackground(bool bNeedShow)
// 	{
// 		m_bNeedShow = bNeedShow;
// //		GameScene* gameScene =  (GameScene*)GetParent();
// //		gameScene->SetMiniMapVisible(!bBattleBackground);
// 	}

void NDMapLayer::MapSwitchRefresh()
{
	MakeOrdersOfMapscenesAndMapanimations();
	CC_SAFE_RELEASE (m_pkFrameRunRecordsOfMapSwitch);

	//m_pkFrameRunRecordsOfMapSwitch = new cocos2d::CCMutableArray<NDFrameRunRecord*>();
	m_pkFrameRunRecordsOfMapSwitch = new cocos2d::CCArray();

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
// 		CCSize winSize =  CCDirector::sharedDirector()->getWinSizeInPixels();
// 		CCPoint ptDraw = ccp(m_screenCenter.x - winSize.width / 2, m_screenCenter.y + winSize.height / 2 - GetContentSize().height);
// 		if (m_areaCamarkSplit == IntersectionAreaNone)
// 		{
// 			[m_texMap ndDrawInRect:CCRectMake(ptDraw.x, ptDraw.y, winSize.width, winSize.height)];
// 		}
// 		else
// 		{
// 			CCRect rect1 = CCRectMake(0, 0, m_ptCamarkSplit.x, m_ptCamarkSplit.y);
// 			CCRect rect2 = CCRectMake(rect1.size.width, 0,  winSize.width - rect1.size.width, rect1.size.height);
// 			CCRect rect3 = CCRectMake(0, rect1.size.height, rect1.size.width, winSize.height - rect1.size.height);
// 			CCRect rect4 = CCRectMake(rect1.size.width, rect1.size.height, rect2.size.width, rect3.size.height);
//
// 			if (rect1.size.width != 0 && rect1.size.height != 0)
// 			{
// 				m_picMap->Cut(rect1);
// 				m_picMap->DrawInRect(CCRectMake(ptDraw.x + winSize.width - m_ptCamarkSplit.x, ptDraw.y + winSize.height - m_ptCamarkSplit.y, rect1.size.width, rect1.size.height));
// 			}
// 			if (rect2.size.width != 0 && rect2.size.height != 0)
// 			{
// 				m_picMap->Cut(rect2);
// 				m_picMap->DrawInRect(CCRectMake(ptDraw.x, ptDraw.y + winSize.height - m_ptCamarkSplit.y, rect2.size.width + 1, rect2.size.height + 1));
// 			}
// 			if (rect3.size.width != 0 && rect3.size.height != 0)
// 			{
// 				m_picMap->Cut(rect3);
// 				m_picMap->DrawInRect(CCRectMake(ptDraw.x + winSize.width - m_ptCamarkSplit.x, ptDraw.y, rect3.size.width, rect3.size.height + 1));
// 			}
// 			if (rect4.size.width != 0 && rect4.size.height != 0)
// 			{
// 				m_picMap->Cut(rect4);
// 				m_picMap->DrawInRect(CCRectMake(ptDraw.x, ptDraw.y, rect4.size.width + 1, rect4.size.height + 1));
// 			}
// 		}
//
// //		DrawLine(ccp(ptDraw.x + 0, ptDraw.y + m_ptCamarkSplit.y), ccp(ptDraw.x + 480, ptDraw.y + m_ptCamarkSplit.y), ccc4(255, 0, 0, 255), 1);
// //		DrawLine(ccp(ptDraw.x + m_ptCamarkSplit.x, ptDraw.y + 0), ccp(ptDraw.x + m_ptCamarkSplit.x, ptDraw.y + 320), ccc4(255, 0, 0, 255), 1);
// 	}

void NDMapLayer::DrawBgs()
{
	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	CCRect scrRect = CCRectMake(m_kScreenCenter.x - winSize.width / 2,
			m_kScreenCenter.y - winSize.height / 2, winSize.width,
			winSize.height);

	unsigned int orderCount = m_pkMapData->getBgTiles()->count();
	for (unsigned int i = 0; i < orderCount; i++)
	{
		NDTile* pkTile = (NDTile*) m_pkMapData->getBgTiles()->objectAtIndex(i);
		if (pkTile && cocos2d::CCRect::CCRectIntersectsRect(scrRect, pkTile->getDrawRect()))
		{
			draw();
// 				CCRect intersectRect	= CCRectZero;
// 				CCRect drawRect			= CCRectZero;
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

	unsigned int orderCount = m_pkOrders->count();
	unsigned int uiSceneTileCount = m_pkMapData->getSceneTiles()->count();
	unsigned int aniGroupCount = m_pkMapData->getAnimationGroups()->count();
	unsigned int switchCount = m_pkMapData->getSwitchs()->count();

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

		if (0) {}
#if 1
		else if (uiIndex < uiSceneTileCount) //布景
		{
			//PerformanceTestPerFrameBeginName("布景");
			NDTile *pkTile = (NDTile *) m_pkMapData->getSceneTiles()->objectAtIndex(uiIndex);

			if (pkTile)
			{			
				if (isMapRectIntersectScreen(pkTile->getDrawRect()))
				{
					pkTile->draw();
				}
			}
			//PerformanceTestPerFrameEndName("布景");
		}
#endif

 			else if (m_bBattleBackground) // 战斗状态，不绘制其他地表元素
 			{
 				continue;
 			}
#if 1
		else if (uiIndex < uiSceneTileCount + aniGroupCount) //地表动画
		{
			//PerformanceTestPerFrameBeginName("地表动画");
			uiIndex -= uiSceneTileCount;

			NDAnimationGroup* pkAniGroup =
					(NDAnimationGroup*) m_pkMapData->getAnimationGroups()->objectAtIndex(
							uiIndex);

			//CCMutableArray<NDFrameRunRecord*>* pkFrameRunRecordList = m_pkFrameRunRecordsOfMapAniGroups->getObjectAtIndex(uiIndex);
			CCArray* pkFrameRunRecordList = (CCArray*) m_pkFrameRunRecordsOfMapAniGroups->objectAtIndex(uiIndex);

			pkAniGroup->setReverse(GetMapDataAniParamReverse(uiIndex));
			pkAniGroup->setPosition(GetMapDataAniParamPos(uiIndex));
			pkAniGroup->setRunningMapSize(GetMapDataAniParamMapSize(uiIndex));

			unsigned int uiAniCount = pkAniGroup->getAnimations()->count();

			for (unsigned int j = 0; j < uiAniCount; j++)
			{
				NDFrameRunRecord *pkFrameRunRecord = 
					(NDFrameRunRecord*) pkFrameRunRecordList->objectAtIndex(j);

				NDAnimation *pkAnimation = 
						(NDAnimation *) pkAniGroup->getAnimations()->objectAtIndex(j);

				if (isMapRectIntersectScreen(pkAnimation->getRect()))
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
#endif
#if 1
		else if (uiIndex < uiSceneTileCount + aniGroupCount + switchCount) //切屏点
		{
			//PerformanceTestPerFrameBeginName("切屏点");
			uiIndex -= m_pkMapData->getSceneTiles()->count()
					+ m_pkMapData->getAnimationGroups()->count();

			NDMapSwitch *pkMapSwitch =
					(NDMapSwitch *) m_pkMapData->getSwitchs()->objectAtIndex(
							uiIndex);

			//NDFrameRunRecord *pkFrameRunRecord = m_pkFrameRunRecordsOfMapSwitch->getObjectAtIndex(uiIndex);
			NDFrameRunRecord *pkFrameRunRecord = (NDFrameRunRecord*) m_pkFrameRunRecordsOfMapSwitch->objectAtIndex(uiIndex);

			m_pkSwitchAniGroup->setReverse(false);

// 			CCPoint kPos = ccp(
// 					pkMapSwitch->getX() * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
// 					pkMapSwitch->getY() * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET);//@del
			CCPoint kPos = ConvertUtil::convertCellToDisplay( pkMapSwitch->getX(), pkMapSwitch->getY());

			m_pkSwitchAniGroup->setPosition(kPos);

			m_pkSwitchAniGroup->setRunningMapSize(GetContentSize());

			if (m_pkSwitchAniGroup->getAnimations()->count() > 0)
			{
				NDAnimation *pkAnimation =
						(NDAnimation *) m_pkSwitchAniGroup->getAnimations()->objectAtIndex(
								0);

				if (isMapRectIntersectScreen(pkAnimation->getRect()))
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
#endif
#if 1
		else //精灵
		{
			//PerformanceTestPerFrameBeginName("精灵");
			uiIndex -= uiSceneTileCount + aniGroupCount + switchCount;

			if (uiIndex < 0 || uiIndex >= GetChildren().size())
			{
				continue;
			}

			NDNode* pkNode = GetChildren().at(uiIndex);
			if (pkNode->IsKindOfClass(RUNTIME_CLASS(NDSprite)))
			{
				NDSprite* pkSprite = (NDSprite*) pkNode;
				bool bSet = isMapRectIntersectScreen(pkSprite->GetSpriteRect());
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
#endif
		//PerformanceTestPerFrameEndName(" NDMapLayer::DrawScenesAndAnimations inner");
	}//for

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
CCPoint NDMapLayer::ConvertToMapPoint(CCPoint kScreenPoint)
{
	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	return ccpAdd(	
		ccpSub(kScreenPoint, ccp(winSize.width / 2, winSize.height / 2)),
			m_kScreenCenter );
}

bool NDMapLayer::isMapPointInScreen(CCPoint mapPoint)
{
	CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	return cocos2d::CCRect::CCRectContainsPoint(
			CCRectMake(m_kScreenCenter.x - kWinSize.width / 2,
					m_kScreenCenter.y - kWinSize.height / 2, kWinSize.width,
					kWinSize.height), mapPoint);
}

bool NDMapLayer::isMapRectIntersectScreen(CCRect mapRect)
{
	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	CCRect scrRect = CCRectMake(m_kScreenCenter.x - winSize.width / 2,
			m_kScreenCenter.y - winSize.height / 2, winSize.width,
			winSize.height);
	return cocos2d::CCRect::CCRectIntersectsRect(scrRect, mapRect);
}

void NDMapLayer::SetPosition(CCPoint kPosition)
{
	CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();

	if (kPosition.x > 0)
	{
		kPosition.x = 0;
	}

	if (kPosition.x < kWinSize.width - GetContentSize().width)
	{
		kPosition.x = kWinSize.width - GetContentSize().width;
	}

	if (kPosition.y > 0)
	{
		kPosition.y = 0;
	}

	if (kPosition.y < kWinSize.height - GetContentSize().height)
	{
		kPosition.y = kWinSize.height - GetContentSize().height;
	}

	//m_ccNode->setPositionInPixels(kPosition);
	const float fScale = CCDirector::sharedDirector()->getContentScaleFactor(); //@check
	kPosition.x /= fScale; kPosition.y /= fScale;
	m_ccNode->setPosition(kPosition);
}

bool NDMapLayer::SetScreenCenter(CCPoint kPoint)
{
 		if(m_bBattleBackground){
 			return false;
 		}

	bool bOverBoder = false;
	int width = GetContentSize().width;
	int height = GetContentSize().height;

	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();

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

	//ReflashMapTexture(m_screenCenter, p);

	//modify yay
	CCPoint backOff = ccpSub(kPoint, m_kScreenCenter);
	m_pkMapData->moveBackGround(backOff.x, backOff.y);
	//[m_mapData moveBackGround:backOff.x,backOff.y];

	m_kScreenCenter = kPoint;
	//NDLog("center:%f,%f",p.x,p.y);
	SetPosition(
			CCPointMake(winSize.width / 2 - kPoint.x,
					winSize.height / 2 + kPoint.y - height));

	return bOverBoder;
}

CCPoint NDMapLayer::GetScreenCenter()
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
		m_ndBlockTimer = new NDTimer;
	}

	m_ndBlockTimer->SetTimer(this, blockTimerTag, 1.0f);
	m_nRoadBlockTimeCount = time;

	if (m_pkMapData)
	{
		m_pkMapData->setRoadBlock(x, y);
	}
}

void NDMapLayer::setAutoBossFight(bool isAuto)
{
	///< 又调用到Logic了 郭浩
//  isAutoBossFight = isAuto;
//  if(isAuto)
//  {
//  walkToBoss();
//  }else {
//  NDPlayer::defaultHero().stopMoving(false, false);
//  }

}

void NDMapLayer::walkToBoss()
{
	///< 又调用到Logic了 郭浩
//  NDMonster* boss = NDMapMgrObj.GetBoss();
//  if (boss!=NULL)
//  {
//  CCPoint point = boss->GetPosition();
//  NDLog("boss:%d,%d",point.x,point.y);
//  NDPlayer::defaultHero().Walk(point, SpriteSpeedStep4);
//  }
}

void NDMapLayer::OnTimer(OBJID tag)
{
	if (blockTimerTag == tag)
	{
		m_nRoadBlockTimeCount--;
		//NDLog("tag:%d,count:%d",tag,roadBlockTimeCount);
		if (m_nRoadBlockTimeCount <= 0)
		{
			m_pkMapData->setRoadBlock(-1, -1);
			m_nRoadBlockTimeCount = 0;
			m_ndBlockTimer->KillTimer(this, blockTimerTag);
			m_ndBlockTimer = NULL;

			/*if(isAutoBossFight)
			 {
			 walkToBoss();
			 }*/
		}
	}
	else if (tag == titleTimerTag)
	{
		m_ndTitleTimer->KillTimer(this, titleTimerTag);
		m_ndTitleTimer = NULL;
		//todo(zjh)
		/*if(NDMapMgrObj.GetMotherMapID()/100000000!=9){
		 showTitle=false;
		 }
		 */
	}
}

// 	void NDMapLayer::ReplaceMapTexture(CCTexture2D* tex, CCRect replaceRect, CCRect tilesRect)
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
// 						CCRect rect; IntersectionArea area;
// 						RectIntersectionRect(tile.drawRect, tilesRect, rect, area);
// 						if (area != IntersectionAreaNone)
// 						{
// 							rect = CCRectMake(rect.origin.x - tile.drawRect.origin.x, rect.origin.y - tile.drawRect.origin.y, rect.size.width, rect.size.height);
// 							newTile.cutRect	= CCRectMake(tile.cutRect.origin.x + rect.origin.x, tile.cutRect.origin.y + rect.origin.y, rect.size.width, rect.size.height);
// 							newTile.drawRect = CCRectMake(x, y, rect.size.width, rect.size.height);
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

// 	void NDMapLayer::ReflashMapTexture(CCPoint oldScreenCenter, CCPoint newScreenCenter)
// 	{
// 		if (oldScreenCenter.x == newScreenCenter.x && oldScreenCenter.y == newScreenCenter.y)
// 			return;
//
// 		if (m_texMap)
// 		{
// 			CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
//
// 			CCRect oldRect = CCRectMake(oldScreenCenter.x - winSize.width / 2, oldScreenCenter.y - winSize.height / 2,
// 										winSize.width, winSize.height);
// 			CCRect newRect = CCRectMake(newScreenCenter.x - winSize.width / 2, newScreenCenter.y - winSize.height / 2,
// 										winSize.width, winSize.height);
//
// 			CCRect rect;
// 			RectIntersectionRect(oldRect, newRect, rect, m_areaCamarkSplit);
// 			if (m_areaCamarkSplit == IntersectionAreaNone)
// 			{
// 				m_ptCamarkSplit = ccp(0, 0);
// 				ReplaceMapTexture(m_texMap,
// 								  CCRectMake(0, 0, winSize.width, winSize.height),
// 								  CCRectMake(newRect.origin.x, newRect.origin.y, winSize.width, winSize.height));
// 			}
// 			else
// 			{
// 				CCRect nRect = CCRectZero;
// 				if (newScreenCenter.x > oldScreenCenter.x)
// 				{
// 					nRect = CCRectMake(oldScreenCenter.x + winSize.width / 2,
// 									   oldScreenCenter.y - winSize.height / 2,
// 									   newScreenCenter.x - oldScreenCenter.x, winSize.height);
// 				}
// 				else
// 				{
// 					nRect = CCRectMake(newScreenCenter.x - winSize.width / 2,
// 									   oldScreenCenter.y - winSize.height / 2,
// 									   oldScreenCenter.x - newScreenCenter.x, winSize.height);
// 				}
// 				ScrollHorizontal(newScreenCenter.x - oldScreenCenter.x, nRect);
//
// 				if (newScreenCenter.y > oldScreenCenter.y)
// 				{
// 					nRect = CCRectMake(newScreenCenter.x - winSize.width / 2,
// 									   oldScreenCenter.y + winSize.height / 2,
// 									   winSize.width, newScreenCenter.y - oldScreenCenter.y);
// 				}
// 				else
// 				{
// 					nRect = CCRectMake(newScreenCenter.x - winSize.width / 2,
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
// 		CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
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

// 	void NDMapLayer::ScrollVertical(int y, CCRect newRect)
// 	{
// 		if (y == 0)	return;
//
// 		CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
//
// 		if (y < 0 && abs(y) > m_ptCamarkSplit.y && m_ptCamarkSplit.y > 0 && m_ptCamarkSplit.y < winSize.height)
// 		{
// 			int y1 = -m_ptCamarkSplit.y;
// 			int y2 = m_ptCamarkSplit.y + y;
//
// 			CCRect newRect1 = CCRectMake(newRect.origin.x, newRect.origin.y - y2, newRect.size.width, -y1);
// 			ScrollVertical(y1, newRect1);
//
// 			CCRect newRect2 = CCRectMake(newRect.origin.x, newRect.origin.y, newRect.size.width, y2);
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
// 			CCRect newRect1 = CCRectMake(newRect.origin.x, newRect.origin.y, newRect.size.width, y1);
// 			ScrollVertical(y1, newRect1);
//
// 			CCRect newRect2 = CCRectMake(newRect.origin.x, newRect.origin.y + y1, newRect.size.width, y2);
// 			ScrollVertical(y2, newRect2);
//
// 			return;
// 		}
//
// 		if (y < 0)
// 			ScrollSplit(0, y);
//
// 		ReplaceMapTexture(m_texMap,
// 						  CCRectMake(0, m_ptCamarkSplit.y, m_ptCamarkSplit.x, abs(y)),
// 						  CCRectMake(newRect.origin.x + winSize.width - m_ptCamarkSplit.x, newRect.origin.y, m_ptCamarkSplit.x, abs(y)));
// 		ReplaceMapTexture(m_texMap,
// 						  CCRectMake(m_ptCamarkSplit.x, m_ptCamarkSplit.y, winSize.width - m_ptCamarkSplit.x, abs(y)),
// 						  CCRectMake(newRect.origin.x, newRect.origin.y, winSize.width - m_ptCamarkSplit.x, abs(y)));
//
// 		if (y > 0)
// 			ScrollSplit(0, y);
// 	}
//
// 	void NDMapLayer::ScrollHorizontal(int x, CCRect newRect)
// 	{
// 		if (x == 0) return ;
//
// 		CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
//
// 		if (x < 0 && abs(x) > m_ptCamarkSplit.x && m_ptCamarkSplit.x > 0 && m_ptCamarkSplit.x < winSize.width)
// 		{
// 			int x1 = -m_ptCamarkSplit.x;
// 			int x2 = m_ptCamarkSplit.x + x;
//
// 			CCRect newRect1 = CCRectMake(newRect.origin.x - x2, newRect.origin.y, -x1, newRect.size.height);
// 			ScrollHorizontal(x1, newRect1);
//
// 			CCRect newRect2 = CCRectMake(newRect.origin.x, newRect.origin.y, -x2, newRect.size.height);
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
// 			CCRect newRect1 = CCRectMake(newRect.origin.x, newRect.origin.y, x1, newRect.size.height);
// 			ScrollHorizontal(x1, newRect1);
//
// 			CCRect newRect2 = CCRectMake(newRect.origin.x + x1, newRect.origin.y, x2, newRect.size.height);
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
// 						  CCRectMake(m_ptCamarkSplit.x, 0, abs(x), m_ptCamarkSplit.y),
// 						  CCRectMake(newRect.origin.x, newRect.origin.y + winSize.height - m_ptCamarkSplit.y, abs(x), m_ptCamarkSplit.y));
// 		ReplaceMapTexture(m_texMap,
// 						  CCRectMake(m_ptCamarkSplit.x, m_ptCamarkSplit.y, abs(x), winSize.height - m_ptCamarkSplit.y),
// 						  CCRectMake(newRect.origin.x, newRect.origin.y, abs(x), winSize.height - m_ptCamarkSplit.y));
//
// 		if (x > 0)
// 			ScrollSplit(x, 0);
// 	}

// 	void NDMapLayer::RectIntersectionRect(CCRect rect1, CCRect rect2, CCRect& intersectionRect, IntersectionArea& intersectionArea)
// 	{
// 		intersectionRect = CCRectIntersection(rect1, rect2);
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
	const std::vector<NDNode*>& kCLD = GetChildren();
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
				unsigned index = InsertIndex(pkSprite->GetOrder(),
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
	
	int iNumSceneTitles = (int) m_pkMapData->getSceneTiles()->count();
	int iNumAniGroupParams = (int) m_pkMapData->getAniGroupParams()->count();
	int iNumSwitchs = (int) m_pkMapData->getSwitchs()->count();
	

	for (int i = 0; i < iNumSceneTitles; i++)
	{
		NDSceneTile *pkSceneTile =
				(NDSceneTile *) m_pkMapData->getSceneTiles()->objectAtIndex(i);

		int orderId = (short) pkSceneTile->getOrderID();

		MAP_ORDER *dict = new MAP_ORDER;

		(*dict)["index"] = i;
		(*dict)["orderId"] = orderId;

		//NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

		//[dict setObject:[NSNumber numberWithInt:i] forKey:@"index"];
		//[dict setObject:[NSNumber numberWithInt:orderId] forKey:@"orderId"];

		m_pkOrdersOfMapscenesAndMapanimations->addObject(dict);
		dict->release();
	}
	for (int i = 0; i < iNumAniGroupParams; i++)
	{
		//NSDictionary *dictAniGroupParam = [m_mapData.aniGroupParams objectAtIndex:i];
		int nOrderID = GetMapDataAniParamOrderId(i);

		MAP_ORDER *pkDict = new MAP_ORDER;

		(*pkDict)["index"] = i + m_pkMapData->getSceneTiles()->count();
		(*pkDict)["orderId"] = nOrderID;

		//NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		//[dict setObject:[NSNumber numberWithInt:i + [m_mapData.sceneTiles count]] forKey:@"index"];
		//[dict setObject:[NSNumber numberWithInt:orderId] forKey:@"orderId"];

		m_pkOrdersOfMapscenesAndMapanimations->addObject(pkDict);
		pkDict->release();
	}
	for (int i = 0; i < iNumSwitchs; i++)
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

	QuickSort(m_pkOrdersOfMapscenesAndMapanimations, 0,
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
		int highOrder = GetMapOrderId(pkDict);

		//[[dict objectForKey:@"orderId"] intValue];
		if (order > highOrder)
		{
			return nHigh + 1;
		}

		pkDict = (MAP_ORDER *) inArray->objectAtIndex(nLow);
		int lowOrder = GetMapOrderId(pkDict);
		if (order < lowOrder)
		{
			return nLow;
		}

		nMid = (nLow + nHigh) / 2;
		pkDict = (MAP_ORDER *) inArray->objectAtIndex(nMid);
		nMidOrder = GetMapOrderId(pkDict);
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
		nMidOrder = GetMapOrderId(pkDict);
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
		int pivotloc = Partition(array, low, high);
		QuickSort(array, low, pivotloc);
		QuickSort(array, pivotloc + 1, high);
	}
}

int NDMapLayer::Partition(cocos2d::CCArray*/*<MAP_ORDER*>*/array, int low,
		int high)
{
	MAP_ORDER *dict = (MAP_ORDER *) array->objectAtIndex(low);
	int nPivotkey = GetMapOrderId(dict);

	while (low < high)
	{
		dict = (MAP_ORDER *) array->objectAtIndex(high);
		int curKey = GetMapOrderId(dict);

		while (low < high && curKey >= nPivotkey)
		{
			dict = (MAP_ORDER *) array->objectAtIndex(--high);
			curKey = GetMapOrderId(dict);
		}
		if (low != high)
			array->exchangeObjectAtIndex(low, high);

		dict = (MAP_ORDER *) array->objectAtIndex(low);
		curKey = GetMapOrderId(dict);
		while (low < high && curKey <= nPivotkey)
		{
			dict = (MAP_ORDER *) array->objectAtIndex(++low);
			curKey = GetMapOrderId(dict);
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

		//cocos2d::CCMutableArray<NDFrameRunRecord*>* pkRunFrameRecordList = new cocos2d::CCMutableArray<NDFrameRunRecord*>();
		cocos2d::CCArray* pkRunFrameRecordList = new cocos2d::CCArray();

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
		m_pkRoadSignLightEffect->Initialization(NDPath::GetAniPath("click.spr").c_str());
		m_pkRoadSignLightEffect->setScale(0.5f*SCREEN_SCALE);
		m_pkRoadSignLightEffect->SetLightId(0, false);
	}

	m_pkRoadSignLightEffect->SetPosition(
		ConvertUtil::convertCellToDisplay( nX, nY ));
// 			ccp(nX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
// 					nY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));//@del
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

CCPoint NDMapLayer::GetMapDataAniParamPos(int nIndex)
{
	anigroup_param *dictAniGroupParam =
			(anigroup_param *) m_pkMapData->getAniGroupParams()->objectAtIndex(
					nIndex);
	CCPoint pos = CCPointZero;
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

CCSize NDMapLayer::GetMapDataAniParamMapSize(int nIndex)
{
	anigroup_param *dictAniGroupParam =
			(anigroup_param *) m_pkMapData->getAniGroupParams()->objectAtIndex(
					nIndex);
	CCSize size = CCSizeZero;
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

#if 0
void NDMapLayer::AddChild(NDNode* node, int z, int tag)
{
	NDNode::AddChild(node, z, tag);
}
#endif

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

bool NDMapLayer::TouchDoubleClick(NDTouch* touch)
{
	return true;
}

void NDMapLayer::ShowTreasureBox()
{
}

void NDMapLayer::OpenTreasureBox()
{
	if (m_pkTreasureBox)
	{
		NDTransData kData(_MSG_INSTANCING_BOX_AWARD_LIST);

		NDDataTransThread::DefaultThread()->GetSocket()->Send(&kData);

		m_pkTreasureBox->SetCurrentAnimation(2, false);
		m_eBoxStatus = BOX_OPENING;
	}
}

void NDMapLayer::debugDraw()
{
#if 1 //@del
	float w = CCDirector::sharedDirector()->getVisibleSize().width;
	float h = CCDirector::sharedDirector()->getVisibleSize().height;
	glLineWidth(2);
	ccDrawColor4F(0,1,0,1);//green
	ccDrawLine( ccp(0,0), ccp(w,h));
	ccDrawLine( ccp(0,h), ccp(w,0));
#endif

	if (!NDDebugOpt::getDrawDebugEnabled() ||
		!NDDebugOpt::getDrawCellEnabled()) return;

	//drawCell();
}

void NDMapLayer::drawCell()
{
	NDMapData* pMapData = this->GetMapData();	
	if (!pMapData) return;

	const float fScale = CCDirector::sharedDirector()->getContentScaleFactor();

	const int colAmount = pMapData->getColumns();
	const int rowAmount = pMapData->getRows();
	const float pad = 0.25f;

	ccDrawColor4F(1,1,1,1);

	for (int row = 0; row < rowAmount; row++)
	{
		for (int col = 0; col < colAmount; col++)
		{
			float x = col * MAP_UNITSIZE_X;
			float y = row * MAP_UNITSIZE_Y;
	
			//@todo: check visible
			CCPoint org = ccp(x + pad, y + pad);//left top
			CCPoint dest = ccp(x + MAP_UNITSIZE_X - pad, y + MAP_UNITSIZE_Y + - pad); //right bottom
			ccDrawRect( org, dest );
		}
	}
}

void NDMapLayer::dumpRole()
{
//@del: 留着有用，暂时别删~
// 	char str[1024] = "";
// 	HANDLE hOut = NDConsole::GetSingletonPtr()->getOutputHandle();
// 
// 	int cnt = m_kChildrenList.size();
// 	for (int i = 0; i < cnt; i++)
// 	{
// 		NDNode* pkNode = m_kChildrenList[i];
// 		if (pkNode && pkNode->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)))
// 		{
// 			NDBaseRole* pRole = (NDBaseRole*) pkNode;
// 			bool bVisible = isMapRectIntersectScreen(pRole->GetSpriteRect());
// 			if (!bVisible) continue;
// 			
// 			char* roleType = 0;
// 			if (pkNode->IsKindOfClass(RUNTIME_CLASS(NDNpc)))
// 				roleType = "npc";
// 			if (pkNode->IsKindOfClass(RUNTIME_CLASS(NDManualRole)))
// 				roleType = "manual";
// 			else if (pkNode->IsKindOfClass(RUNTIME_CLASS(NDPlayer)))
// 				roleType = "player";
// 			else if (pkNode->IsKindOfClass(RUNTIME_CLASS(NDMonster)))
// 				roleType = "monster";
// 			
// 			if (roleType)
// 			{
// 				CCPoint pos = pRole->GetPosition();
// 				sprintf( str, "%-10s %-20s pos(%d, %d)\r\n", 
// 					roleType, pRole->m_strName.c_str(), (int)pos.x, (int)pos.y );
// 
// 				DWORD n = 0;
// 				WriteConsoleA( hOut, str, strlen(str), &n, NULL );		
// 			}
// 		}
// 	}
}

NS_NDENGINE_END