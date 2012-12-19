/*
 *  Battle.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-17.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "Battle.h"
#include "Fighter.h"
#include "NDPlayer.h"
#include "NDConstant.h"
#include "CCPointExtension.h"
#include "ImageNumber.h"
#include "NDUtility.h"
#include "NDDirector.h"
#include "NDMsgDefine.h"
#include "NDDataTransThread.h"
#include "BattleUtil.h"
#include "NDMapLayer.h"
#include "NDMapMgr.h"
#include "NDPath.h"
#include "ScriptGlobalEvent.h"
#include "ItemMgr.h"
#include <sstream>
//#include "NDUIMemo.h"
#include "SMGameScene.h"
#include "NDAnimationGroup.h"
#include "NDUISynLayer.h"
//#include "ChatInput.h"
//#include "ChatRecordManager.h"
#include "StatusDialog.h"
//#include "NDDataPersist.h"
#include "ItemImage.h"
//#include "BattleFieldScene.h"
#include "CPet.h"
//#include "NewChatScene.h"
#include "GameScene.h"
#include "GlobalDialog.h"
#include "ScriptMgr.h"
#include "ObjectTracker.h"


//===========================================================================
typedef struct _tagEffectProp{
	int		iPos;		//特效播放的位置;0:头顶,1:脚底,2:中间
	bool	bRevers;	//特效播放是否需要翻转
}TEffectProp;
//所有特效播放属性
TEffectProp		g_ArrayEfectProp[] = {
	{ 0, true },	//0
	{ 2, true },	//1
	{ 2, true },	//2
	{ 1, true },	//3
	{ 1, true },	//4
	{ 1, true },	//5
	{ 1, true },	//6
	{ 2, true },	//7
	{ 2, true },	//8
	{ 1, true },	//9
	{ 1, true },	//10
	{ 1, false },	//11
	{ 1, false },	//12
	{ 2, true },	//13
	{ 1, true },	//14
	{ 1, true },	//15
	{ 1, true },	//16
	{ 2, true },	//17
	{ 2, false },	//18
	{ 2, false },	//19
	{ 1, false },	//20
	{ 1, false },	//21
	{ 1, false },	//22sd
	{2,false},//{ 0, false },	//23
	{2,false},//{ 0, false },	//24
	{2,false},//{ 0, false },	//25
	{2,false},//{ 0, false },	//26
	{2,false},//{ 0, false },	//27
	{2,false},//{ 0, false },	//28
	{2,false},//{ 0, false },	//29
	{2,false},//{ 0, false },	//30
	{2,false},//{ 0, false },	//31
	{2,false},//{ 2, false },	//32
	{2,false},//{ 0, false },	//33
	{1,false},//{ 0, false },	//34
	{1,false},//{ 0, false },	//35
	{1,false},//{ 0, false },	//36
	{1,false},//{ 0, false },	//37
	{1,false},//{ 0, false },	//38
	{1,false},//{ 0, false },	//39
	{1,false},//{ 0, false },	//40
	{ 1, true },	//41
	{ 1, true },	//42
	{ 2, true },	//43
	{ 1, true },	//44
	{ 1, false },	//45
	{ 2, false },	//46
	{ 2, false },	//47
	{ 2, false },	//48
};

//===========================================================================

IMPLEMENT_CLASS(QuickTalkCell, NDUINode)

QuickTalkCell::QuickTalkCell()
{
	INC_NDOBJ_RTCLS

	m_clrFocus = ccc4(9, 54, 55, 255);
	m_clrText = ccc4(155, 255, 255, 255);
	m_clrFocusText = ccc4(249, 229, 64, 255);
	m_lbText = NULL;
}

QuickTalkCell::~QuickTalkCell()
{
	DEC_NDOBJ_RTCLS
}

void QuickTalkCell::Initialization(const char* pszText, const CCSize& size)
{
	NDUINode::Initialization();

	NDUIImage* img = new NDUIImage;
	img->Initialization();
	NDPicture* pic = new NDPicture;
	pic->Initialization(NDPath::GetImgPathBattleUI("chat_icon_sys.png").c_str());
	img->SetPicture(pic, true);
	img->SetFrameRect(CCRectMake(3.0f, 9.0f, 9.0f, 9.0f));
	AddChild(img);

	img = new NDUIImage;
	img->Initialization();
	pic = new NDPicture;
	pic->Initialization(NDPath::GetImgPathBattleUI("battle_chat_line.png").c_str(), 10,1);
	img->SetPicture(pic, true);
	img->SetFrameRect(CCRectMake(0.0f, size.height - 6.0f, size.width, 2.0f));
	AddChild(img);

	CCRect rectText = CCRectMake(15.0f, 5.0f, size.width - 15.0f, size.height - 7.0f);

	m_lbText = new NDUILabel;
	m_lbText->Initialization();
	m_lbText->SetFontSize(13);
	m_lbText->SetFontColor(m_clrText);
	m_lbText->SetText(pszText);
	m_lbText->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbText->SetFrameRect(rectText);
	AddChild(m_lbText);
}

void QuickTalkCell::draw()
{
	NDNode* parentNode = GetParent();

	if (parentNode && parentNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
	{
		NDUILayer* uiLayer = (NDUILayer*) parentNode;

		if (uiLayer->GetFocus() == this)
		{ // 当前处于焦点,绘制焦点色
		  //DrawRecttangle(GetScreenRect(), m_clrFocus); ///< 临时性注释 郭浩
			m_lbText->SetFontColor(m_clrFocusText);
		}
		else
		{
			m_lbText->SetFontColor(m_clrText);
		}
	}

	NDUINode::draw();
}

string QuickTalkCell::GetText()
{
	if (m_lbText)
	{
		return m_lbText->GetText();
	}

	return "";
}

IMPLEMENT_CLASS(HighlightTipStatusBar, NDUINode)
IMPLEMENT_CLASS(HighlightTip, NDUILayer)

HighlightTip::HighlightTip()
{
	INC_NDOBJ_RTCLS
	m_pkPicBubble = NULL;
	m_hpBar = NULL;
	m_mpBar = NULL;
}
HighlightTip::~HighlightTip()
{
	DEC_NDOBJ_RTCLS
	CC_SAFE_DELETE (m_pkPicBubble);
}

void HighlightTip::Initialization()
{
	NDUILayer::Initialization();

	m_pkPicBubble = new NDPicture;
	m_pkPicBubble->Initialization(NDPath::GetImgPath("ui_map.png").c_str(), 70, 60);

	NDUIImage* pImgBubble = new NDUIImage;
	pImgBubble->Initialization();
	pImgBubble->SetFrameRect(CCRectMake(0, 0, m_pkPicBubble->GetSize().width, m_pkPicBubble->GetSize().height));
	pImgBubble->SetPicture(m_pkPicBubble, false);
	AddChild(pImgBubble);

	NDUIImage* imgHp = new NDUIImage;
	imgHp->Initialization();
	NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("hp.png"));
	imgHp->SetPicture(pic);
	imgHp->SetFrameRect(CCRectMake(2, 20, pic->GetSize().width, pic->GetSize().height));
	AddChild(imgHp);

	NDUIImage* imgMp = new NDUIImage;
	imgMp->Initialization();
	pic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("mp.png"));
	imgMp->SetPicture(pic);
	imgMp->SetFrameRect(CCRectMake(2, 35, pic->GetSize().width, pic->GetSize().height));
	AddChild(imgMp);

	m_hpBar = new HighlightTipStatusBar(0xC7321A);
	m_hpBar->Initialization();
	AddChild(m_hpBar);

	m_mpBar = new HighlightTipStatusBar(0x3C4ACF);
	m_mpBar->Initialization();
	AddChild(m_mpBar);

	m_imgNumHp = new ImageNumber;
	m_imgNumHp->Initialization();
	m_imgNumHp->SetFrameRect(CCRectMake(16, 25, 40, 10));
	AddChild(m_imgNumHp);

	m_imgNumMp = new ImageNumber;
	m_imgNumMp->Initialization();
	m_imgNumMp->SetFrameRect(CCRectMake(16, 43, 40, 10));
	AddChild(m_imgNumMp);

	EnableEvent(false);
}

void HighlightTip::SetFighter(Fighter* pkFighter)
{
	if (!pkFighter)
	{
		return;
	}

	NDBaseRole* pkRole = pkFighter->GetRole();
	CCPoint kPoint = CCPointMake(pkFighter->getX(), pkFighter->getY());

	CCRect kRect = CCRectMake(kPoint.x, kPoint.y, m_pkPicBubble->GetSize().width,
			m_pkPicBubble->GetSize().height);

	kRect.origin.x -= kRect.size.width / 2;

	if (kRect.origin.x < 0)
	{
		kRect.origin.x = 0;
	}

	kRect.origin.y = kRect.origin.y - pkRole->GetHeight() - kRect.size.height;

	if (kRect.origin.y < 0)
	{
		kRect.origin.y = 0;
	}

	SetFrameRect(kRect);

	m_hpBar->SetNum(pkFighter->m_kInfo.nLife, pkFighter->m_kInfo.nLifeMax);
	m_hpBar->SetFrameRect(
			CCRectMake(kRect.origin.x + 16, kRect.origin.y + 20, 40, 10));
	m_imgNumHp->SetSmallRedTwoNumber(pkFighter->m_kInfo.nLife, pkFighter->m_kInfo.nLifeMax);

	m_mpBar->SetNum(pkFighter->m_kInfo.nMana, pkFighter->m_kInfo.nManaMax);
	m_mpBar->SetFrameRect(
			CCRectMake(kRect.origin.x + 16, kRect.origin.y + 38, 40, 10));
	m_imgNumMp->SetSmallRedTwoNumber(pkFighter->m_kInfo.nMana, pkFighter->m_kInfo.nManaMax);

	NDUILabel* pkNameLabel = (NDUILabel*) GetChild(TAG_NAME);

	if (!pkNameLabel)
	{
		pkNameLabel = new NDUILabel;
		pkNameLabel->SetFontColor(ccc4(255, 255, 255, 255));
		pkNameLabel->Initialization();
		pkNameLabel->SetTag(TAG_NAME);
		AddChild(pkNameLabel);
	}
	std::stringstream kStringStream;
	kStringStream << pkRole->m_strName << "Lv" << pkRole->m_nLevel;
	//	if (f->m_kInfo.fighterType == Fighter_TYPE_RARE_MONSTER)
	//	{
	//		ss << "【" << NDCommonCString("xiyou") << "】"; 
	//	}
	pkNameLabel->SetText(kStringStream.str().c_str());
	CCSize sizeName = getStringSize(kStringStream.str().c_str(), 15);
	pkNameLabel->SetFrameRect(
			CCRectMake((kRect.size.width - sizeName.width) / 2, 0,
					sizeName.width, sizeName.height));
}

enum
{
	MAX_TURN = 30,	// 最大回合数
	AUTO_COUNT = 0,	// 自动倒计时时间

	TEXT_BTN_HEIGHT = 29, // 按钮高度
};

#define TIMER_TIMELEFT 1
#define TIMER_BACKTOGAME 2
#define TIMER_AUTOCOUNT 3
#define TIMER_AUTOFIGHT 4
#define MAX_SKILL_NUM (20)


bool Battle::ms_bAuto = false;
BattleAction Battle::ms_kLastTurnActionUser(BATTLE_ACT_PHY_ATK);
BattleAction Battle::ms_kLastTurnActionEudemon(BATTLE_ACT_PET_PHY_ATK);

IMPLEMENT_CLASS(Battle, NDUILayer)

void Battle::ResetLastTurnBattleAction()
{
	ms_bAuto = false;
	ms_kLastTurnActionUser.btAction = BATTLE_ACT_PHY_ATK;
	ms_kLastTurnActionUser.vData.clear();
	ms_kLastTurnActionEudemon.btAction = BATTLE_ACT_PET_PHY_ATK;
	ms_kLastTurnActionEudemon.vData.clear();
}

Battle::Battle()
{
	Init();
}

Battle::Battle(Byte btType)
{
	INC_NDOBJ_RTCLS
	Init();
	m_battleType = BATTLE_TYPE(btType);

}

void Battle::CloseChatInput()
{
	//if (NULL != m_chatDelegate.tfChat.subviews) {
	//	[m_chatDelegate.tfChat removeFromSuperview];
	//}
}

Battle::~Battle()
{
	DEC_NDOBJ_RTCLS
	//	if (m_imgTurn) {
	//		m_imgTurn->RemoveFromParent(false);
	//		SAFE_DELETE(m_imgTurn);
	//	}
	//	if (m_imgTimer) {
	//		m_imgTimer->RemoveFromParent(false);
	//		SAFE_DELETE(m_imgTimer);
	//	}
	//	if (m_imgQuickTalkBg) {
	//		m_imgQuickTalkBg->RemoveFromParent(false);
	//		SAFE_DELETE(m_imgQuickTalkBg);
	//	}
	//	if (m_tlQuickTalk) {
	//		m_tlQuickTalk->RemoveFromParent(false);
	//		SAFE_DELETE(m_tlQuickTalk);
	//	}
	//	if (m_imgChat) {
	//		m_imgChat->RemoveFromParent(false);
	//		SAFE_DELETE(m_imgChat);
	//	}
	//	if (m_btnSendChat) {
	//		m_btnSendChat->RemoveFromParent(false);
	//		SAFE_DELETE(m_btnSendChat);
	//	}

	CloseChatInput();
	//[m_chatDelegate release];
	if (eraseInOutEffect)
	{
		NDEraseInOutEffect *eioEffect = eraseInOutEffect.Pointer();
		SAFE_DELETE_NODE(eioEffect);
	}
	//CC_SAFE_DELETE (m_picActionWordDef);
	//CC_SAFE_DELETE (m_picActionWordDodge);
	//CC_SAFE_DELETE (m_picActionWordFlee);
	//CC_SAFE_DELETE (m_battleBg);

	//	SAFE_DELETE(m_picTalk);
	//	SAFE_DELETE(m_picQuickTalk);
	//	SAFE_DELETE(m_picAuto);
	//	SAFE_DELETE(m_picAutoCancel);
	//	SAFE_DELETE(m_picLeave);

	// 设置战斗状态
	NDPlayer::defaultHero().UpdateState(USERSTATE_FIGHTING, false);

	CC_SAFE_DELETE (m_curBattleAction);

	if (m_dlgBattleResult)
	{
		m_dlgBattleResult->RemoveFromParent(true);
	}
	//	if(m_orignalMapId!=NDMapMgrObj.m_iMapID){
	//		NDMapMgrObj.loadSceneByMapID(m_orignalMapId);
	//		NDMapMgrObj.AddAllNpcToMap();
	//		NDMapMgrObj.AddAllMonsterToMap();
	//	}
	NDDirector* director = NDDirector::DefaultDirector();
//	director->PopScene(true);
	GameScene* gameScene = (GameScene*) director->GetRunningScene();

	NDMapLayer* mapLayer = NDMapMgrObj.getMapLayerOfScene(gameScene);
	if (mapLayer) {
		//		mapLayer->SetScreenCenter(m_orignalPos);
		//mapLayer->SetBattleBackground(false);//不在此设置非战斗背景播放其他非战斗元素(NPC==)--Guosen 2012.7.5
		//mapLayer->replaceMapData(sceneMapId, sceneCenterX, sceneCenterY);//不在此还原地图--Guosen 2012.7.5
		//ScriptMgrObj.excuteLuaFunc("SetUIVisible", "",0);//不在此显示UI--Guosen 2012.7.2
		int theId=NDMapMgrObj.GetMotherMapID();
		//if(theId/100000000==9){
		//ScriptMgrObj.excuteLuaFunc("showDynMapUI", "",0);
		//}else{
		//ScriptMgrObj.excuteLuaFunc("showCityMapUI", "",0);
		//}
		//		mapLayer->AddChild(&(NDPlayer::defaultHero()));
	}

	gameScene->OnBattleEnd();
	//	if (m_btnLeave) {
	//		RemoveChild(m_btnLeave, false);
	//		SAFE_DELETE(m_btnLeave);
	//	}

	//	if (m_battleOpt) {
	//		RemoveChild(m_battleOpt, false);
	//		SAFE_DELETE(m_battleOpt);
	//	}
	//	if (m_eudemonOpt) {
	//		RemoveChild(m_eudemonOpt, false);
	//		SAFE_DELETE(m_eudemonOpt);
	//	}

	//	SAFE_DELETE(m_picWhoAmI);
	//	SAFE_DELETE(m_picLingPai);
	//CC_SAFE_DELETE (m_picBaoJi);

	//	if (s_bAuto) {
	//		RemoveChild(m_lbAuto, false);
	//		RemoveChild(m_imgAutoCount, false);
	//		SAFE_DELETE(m_imgAutoCount);
	//		SAFE_DELETE(m_lbAuto);
	//	}

	ReleaseCommandList();

	for (VEC_FIGHTER_IT it = m_vAttaker.begin(); it != m_vAttaker.end(); it++)
	{
		Fighter* fighter = *it;
		fighter->GetRole()->RemoveFromParent(false);
		fighter->ClearAllStatusIcons();
	}

	for (VEC_FIGHTER_IT it = m_vDefencer.begin(); it != m_vDefencer.end(); it++)
	{
		Fighter* fighter = *it;
		fighter->GetRole()->RemoveFromParent(false);
		fighter->ClearAllStatusIcons();
	}

	for (VEC_SUB_ANI_GROUP_IT it = m_vSubAniGroup.begin();
			it != m_vSubAniGroup.end(); it++)
	{
		it->frameRec->release();
	}

	NDPlayer& player = NDPlayer::defaultHero();

	if (player.IsInState(USERSTATE_DEAD))
	{
		NDScene* gameScene = NDDirector::DefaultDirector()->GetRunningScene();
		if (gameScene && gameScene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
		{
			((GameScene*) gameScene)->ShowRelieve(true);
		}
	}
	else
	{
		// 使用自动恢复药
		if (player.m_nLife < player.m_nMaxLife
				|| player.m_nMana < player.m_nMaxMana)
		{
			ItemMgr& items = ItemMgrObj;
			Item* pkRecoverItem = items.GetBagItemByType(IT_RECOVER);

			if (pkRecoverItem && pkRecoverItem->m_bIsActive)
			{
				sendItemUse(*pkRecoverItem);
			}
		}
	}

// 	if (player.IsInState(USERSTATE_BF_WAIT_RELIVE))
// 	{
// 		BattleFieldRelive::Show();
// 	}
	
	if (m_rewardContent.size() > 2)
	{
		GlobalShowDlg(NDCommonCString("BattleRes"), m_rewardContent.c_str(),3.0f);
	}
}

void Battle::OnDialogClose(NDUIDialog* dialog)
{
	if (m_dlgBattleResult == dialog)
	{
		// 点击释放dialog
		m_dlgBattleResult->SetDelegate(NULL);
		m_dlgBattleResult = NULL;
		BattleMgrObj.quitBattle();
		//	} else if (m_dlgHint == dialog) {
		//		m_dlgHint = NULL;
		//		switch (m_battleStatus) {
		//			case BS_USE_ITEM_MENU:
		//			case BS_USER_SKILL_MENU:
		//				m_battleStatus = BS_USER_MENU;
		//				//AddChild(m_battleOpt);
		//				break;
		//			case BS_EUDEMON_SKILL_MENU:
		//				m_battleStatus = BS_EUDEMON_MENU;
		//				//AddChild(m_eudemonOpt);
		//				break;
		//			default:
		//				break;
		//		}
	}
}

void Battle::AddFighter(Fighter* f)
{
	BATTLE_GROUP group = f->GetGroup();
	NDBaseRole* role = f->GetRole();
	if (!role)
	{
		CC_SAFE_DELETE(f);
		return;
	}

	AddChild(role);
	if (role->IsKindOfClass(RUNTIME_CLASS(NDPlayer)))
	{
		//		m_playerHead->SetBattlePlayer(f);
		m_ourGroup = group;
	}

	//	if (role->IsKindOfClass(RUNTIME_CLASS(NDBattlePet))) {
	//		if (f->m_kInfo.line == BATTLE_LINE_FRONT && f->m_kInfo.posIdx == 0) { // 玩家战宠
	//			if (NULL == m_petHead) {
	//				m_petHead = new PetHead;
	//				m_petHead->Initialization(f);
	//				AddChild(m_petHead);
	//			}
	//		}
	//	}

	if (BATTLE_GROUP_DEFENCE == group)
	{
		role->m_bFaceRight = false;
		m_vDefencer.push_back(f);
	}
	else
	{
		role->m_bFaceRight = true;
		m_vAttaker.push_back(f);
	}
	f->setPosition(m_teamAmout);
	f->showFighterName(true);
	//	if (f->m_kInfo.bRoleMonster) {
	//		role->m_faceRight = !role->m_faceRight;
	//	}

	battleStandAction(*f);
}

void Battle::clearHighlight()
{
	RemoveChild(TAG_LINGPAI, true);
	RemoveChild(TAG_NAME, true);
	clearAllWillBeAtk();
	//if (m_highlightFighter)
	//		m_highlightFighter->setWillBeAtk(false);
	m_highlightFighter = NULL;
}

void Battle::CloseViewStatus()
{
	RemoveChild(TAG_VIEW_FIGHTER_STATUS, true);
	clearHighlight();

	//	if (m_dlgHint) {
	//		m_dlgHint->RemoveFromParent(true);
	//		m_dlgHint = NULL;
	//	}

	if (m_dlgStatus)
	{
		m_dlgStatus->RemoveFromParent(true);
		m_dlgStatus = NULL;
	}
}

//void Battle::CloseSkillMenu()
//{
//	if (m_dlgHint) {
//		m_dlgHint->RemoveFromParent(true);
//		m_dlgHint = NULL;
//	} else if (m_skillOpt) {
//		RemoveChild(m_skillOpt, true);
//		m_skillOpt = NULL;
//		RemoveChild(TAG_SKILL_MEMO, true);
//	}
//}

//void Battle::CloseItemMenu()
//{
//	if (m_dlgHint) {
//		m_dlgHint->RemoveFromParent(true);
//		m_dlgHint = NULL;
//	} else if (m_itemOpt) {
//		m_mapUseItem.clear();
//		RemoveChild(m_itemOpt, true);
//		m_itemOpt = NULL;
//	}
//}

void Battle::ShowQuickChat(bool bShow)
{
	//	if (bShow) {
	//		AddChild(m_imgQuickTalkBg);
	//		AddChild(m_tlQuickTalk);
	//		m_layerBtnQuitTalk->SetFrameRect(CCRectMake(35, 136, 48, 20));
	//	} else {
	//		RemoveChild(m_imgQuickTalkBg, false);
	//		RemoveChild(m_tlQuickTalk, false);
	//		m_layerBtnQuitTalk->SetFrameRect(CCRectMake(35, 300, 48, 20));
	//	}
}

void Battle::ShowChatTextField(bool bShow)
{
	//	if (m_bShowChatTextField == bShow) {
	//		return;
	//	}
	//	
	//	m_bShowChatTextField = bShow;
	//	
	//	if (m_bShowChatTextField) {
	//		AddChild(m_imgChat);
	//		AddChild(m_btnSendChat);
	//		
	//		if (NULL == m_chatDelegate.tfChat) {
	//			UITextField* tfChat = [[UITextField alloc] init];
	//			tfChat.transform = CGAffineTransformMakeRotation(3.141592f/2.0f);
	//			tfChat.frame = CCRectMake(290.0f, 54.0f, 25.0f, 326.0f);
	//			tfChat.textColor = [UIColor whiteColor];
	//			tfChat.returnKeyType = UIReturnKeyDone;
	//			tfChat.delegate = m_chatDelegate;
	//			m_chatDelegate.tfChat = tfChat;
	//			[tfChat release];
	//		}
	//		
	//		if (NULL == [m_chatDelegate.tfChat superview]) {
	//			[[[CCDirector sharedDirector] openGLView] addSubview:m_chatDelegate.tfChat];
	//		}
	//	} else {
	//		RemoveChild(m_imgChat, false);
	//		RemoveChild(m_btnSendChat, false);
	//		[m_chatDelegate.tfChat removeFromSuperview];
	//	}
}

void Battle::OnButtonClick(NDUIButton* button)
{
	//	if (button == m_btnLeave) {
	//		if (m_bWatch) {
	//			ShowProgressBar;
	//			NDTransData bao(_MSG_BATTLEACT);
	//			bao << BATTLE_ACT_LEAVE << Byte(0) << Byte(0);
	//			// SEND_DATA(bao);
	//			return;
	//		}
	//		
	//	} else if (button == m_btnAuto) {
	//		if (s_bAuto) {
	//			stopAuto();
	//		} else {
	//			OnBtnAuto(m_battleStatus < BS_SET_FIGHTER);
	//		}
	//		
	//		/*switch (m_battleStatus) {
	//			case BS_USER_MENU:
	//			case BS_EUDEMON_MENU:
	//			{
	//				stopAuto();
	//				VEC_FIGHTER& enemyList = GetEnemySideList();
	//				for (VEC_FIGHTER_IT it = enemyList.begin(); it != enemyList.end(); it++) {
	//					if ((*it)->isVisiable()) {
	//						if (m_battleStatus == BS_EUDEMON_MENU) {
	//							m_battleStatus = BS_CHOOSE_VIEW_FIGHTER_STATUS_PET;
	//							RemoveChild(m_eudemonOpt, false);
	//						} else {
	//							m_battleStatus = BS_CHOOSE_VIEW_FIGHTER_STATUS;
	//							RemoveChild(m_battleOpt, false);
	//						}
	//						
	//						HighlightFighter(*it);
	//						
	//						CCSize size = CCDirector::sharedDirector()->getWinSizeInPixels();
	//						NDUILabel* lbViewFighter = new NDUILabel;
	//						lbViewFighter->Initialization();
	//						lbViewFighter->SetText(TEXT_VIEW_STATUS);
	//						lbViewFighter->SetFontColor(ccc4(255, 255, 255, 255));
	//						CCSize sizeText = getStringSize(TEXT_VIEW_STATUS, 15);
	//						lbViewFighter->SetTag(TAG_VIEW_FIGHTER_STATUS);
	//						lbViewFighter->SetFrameRect(CCRectMake((size.width - sizeText.width) / 2
	//										       , 260, sizeText.width, sizeText.height));
	//						AddChild(lbViewFighter);
	//						return;
	//					}
	//				}
	//			}
	//				break;
	//			case BS_CHOOSE_VIEW_FIGHTER_STATUS:
	//				CloseViewStatus();
	//				AddChild(m_battleOpt);
	//				m_battleStatus = BS_USER_MENU;
	//				break;
	//			case BS_CHOOSE_VIEW_FIGHTER_STATUS_PET:
	//				CloseViewStatus();
	//				AddChild(m_eudemonOpt);
	//				m_battleStatus = BS_EUDEMON_MENU;
	//				break;
	//			case BS_USE_ITEM_MENU:
	//				CloseItemMenu();
	//				m_battleStatus = BS_USER_MENU;
	//				AddChild(m_battleOpt);
	//				break;
	//			case BS_EUDEMON_USE_ITEM_MENU:
	//				CloseItemMenu();
	//				m_battleStatus = BS_EUDEMON_MENU;
	//				AddChild(m_eudemonOpt);
	//				break;
	//			case BS_USER_SKILL_MENU:
	//				CloseSkillMenu();
	//				m_battleStatus = BS_USER_MENU;
	//				AddChild(m_battleOpt);
	//				break;
	//			case BS_EUDEMON_SKILL_MENU:
	//				CloseSkillMenu();
	//				m_battleStatus = BS_EUDEMON_MENU;
	//				AddChild(m_eudemonOpt);
	//				break;
	//			case BS_CHOOSE_ENEMY_CATCH:
	//			case BS_CHOOSE_ENEMY_PHY_ATK:
	//			case BS_CHOOSE_ENEMY_MAG_ATK:
	//			case BS_CHOOSE_OUR_SIDE_MAG_ATK:
	//				clearHighlight();
	//				AddChild(m_battleOpt);
	//				m_battleStatus = BS_USER_MENU;
	//				break;
	//			case BS_CHOOSE_OUR_SIDE_USE_ITEM_USER:
	//				clearHighlight();
	//				OnBtnUseItem(BS_USE_ITEM_MENU);
	//				break;
	//			case BS_CHOOSE_OUR_SIDE_USE_ITEM_EUDEMON:
	//				clearHighlight();
	//				OnBtnUseItem(BS_EUDEMON_USE_ITEM_MENU);
	//				break;
	//			case BS_CHOOSE_ENEMY_PHY_ATK_EUDEMON:
	//			case BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON:
	//			case BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON:
	//				clearHighlight();
	//				AddChild(m_eudemonOpt);
	//				m_battleStatus = BS_EUDEMON_MENU;
	//				break;
	//			default:
	//				break;
	//		}*/
	//	} else if (button == m_btnTalk) 
	//	{
	//		//ChatRecordManager::DefaultManager()->Show();
	//		// 直接显示聊天输入框
	//		//ShowChatTextField(!m_bShowChatTextField);
	//		NewChatScene::DefaultManager()->Show();
	//	} else if (button == m_btnQuickTalk) {
	//		// 快捷聊天
	//		ShowQuickChat(m_imgQuickTalkBg->GetParent() == NULL);
	//		
	//	} else if (button == m_btnSendChat) {
	//		NSString msg = m_chatDelegate.tfChat.text;
	//		if ([msg length] > 0) {
	//			ChatInput::SendChatDataToServer(ChatTypeSection, [msg UTF8String]);
	//			m_chatDelegate.tfChat.text = @"";
	//			string speaker = NDPlayer::defaultHero().m_name;
	//			speaker += "：";
	//			Chat::DefaultChat()->AddMessage(ChatTypeSection, [msg UTF8String], speaker.c_str());
	//		}
	//	}
	//	else if (button == m_btnCancleAutoFight)
	//	{
	//		//取消自动战斗
	//		RemoveCancleAutoFightButton();
	//		s_bAuto = false;
	//	}
}

void Battle::Initialization(int action)
{
	NDUILayer::Initialization();

	SetScrollEnabled(true);

	if (action == BATTLE_STAGE_WATCH)
	{
		m_bWatch = true;
	}

	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();

	m_battleBg = new NDUILayer();
	m_battleBg->Initialization();
	m_battleBg->SetBackgroundColor(ccc4(0, 0, 0, 188));
	m_battleBg->SetFrameRect(CCRectMake(0, 0, winSize.width, winSize.height));

	if (m_bWatch)
	{ // 观战不需要其他操作
		return;
	}



	if (ms_bAuto)
	{
		SetAutoCount();
	}


	if (ms_bAuto)
	{
		//RemoveChild(m_battleOpt, false);
		m_timer.SetTimer(this, TIMER_AUTOFIGHT, 0.5f);
	}
}

void Battle::InitEudemonOpt()
{
	// 有战宠
	getMainEudemon();

	/*if (getMainEudemon()) {
	 CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	 m_eudemonOpt = new NDUITableLayer;
	 m_eudemonOpt->Initialization();
	 m_eudemonOpt->VisibleSectionTitles(false);
	 m_eudemonOpt->SetFrameRect(CCRectMake((winSize.width / 2) - 30, winSize.height / 2 - 115, 60, TEXT_BTN_HEIGHT * 5));
	 NDDataSource *ds = new NDDataSource;
	 NDSection *sec = new NDSection;
	 
	 // 攻击
	 NDUIButton *attack = new NDUIButton;
	 attack->Initialization();
	 attack->SetTag(BTN_EUD_ATK);
	 attack->SetTitle("攻  击");
	 attack->SetFocusColor(ccc4(253, 253, 253, 255));
	 sec->AddCell(attack);
	 
	 // 物品
	 NDUIButton  *btnUseItem = new NDUIButton;
	 btnUseItem->Initialization();
	 btnUseItem->SetTitle("物  品");
	 btnUseItem->SetTag(BTN_EUD_ITEM);
	 btnUseItem->SetFocusColor(ccc4(253, 253, 253, 255));
	 sec->AddCell(btnUseItem);
	 
	 NDUIButton *skill = new NDUIButton;
	 skill->Initialization();
	 skill->SetTag(BTN_EUD_SKILL);
	 skill->SetTitle("技  能");
	 skill->SetFocusColor(ccc4(253, 253, 253, 255));
	 sec->AddCell(skill);
	 
	 NDUIButton *def = new NDUIButton;
	 def->Initialization();
	 def->SetTag(BTN_EUD_DEF);
	 def->SetTitle("防  御");
	 def->SetFocusColor(ccc4(253, 253, 253, 255));
	 sec->AddCell(def);
	 
	 NDUIButton *flee = new NDUIButton;
	 flee->Initialization();
	 flee->SetTag(BTN_EUD_FLEE);
	 flee->SetTitle("逃  跑");
	 flee->SetFocusColor(ccc4(253, 253, 253, 255));
	 sec->AddCell(flee);
	 
	 sec->SetFocusOnCell(0);
	 
	 ds->AddSection(sec);
	 m_eudemonOpt->SetDelegate(this);
	 m_eudemonOpt->SetDataSource(ds);
	 }*/
}

/*void Battle::OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
 {
 if (m_skillOpt == table) {
 // 技能说明
 NDUIMemo* skillMemo = (NDUIMemo*)GetChild(TAG_SKILL_MEMO);
 
 if (m_battleStatus == BS_USER_SKILL_MENU) {
 m_curBattleAction->btAction = BATTLE_ACT_MAG_ATK;
 s_lastTurnActionUser.btAction = BATTLE_ACT_MAG_ATK;
 s_lastTurnActionUser.vData.clear();
 
 SET_BATTLE_SKILL_LIST_IT itSkill = m_setBattleSkillList.begin();
 size_t n = 0;
 for (; n < cellIndex; n++) {
 itSkill++;
 }
 
 if (n < m_setBattleSkillList.size()) {
 m_curBattleAction->vData.push_back(*itSkill);
 s_lastTurnActionUser.vData.push_back(*itSkill);
 s_lastTurnActionUser.vData.push_back(0);
 }
 BattleSkill* skill = BattleMgrObj.GetBattleSkill(*itSkill);
 if (!skill) {
 return;
 }
 
 if (skillMemo) {
 skillMemo->SetText(skill->getSimpleDes(true).c_str());
 }
 } else if (m_battleStatus == BS_EUDEMON_SKILL_MENU) {
 
 NDBattlePet* pet = NDPlayer::defaultHero().battlepet;
 NDAsssert(pet != NULL);
 SET_BATTLE_SKILL_LIST petBattleSkillList = pet->GetSkillList(SKILL_TYPE_ATTACK);
 
 m_curBattleAction->btAction = BATTLE_ACT_PET_MAG_ATK;
 
 s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_MAG_ATK;
 s_lastTurnActionEudemon.vData.clear();
 
 SET_BATTLE_SKILL_LIST_IT itSkill = petBattleSkillList.begin();
 size_t n = 0;
 for (; n < cellIndex; n++) {
 itSkill++;
 }
 
 if (n < petBattleSkillList.size()) {
 m_curBattleAction->vData.push_back(*itSkill);
 s_lastTurnActionEudemon.vData.push_back(*itSkill);
 s_lastTurnActionEudemon.vData.push_back(0);
 }
 BattleSkill* skill = BattleMgrObj.GetBattleSkill(*itSkill);
 if (!skill) {
 return;
 }
 
 if (skillMemo) {
 skillMemo->SetText(skill->getSimpleDes(true).c_str());
 }
 }
 }
 }*/

void Battle::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	//	if (table == m_tlQuickTalk) {
	//		if (cell->IsKindOfClass(RUNTIME_CLASS(QuickTalkCell))) {
	//			QuickTalkCell* quickTalk = (QuickTalkCell*)cell;
	//			string strText = quickTalk->GetText();
	//			ChatInput::SendChatDataToServer(ChatTypeSection, strText.c_str());
	//			string speaker = NDPlayer::defaultHero().m_name;
	//			speaker += "：";
	//			Chat::DefaultChat()->AddMessage(ChatTypeSection, strText.c_str(), speaker.c_str());
	//			ShowQuickChat(false);
	//		}
	//	}
}
/*void Battle::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
 {	
 if (m_battleOpt == table) {
 switch ((cellIndex + 1))
 {
 case BTN_ATTATCK:
 stopAuto();
 OnBtnAttack();
 break;
 case BTN_FLEE:
 stopAuto();
 OnBtnRun();
 break;
 case BTN_DEFENCE:
 stopAuto();
 OnBtnDefence();
 break;
 case BTN_CATCH:
 stopAuto();
 OnBtnCatch();
 break;
 case BTN_AUTO:
 OnBtnAuto(true);
 break;
 //			case BTN_ITEM:
 //				stopAuto();
 //				OnBtnUseItem(BS_USE_ITEM_MENU);
 //				break;
 case BTN_SKILL:
 stopAuto();
 //OnBtnSkill();
 break;
 default:
 break;
 }
 } else if (m_itemOpt == table) {
 if (m_battleStatus == BS_USE_ITEM_MENU) {
 m_curBattleAction->btAction = BATTLE_ACT_USEITEM;
 m_battleStatus = BS_CHOOSE_OUR_SIDE_USE_ITEM_USER;
 } else {
 m_curBattleAction->btAction = BATTLE_ACT_PET_USEITEM;
 m_battleStatus = BS_CHOOSE_OUR_SIDE_USE_ITEM_EUDEMON;
 }
 
 m_curBattleAction->vData.clear();
 
 MAP_USEITEM_IT it = m_mapUseItem.begin();
 for (unsigned int i = 0; it != m_mapUseItem.end() && i < cellIndex; it++, i++) {
 }
 
 if (it != m_mapUseItem.end()) {
 m_curBattleAction->vData.push_back(it->second.first);
 }
 
 VEC_FIGHTER& ourSideList = GetOurSideList();
 Fighter* f;
 for (size_t i = 0; i < ourSideList.size(); i++) {
 f = ourSideList.at(i);
 if (f->isVisiable()) {
 HighlightFighter(f);
 break;
 }
 }
 
 RemoveChild(m_itemOpt, true);
 m_itemOpt = NULL;
 } else if (m_eudemonOpt == table) {
 switch (cell->GetTag()) {
 case BTN_EUD_ATK:
 OnEudemonAttack();
 break;
 case BTN_EUD_SKILL:
 //OnEudemonSkill();
 break;
 case BTN_EUD_DEF:
 {
 BattleAction actioin(BATTLE_ACT_PET_PHY_DEF);
 s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_PHY_DEF;
 SendBattleAction(actioin);
 }
 break;
 case BTN_EUD_FLEE:
 {
 BattleAction actioin(BATTLE_ACT_PET_ESCAPE);
 SendBattleAction(actioin);
 }
 break;
 //			case BTN_EUD_ITEM:
 //				OnBtnUseItem(BS_EUDEMON_USE_ITEM_MENU);
 //				break;
 default:
 break;
 }
 } else if (m_skillOpt == table) {
 m_curBattleAction->vData.clear();
 
 if (m_battleStatus == BS_USER_SKILL_MENU) {
 m_curBattleAction->btAction = BATTLE_ACT_MAG_ATK;
 s_lastTurnActionUser.btAction = BATTLE_ACT_MAG_ATK;
 s_lastTurnActionUser.vData.clear();
 
 SET_BATTLE_SKILL_LIST_IT itSkill = m_setBattleSkillList.begin();
 size_t n = 0;
 for (; n < cellIndex; n++) {
 itSkill++;
 }
 
 if (n < m_setBattleSkillList.size()) {
 m_curBattleAction->vData.push_back(*itSkill);
 s_lastTurnActionUser.vData.push_back(*itSkill);
 s_lastTurnActionUser.vData.push_back(0);
 }
 BattleSkill* skill = BattleMgrObj.GetBattleSkill(*itSkill);
 if (!skill) {
 return;
 }
 
 int targetType = skill->getAtkType();
 GetMainUser()->setUseSkill(skill);
 
 if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
 
 m_battleStatus = BS_CHOOSE_ENEMY_MAG_ATK;
 
 VEC_FIGHTER& enemyList = GetEnemySideList();
 Fighter* f;
 for (size_t i = 0; i < enemyList.size(); i++) {
 f = enemyList.at(i);
 if (f->isVisiable()) {
 HighlightFighter(f);
 break;
 }
 }
 
 } else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
 
 m_battleStatus = BS_CHOOSE_OUR_SIDE_MAG_ATK;
 
 VEC_FIGHTER& ourList = GetOurSideList();
 Fighter* f;
 for (size_t i = 0; i < ourList.size(); i++) {
 f = ourList.at(i);
 if (f->isVisiable()) {
 HighlightFighter(f);
 break;
 }
 }
 
 } else if ((targetType & SKILL_ATK_TYPE_SELF) == SKILL_ATK_TYPE_SELF) {
 m_curBattleAction->vData.push_back(GetMainUser()->m_kInfo.idObj);
 SendBattleAction(*m_curBattleAction);
 
 }
 } else if (m_battleStatus == BS_EUDEMON_SKILL_MENU) {
 
 NDBattlePet* pet = NDPlayer::defaultHero().battlepet;
 NDAsssert(pet != NULL);
 SET_BATTLE_SKILL_LIST petBattleSkillList = pet->GetSkillList(SKILL_TYPE_ATTACK);
 
 m_curBattleAction->btAction = BATTLE_ACT_PET_MAG_ATK;
 
 s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_MAG_ATK;
 s_lastTurnActionEudemon.vData.clear();
 
 SET_BATTLE_SKILL_LIST_IT itSkill = petBattleSkillList.begin();
 size_t n = 0;
 for (; n < cellIndex; n++) {
 itSkill++;
 }
 
 if (n < petBattleSkillList.size()) {
 m_curBattleAction->vData.push_back(*itSkill);
 s_lastTurnActionEudemon.vData.push_back(*itSkill);
 s_lastTurnActionEudemon.vData.push_back(0);
 }
 BattleSkill* skill = BattleMgrObj.GetBattleSkill(*itSkill);
 if (!skill) {
 return;
 }
 
 // 宠物mp不足提示
 if (getMainEudemon()->m_kInfo.nMana < skill->getMpRequire()) {
 m_dlgHint = new NDUIDialog;
 m_dlgHint->Initialization();
 m_dlgHint->SetDelegate(this);
 m_dlgHint->Show("法力不足", "您的宝宝法力不够啦！", NULL, NULL);
 } else {
 int targetType = skill->getAtkType();
 
 if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
 
 m_battleStatus = BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON;
 
 VEC_FIGHTER& enemyList = GetEnemySideList();
 Fighter* f;
 for (size_t i = 0; i < enemyList.size(); i++) {
 f = enemyList.at(i);
 if (f->isVisiable()) {
 HighlightFighter(f);
 break;
 }
 }
 
 } else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
 
 m_battleStatus = BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON;
 
 VEC_FIGHTER& ourList = GetOurSideList();
 Fighter* f;
 for (size_t i = 0; i < ourList.size(); i++) {
 f = ourList.at(i);
 if (f->isVisiable()) {
 HighlightFighter(f);
 break;
 }
 }
 
 } else if ((targetType & SKILL_ATK_TYPE_SELF) == SKILL_ATK_TYPE_SELF) {
 m_curBattleAction->vData.push_back(getMainEudemon()->m_kInfo.idObj);
 SendBattleAction(*m_curBattleAction);
 
 }
 }
 }
 RemoveChild(m_skillOpt, true);
 m_skillOpt = NULL;
 RemoveChild(TAG_SKILL_MEMO, true);
 }
 }*/

void Battle::processBattleSkillList(NDTransData& data, int len)
{
	//	m_setBattleSkillList.clear();
	//	int nCount = data.ReadShort();
	//	for (int i = 0; i < nCount; i++) {
	//		m_setBattleSkillList.insert(data.ReadInt());
	//	}
	//	
	//	if (s_bAuto) {
	//		RefreshSkillBar();
	//		m_fighterLeft->SetGray(true);
	//	}
}

/*void Battle::OnBtnSkill()
 {
 m_battleStatus = BS_USER_SKILL_MENU;
 RemoveChild(m_battleOpt, false);
 
 // 没有技能
 if (m_setBattleSkillList.size() <= 0) {
 m_dlgHint = new NDUIDialog;
 m_dlgHint->Initialization();
 m_dlgHint->SetDelegate(this);
 m_dlgHint->Show(NULL, "本回合无可用技能", NULL, NULL);
 return;
 }
 
 // 打开技能列表
 NDAsssert (m_skillOpt == NULL);
 
 CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
 int height = 0;
 
 m_skillOpt = new NDUITableLayer;
 m_skillOpt->Initialization();
 m_skillOpt->VisibleSectionTitles(false);
 
 NDDataSource *ds = new NDDataSource;
 NDSection *sec = new NDSection;
 
 BattleMgr& bm = BattleMgrObj;
 BattleSkill* bs = NULL;
 
 SET_BATTLE_SKILL_LIST_IT itSkill = m_setBattleSkillList.begin();
 BattleSkill* firstSkill = bm.GetBattleSkill(*itSkill);
 for (; itSkill != m_setBattleSkillList.end(); itSkill++) {
 bs = bm.GetBattleSkill(*itSkill);
 if (!bs) {
 continue;
 }
 height += TEXT_BTN_HEIGHT;
 
 NDUIButton *skill = new NDUIButton;
 skill->Initialization();
 skill->SetFocusColor(ccc4(253, 253, 253, 255));
 skill->SetTitle(bs->getName().c_str());
 sec->AddCell(skill);
 }
 
 if (height > 120) {
 height = 120;
 }
 
 sec->SetFocusOnCell(0);
 
 ds->AddSection(sec);
 m_skillOpt->SetDelegate(this);
 m_skillOpt->SetDataSource(ds);
 m_skillOpt->SetFrameRect(CCRectMake((winSize.width / 2) - 80, winSize.height / 2, 160, height));
 AddChild(m_skillOpt);
 
 // 技能说明
 NDUIMemo* skillMemo = new NDUIMemo();
 skillMemo->Initialization();
 skillMemo->SetTag(TAG_SKILL_MEMO);
 skillMemo->SetBackgroundColor(ccc4(228, 219, 169, 255));
 skillMemo->SetText(firstSkill->getSimpleDes(true).c_str());
 skillMemo->SetFrameRect(CCRectMake((winSize.width / 2) - 80, 30, 160, winSize.height / 2 - 35));
 AddChild(skillMemo);
 }*/

/*void Battle::OnBtnUseItem(BATTLE_STATUS bs)
 {
 m_battleStatus = bs;
 if (m_battleOpt) 
 {
 RemoveChild(m_battleOpt, false);
 }	
 if (m_eudemonOpt) 
 {
 RemoveChild(m_eudemonOpt, false);
 }
 
 m_mapUseItem.clear();
 
 ItemMgr& itemsObj = ItemMgrObj;
 
 vector<Item*> vItemList;
 itemsObj.GetBattleUsableItem(vItemList);
 
 if (vItemList.size() == 0) {
 return;
 }
 
 MAP_USEITEM_IT itUseItem;
 Item* item = NULL;
 for (vector<Item*>::iterator it = vItemList.begin(); it != vItemList.end(); it++) {
 item = *it;
 if (!item) {
 continue;
 }
 
 itUseItem = m_mapUseItem.find(item->iItemType);
 if (itUseItem != m_mapUseItem.end()) {
 itUseItem->second.second += item->iAmount;
 } else {
 m_mapUseItem[item->iItemType] = make_pair(item->iID, item->iAmount);
 }
 }
 
 CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
 int height = 0;
 
 m_itemOpt = new NDUITableLayer;
 m_itemOpt->Initialization();
 m_itemOpt->VisibleSectionTitles(false);
 
 NDDataSource *ds = new NDDataSource;
 NDSection *sec = new NDSection;
 
 NDItemType* itemType = NULL;
 char szItem[256] = "";
 for (itUseItem = m_mapUseItem.begin(); itUseItem != m_mapUseItem.end(); itUseItem++) {
 itemType = itemsObj.QueryItemType(itUseItem->first);
 if (!itemType) {
 continue;
 }
 
 sprintf(szItem, "%s X %d", itemType->m_name.c_str(), itUseItem->second.second);
 
 height += TEXT_BTN_HEIGHT;
 
 NDUIButton *item = new NDUIButton;
 item->Initialization();
 item->SetFocusColor(ccc4(253, 253, 253, 255));
 item->SetTitle(szItem);
 sec->AddCell(item);
 }
 
 if (height > 210) {
 height = 210;
 }
 
 sec->SetFocusOnCell(0);
 
 ds->AddSection(sec);
 m_itemOpt->SetDelegate(this);
 m_itemOpt->SetDataSource(ds);
 m_itemOpt->SetFrameRect(CCRectMake((winSize.width / 2) - 80, winSize.height / 2 - 115, 160, height));
 AddChild(m_itemOpt);
 }*/

void Battle::OnBtnCatch()
{
	//m_battleOpt->RemoveFromParent(false);
//	setBattleStatus(BS_CHOOSE_ENEMY_CATCH);
//	
//	if (ItemMgrObj.IsBagFull()) {
//		Chat::DefaultChat()->AddMessage(ChatTypeSystem,NDCommonCString("BagFullCantCatch"));
//		return;
//	}
//	
//	VEC_FIGHTER& enemyList = GetEnemySideList();
//	Fighter* f;
//	for (size_t i = 0; i < enemyList.size(); i++) {
//		f = enemyList.at(i);
//		if (f->isCatchable()) {
//			HighlightFighter(f);
//			return;
//		}
//	}
//	
//	Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("CantCatch"));
}

void Battle::OnBtnDefence()
{
	//m_battleOpt->RemoveFromParent(false);

	ms_kLastTurnActionUser.btAction = BATTLE_ACT_PHY_DEF;

	BattleAction actioin(BATTLE_ACT_PHY_DEF);
	SendBattleAction(actioin);
}

void Battle::OnBtnRun()
{
	//m_battleOpt->RemoveFromParent(false);

	BattleAction actioin(BATTLE_ACT_ESCAPE);
	SendBattleAction(actioin);
}

/*void Battle::OnEudemonSkill()
 {
 m_battleStatus = BS_EUDEMON_SKILL_MENU;
 RemoveChild(m_eudemonOpt, false);
 
 // 获取宠物技能
 NDBattlePet* pet = NDPlayer::defaultHero().battlepet;
 if (!pet) {
 return;
 }
 
 SET_BATTLE_SKILL_LIST& petSkillList = pet->GetSkillList(SKILL_TYPE_ATTACK);
 if (petSkillList.size() <= 0) {
 m_dlgHint = new NDUIDialog;
 m_dlgHint->Initialization();
 m_dlgHint->SetDelegate(this);
 m_dlgHint->Show(NULL, "本回合无可用技能", NULL, NULL);
 return;
 }
 
 // 打开技能列表
 NDAsssert (m_skillOpt == NULL);
 
 CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
 int height = 0;
 
 m_skillOpt = new NDUITableLayer;
 m_skillOpt->Initialization();
 m_skillOpt->VisibleSectionTitles(false);
 
 NDDataSource *ds = new NDDataSource;
 NDSection *sec = new NDSection;
 
 BattleMgr& bm = BattleMgrObj;
 BattleSkill* bs = NULL;
 
 SET_BATTLE_SKILL_LIST_IT itSkill = petSkillList.begin();
 BattleSkill* firstSkill = bm.GetBattleSkill(*itSkill);
 for (; itSkill != petSkillList.end(); itSkill++) {
 bs = bm.GetBattleSkill(*itSkill);
 if (!bs) {
 continue;
 }
 height += TEXT_BTN_HEIGHT;
 
 NDUIButton *skill = new NDUIButton;
 skill->Initialization();
 skill->SetFocusColor(ccc4(253, 253, 253, 255));
 skill->SetTitle(bs->getName().c_str());
 sec->AddCell(skill);
 }
 
 sec->SetFocusOnCell(0);
 
 if (height > 120) {
 height = 120;
 }
 
 ds->AddSection(sec);
 m_skillOpt->SetDelegate(this);
 m_skillOpt->SetDataSource(ds);
 m_skillOpt->SetFrameRect(CCRectMake((winSize.width / 2) - 80, winSize.height / 2, 160, height));
 AddChild(m_skillOpt);
 
 // 技能说明
 NDUIMemo* skillMemo = new NDUIMemo();
 skillMemo->Initialization();
 skillMemo->SetTag(TAG_SKILL_MEMO);
 skillMemo->SetBackgroundColor(ccc4(228, 219, 169, 255));
 skillMemo->SetText(firstSkill->getSimpleDes(true).c_str());
 skillMemo->SetFrameRect(CCRectMake((winSize.width / 2) - 80, 30, 160, winSize.height / 2 - 35));
 AddChild(skillMemo);
 }*/

void Battle::OnEudemonAttack()
{
//	if (BS_CHOOSE_ENEMY_PHY_ATK_EUDEMON == m_battleStatus) {
//		return;
//	}
//	
//	//m_eudemonOpt->RemoveFromParent(false);
//	setBattleStatus(BS_CHOOSE_ENEMY_PHY_ATK_EUDEMON);
//	//	m_fighterRight->SetFoucusByIndex(3);
//	//	m_fighterLeft->defocus();
//	//	m_fighterBottom->defocus();
//	
//	m_curBattleAction->btAction = BATTLE_ACT_PET_PHY_ATK;
//	m_curBattleAction->vData.clear();
//	
//	VEC_FIGHTER& enemyList = GetEnemySideList();
//	
//	Fighter* f;
//	for (size_t i = 0; i < enemyList.size(); i++) {
//		f = enemyList.at(i);
//		if (f->isVisiable()) {
//			s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_PHY_ATK;
//			s_lastTurnActionEudemon.vData.clear();
//			HighlightFighter(f);
//			return;
//		}
//	}
}

void Battle::OnBtnAttack()
{
//	if (m_battleStatus == BS_CHOOSE_ENEMY_PHY_ATK) {
//		return;
//	}
//	
//	//m_battleOpt->RemoveFromParent(false);
//	setBattleStatus(BS_CHOOSE_ENEMY_PHY_ATK);
//	//	m_fighterRight->SetFoucusByIndex(3);
//	//	m_fighterLeft->defocus();
//	//	m_fighterBottom->defocus();
//	
//	m_curBattleAction->btAction = BATTLE_ACT_PHY_ATK;
//	m_curBattleAction->vData.clear();
//	
//	VEC_FIGHTER& enemyList = GetEnemySideList();
//	
//	Fighter* f;
//	for (size_t i = 0; i < enemyList.size(); i++) {
//		f = enemyList.at(i);
//		if (f->isVisiable()) {
//			s_lastTurnActionUser.btAction = BATTLE_ACT_PHY_ATK;
//			HighlightFighter(f);
//			return;
//		}
//	}
}

void Battle::stopAuto()
{
	if (ms_bAuto)
	{
		//		m_timer.KillTimer(this, TIMER_AUTOCOUNT);
		//		RemoveChild(m_lbAuto, false);
		//		RemoveChild(m_imgAutoCount, false);
		//		SAFE_DELETE(m_lbAuto);
		//		SAFE_DELETE(m_imgAutoCount);
		//		m_autoCount = AUTO_COUNT;
		ms_bAuto = false;
		//		m_btnAuto->SetImage(m_picAuto);
	}
}

void Battle::SetAutoCount()
{
	//	m_lbAuto = new NDUILabel;
	//	m_lbAuto->Initialization();
	//	m_lbAuto->SetText("自动");
	//	m_lbAuto->SetFontColor(ccc4(255, 255, 255, 255));
	//	CCSize sizeText = getStringSize("自动", 15);
	//	m_lbAuto->SetFrameRect(CCRectMake(2, 2, sizeText.width, sizeText.height));
	//	AddChild(m_lbAuto);
	//	
	//	m_imgAutoCount = new ImageNumber();
	//	m_imgAutoCount->Initialization();
	//	m_imgAutoCount->SetBigRedNumber(m_autoCount, false);
	//	m_imgAutoCount->SetFrameRect(CCRectMake(40, 2, m_imgAutoCount->GetNumberSize().width, m_imgAutoCount->GetNumberSize().height));
	//	AddChild(m_imgAutoCount);
	//	
	//	m_timer.SetTimer(this, TIMER_AUTOCOUNT, 1);
}

void Battle::OnBtnAuto(bool bSendAction)
{
	//RemoveChild(m_battleOpt, false);

	//CreateCancleAutoFightButton();

	m_autoCount = 0;

	if (!ms_bAuto)
	{
		ms_bAuto = true;
		//SetAutoCount();
		//		m_btnAuto->SetImage(m_picAutoCancel);
		//		m_fighterRight->SetShrink(true);
		//		m_fighterLeft->SetShrink(true);
		//		m_fighterBottom->SetShrink(true);
	}

	if (!bSendAction)
	{
		return;
	}

	if (!m_bSendCurTurnUserAction && GetMainUser() && GetMainUser()->isAlive())
	{
		bool bUserActionSend = false;
		switch (ms_kLastTurnActionUser.btAction)
		{
		case BATTLE_ACT_PHY_ATK:
			ms_kLastTurnActionUser.vData.clear();
			ms_kLastTurnActionUser.vData.push_back(0);
			break;
		case BATTLE_ACT_PHY_DEF:
			ms_kLastTurnActionUser.vData.clear();
			break;
		case BATTLE_ACT_MAG_ATK:
		{
			if (m_setBattleSkillList.count(ms_kLastTurnActionUser.vData.at(0)) == 0)
			{ // 该技能本回合已不可使用
				BattleAction atk(BATTLE_ACT_PHY_ATK);
				atk.vData.push_back(0);
				SendBattleAction(atk);
				bUserActionSend = true;
			}
		}
			break;
		default:
			ms_kLastTurnActionUser.btAction = BATTLE_ACT_PHY_ATK;
			ms_kLastTurnActionUser.vData.clear();
			ms_kLastTurnActionUser.vData.push_back(0);
			break;
		}

		if (!bUserActionSend)
		{
			SendBattleAction(ms_kLastTurnActionUser);
		}
	}

	// 宠物自动战斗
	if (m_mainEudemon && m_mainEudemon->isAlive()
			&& !m_mainEudemon->isEscape())
	{
		switch (ms_kLastTurnActionEudemon.btAction)
		{
		case BATTLE_ACT_PET_PHY_DEF:
			ms_kLastTurnActionEudemon.vData.clear();
			break;
		case BATTLE_ACT_PET_MAG_ATK:
			break;
		default:
			ms_kLastTurnActionEudemon.btAction = BATTLE_ACT_PET_PHY_ATK;
			ms_kLastTurnActionEudemon.vData.clear();
			ms_kLastTurnActionEudemon.vData.push_back(0);
			break;
		}
		SendBattleAction(ms_kLastTurnActionEudemon);
	}
}

void Battle::HighlightFighter(Fighter* f)
{
	m_highlightFighter = f;

	NDUILabel *name = (NDUILabel*) GetChild(TAG_NAME);
	NDUIImage *lingpai = (NDUIImage*) GetChild(TAG_LINGPAI);

	NDBaseRole* role = f->GetRole();
	CCPoint pt = CCPointMake(f->getX(), f->getY());

	if (!lingpai)
	{
		//		lingpai = new NDUIImage;
		//		lingpai->Initialization();
		//		lingpai->SetTag(TAG_LINGPAI);
		//		lingpai->SetPicture(m_picBoji);
		//		AddChild(lingpai);
	}

	//	if (m_picBoji) m_picBoji->SetReverse(f->GetGroup() == BATTLE_GROUP_DEFENCE);
	//	
	//	CCRect rect = CCRectMake(f->getX() + role->GetWidth() / 2 + 5,
	//							 f->getY() - 15,
	//							 m_picBoji->GetSize().width,
	//							 m_picBoji->GetSize().height);
	//							 
	//	if (f->GetGroup() == BATTLE_GROUP_DEFENCE) {
	//		rect.origin.x = rect.origin.x - role->GetWidth() - 10;
	//	}
	//	
	//	lingpai->SetFrameRect(rect);

	//CCRect frameLingpai = lingpai->GetFrameRect();
	if (!name)
	{
		name = new NDUILabel;
		name->SetFontColor(ccc4(255, 255, 255, 255));
		name->Initialization();
		name->SetTag(TAG_NAME);
		AddChild(name);
	}
	std::stringstream ss;
	ss << role->m_strName << "Lv" << role->m_nLevel;
	//	if (f->m_kInfo.fighterType == Fighter_TYPE_RARE_MONSTER)
	//	{
	//		ss << "【" << NDCommonCString("xiyou") << "】"; 
	//	}
	name->SetText(ss.str().c_str());
	CCSize sizeName = getStringSize(ss.str().c_str(), 15);
	name->SetFrameRect(
			CCRectMake(pt.x - sizeName.width / 2,
					pt.y - role->getGravityY() - sizeName.height,
					sizeName.width, sizeName.height));

	setWillBeAtk(getHighlightList());

	//f->setWillBeAtk(true);	
}

void Battle::OnTimer(OBJID tag)
{
	NDUILayer::OnTimer(tag);

	if (tag == TIMER_TIMELEFT)
	{
		if (m_timeLeft > 0)
		{
			if (m_bWatch)
			{
				if (m_battleStatus != BS_SHOW_FIGHT
						&& m_battleStatus != BS_FIGHTER_SHOW_PAS)
				{
					m_timeLeft--;
					stringstream ss;
					ss << m_timeLeft;
					//					m_lbTimer->SetText(ss.str().c_str());
					//m_imgTimer->SetBigRedNumber(m_timeLeft, false);
				}
			}
			else
			{
				if (IsUserOperating() || IsEudemonOperating())
				{
					m_timeLeft--;
					stringstream ss;
					ss << m_timeLeft;
					//					m_lbTimer->SetText(ss.str().c_str());
					//m_imgTimer->SetBigRedNumber(m_timeLeft, false);
				}
			}
		}
	}
	else if (tag == TIMER_BACKTOGAME)
	{
		BattleMgrObj.quitBattle();
	}
	//	else if (tag == TIMER_AUTOCOUNT) 
	//	{
	//		if (m_autoCount > 0) {
	//			m_autoCount--;
	//			m_imgAutoCount->SetBigRedNumber(m_autoCount, false);
	//			if (m_autoCount == 0) {
	//				OnBtnAuto();
	//			}
	//		}
	//	}
	else if (tag == TIMER_AUTOFIGHT)
	{
		OnBtnAuto(true);
		m_timer.KillTimer(this, TIMER_AUTOFIGHT);
	}
}

void Battle::Init()
{
	// 设置战斗状态
	int sceneMapId;
	int sceneCenterX;
	int sceneCenterY;
	NDPlayer::defaultHero().UpdateState(USERSTATE_FIGHTING, true);
	dieAniGroup=NULL;
	m_bChatTextFieldShouldShow = false;
	//	m_imgTurn = NULL;
	//	m_imgTimer = NULL;
	//	m_imgQuickTalkBg = NULL;
	//	m_tlQuickTalk = NULL;
	m_orignalMapId = 0;
	m_nLastSkillPageUser = 0;
	m_nLastSkillPageEudemon = 0;
	//m_chatDelegate = [[ChatTextFieldDelegate alloc] init];
	m_bShowChatTextField = false;
	//	m_imgChat = NULL;
	//	m_btnSendChat = NULL;
	m_mapLayer = NULL;
	m_bSendCurTurnUserAction = false;

	//m_btnCancleAutoFight = NULL;

	m_dlgStatus = NULL;
	theActor = NULL;
	theTarget = NULL;
	m_bWatch = false;
	//m_battleOpt = NULL;
	//	m_playerHead = NULL;
	//	m_petHead = NULL;
	m_battleBg = NULL;
	//m_eudemonOpt = NULL;

	//--Guosen 2012.6.28//不显示动作名称（防御，逃跑，闪避），也就不加载图形文件
	//m_picActionWordDef = new NDPicture;
	//m_picActionWordDef->Initialization(NDPath::GetImgPath("actionWord.png"));
	//m_picActionWordDef->Cut(CCRectMake(0.0f, 0.0f, 37.0f, 18.0f));
	//m_picActionWordFlee = new NDPicture;
	//m_picActionWordDodge = new NDPicture;
	//m_picActionWordDodge->Initialization(NDPath::GetImgPath("actionWord.png"));
	//m_picActionWordDodge->Cut(CCRectMake(0.0f, 18.0f, 37.0f, 18.0f));
	//m_picActionWordFlee->Initialization(NDPath::GetImgPath("actionWord.png"));
	//m_picActionWordFlee->Cut(CCRectMake(0.0f, 36.0f, 37.0f, 18.0f));
	//--

	//	m_picTalk = NULL;
	//	m_picQuickTalk = NULL;
	//	m_picAuto = NULL;
	//	m_picAutoCancel = NULL;
	//	m_picLeave = NULL;
	//	
	//	m_btnTalk = NULL;
	//	m_btnQuickTalk = NULL;
	//	m_layerBtnQuitTalk = NULL;
	//	m_btnAuto = NULL;
	//	m_btnLeave = NULL;

	m_curBattleAction = new BattleAction(BATTLE_ACT_PHY_ATK);
	//	m_dlgHint = NULL;
	//	m_itemOpt = NULL;
	//	m_skillOpt = NULL;
	m_autoCount = AUTO_COUNT;
	//m_lbAuto = NULL;
	//m_imgAutoCount = NULL;
	bActionSet = false;
	m_dlgBattleResult = NULL;
	m_mainEudemon = NULL;
	serverBattleResult = 2;
	battleCompleteResult = BATTLE_COMPLETE_NO;
	m_battleType = BATTLE_TYPE_NONE;
	m_ourGroup = BATTLE_GROUP_ATTACK;
	m_turn = 0;
	//	m_lbTurnTitle = NULL;
	//	m_lbTurn = NULL;
	//	m_lbTimerTitle = NULL;
	//	m_lbTimer = NULL;
	//m_imgTurn = NULL;
	m_timeLeft = 30;
	//	m_picWhoAmI = NULL;
	//	m_imgWhoAmI = NULL;
	m_mainFighter = NULL;
	m_battleStatus = BS_BATTLE_WAIT;
	//	m_picLingPai = NULL;
	m_highlightFighter = NULL;
	m_timeLeftMax = 29;
	m_actionFighterPoint = 0;
	m_foreBattleStatus = 0;
	watchBattle = false;

// 	m_picBaoJi = new NDPicture;
// 	m_picBaoJi->Initialization(NDPath::GetImgPath("bo.png").c_str());

	m_defaultActionUser = BATTLE_ACT_PHY_ATK;
	m_pkDefaultTargetUser = NULL;
	m_nDefaultSkillID = ID_NONE;

	m_defaultActionEudemon = BATTLE_ACT_PET_PHY_ATK;
	m_defaultTargetEudemon = NULL;
	m_defaultSkillIDEudemon = ID_NONE;

	m_bTurnStart = true;
	m_bTurnStartPet = false;

	// 战斗快捷栏
	//	m_fighterBottom = NULL;
	//	m_fighterLeft = NULL;
	//	m_fighterRight = NULL;

	m_bShrinkRight = false;
	m_bShrinkLeft = false;
	m_bShrinkBottom = false;
}

Fighter* Battle::GetTouchedFighter(VEC_FIGHTER& fighterList, CCPoint pt)
{
	VEC_FIGHTER_IT itBegin = fighterList.begin();
	VEC_FIGHTER_IT itEnd = fighterList.end();

	Fighter* pkFighter;
	for (; itBegin != itEnd; itBegin++)
	{
		pkFighter = (*itBegin);
		if (!(pkFighter->isVisiable() && pkFighter->isVisibleStatus))
		{
			continue;
		}

		NDBaseRole* pkRole = pkFighter->GetRole();
		CCPoint fPos = pkRole->GetPosition();

		int w = pkRole->GetWidth();
		int h = pkRole->GetHeight();

		fPos.x -= (w >> 1);
		fPos.y -= h;

		if (IsPointInside(pt, CCRectMake(fPos.x, fPos.y, w, h)))
		{
			return pkFighter;
		}
	}

	return NULL;
}

bool Battle::TouchEnd(NDTouch* touch)
{
	if (!this->IsVisibled())
	{
		return false;
	}

	if (m_dlgStatus)
	{
		CloseStatusDlg();
	}

	if (touch && touch->GetLocation().x > 0.0001f
		&& touch->GetLocation().y > 0.0001f)
	{
		if (NDUILayer::TouchEnd(touch))
		{
			return false;
		}
	}

	Fighter* f = GetTouchedFighter(GetOurSideList(), touch->GetLocation());
	if (!f)
	{
		f = GetTouchedFighter(GetEnemySideList(), touch->GetLocation());
	}

	if (f)
	{
		NDLog("touch fighter");
		if (currentShowFighter > 0)
		{
			BaseScriptMgrObj.excuteLuaFunc("CloseFighterInfo", "FighterInfo", 0);
		}
		currentShowFighter = f->m_kInfo.idObj;

		//int nLevel = 0;
		//if ( f->m_kInfo.fighterType == FIGHTER_TYPE_PET )
		//{
		//    nLevel = ScriptDBObj.GetN( "pet_config", f->m_kInfo.idType, DB_PET_CONFIG_SKILL );
		//}
		//else if( f->m_kInfo.fighterType == FIGHTER_TYPE_MONSTER )
		//{
		//    nLevel = ScriptDBObj.GetN( "monstertype", f->m_kInfo.idType, DB_MONSTERTYPE_LEVEL );
		//}
		BaseScriptMgrObj.excuteLuaFunc("LoadUI", "FighterInfo", f->getOriginX(),
			f->getOriginY());
		std::string skillName = "";
		if (f->m_kInfo.skillId > 0)
		{
			skillName = ScriptDBObj.GetS("skill_config", f->m_kInfo.skillId,
				DB_SKILL_CONFIG_NAME);

		}
		else
		{
			NDLog(@"fighter have no skill");
		}
		BaseScriptMgrObj.excuteLuaFunc<bool>("SetFighterInfo", "FighterInfo",
			f->GetRole()->m_strName, skillName, f->m_kInfo.level);

		BaseScriptMgrObj.excuteLuaFunc("UpdateHp", "FighterInfo",
			f->m_kInfo.nLife, f->m_kInfo.nLifeMax);
		BaseScriptMgrObj.excuteLuaFunc("UpdateMp", "FighterInfo",
			f->m_kInfo.nMana, f->m_kInfo.nManaMax);
	}

	//	switch (m_battleStatus)
	//	{
	//		case BS_CHOOSE_VIEW_FIGHTER_STATUS:
	//		case BS_CHOOSE_VIEW_FIGHTER_STATUS_PET:
	//		{
	//			Fighter* f = GetTouchedFighter(GetEnemySideList(), touch->GetLocation());
	//			if (!f) {
	//				f = GetTouchedFighter(GetOurSideList(), touch->GetLocation());
	//			}
	//			
	//			if (f) {
	//				if (m_highlightFighter != f) {
	//					HighlightFighter(f);
	//					break;
	//				}
	//			}
	//			
	//			if (m_highlightFighter) {
	//				m_dlgStatus = new StatusDialog;
	//				m_dlgStatus->Initialization(m_highlightFighter);
	//				m_dlgStatus->SetFrameRect(CCRectMake(0, 0, CCDirector::sharedDirector()->getWinSizeInPixels().width,
	//													 CCDirector::sharedDirector()->getWinSizeInPixels().height));
	//				AddChild(m_dlgStatus);
	//			}
	//		}
	//			break;
	//		case BS_CHOOSE_ENEMY_PHY_ATK:
	//		case BS_CHOOSE_ENEMY_PHY_ATK_EUDEMON:
	//		case BS_CHOOSE_ENEMY_MAG_ATK:
	//		case BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON:
	//		{
	//			Fighter* f = GetTouchedFighter(GetEnemySideList(), touch->GetLocation());
	//			if (f)
	//			{
	//				if (m_highlightFighter == f)
	//				{
	//					// 发送攻击指令
	//					m_curBattleAction->vData.push_back(m_highlightFighter->m_kInfo.idObj);
	//					SendBattleAction(*m_curBattleAction);
	//				}
	//				else
	//				{
	//					if (m_battleStatus == BS_CHOOSE_ENEMY_PHY_ATK || m_battleStatus == BS_CHOOSE_ENEMY_MAG_ATK) {
	//						m_defaultTargetUser = f;
	//					} else {
	//						m_defaultTargetEudemon = f;
	//					}
	//					HighlightFighter(f);
	//				}
	//			} else {
	//				if (m_highlightFighter) {
	//					// 发送攻击指令
	//					m_curBattleAction->vData.push_back(m_highlightFighter->m_kInfo.idObj);
	//					SendBattleAction(*m_curBattleAction);
	//				}
	//			}
	//			
	//		}
	//			break;
	//		case BS_CHOOSE_ENEMY_CATCH:
	//		{
	//			Fighter* f = GetTouchedFighter(GetEnemySideList(), touch->GetLocation());
	//			if (f)
	//			{
	//				if (f->isCatchable()) {
	//					// 发送捕捉指令
	//					BattleAction actioin(BATTLE_ACT_CATCH);
	//					actioin.vData.push_back(f->m_kInfo.idObj);
	//					SendBattleAction(actioin);
	//				} else {
	//					Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("DestCantCatch"));
	//				}
	//				
	//			} else {
	//				if (m_highlightFighter) {
	//					// 发送捕捉指令
	//					BattleAction actioin(BATTLE_ACT_CATCH);
	//					actioin.vData.push_back(m_highlightFighter->m_kInfo.idObj);
	//					SendBattleAction(actioin);
	//				}
	//			}
	//			
	//		}
	//			break;
	//		case BS_CHOOSE_OUR_SIDE_USE_ITEM_USER:
	//		case BS_CHOOSE_OUR_SIDE_USE_ITEM_EUDEMON:
	//		case BS_CHOOSE_OUR_SIDE_MAG_ATK:
	//		case BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON:
	//		{
	//			Fighter* f = GetTouchedFighter(GetOurSideList(), touch->GetLocation());
	//			if (f)
	//			{
	//				if (m_highlightFighter == f)
	//				{
	//					m_curBattleAction->vData.push_back(m_highlightFighter->m_kInfo.idObj);
	//					SendBattleAction(*m_curBattleAction);
	//				}
	//				else
	//				{
	//					if (m_battleStatus == BS_CHOOSE_OUR_SIDE_MAG_ATK) {
	//						m_defaultTargetUser = f;
	//					} else if (m_battleStatus == BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON) {
	//						m_defaultTargetEudemon = f;
	//					}
	//					HighlightFighter(f);
	//				}
	//			} else {
	//				if (m_highlightFighter) {
	//					m_curBattleAction->vData.push_back(m_highlightFighter->m_kInfo.idObj);
	//					SendBattleAction(*m_curBattleAction);
	//				}
	//			}
	//		}
	//			break;
	//		case BS_CHOOSE_SELF_MAG_ATK:
	//		case BS_CHOOSE_SELF_MAG_ATK_EUDEMON:
	//			if (m_highlightFighter) {
	//				m_curBattleAction->vData.push_back(m_highlightFighter->m_kInfo.idObj);
	//				SendBattleAction(*m_curBattleAction);
	//			}
	//		default:
	//			break;
	//	}
	return true;
}

void Battle::SendBattleAction(const BattleAction& action)
{
	// 移除令牌和名字显示，加入等待显示
	clearHighlight();

	if (!GetChild(TAG_WAITING) && m_mainFighter)
	{
		CCPoint pt = m_mainFighter->GetRole()->GetPosition();
		NDUILabel* waiting = new NDUILabel;
		waiting->Initialization();
		waiting->SetFontColor(ccc4(255, 255, 255, 255));
		waiting->SetTag(TAG_WAITING);
		waiting->SetText(NDCommonCString("wait").c_str());
		CCSize sizeText = getStringSize(NDCommonCString("wait").c_str(), 15);
		waiting->SetFrameRect(CCRectMake(pt.x - sizeText.width / 2, pt.y, sizeText.width, sizeText.height));
		AddChild(waiting);
	}

	NDTransData data(_MSG_BATTLEACT);
	Byte btDataCount = action.vData.size();
	data << action.btAction << Byte(m_turn - 1) << btDataCount;

	for (int i = 0; i < btDataCount; i++)
	{
		data << action.vData.at(i);
	}

	NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);

	if ((action.btAction == BATTLE_ACT_MAG_ATK
			|| action.btAction == BATTLE_ACT_PET_MAG_ATK) && btDataCount > 0)
	{
		if (!((action.btAction == BATTLE_ACT_PET_MAG_ATK
				|| action.btAction == BATTLE_ACT_MAG_ATK)
				&& CanPetFreeUseSkill()))
		{
			int useSkillID = action.vData[0];
			UseSkillDealOfCooldown(useSkillID);
		}
	}

	// 有宠物，且非自动战斗
//	if (m_mainEudemon && m_mainEudemon->isAlive() &&
//	    !m_mainEudemon->isEscape() && !s_bAuto) {
//		switch (m_battleStatus) {
//			case BS_USER_MENU:
//			case BS_USER_SKILL_MENU:
//			case BS_CHOOSE_ENEMY_PHY_ATK:
//			case BS_CHOOSE_ENEMY_CATCH:
//			case BS_CHOOSE_OUR_SIDE_USE_ITEM_USER:
//			case BS_CHOOSE_ENEMY_MAG_ATK:
//			case BS_CHOOSE_OUR_SIDE_MAG_ATK:
//				//m_battleStatus = BS_EUDEMON_MENU;
//				//AddChild(m_eudemonOpt);
//				m_bSendCurTurnUserAction = true;
//				m_bTurnStartPet = true;
//				return;
//			default:
//				//RemoveChild(m_eudemonOpt, false);
//				break;
//		}
//	}

	setBattleStatus (BS_WAITING_SERVER_MESSAGE);

	//	m_fighterRight->SetShrink(true);
	//	m_fighterLeft->SetShrink(true);
	//	m_fighterBottom->SetShrink(true);
	//	
	//	m_fighterRight->SetGray(true);
	//	m_fighterLeft->SetGray(true);
	//	m_fighterBottom->SetGray(true);
}

void Battle::setBattleMap(int mapId, int posX, int posY)
{
	//	m_orignalMapId=NDMapMgrObj.m_iMapID;
	//	m_orignalPos=NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene())->GetScreenCenter();
	//	NDMapMgrObj.ClearNpc();
	//	NDMapMgrObj.ClearMonster();
	//	NDMapMgrObj.ClearGP();

	NDMapLayer* mapLayer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
	if(mapLayer)
	{
		sceneMapId = mapLayer->GetMapIndex();
		sceneCenterX = mapLayer->GetScreenCenter().x;
		sceneCenterY = mapLayer->GetScreenCenter().y;
		mapLayer->SetBattleBackground(true);
		mapLayer->replaceMapData(mapId, posX, posY);

		//mapLayer->SetNeedShowBackground(false);
	}
}

void Battle::drawSubAniGroup()
{
	bool bErase = false;

	for (VEC_SUB_ANI_GROUP_IT it = m_vSubAniGroup.begin();
			it != m_vSubAniGroup.end(); it++)
	{
		NDSprite* role = it->role;
		if (!role)
		{
			continue;
		}

// 		if (!(it->isCanStart))
// 		{
// 			it->isCanStart = true;
// 		}
// 		if (!(it->isCanStart))
// 		{
// 			continue;
// 		}
		if(it->startFrame>0){
			it->startFrame--;
			continue;
		}
		//NDLog("draw subanigroup");
		it->bComplete = role->DrawSubAnimation(*it);
		if (it->bComplete)
		{
/*			NDLog("subanigroup complete");*/
			bErase = true;
			if (it->isFromOut)
			{
				it->aniGroup->release();
			}
			it->frameRec->release();
			it->frameRec = NULL;
		}
	}

	if (bErase)
	{
		m_vSubAniGroup.erase(remove_if(m_vSubAniGroup.begin(), m_vSubAniGroup.end(), IsSubAniGroupComplete()), m_vSubAniGroup.end());
	}
}

void Battle::sortFighterList(VEC_FIGHTER& fighterList)
{
	Fighter* fTemp = NULL;
	for (VEC_FIGHTER_IT itHead = fighterList.begin();
			itHead != fighterList.end(); itHead++)
	{
		for (VEC_FIGHTER_IT itMin = itHead + 1; itMin != fighterList.end();
				itMin++)
		{
			if ((*itMin)->getOriginY() < (*itHead)->getOriginY())
			{
				fTemp = *itMin;
				*itMin = *itHead;
				*itHead = fTemp;
			}
		}
	}
}

void Battle::sortFighterList()
{
	sortFighterList(m_vDefencer);
	sortFighterList(m_vAttaker);

	for (VEC_FIGHTER_IT it = m_vDefencer.begin(); it != m_vDefencer.end(); it++)
	{
		Fighter* fighter = *it;
		fighter = NULL;
	}
}

void Battle::drawFighter()
{
	Fighter* f = NULL;
	for (VEC_FIGHTER_IT it = m_vAttaker.begin(); it != m_vAttaker.end(); it++)
	{
		f = *it;
		if (f->isVisiable())
		{
			f->updatePos();
			f->draw();
			//--Guosen 2012.6.28//不显示动作名称（防御，逃跑，闪避）
			//f->drawActionWord();
		}
	}

	for (VEC_FIGHTER_IT it = m_vDefencer.begin(); it != m_vDefencer.end(); it++)
	{
		f = *it;
		if (f->isVisiable())
		{
			f->updatePos();
			f->draw();
			//--Guosen 2012.6.28//不显示动作名称（防御，逃跑，闪避）
			//f->drawActionWord();
		}
	}

	//	if (m_mainFighter && !watchBattle)
	//	{
	//		NDBaseRole* role = m_mainFighter->GetRole();
	//		CCPoint pt = role->GetPosition();
	//		m_imgWhoAmI->SetFrameRect(CCRectMake(pt.x - 6, pt.y - role->GetHeight(), m_picWhoAmI->GetSize().width, m_picWhoAmI->GetSize().height));
	//	}
}

void Battle::draw()
{
	if (eraseInOutEffect && !eraseInOutEffect->isChangeComplete())
	{
		return;
	}

	if (!IsVisibled())
	{
		SetVisible(true);
		//		NDMapLayer* mapLayer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
		//		mapLayer->SetBattleBackground(true);
		//		mapLayer->SetNeedShowBackground(false);
	}

	NDDirector::DefaultDirector()->EnableDispatchEvent(true);
	//	
	//	if(m_mapLayer){
	//		m_mapLayer->draw();
	//	}

	//	m_battleBg->draw();

	//if (eraseInOutEffect->isChangeComplete())
	battleRefresh();

	// 绘制参战单位
	drawFighter();

	//	if (!eraseInOutEffect->isChangeComplete()) {
	//		return;
	//	}

	// 绘制去血
	drawAllFighterHurtNumber();

//	switch (m_battleStatus) {
//		case BS_CHOOSE_ENEMY_PHY_ATK_EUDEMON:
//		case BS_CHOOSE_ENEMY_PHY_ATK:
//		case BS_CHOOSE_ENEMY_CATCH:
//		case BS_CHOOSE_OUR_SIDE_USE_ITEM_USER:
//		case BS_CHOOSE_OUR_SIDE_USE_ITEM_EUDEMON:
//		case BS_CHOOSE_ENEMY_MAG_ATK:
//			if (m_highlightFighter) {
//				m_highlightFighter->drawHPMP();
//			}
//			break;
//		default:
//			break;
//	}

	drawSubAniGroup();

	//	if (m_mainFighter && m_battleOpt) 
	//	{
	//		m_battleOpt->SetVisible(!m_mainFighter->isEscape());
	//	}
	//	
	//	if (m_mainEudemon && m_eudemonOpt) 
	//	{
	//		m_eudemonOpt->SetVisible(!m_mainEudemon->isEscape());
	//	}

	//	NDUILayer::draw();
}

Fighter* Battle::GetMainUser()
{
	if (!m_mainFighter)
	{
		NDPlayer& player = NDPlayer::defaultHero();

		if (m_ourGroup == BATTLE_GROUP_ATTACK)
		{
			for (VEC_FIGHTER_IT it = m_vAttaker.begin(); it != m_vAttaker.end();
					it++)
			{
				if ((*it)->m_kInfo.idObj == player.m_nID)
				{
					m_mainFighter = (*it);
				}
			}
		}
		else
		{
			for (VEC_FIGHTER_IT it = m_vDefencer.begin();
					it != m_vDefencer.end(); it++)
			{
				if ((*it)->m_kInfo.idObj == player.m_nID)
				{
					m_mainFighter = (*it);
				}
			}
		}
	}

	return m_mainFighter;
}

void Battle::SetTurn(int turn)
{
	m_turn = turn + 1;
	stringstream ss;
	ss << m_turn << "/" << MAX_TURN;
	//	m_lbTurn->SetText(ss.str().c_str());
	//m_imgTurn->SetBigRedTwoNumber(m_turn - 1, MAX_TURN);

	AddTurnDealOfCooldown();
}

void Battle::AddCommand(Command* cmd)
{
	m_vCmdList.push_back(cmd);
}

void Battle::AddActionCommand(FightAction* action)
{
	Fighter* f = action->m_pkActor;
	int team = 0;
	if (f)
	{
		team = (f->m_kInfo.btBattleTeam - 1) % 3 + 1;
	}
	else
	{
		team = (action->m_nTeamAttack - 1) % 3 + 1;
	}

	switch (team)
	{
	case 1:
		BattleMgrObj.m_vActionList1.push_back(action);
		break;
	case 2:
		BattleMgrObj.m_vActionList2.push_back(action);
		break;
	case 3:
		BattleMgrObj.m_vActionList3.push_back(action);
		break;
	default:
		NDLog("can not addAction %d", team);
		break;
	}

	//	m_vActionList.push_back(action);
}

void Battle::ReleaseCommandList()
{
	VEC_COMMAND_IT it = m_vCmdList.begin();

	for (; it != m_vCmdList.end(); it++)
	{
		//SAFE_DELETE((*it)->skill);
		if ( (*it) == NULL )
			continue;
		Command* cmdNext = (*it)->cmdNext;
		while (cmdNext)
		{
			Command* cmd = cmdNext;
			cmdNext = cmd->cmdNext;
			//SAFE_DELETE(cmd->skill);
			CC_SAFE_DELETE(cmd);
		}
		CC_SAFE_DELETE(*it);
	}

	m_vCmdList.clear();
}

Fighter* Battle::GetFighter(int idFighter)
{
	VEC_FIGHTER_IT it = m_vAttaker.begin();
	for (; it != m_vAttaker.end(); it++)
	{
		if ((*it)->m_kInfo.idObj == idFighter)
		{
			return *it;
		}
	}

	for (it = m_vDefencer.begin(); it != m_vDefencer.end(); it++)
	{
		if ((*it)->m_kInfo.idObj == idFighter)
		{
			return *it;
		}
	}

	return NULL;
}

void Battle::AddAnActionFighter(Fighter* fAction)
{
	for (VEC_FIGHTER_IT it = m_vActionFighterList.begin();
			it != m_vActionFighterList.end(); it++)
	{
		if ((*it) == fAction)
		{
			return;
		}
	}

	m_vActionFighterList.push_back(fAction);
}

void Battle::showBattleComplete()
{
	const char* psz = NULL;

	switch (battleCompleteResult)
	{
	case BATTLE_COMPLETE_WIN:
		psz = NDCommonCString("BattleSucc").c_str();
		break;
	case BATTLE_COMPLETE_LOSE:
		psz = NDCommonCString("BattleFail").c_str();
		break;
	case BATTLE_COMPLETE_NO:
		psz = NDCommonCString("BattleEnd").c_str();
		break;
//		case BATTLE_COMPLETE_END:
//			psz = NDCommonCString("BattleEnd");
//			break;
	default:
		psz = NDCommonCString("BattleShouGong").c_str();
		break;
	}

	m_dlgBattleResult = new NDUIDialog();
	m_dlgBattleResult->Initialization();
	m_dlgBattleResult->SetDelegate(this);
	//m_dlgBattleResult->SetWidth(100);
	//m_dlgBattleResult->SetContextHeight(20);
	m_dlgBattleResult->Show(NULL, psz, NULL, NULL);

	// 两秒后回到游戏场景
	m_timer.SetTimer(this, TIMER_BACKTOGAME, 2);
}

void Battle::battleRefresh()
{
	fighterSomeActionChangeToWait (m_vAttaker);
	fighterSomeActionChangeToWait (m_vDefencer);

	if (m_battleStatus == BS_SHOW_FIGHT && m_startWait <= 0)
	{

		ShowFight();

	}
	else if (m_battleStatus == BS_FIGHTER_SHOW_PAS)
	{
		if (AllFighterActionOK())
		{
			ShowPas();
		}

	}
//	else {
//		if (!m_bWatch) {
//			if (m_bTurnStart) {
//				TurnStart();
//			} else if (m_bTurnStartPet) {
//				TurnStartPet();
//			}
//		}
//	}

	if (m_startWait > 0)
	{
		m_startWait--;
	}

	//refreshFighterData();
}

bool Battle::sideRightAtk()
{
	bool result = false;

	for (size_t i = 0; i < m_vActionFighterList.size(); i++)
	{
		Fighter& f = *m_vActionFighterList.at(i);
		if (f.m_kInfo.group == BATTLE_GROUP_ATTACK)
		{
			if (f.m_action == Fighter::ATTACK
					|| f.m_action == Fighter::SKILLATTACK)
			{
				result = true;
				break;
			}
		}
	}
	return result;
}

bool Battle::sideAttakerAtk()
{
	bool bResult = false;

	for (size_t i = 0; i < m_vActionFighterList.size(); i++)
	{
		Fighter& kFighter = *m_vActionFighterList.at(i);
		if (kFighter.m_kInfo.group == BATTLE_GROUP_ATTACK)
		{
			if (kFighter.m_action == Fighter::ATTACK
					|| kFighter.m_action == Fighter::SKILLATTACK)
			{
				bResult = true;
				break;
			}
		}
	}
	return bResult;
}

void Battle::ShowTimerAndTurn(bool bShow)
{
	//	if (bShow) {
	//		AddChild(m_imgTimer);
	//		AddChild(m_lbTimer);
	//		AddChild(m_lbTimerTitle);
	//		
	//		AddChild(m_imgTurn);
	//		AddChild(m_lbTurn);
	//		AddChild(m_lbTurnTitle);
	//	} else {
	//		m_lbTimer->RemoveFromParent(false);
	//		m_imgTimer->RemoveFromParent(false);
	//		m_lbTimerTitle->RemoveFromParent(false);
	//		
	//		m_lbTurn->RemoveFromParent(false);
	//		m_lbTurnTitle->RemoveFromParent(false);
	//		m_imgTurn->RemoveFromParent(false);
	//	}

}

void Battle::dealWithCommand()
{
	if (m_vCmdList.size() > 0 && m_battleStatus != BS_SHOW_FIGHT)
	{
		setBattleStatus (BS_SET_FIGHTER);

		for (int i = 0; i < m_vCmdList.size(); i++)
		{
			NDLog("%d action", i);
			Command* cmd = this->m_vCmdList.at(i);

			if ( cmd == NULL )
				continue;

			if (cmd->complete)
			{// 针对连锁cmd
				continue;
			}
			FightAction* action=NULL;
			switch (cmd->btEffectType) {
				case BATTLE_EFFECT_TYPE_ATK://攻击
					NDLog("%d atk",cmd->idActor);
					//					Fighter* theTarget = 
					//					theActor->m_effectType=BATTLE_EFFECT_TYPE(cmd->btEffectType);
					//					theActor->m_mainTarget=this->GetFighter(cmd->idTarget);
					//					if (theActor->GetNormalAtkType() == ATKTYPE_NEAR) {
					//						theActor->m_action = (Fighter::MOVETOTARGET);
					//					} else if (theActor->GetNormalAtkType() == ATKTYPE_DISTANCE) {
					//						theActor->m_action = (Fighter::AIMTARGET);
					//					}
					//					theActor->m_actionType = (Fighter::ACTION_TYPE_NORMALATK);
					//					this->AddAnActionFighter(theActor);
					action = new FightAction(this->GetFighter(cmd->idActor),this->GetFighter(cmd->idTarget),BATTLE_EFFECT_TYPE(cmd->btEffectType));
					break;
				case BATTLE_EFFECT_TYPE_SKILL://技能
					NDLog("%d skill",cmd->idActor);
					action = new FightAction(this->GetFighter(cmd->idActor),this->GetFighter(cmd->idTarget),BATTLE_EFFECT_TYPE(cmd->btEffectType));
					action->m_pkSkill = cmd->skill;
					break;
				case BATTLE_EFFECT_TYPE_SKILL_EFFECT://技能效果
					NDLog("%d skill_effect",cmd->idActor);
					action = new FightAction(this->GetFighter(cmd->idActor),this->GetFighter(cmd->idTarget),BATTLE_EFFECT_TYPE(cmd->btEffectType));
					action->m_pkSkill = cmd->skill;
					break;
				case BATTLE_EFFECT_TYPE_STATUS_ADD: // 加状态
					NDLog("%d status_add", cmd->idActor);
					action = new FightAction(this->GetFighter(cmd->idActor),NULL,BATTLE_EFFECT_TYPE(cmd->btEffectType));
					action->m_nData = cmd->idTarget;
					break;
				case BATTLE_EFFECT_TYPE_STATUS_LOST: // 取消状态
					NDLog("%d status_cancel", cmd->idActor);
					action = new FightAction(this->GetFighter(cmd->idActor),NULL,BATTLE_EFFECT_TYPE(cmd->btEffectType));
					action->m_nData = cmd->idTarget;
					break;
				case BATTLE_EFFECT_TYPE_CTRL:
					break;
				case BATTLE_EFFECT_TYPE_ESCORTING://护驾//没有
					NDLog("%d ESCORTING", cmd->idActor);
					action = new FightAction(this->GetFighter(cmd->idActor),NULL,BATTLE_EFFECT_TYPE(cmd->btEffectType));
					break;
				case BATTLE_EFFECT_TYPE_COOPRATION_HIT://合击
					NDLog("%d COOPRATION_HIT", cmd->idActor);
					action = new FightAction(this->GetFighter(cmd->idActor),NULL,BATTLE_EFFECT_TYPE(cmd->btEffectType));
					break;
				case BATTLE_EFFECT_TYPE_RESIST://免疫
					NDLog("%d RESIST", cmd->idActor);
					action = new FightAction(this->GetFighter(cmd->idActor),NULL,BATTLE_EFFECT_TYPE(cmd->btEffectType));
					break;
				case BATTLE_EFFECT_TYPE_CHANGE_POSTION://移位
					NDLog("%d CHANGE_POSTION", cmd->idActor);
					action = new FightAction(this->GetFighter(cmd->idActor),NULL,BATTLE_EFFECT_TYPE(cmd->btEffectType));
					action->m_nData = cmd->idTarget;//pos id
					break;
				case BATTLE_EFFECT_TYPE_PLAY_ANIMATION:// 对象身上播放指定动画
					NDLog("%d PLAY_ANIMATION", cmd->idActor);
					action = new FightAction(this->GetFighter(cmd->idActor),NULL,BATTLE_EFFECT_TYPE(cmd->btEffectType));
					action->m_nData = cmd->idTarget;//ani id
					break;
				case EFFECT_TYPE_TURN_END:
					NDLog("turn end");
					continue;
				case EFFECT_TYPE_BATTLE_BEGIN:
					NDLog("%d battle_begin",cmd->idTarget);
					action=new FightAction(cmd->idActor,cmd->idTarget,EFFECT_TYPE_BATTLE_BEGIN);
					break;
				case EFFECT_TYPE_BATTLE_END:
					NDLog("%d battle_end",cmd->idActor);
					action=new FightAction(cmd->idActor,cmd->idTarget,EFFECT_TYPE_BATTLE_END);
					break;
				case BATTLE_EFFECT_TYPE_STATUS_LIFE:
					NDLog("%d status_life",cmd->idActor);
					action=new FightAction(this->GetFighter(cmd->idActor),this->GetFighter(cmd->idTarget),BATTLE_EFFECT_TYPE(cmd->btEffectType));
					action->m_nData=cmd->nHpLost;
					break;
				case BATTLE_EFFECT_TYPE_STATUS_MANA:
					NDLog("%d status_mana",cmd->idActor);
					action=new FightAction(this->GetFighter(cmd->idActor),this->GetFighter(cmd->idTarget),BATTLE_EFFECT_TYPE(cmd->btEffectType));
					action->m_nData=cmd->nMpLost;
					break;
				case BATTLE_EFFECT_TYPE_LIFE:
					action = new FightAction( this->GetFighter(cmd->idActor), this->GetFighter(cmd->idTarget), BATTLE_EFFECT_TYPE(cmd->btEffectType) );
					action->m_nData = cmd->nHpLost;
					break;
				case BATTLE_EFFECT_TYPE_MANA:
					action = new FightAction( this->GetFighter(cmd->idActor), this->GetFighter(cmd->idTarget), BATTLE_EFFECT_TYPE(cmd->btEffectType) );
					action->m_nData = cmd->nMpLost;
					break;
				default:
					NDLog("Battle::dealWithCommand() EffectType: %d ",cmd->btEffectType);
					break;
			}
			//处理主要动作后的连锁动作
			if (action) {
				Command* nextCmd = cmd->cmdNext;
				while (nextCmd) {

					FIGHTER_CMD* fcmd = new FIGHTER_CMD();
					switch(nextCmd->btEffectType){
						case BATTLE_EFFECT_TYPE_LIFE:
							NDLog("%d chageLife",nextCmd->idActor);
							fcmd->actor			= nextCmd->idActor;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_LIFE;
							fcmd->data			= (int)nextCmd->nHpLost;
							break;
						case BATTLE_EFFECT_TYPE_MANA:
							NDLog("%d chageMana",nextCmd->idActor);
							fcmd->actor			= nextCmd->idActor;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_MANA;
							fcmd->data			= (int)nextCmd->nMpLost;
							break;
						case BATTLE_EFFECT_TYPE_SKILL_TARGET:
							NDLog("%d skill_target %d",nextCmd->idActor,nextCmd->idTarget);
							if( action->m_eEffectType == BATTLE_EFFECT_TYPE_SKILL )
							{
								Fighter * pF = GetFighter(nextCmd->idTarget);
								if ( pF )
								{
									action->m_kFighterList.push_back( pF );
									if( action->m_pkTarget == NULL )
									{
										action->m_pkTarget = pF;
									}
								}
							}
							nextCmd = nextCmd->cmdNext;
							continue;

						case BATTLE_EFFECT_TYPE_SKILL_EFFECT_TARGET:
							nextCmd = nextCmd->cmdNext;
							continue;
						case BATTLE_EFFECT_TYPE_SKILL_EFFECT:
							NDLog("%d skill_effect %d",nextCmd->idActor, nextCmd->idTarget);
							if( action->m_eEffectType == BATTLE_EFFECT_TYPE_SKILL )
							{
								fcmd->actor			= nextCmd->idActor;//受击方
								fcmd->effect_type	= BATTLE_EFFECT_TYPE_SKILL_EFFECT;
								fcmd->data			= (int)nextCmd->idTarget;//受击表现skill_result_cfg.lookface
								action->addCommand(fcmd);
							}
							nextCmd = nextCmd->cmdNext;
							continue;

						case BATTLE_EFFECT_TYPE_DODGE:
							NDLog("%d dodge",nextCmd->idActor);
							fcmd->actor			= nextCmd->idActor;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_DODGE;
							break;
						case BATTLE_EFFECT_TYPE_DRITICAL:
							//action->isDritical=true;
							action->m_bIsCriticalHurt	= true;//改为受击方显示伤害数字，而不是上面的显示暴击光效
							NDLog("%d dritical",nextCmd->idActor);
							fcmd->actor			= nextCmd->idActor;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_DRITICAL;
							fcmd->data			= (int)nextCmd->nHpLost;
							break;
						case BATTLE_EFFECT_TYPE_BLOCK:
							NDLog("%d block",nextCmd->idActor);
							fcmd->actor			= nextCmd->idActor;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_BLOCK;
							break;
						case BATTLE_EFFECT_TYPE_COMBO:
							NDLog("%d combo",nextCmd->idActor);
							action->m_bIsCombo		= true;
							this->AddActionCommand(action);
							action				= new FightAction(this->GetFighter(cmd->idActor),this->GetFighter(cmd->idTarget),BATTLE_EFFECT_TYPE(cmd->btEffectType));
							fcmd->actor			= cmd->idTarget;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_LIFE;
							fcmd->data			= (int)nextCmd->nHpLost;
							action->addCommand(fcmd);
							nextCmd				= nextCmd->cmdNext;
							continue;
						case BATTLE_EFFECT_TYPE_STATUS_ADD://加状态
							fcmd->actor			= nextCmd->idActor;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_STATUS_ADD;
							fcmd->data			= nextCmd->idTarget;
							break;
						case BATTLE_EFFECT_TYPE_STATUS_LOST://减状态
							fcmd->actor			= nextCmd->idActor;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_STATUS_LOST;
							fcmd->data			= nextCmd->idTarget;
							break;
						case BATTLE_EFFECT_TYPE_CTRL:
							break;
						case BATTLE_EFFECT_TYPE_ESCORTING://护驾/援护
							fcmd->actor			= nextCmd->idActor;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_ESCORTING;
							break;
						case BATTLE_EFFECT_TYPE_COOPRATION_HIT://合击
							fcmd->actor			= nextCmd->idActor;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_COOPRATION_HIT;
							break;
						case BATTLE_EFFECT_TYPE_RESIST://免疫
							fcmd->actor			= nextCmd->idActor;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_RESIST;
							break;
						case BATTLE_EFFECT_TYPE_CHANGE_POSTION://移位
							fcmd->actor			= nextCmd->idActor;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_STATUS_LOST;
							fcmd->data			= nextCmd->idTarget;//pos id
							break;
						case BATTLE_EFFECT_TYPE_PLAY_ANIMATION:// 对象身上播放指定动画
							fcmd->actor			= nextCmd->idActor;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_PLAY_ANIMATION;
							fcmd->data			= nextCmd->idTarget;//ani id
							break;
						case BATTLE_EFFECT_TYPE_DEAD:
							fcmd->actor			= nextCmd->idActor;
							fcmd->effect_type	= BATTLE_EFFECT_TYPE_DEAD;
							break;
						default:
							break;
					}
					action->addCommand(fcmd);
					//					theTarget = GetFighter(nextCmd->idActor);

					//					if (nextCmd->btType == EFFECT_CHANGE_LIFE_TYPE_SKILL_STATUS_ADD) {
					//						// 动作后，附加状态
					//						theTarget = GetFighter(nextCmd->idTarget);
					//						theTarget->AddAHurt(NULL, nextCmd->btType,
					//								   nextCmd->nHpLost, nextCmd->nMpLost,
					//								   nextCmd->dwData, HURT_TYPE_PASSIVE);
					//						StatusAction sa(StatusAction::ADD_STATUS,
					//								nextCmd->status,
					//								nextCmd->idTarget);
					//						theActor->AddAStatusTarget(sa);
					//						nextCmd->complete = (true);
					//						
					//					} else if (nextCmd->btType == EFFECT_CHANGE_LIFE_TYPE_SKILL_STATUS_LOST) {
					//						// 动作后，取消附加状态
					//						theTarget = GetFighter(nextCmd->idTarget);
					//						theTarget->AddAHurt(NULL, nextCmd->btType,
					//								   nextCmd->nHpLost, nextCmd->nMpLost,
					//								   nextCmd->dwData, HURT_TYPE_PASSIVE);
					//						StatusAction sa(StatusAction::CANCEL_STATUS,
					//								nextCmd->status,
					//								nextCmd->idTarget);
					//						theActor->AddAStatusTarget(sa);						
					//						nextCmd->complete = (true);
					//					}

					nextCmd = nextCmd->cmdNext;
				}
				NDLog("addAction");
				AddActionCommand(action);
			}
		}

		//		if (m_vActionFighterList.size() > 0) {
		//			Fighter* f = m_vActionFighterList.at(0);
		//			f->setBeginAction(true);
		//		}

		m_actionFighterPoint = 0;

		m_foreBattleStatus = 0;

		setBattleStatus (BS_SHOW_FIGHT);
		m_startWait = 25;
	}
}

void Battle::RestartFight()
{
	ShowTimerAndTurn(false);

	RemoveChild(TAG_WAITING, true);
	clearHighlight();

	m_currentActionIndex1 = 0;
	m_currentActionIndex2 = 0;
	m_currentActionIndex3 = 0;
	m_Team1_status = TEAM_WAIT;
	m_Team2_status = TEAM_WAIT;
	m_Team3_status = TEAM_WAIT;

	setBattleStatus (BS_SHOW_FIGHT);
	m_startWait = 25;
}

void Battle::StartFight()
{
	ShowTimerAndTurn(false);
	//RemoveChild(TAG_TIMER, false);
	if (!m_bWatch)
	{
		RemoveChild(TAG_WAITING, true);
		clearHighlight();
		if (ms_bAuto)
		{
			//			RemoveChild(m_imgAutoCount, false);
			//			RemoveChild(m_lbAuto, false);
		}

//		switch (m_battleStatus) {
//			case BS_USER_MENU:
//				//RemoveChild(m_battleOpt, false);
//				break;
//			case BS_USE_ITEM_MENU:
//				//CloseItemMenu();
//				break;
//			case BS_CHOOSE_VIEW_FIGHTER_STATUS:
//				CloseViewStatus();
//				break;
//			case BS_USER_SKILL_MENU:
//				//CloseSkillMenu();
//				break;
//			default:
//				break;
//		}
	}
	dealWithCommand();
	m_currentActionIndex1 = 0;
	m_currentActionIndex2 = 0;
	m_currentActionIndex3 = 0;
	m_Team1_status = TEAM_WAIT;
	m_Team2_status = TEAM_WAIT;
	m_Team3_status = TEAM_WAIT;
}

bool Battle::AllFighterActionOK()
{
	bool result = true;

	//test 预防actionOK不了超时的问题。
	for (size_t i = 0; i < m_vActionFighterList.size(); i++)
	{
		Fighter* f = m_vActionFighterList.at(i);
		if (f->getActionTime() > 200)
		{
			f->setActionOK(true);
		}
	}

	// 判断action是否ok
	for (size_t i = 0; i < m_vActionFighterList.size(); i++)
	{
		Fighter* f = m_vActionFighterList.at(i);
		if (!f->isVisiable() || f->isActionOK()
				|| (!f->isEscape() && !f->isAlive()))
		{
			continue;
		}
		else
		{
			result = false;
			break;
		}
	}
	// 判断状态动作是否完成。
	if (result == true)
	{
		return fighterStatusOK(m_vAttaker) && fighterStatusOK(m_vDefencer);
	}
	return result;
}

bool Battle::fighterStatusOK(VEC_FIGHTER& fighterList)
{
	bool result = true;
	for (size_t i = 0; i < fighterList.size(); i++)
	{
		Fighter* f = fighterList.at(i);
		if (!f->isHurtOK() && !f->isDodgeOK() && !f->isDieOK())
		{
			continue;
		}
		else
		{
			result = false;
			break;
		}
	}
	return result;
}

void Battle::notifyNextFighterBeginAction()
{
	size_t idx = m_actionFighterPoint;

	if (idx >= m_vActionFighterList.size())
		return;

	Fighter* f = m_vActionFighterList.at(idx);
	Fighter* fNext = NULL;
	size_t i = 0;
	if (idx < m_vActionFighterList.size() - 1)
	{
		for (i = idx + 1; i < m_vActionFighterList.size(); i++)
		{
			Fighter* ftmp = m_vActionFighterList.at(i);
			if (ftmp->isAlive() && ftmp->isVisiable() && !ftmp->isBeginAction())
			{
				fNext = ftmp;
				break;
			}
		}
	}
	if (fNext)
	{
		if (f->m_kInfo.group == fNext->m_kInfo.group)
		{			// 同边的很快就开始动作
			if (f->completeOneAction())
			{
				fNext->setBeginAction(true);
				m_actionFighterPoint = i;
			}
		}
		else
		{
			if (f->isActionOK() && !fNext->isHurtOK() && !fNext->isDodgeOK()
					&& !fNext->isDieOK()
					|| f->m_actionType == Fighter::ACTION_TYPE_PROTECT)
			{
				fNext->setBeginAction(true);
				m_actionFighterPoint = i;
			}
		}
	}
}

bool Battle::isPasClear()
{
	bool result = true;
	//	for (size_t i = 0; i < m_vActionFighterList.size(); i++) {
	//		Fighter& f = *m_vActionFighterList.at(i);
	//		if (f.m_changeLifeTypePas != EFFECT_CHANGE_LIFE_TYPE_NONE) {
	//			result = false;
	//			break;
	//		}
	//	}
	return result;
}

bool Battle::noOneCanAct(VEC_FIGHTER& fighterList)
{
	bool result = false;
	if (fighterList.size() == 0)
	{
		result = true;
	}
	for (size_t i = 0; i < fighterList.size(); i++)
	{
		Fighter& f = *fighterList.at(i);
		if (f.isVisiable() && f.isAlive())
		{
			break;
		}
		else if (i == fighterList.size() - 1)
		{
			result = true;
		}
	}
	return result;
}

BATTLE_COMPLETE Battle::battleComplete()
{
	BATTLE_COMPLETE result = BATTLE_COMPLETE(serverBattleResult);
//	if (noOneCanAct(GetEnemySideList())) {
//		result = BATTLE_COMPLETE_WIN;
//		if (GetMainUser() == NULL || GetMainUser()->m_kInfo.nLife > 0) {
//			monsterResult(GetEnemySideList());
//		}
//	}else if (noOneCanAct(GetOurSideList())) {
//		result = BATTLE_COMPLETE_LOSE;
//	}
//	
//	if(getServerBattleResult() != -2) {
//		result = BATTLE_COMPLETE(getServerBattleResult());
//	}
	monsterResult(GetEnemySideList());
	monsterResult(GetOurSideList());
	return result;
}

VEC_FIGHTER& Battle::GetOurSideList()
{
	if (m_ourGroup == BATTLE_GROUP_ATTACK)
	{
		return m_vAttaker;
	}
	else
	{
		return m_vDefencer;
	}
}

VEC_FIGHTER& Battle::GetEnemySideList()
{
	if (m_ourGroup == BATTLE_GROUP_DEFENCE)
	{
		return m_vAttaker;
	}
	else
	{
		return m_vDefencer;
	}
}

Fighter* Battle::getMainEudemon()
{
// 	if (!m_mainEudemon)
// 	{
// 		Fighter* user = GetMainUser();
// 		if (user) {
// 			PetInfo* petInfo = PetMgrObj.GetMainPet(NDPlayer::defaultHero().m_id);
// 			if (petInfo) {
// 				VEC_FIGHTER& euList = GetOurSideList();
// 				for (size_t i = 0; i < euList.size(); i++) {
// 					Fighter* f =  euList.at(i);
// 					//					if (f->m_kInfo.idPet == petInfo->data.int_PET_ID) {
// 					//						m_mainEudemon = f;
// 					//						break;
// 					//					}
// 
// 				}
// 			}
// 
// 		}
// 	}

	return m_mainEudemon;
}

void Battle::setFighterToWait(VEC_FIGHTER& fighterList)
{
	for (size_t i = 0; i < fighterList.size(); i++)
	{
		Fighter& f = *fighterList.at(i);
		if (!f.isVisiable())
		{
			continue;
		}
		f.m_action = (Fighter::WAIT);
		if (f.isAlive())
		{
			battleStandAction(f);
		}
	}
}

void Battle::setAllFightersToWait()
{
	setFighterToWait (m_vAttaker);
	setFighterToWait (m_vDefencer);
}

void Battle::clearFighterStatus(Fighter& f)
{
	f.clearFighterStatus();
	f.setBeginAction(false);
	f.m_bMissAtk = false;
	f.setHurtOK(false);
	f.setDodgeOK(false);
	f.setActionOK(false);
	f.setDefenceOK(false);
	f.setActionTime(0);
}

void Battle::clearActionFighterStatus()
{
	for (size_t i = 0; i < m_vActionFighterList.size(); i++)
	{
		Fighter& f = *m_vActionFighterList.at(i);
		clearFighterStatus(f);
	}
	m_vActionFighterList.clear();
}

void Battle::FinishBattle()
{
	if(BattleMgrObj.GetBattleReward())
	{
		NDMapMgrObj.BattleEnd(BattleMgrObj.GetBattleReward()->m_nBattleResult);

	}
	//m_timer.SetTimer(this, TIMER_BACKTOGAME, 1);
	BattleMgrObj.quitBattle();
}

void Battle::ShowPas()
{
	setBattleStatus (BS_BATTLE_COMPLETE);
	battleCompleteResult = battleComplete();
	//showBattleComplete();
	// 退出战斗,地图逻辑处理

	if (currentShowFighter > 0)
	{
		ScriptMgrObj.excuteLuaFunc("CloseFighterInfo","FighterInfo",0);
	}
	BattleMgrObj.showBattleResult();
	//	if (isPasClear() && AllFighterActionOK()) {
	//		battleCompleteResult = battleComplete();
	//		
	//		if (battleCompleteResult != BATTLE_COMPLETE_NO) {
	//			setBattleStatus(BS_BATTLE_COMPLETE);
	//			showBattleComplete();
	//		} else {// 战斗还未结束,回合结束
	//			if (m_vCmdList.size() > 0) {// 已经存了不少服务端提前发来的指令。不再收集玩家指令了。
	//				setBattleStatus(BS_SET_FIGHTER);
	//				
	//			} else {
	//				if (GetMainUser()) {
	//					setBattleStatus(BS_USER_MENU);// 先进入玩家指令状态，在根据具体情况改变。
	//					
	//					if (!GetMainUser()->isAlive()) {// 如果玩家死了，有宠物就弹出宠物的指令
	//						if (getMainEudemon()) {// 如果玩家有宠物
	//							if (getMainEudemon()->isVisiable()) {
	//								setBattleStatus(BS_EUDEMON_MENU);
	//							}
	//						} else {// 玩家又没有宠物
	//							setBattleStatus(BS_USER_MENU);// 进入该状态，应为玩家的死亡状态等，指令框不会弹出
	//						}
	//					} else {// 如果玩家活着
	//						if (GetMainUser()->isVisiable()) {// 而且玩家没有逃跑，就是用玩家指令
	//							setBattleStatus(BS_USER_MENU);
	//							m_bSendCurTurnUserAction = false;
	//							
	//						} else {// 但是玩家跑了，有宠物就用宠物指令。
	//							if (getMainEudemon() != NULL && getMainEudemon()->isVisiable()) {
	//								setBattleStatus(BS_EUDEMON_MENU);
	//							}
	//						}
	//					}
	//					
	//					if (m_battleStatus == BS_USER_MENU) 
	//					{
	//						if (s_bAuto) 
	//						{
	//							OnBtnAuto(true);
	//						}
	//						else 
	//						{
	//							//AddChild(m_battleOpt);
	//							m_bTurnStart = true;
	//						}
	//					} 
	//					else if (m_battleStatus == BS_EUDEMON_MENU) 
	//					{
	//						if (s_bAuto) {
	//							OnBtnAuto(true);
	//						} else {
	//							//AddChild(m_eudemonOpt);
	//							m_bTurnStartPet = true;
	//						}
	//
	//					}
	//				} else {
	//					if (m_bWatch) {
	//						setBattleStatus(BS_WAITING_SERVER_MESSAGE);
	//					}
	//					else
	//					{
	//						if (getMainEudemon()) {// 如果玩家有宠物
	//							if (getMainEudemon()->isVisiable()) {
	//								setBattleStatus(BS_EUDEMON_MENU);
	//								if (s_bAuto) {
	//									OnBtnAuto(true);
	//								} else {
	//									//AddChild(m_eudemonOpt);
	//									m_bTurnStartPet = true;
	//								}
	//							}
	//						}
	//						else
	//						{
	//							setBattleStatus(BS_WAITING_SERVER_MESSAGE);
	//						} 
	//					}
	//				}
	//			}
	//			
	//			setAllFightersToWait();
	//			
	//			// 更新回合数和倒计时
	//			//m_turn++;
	//			{
	//				stringstream ss;
	//				ss << m_turn << "/" << MAX_TURN;
	////				m_lbTurn->SetText(ss.str().c_str());
	//			}
	//			//m_imgTurn->SetBigRedTwoNumber(m_turn, MAX_TURN);
	//			m_timeLeft = m_timeLeftMax;
	//			{
	//				stringstream ss;
	//				ss << m_timeLeft;
	////				m_lbTimer->SetText(ss.str().c_str());
	//			}
	//			ShowTimerAndTurn(true);
	//			//m_imgTimer->SetBigRedNumber(, false);
	////			if (m_lbTimer->GetParent() == NULL) {
	////				AddChild(m_lbTimer);
	////			}
	//			
	//			// 更新倒计时
	////			if (s_bAuto && m_mainFighter->isAlive()) {
	////				AddChild(m_imgAutoCount);
	////				AddChild(m_lbAuto);
	////				m_autoCount = AUTO_COUNT;
	////				m_imgAutoCount->SetBigRedNumber(m_autoCount, false);
	////			}
	//			
	//			clearActionFighterStatus();
	//		}
	//	} else {
	////		for (size_t i = 0; i < m_vActionFighterList.size(); i++) {
	////			Fighter& f = *m_vActionFighterList.at(i);
	////			if (f.m_changeLifeTypePas == EFFECT_CHANGE_LIFE_TYPE_SKILL_STATUS || f.m_changeLifeTypePas == EFFECT_CHANGE_LIFE_TYPE_CHG_MAX
	////			    || f.m_changeLifeTypePas == EFFECT_CHANGE_LIFE_TYPE_SKILL_STATUS_LOST) {
	////				
	////				performStatus(f);
	////				
	////			}
	////		}
	//	}
}

void Battle::performStatus(Fighter& theTarget)
{
	//	if (theTarget.m_changeLifeTypePas != EFFECT_CHANGE_LIFE_TYPE_NONE) {
	//		int status = theTarget.getAPasStatus();
	//		
	//		Hurt hurt = theTarget.getHurt(NULL, theTarget.m_changeLifeTypePas, status, HURT_TYPE_PASSIVE).second;
	//		
	//		int hurtHP = hurt.hurtHP;
	//		int hurtMP = hurt.hurtMP;
	//		int addHP = 0;
	//		int addMP = 0;
	//		int currentHP = 0;
	//		int currentMP = 0;
	//		if (hurtHP != 0) {
	//			if (theTarget.m_changeLifeTypePas == EFFECT_CHANGE_LIFE_TYPE_CHG_MAX) {
	//				addHP = hurtHP - theTarget.m_kInfo.nLifeMax;
	//				theTarget.m_kInfo.nLifeMax = (hurtHP);
	//				currentHP = theTarget.m_kInfo.nLife;
	//				currentHP += addHP;
	//				theTarget.hurted(addHP);
	//				
	//			} else {
	//				currentHP = theTarget.m_kInfo.nLife;
	//				currentHP += hurtHP;
	//				theTarget.hurted(hurtHP);
	//			}
	//			if (!IsPracticeBattle()) {
	//				theTarget.setCurrentHP(currentHP);
	//			}
	//			currentHP = theTarget.m_kInfo.nLife;
	//			if (hurtHP < 0) {
	//				
	//				if (currentHP > 0) {// hurt
	//					theTarget.setHurtOK(true);
	//					hurtAction(theTarget);
	//				} else {// die
	//					theTarget.setDieOK(true);
	//					dieAction(theTarget);
	//				}
	//				
	//			}
	//		}
	//		if (hurtMP != 0) {
	//			if (theTarget.m_changeLifeTypePas == EFFECT_CHANGE_LIFE_TYPE_CHG_MAX) {
	//				addMP = hurtMP - theTarget.m_kInfo.nManaMax;
	//				theTarget.m_kInfo.nManaMax = (hurtMP);
	//				currentMP = theTarget.m_kInfo.nMana;
	//				currentMP += addMP;
	//				theTarget.hurted(addMP);
	//				theTarget.setCurrentMP(currentMP);
	//			} else {
	//				currentMP = theTarget.m_kInfo.nMana;
	//				currentMP += hurtMP;
	//				theTarget.hurted(hurtMP);
	//				theTarget.setCurrentMP(currentMP);
	//			}
	//
	//			if (hurtMP < 0) {
	//				hurtAction(theTarget);
	//			}
	//
	//		}
	//
	//		if (theTarget.m_changeLifeTypePas == EFFECT_CHANGE_LIFE_TYPE_SKILL_STATUS_LOST) {
	//			// 释放状态动画
	//			theTarget.removeAStatusAniGroup(hurt.dwData);
	//		}
	//
	//		if (!theTarget.hasMorePasStatus()) {
	//			theTarget.m_changeLifeTypePas = (EFFECT_CHANGE_LIFE_TYPE_NONE);
	//		}
	//	}
}

bool Battle::isActionCanBegin(FightAction* action)
{
	Fighter* fighter = action->m_pkActor;
	if (fighter)
	{
		if (!fighter->isAlive())
		{
			action->m_eActionStatus = ACTION_STATUS_FINISH;
			NDLog("fighter already dead,action skip");
			return false;
		}
		if (fighter->isActionOK() && !fighter->isHurtOK()
				&& !fighter->isDodgeOK() && !fighter->isDefenceOK()
				&& !fighter->isDieOK())
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
		if (action->m_eEffectType == EFFECT_TYPE_BATTLE_BEGIN)
		{
			TEAM_STATUS status;
			switch (action->m_nTeamAttack)
			{
			case 1:
				status = m_Team1_status;
				break;
			case 2:
				status = m_Team2_status;
				break;
			case 3:
				status = m_Team3_status;
				break;
			default:
				break;
			}
			if (status == TEAM_WAIT)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		return true;
	}
}

VEC_FIGHTER& Battle::getDefFightersByTeam(int team)
{
	VEC_FIGHTER v_team;
	for (VEC_FIGHTER::iterator it = m_vDefencer.begin(); it != m_vDefencer.end(); it++)
	{
		Fighter* f = *it;
		if (f->m_kInfo.btBattleTeam == team)
		{

			v_team.push_back(f);
		}
	}
	return v_team;
}

void Battle::startAction(FightAction* pkFighterAction)
{
	switch (pkFighterAction->m_eEffectType)
	{
	case BATTLE_EFFECT_TYPE_ATK:
		if (pkFighterAction->m_pkActor->GetNormalAtkType() == ATKTYPE_NEAR)
		{
			pkFighterAction->m_pkActor->m_action = Fighter::MOVETOTARGET;
		}
		else if (pkFighterAction->m_pkActor->GetNormalAtkType() == ATKTYPE_DISTANCE)
		{
			pkFighterAction->m_pkActor->m_action = Fighter::AIMTARGET;
		}
		break;
	case BATTLE_EFFECT_TYPE_SKILL:
		if(!pkFighterAction->m_pkActor)
			break;
		if (pkFighterAction->m_pkSkill->getAtkType() == SKILL_ATK_TYPE_REMOTE)
		{
			pkFighterAction->m_pkActor->m_action = Fighter::AIMTARGET;
		}
		else
		{
			pkFighterAction->m_pkActor->m_action = Fighter::MOVETOTARGET;
		}
		break;
	case BATTLE_EFFECT_TYPE_SKILL_EFFECT://技能目标
		if(pkFighterAction->m_pkSkill->getAtkType() == SKILL_ATK_TYPE_REMOTE)
		{
			pkFighterAction->m_pkActor->m_action = Fighter::AIMTARGET;
		}
		else
		{
			pkFighterAction->m_pkActor->m_action = Fighter::MOVETOTARGET;
		}
		break;
	case EFFECT_TYPE_BATTLE_BEGIN:
		//			NDLog("START_MOVE_TEAM");
		for (VEC_FIGHTER_IT it = m_vAttaker.begin(); it != m_vAttaker.end(); it++)
		{
			Fighter* pkFighter = *it;
			if (pkFighter->m_kInfo.btBattleTeam == pkFighterAction->m_nTeamDefense)
			{
				pkFighter->m_action = Fighter::MOVETOTARGET;
				pkFighter->m_nTargetX = countX(m_teamAmout, pkFighter->m_kInfo.group,
						(pkFighterAction->m_nTeamDefense - 1) % 3 + 1, pkFighter->m_kInfo.btStations);
				pkFighter->m_nTargetY = countY(m_teamAmout, pkFighter->m_kInfo.group,
						(pkFighterAction->m_nTeamDefense - 1) % 3 + 1, pkFighter->m_kInfo.btStations);
				pkFighterAction->m_kFighterList.push_back(pkFighter);
			}
		}
		switch (pkFighterAction->m_nTeamAttack)
		{
		case 1:
			m_Team1_status = TEAM_FIGHT;
			break;
		case 2:
			m_Team2_status = TEAM_FIGHT;
			break;
		case 3:
			m_Team3_status = TEAM_FIGHT;
			break;
		default:
			break;
		}
		break;
	default:
		break;
	}
	pkFighterAction->m_eActionStatus = ACTION_STATUS_PLAY;
}

void Battle::runAction(int nTeamID)
{
	int nCurrentIndex = 0;
	VEC_FIGHTACTION* pkActionList;
	switch (nTeamID)
	{
	case 1:
		nCurrentIndex = m_currentActionIndex1;
		pkActionList = &(BattleMgrObj.m_vActionList1);
		break;
	case 2:
		nCurrentIndex = m_currentActionIndex2;
		pkActionList = &(BattleMgrObj.m_vActionList2);
		break;
	case 3:
		nCurrentIndex = m_currentActionIndex3;
		pkActionList = &(BattleMgrObj.m_vActionList3);
		break;
	default:
		break;
	}

	FightAction* fa = NULL;
	if (nCurrentIndex < pkActionList->size())
	{
		fa = pkActionList->at(nCurrentIndex);
	}
	else
	{	//actio列表已取完
		//NDLog("%d no more action,battle end",teamId);
		switch (nTeamID)
		{
		case 1:
			m_Team1_status = TEAM_OVER;
			break;
		case 2:
			m_Team2_status = TEAM_OVER;
			break;
		case 3:
			m_Team3_status = TEAM_OVER;
			break;
		default:
			break;
		}
		return;
	}

	notifyNextFighterBeginAction();

	if (fa)
	{
		if (fa->m_pkActor)
		{
			fa->m_pkActor->actionTimeIncrease();
		}

		if (fa->m_eActionStatus == ACTION_STATUS_FINISH)
		{
			nCurrentIndex++;
			switch (nTeamID)
			{
			case 1:
				m_currentActionIndex1 = nCurrentIndex;
				break;
			case 2:
				m_currentActionIndex2 = nCurrentIndex;
				break;
			case 3:
				m_currentActionIndex3 = nCurrentIndex;
				break;
			default:
				break;
			}
			if (nCurrentIndex < pkActionList->size())
			{
				fa = pkActionList->at(nCurrentIndex);
				//NDLog("team:%d index %d",teamId,currentIndex);
				if (isActionCanBegin(fa))
				{
					startAction(fa);
				}
				else
				{
					return;
				}
			}
			else
			{
				return;
			}
		}
		else if (fa->m_eActionStatus == ACTION_STATUS_WAIT)
		{
			if (isActionCanBegin(fa))
			{
				startAction(fa);
			}
			else
			{
				return;
			}
		}

		switch (fa->m_eEffectType)
		{
		case BATTLE_EFFECT_TYPE_ATK:
			if (fa->m_pkActor->GetNormalAtkType() == ATKTYPE_NEAR)
			{
				moveToTarget(fa);
				//						if (f->m_mainTarget->protector) {
				//							moveToTarget(*f->m_mainTarget->protector);
				//						}
				normalAttack(fa);
				moveBack(fa);
				//						if (f->m_mainTarget->protector) {
				//							moveBack(*f->m_mainTarget->protector);
				//						}
			}
			else if (fa->m_pkActor->GetNormalAtkType() == ATKTYPE_DISTANCE)
			{
				aimTarget(fa);
				//						if (f->m_mainTarget->protector) {
				//							moveToTarget(fa->m_mainTarget->protector);
				//						}
				normalDistanceAttack(fa);
				distanceAttackOver(fa);
				//						if (f->m_mainTarget->protector) {
				//							moveBack(*fa->m_mainTarget->protector);
				//						}
			}
			break;
		case BATTLE_EFFECT_TYPE_SKILL:
			if (fa->m_pkSkill->getAtkType() == SKILL_ATK_TYPE_REMOTE)
			{
				aimTarget(fa);
				//						if (f->m_mainTarget->protector) {
				//							moveToTarget(*f->m_mainTarget->protector);
				//						}
				distanceSkillAttack(fa);
				distanceAttackOver(fa);
			}
			else
			{
				moveToTarget(fa);
				skillAttack(fa);
				moveBack(fa);
			}
			//						if (f->m_mainTarget->protector) {
			//							moveBack(*f->m_mainTarget->protector);
			//						}
			//					}
			break;
		case BATTLE_EFFECT_TYPE_SKILL_EFFECT://技能目标
			if(fa->m_pkSkill->getAtkType() == SKILL_ATK_TYPE_REMOTE)
			{
				aimTarget(fa);
				distanceSkillAttack(fa);
				distanceAttackOver(fa);
			}
			else
			{
				moveToTarget(fa);
				skillAttack(fa);
				moveBack(fa);
			}
			break;
		case EFFECT_TYPE_BATTLE_BEGIN:				//战斗开始时，把队伍移动到战斗位
			moveTeam(fa);
			break;
			//			case EFFECT_TYPE_DEFENCE:
			//				defence(*f);
			//				break;
			//			case EFFECT_TYPE_ESCAPE:
			//				fleeSuccess(*f);
			//				break;
			//			case EFFECT_TYPE_ESCAPE_FAIL:
			//				fleeFail(*f);
			//				break;
			//			case EFFECT_TYPE_CATCH:
			//			case EFFECT_TYPE_CATCH_FAIL: {
			//				aimTarget(*f);
			//				catchPet(*f);
			//				distanceAttackOver(*f);
			//				break;
			//			}
		case EFFECT_TYPE_BATTLE_END:
			switch (fa->m_nTeamAttack)
			{
			case 1:
				m_Team1_status = TEAM_WAIT;
				break;
			case 2:
				m_Team2_status = TEAM_WAIT;
				break;
			case 3:
				m_Team3_status = TEAM_WAIT;
				break;
			default:
				break;
			}
			fa->m_eActionStatus = ACTION_STATUS_FINISH;
			break;
		case BATTLE_EFFECT_TYPE_STATUS_LIFE:				//状态去血
			fa->m_pkActor->hurted(fa->m_nData);
			fa->m_pkActor->setCurrentHP((fa->m_pkActor->m_kInfo.nLife) + (fa->m_nData));
			if (fa->m_pkActor->m_kInfo.nLife > 0)
			{				// hurt
				fa->m_pkActor->setHurtOK(true);
				hurtAction(*(fa->m_pkActor));
			}
			else
			{				// die
				fa->m_pkActor->setDieOK(true);
				stringstream ss;
				ss << "die_action.spr";

				//死亡音效
				ScriptMgrObj.excuteLuaFunc("PlayBattleSoundEffect", "Music",1092);
				
				addSkillEffectToFighter(fa->m_pkActor, 
					NDPath::GetAniPath(ss.str().c_str()).c_str(), 
					0, 1);

				fa->m_pkActor->showFighterName(false);
				dieAction(*(fa->m_pkActor));
			}
			fa->m_eActionStatus = ACTION_STATUS_FINISH;
			break;
		case BATTLE_EFFECT_TYPE_STATUS_MANA://状态去气
			fa->m_pkActor->setCurrentMP((fa->m_pkActor->m_kInfo.nMana)+(fa->m_nData));
			fa->m_eActionStatus = ACTION_STATUS_FINISH;
			break;
		case BATTLE_EFFECT_TYPE_STATUS_ADD:

			{
				unsigned int	nIconID = ScriptDBObj.GetN( "skill_result_cfg", fa->m_nData, DB_SKILL_RESULT_CFG_ICON );
				unsigned int	effectId = ScriptDBObj.GetN( "skill_result_cfg", fa->m_nData, DB_SKILL_RESULT_CFG_LOOKFACE );


				fa->m_pkActor->AppendStatusIcon( nIconID );
				fa->m_eActionStatus = ACTION_STATUS_FINISH;

				ScriptMgrObj.excuteLuaFunc("PlayBattleSoundEffect", "Music",effectId,600);
			}

			break;
		case BATTLE_EFFECT_TYPE_STATUS_LOST:
			{
				unsigned int	nIconID = ScriptDBObj.GetN( "skill_result_cfg", fa->m_nData, DB_SKILL_RESULT_CFG_ICON );
				fa->m_pkActor->RemoveStatusIcon( nIconID);
				fa->m_eActionStatus = ACTION_STATUS_FINISH;
			}
			break;
		case BATTLE_EFFECT_TYPE_ESCORTING://护驾=援护
			{//播放“援护”文字动画++Guosen 2012.7.9//
				string file = NDPath::GetAniPath("sm_effect_47.spr");
				addSkillEffectToFighter(fa->m_pkActor,file.c_str(),0,g_ArrayEfectProp[47].iPos,g_ArrayEfectProp[47].bRevers);
			}
			fa->m_eActionStatus = ACTION_STATUS_FINISH;
			break;
		case BATTLE_EFFECT_TYPE_COOPRATION_HIT://合击
			{//播放“合击”文字动画++Guosen 2012.7.9
				string file = NDPath::GetAniPath("sm_effect_46.spr");
				addSkillEffectToFighter(fa->m_pkActor,file.c_str(),0,g_ArrayEfectProp[46].iPos,g_ArrayEfectProp[46].bRevers);
			}
			fa->m_eActionStatus = ACTION_STATUS_FINISH;
			break;
		case BATTLE_EFFECT_TYPE_RESIST://免疫
			{//播放“免疫”文字动画++Guosen 2012.8.2
				string file = NDPath::GetAniPath("sm_effect_32.spr");
				addSkillEffectToFighter(fa->m_pkActor,file.c_str(),0,g_ArrayEfectProp[32].iPos,g_ArrayEfectProp[32].bRevers);
			}
			fa->m_eActionStatus = ACTION_STATUS_FINISH;
			break;
		case BATTLE_EFFECT_TYPE_CHANGE_POSTION://移位
			{//++Guosen 2012.7.10
				int targetX = countX( this->m_teamAmout, fa->m_pkActor->m_kInfo.group, (fa->m_nTeamDefense-1)%3+1, fa->m_nData );
				int targetY = countY( this->m_teamAmout, fa->m_pkActor->m_kInfo.group, (fa->m_nTeamDefense-1)%3+1, fa->m_nData );
				if ( fa->m_pkActor->moveTo( targetX, targetY ) )
				{
					fa->m_pkActor->m_kInfo.btStations = fa->m_nData;
					fa->m_pkActor->setOriginPos( targetX, targetY );
					fa->m_eActionStatus = ACTION_STATUS_FINISH;
				}
			}
			break;
		case BATTLE_EFFECT_TYPE_PLAY_ANIMATION:// 对象身上播放指定动画
			{
				stringstream ss;
				ss << "sm_effect_" << fa->m_nData << ".spr";
				string file = NDPath::GetAniPath(ss.str().c_str());
				addSkillEffectToFighter(fa->m_pkActor,file.c_str(),0,g_ArrayEfectProp[fa->m_nData].iPos,g_ArrayEfectProp[fa->m_nData].bRevers);
			}
			fa->m_eActionStatus = ACTION_STATUS_FINISH;
			break;
		case BATTLE_EFFECT_TYPE_LIFE:
			fa->m_pkActor->m_bHardAtk=false;
			fa->m_pkActor->hurted(fa->m_nData);
			NDLog("hurt %d",fa->m_nData);
			fa->m_pkActor->setCurrentHP((fa->m_pkActor->m_kInfo.nLife)+(fa->m_nData));
			if (fa->m_pkActor->m_kInfo.nLife > 0)
			{
				// hurt
				fa->m_pkActor->setHurtOK(true);
				if(fa->m_nData<0){
					hurtAction(*(fa->m_pkActor));
				}
			} 
			else
			{
				// die
				fa->m_pkActor->setDieOK(true);
				dieAction(*(fa->m_pkActor));
				stringstream ss;
				ss << "die_action.spr";

				//死亡音效
				ScriptMgrObj.excuteLuaFunc("PlayBattleSoundEffect", "Music",1092);

				fa->m_pkActor->showFighterName(false);
				string file = NDPath::GetAniPath(ss.str().c_str());
				addSkillEffectToFighter(fa->m_pkActor,file.c_str(),0,1);
			}
			fa->m_eActionStatus = ACTION_STATUS_FINISH;
			break;
		case BATTLE_EFFECT_TYPE_MANA:
			fa->m_pkActor->setCurrentMP((fa->m_pkActor->m_kInfo.nMana)+(fa->m_nData));
			fa->m_eActionStatus = ACTION_STATUS_FINISH;
			break;
		default:
			break;
		}
	}

}

void Battle::ShowFight()
{
	if (m_Team1_status != TEAM_OVER)
	{
		runAction(1);
	}
	if (m_Team2_status != TEAM_OVER)
	{
		runAction(2);
	}
	if (m_Team3_status != TEAM_OVER)
	{
		runAction(3);
	}
	if (m_Team1_status == TEAM_OVER && m_Team2_status == TEAM_OVER
			&& m_Team3_status == TEAM_OVER)
	{
		setBattleStatus (BS_FIGHTER_SHOW_PAS);
		//ReleaseActionList();
		ReleaseCommandList();

	}
	//	if (AllFighterActionOK()) {
	//		setBattleStatus(BS_FIGHTER_SHOW_PAS);
	//	}
}

void Battle::useItem(Fighter& theActor)
{
	if (theActor.m_action == Fighter::USEITEM)
	{	// 暂时没有使用道具的动作，而且是对自己使用补充物品
		if (theActor.GetRole()->IsAnimationComplete())
		{
			Fighter& target = *theActor.m_pkMainTarget;

			Hurt hurt = target.getHurt(&theActor, 0, theActor.m_uiUsedItem,
					HURT_TYPE_ACTIVE).second;

			int hurtHP = hurt.hurtHP;

			if (hurtHP > 0)
			{
				int currentHP = target.m_kInfo.nLife;
				int addHP = hurtHP;
				currentHP += addHP;
				if (currentHP > target.m_kInfo.nLifeMax)
				{
					currentHP = target.m_kInfo.nLifeMax;
				}
				target.hurted(addHP);
				if (!IsPracticeBattle())
				{
					target.setCurrentHP(currentHP);
				}
				//处理复活
				if (!target.isAlive())
				{
					target.setAlive(true);
					clearFighterStatus(target);
					battleStandAction(target);
					watchBattle = false;
				}
			}

			int hurtMP = hurt.hurtMP;

			if (hurtMP > 0)
			{
				int currentMP = target.m_kInfo.nMana;
				int addMP = hurtMP;
				currentMP += addMP;
// 				if (currentMP > target.m_kInfo.nManaMax)
// 				{
// 					currentMP = target.m_kInfo.nManaMax;
// 				}
				target.hurted(addMP);
				target.setCurrentMP(currentMP);
			}
			// 动作后触发状态变化
			handleStatusActions(theActor.getArrayStatusTarget());
			theActor.m_action = (Fighter::DISTANCEATTACKOVER);
			battleStandAction(theActor);
		}
	}
}

void Battle::catchPet(Fighter& f)
{
	//	if (f.m_action == Fighter::CATCH_PET) {
	//		if (f.GetRole()->IsAnimationComplete()) {
	//			// 完成捕捉,此处可添加 被捕捉的对象动画
	//			if (f.m_effectType == EFFECT_TYPE_CATCH) {
	//				f.m_mainTarget->setAlive(false);
	//				Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("CatchSucc"));
	//			} else if (f.m_effectType == EFFECT_TYPE_CATCH_FAIL) {
	//				Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("CatchFail"));
	//			}
	//			// 动作后触发状态变化
	//			handleStatusActions(theActor->getArrayStatusTarget());
	//			// 设置下一状态
	//			f.m_action = (Fighter::DISTANCEATTACKOVER);
	//			battleStandAction(f);
	//		}
	//	}
}

void Battle::defence(Fighter& theActor)
{
	if (theActor.m_action == Fighter::DEFENCE)
	{
		if (theActor.GetRole()->IsAnimationComplete())
		{
			theActor.setActionOK(true);
			// 动作后触发状态变化
			handleStatusActions(theActor.getArrayStatusTarget());
		}
	}
}

void Battle::fleeFail(Fighter& theActor)
{
	if (theActor.m_action == Fighter::FLEE_FAIL)
	{
		if (!bActionSet)
		{
			fleeFailAction(theActor);
			bActionSet = true;
		}
		if (theActor.GetRole()->IsAnimationComplete())
		{
			theActor.setActionOK(true);
			// 动作后触发状态变化
			handleStatusActions(theActor.getArrayStatusTarget());
			battleStandAction(theActor);
			bActionSet = false;
		}
	}
}

void Battle::fleeSuccess(Fighter& theActor)
{
	if (theActor.m_action == Fighter::FLEE_SUCCESS)
	{
		if (!bActionSet)
		{
			bActionSet = true;
			fleeSuccessAction(theActor);
		}
		if (theActor.GetRole()->IsAnimationComplete())
		{
			if (theActor.m_kInfo.idObj == NDPlayer::defaultHero().m_nID)
			{	// 如果是自己逃跑了或者死了
				// ，就观战
				watchBattle = true;
				//				m_imgWhoAmI->RemoveFromParent(true);
				//				m_imgWhoAmI = NULL;
			}
			// 动作后触发状态变化
			handleStatusActions(theActor.getArrayStatusTarget());
			theActor.setActionOK(true);
			theActor.setEscape(true);
			bActionSet = false;
		}
	}
}

void Battle::moveTeam(FightAction* action)
{

	VEC_FIGHTER* v_fighters = &(action->m_kFighterList);
	bool isOk = true;
	if (v_fighters)
	{
		for (int i = 0; i < v_fighters->size(); i++)
		{
			Fighter* f = v_fighters->at(i);
			if (f->StandInOrigin())
			{
				moveToTargetAction(*f);
			}
			if (f->moveTo(f->m_nTargetX, f->m_nTargetY))
			{
				f->m_action = (Fighter::WAIT);
				battleStandAction(*f);
				f->setOriginPos(f->m_nTargetX, f->m_nTargetY);
				f->setActionOK(true);
			}
			else
			{
				isOk = false;
			}
		}
	}
	if (isOk)
	{
		action->m_eActionStatus = ACTION_STATUS_FINISH;
		for (int i = 0; i < action->m_vCmdList.size(); i++)
		{
			FIGHTER_CMD* cmd = action->m_vCmdList.at(i);
			dealWithFighterCmd(cmd);
		}
	}
}

void Battle::moveToTarget(FightAction* action)
{
	Fighter* theActor = action->m_pkActor;
	if (theActor->m_action == Fighter::MOVETOTARGET)
	{

		NDBaseRole* role = theActor->GetRole();

		int coordw = role->GetWidth() >> 1;
		//		if (theActor.m_kInfo.group != m_ourGroup) {
		//			coordw = -coordw;
		//		}
		if (theActor->m_kInfo.group == BATTLE_GROUP_ATTACK)
		{
			coordw = -coordw;
		}

		if (theActor->m_actionType == Fighter::ACTION_TYPE_PROTECT)
		{
			coordw = -coordw;
		}

		if (theActor->StandInOrigin())
		{
			moveToTargetAction(*(action->m_pkActor));
		}

		int roleOffset = 0;

		//		if (role->IsKindOfClass(RUNTIME_CLASS(NDManualRole)) &&
		//		    theActor.m_mainTarget->GetRole()->IsKindOfClass(RUNTIME_CLASS(NDManualRole))) {
		//			roleOffset = theActor.m_kInfo.group == BATTLE_GROUP_ATTACK ? 60 : -60;
		//		}
		if (action->m_pkTarget)
		{
			if (theActor->moveTo(
					action->m_pkTarget->getOriginX() + coordw + roleOffset,
					action->m_pkTarget->getOriginY()))
			{		// 如果返回到达目的地
				if (action->m_eEffectType == BATTLE_EFFECT_TYPE_ATK)
				{
					theActor->m_action = (Fighter::ATTACK);
					attackAction(*theActor);
				}
				else if (action->m_eEffectType == BATTLE_EFFECT_TYPE_SKILL)
				{

					theActor->m_action = (Fighter::SKILLATTACK);
					//处理技能动作
					BattleSkill* skill = action->m_pkSkill;

					//技能声效播放
					ScriptMgrObj.excuteLuaFunc("PlayBattleSoundEffect", "Music",1099,500);

					theActor->setSkillName(skill->getName());
					theActor->showSkillName(true);
					int actId = skill->GetActId();
//					if(theActor->m_lookfaceType==LOOKFACE_MANUAL){
					roleAction(*theActor, actId);
//					}else{
//						petAction(*theActor, actId);
//					}
					//处理技能光效
//					int effectId=skill->GetLookfaceID()/100;
//					if(effectId!=0){//光效播放在自已身上
//						int delay=skill->GetLookfaceID()%100;
//						stringstream ss;
//						ss << "effect_" << effectId << ".spr";
//						NSString file = [NSString stringWithUTF8String:GetAniPath(ss.str().c_str())];
//						NDLog("add self effect");
//						addSkillEffectToFighter(theActor,file,delay);
//					}
//					effectId=skill->GetLookfaceTargetID()/100;//光效播放在目标身上
//					if(effectId!=0){
//						int delay=skill->GetLookfaceTargetID()%100;
//						stringstream ss;
//						ss << "effect_" << effectId << ".spr";
//						NSString file = [NSString stringWithUTF8String:GetAniPath(ss.str().c_str())];
//						for (int i = 0; i < action->m_FighterList.size(); i++)
//						{	
//							Fighter* f=action->m_FighterList.at(i);
//							addSkillEffectToFighter(f, file,delay);
//						}
//					}
				}
			}
		}
		else
		{
			if (action->m_eEffectType == BATTLE_EFFECT_TYPE_ATK)
			{
				theActor->m_action = (Fighter::ATTACK);
				attackAction(*theActor);
			}
			else if (action->m_eEffectType == BATTLE_EFFECT_TYPE_SKILL)
			{

				theActor->showSkillName(true);
				theActor->m_action = (Fighter::SKILLATTACK);
				//处理技能动作
				BattleSkill* skill = action->m_pkSkill;
				int actId = skill->GetActId();
//				if(theActor->m_lookfaceType==LOOKFACE_MANUAL){
				roleAction(*theActor, actId);
//				}else{
//					petAction(*theActor, 0);
//				}
				//处理技能光效

				int effectId = skill->getSelfEffect();///1000;
				NDLog("add effect:%d",effectId);
				if(effectId != 0)
				{
					//光效播放在自已身上
					int delay = 0;//(skill->GetLookfaceID()/10)%100;
					int pos = 0;//(skill->GetLookfaceID())%10;
					stringstream ss;
					ss << "sm_effect_" << effectId << ".spr";
					string file = NDPath::GetAniPath(ss.str().c_str());
					
					//++Guosen 2012.6.28//播放特效动画须指定的位置及翻转设定
					//addSkillEffectToFighter(theActor,file,delay,pos);
					addSkillEffectToFighter(theActor,file.c_str(),delay,g_ArrayEfectProp[effectId].iPos,g_ArrayEfectProp[effectId].bRevers);
				}
				effectId=skill->getTargetEffect();///1000;//光效播放在目标身上
				if(effectId != 0)
				{
					int delay = 0;//(skill->GetLookfaceTargetID()/10)%100;
					int pos = 0;//skill->GetLookfaceTargetID()%10;
					stringstream ss;
					ss << "sm_effect_" << effectId << ".spr";
					string file = NDPath::GetAniPath(ss.str().c_str());
					for (UInt32 i = 0; i < action->m_kFighterList.size(); i++)
					{	
						Fighter* f=action->m_kFighterList.at(i);

						//++Guosen 2012.6.28//播放特效动画须指定的位置及翻转设定
						//addSkillEffectToFighter(f, file,delay,pos);
						addSkillEffectToFighter(f,file.c_str(),delay,g_ArrayEfectProp[effectId].iPos,g_ArrayEfectProp[effectId].bRevers);
					}
				}
			}
		}
	}
}

void Battle::dealWithFighterCmd(FIGHTER_CMD* cmd)
{
	Fighter* fighter = GetFighter(cmd->actor);
	NDLog("%d cmd:%d", cmd->actor, cmd->effect_type);
	if (fighter)
	{
		switch (cmd->effect_type)
		{
		case BATTLE_EFFECT_TYPE_LIFE:
			fighter->m_bHardAtk = false;
			fighter->hurted(cmd->data);
			NDLog("hurt %d", cmd->data);
			fighter->setCurrentHP((fighter->m_kInfo.nLife) + (cmd->data));
			if (fighter->m_kInfo.nLife > 0)
			{				// hurt
				fighter->setHurtOK(true);
				if (cmd->data < 0)
				{
					hurtAction(*fighter);
				}
			}
			else
			{				// die
				fighter->setDieOK(true);
				dieAction(*fighter);
				stringstream ss;
				ss << "die_action.spr";

				//死亡音效
				ScriptMgrObj.excuteLuaFunc("PlayBattleSoundEffect", "Music",1092);

				fighter->showFighterName(false);
				string file = NDPath::GetAniPath(ss.str().c_str());
				addSkillEffectToFighter(fighter, file.c_str(), 0, 1);
			}
			break;
		case BATTLE_EFFECT_TYPE_MANA:
			fighter->setCurrentMP((fighter->m_kInfo.nMana) + (cmd->data));
			break;
		case BATTLE_EFFECT_TYPE_DODGE:
			//fighter->setDodgeOK(true);//显示"闪避"文字
			{
				//播放闪避文字动画++Guosen 2012.6.28
				string file = NDPath::GetAniPath("sm_effect_25.spr");
				//addSkillEffectToFighter(fighter,file,0,0, false);
				addSkillEffectToFighter(fighter,file.c_str(),0,g_ArrayEfectProp[25].iPos,g_ArrayEfectProp[25].bRevers);
			}
			dodgeAction(*fighter);
			break;
		case BATTLE_EFFECT_TYPE_DRITICAL:
			fighter->m_bHardAtk = true;
			fighter->hurted(cmd->data);
			fighter->setCurrentHP((fighter->m_kInfo.nLife)+(cmd->data));
			if (fighter->m_kInfo.nLife > 0)
			{
				// hurt
				fighter->setHurtOK(true);
				if(cmd->data < 0)
				{
					hurtAction(*fighter);
				}
			}
			else
			{
				// die
				fighter->setDieOK(true);
				dieAction(*fighter);
				stringstream ss;

				//死亡音效
				ScriptMgrObj.excuteLuaFunc("PlayBattleSoundEffect", "Music",1092);

				ss << "die_action.spr";
				fighter->showFighterName(false);
				string file = NDPath::GetAniPath(ss.str().c_str());
				addSkillEffectToFighter(fighter,file.c_str(),0,1);
			}
			break;
		case BATTLE_EFFECT_TYPE_BLOCK:
			//格挡……
			//fighter->setDefenceOK(true);
			defenceAction(*fighter);

			break;
			//++Guosen 2012.7.11//
		case BATTLE_EFFECT_TYPE_STATUS_ADD:
			{
				unsigned int	nIconID = ScriptDBObj.GetN( "skill_result_cfg", cmd->data, DB_SKILL_RESULT_CFG_ICON );
				fighter->AppendStatusIcon( nIconID );
			}
			break;
		case BATTLE_EFFECT_TYPE_STATUS_LOST:
			{
				unsigned int	nIconID = ScriptDBObj.GetN( "skill_result_cfg", cmd->data, DB_SKILL_RESULT_CFG_ICON );
				fighter->RemoveStatusIcon( nIconID );
			}
			break;
		case BATTLE_EFFECT_TYPE_ESCORTING://护驾=援护
			{
				//播放“援护”文字动画
				string file = NDPath::GetAniPath("sm_effect_47.spr");
				addSkillEffectToFighter(fighter,file.c_str(),0,g_ArrayEfectProp[47].iPos,g_ArrayEfectProp[47].bRevers);
			}
			break;
		case BATTLE_EFFECT_TYPE_COOPRATION_HIT://合击
			{//播放“合击”文字动画
				string file = NDPath::GetAniPath("sm_effect_46.spr");
				addSkillEffectToFighter(fighter,file.c_str(),0,g_ArrayEfectProp[46].iPos,g_ArrayEfectProp[46].bRevers);
			}
			break;
		case BATTLE_EFFECT_TYPE_RESIST://免疫
			{//播放“免疫”文字动画
				string file = NDPath::GetAniPath("sm_effect_32.spr");
				addSkillEffectToFighter(fighter,file.c_str(),0,g_ArrayEfectProp[32].iPos,g_ArrayEfectProp[32].bRevers);
			}
			break;
		case BATTLE_EFFECT_TYPE_CHANGE_POSTION://移位
			{
				int targetX = countX( this->m_teamAmout, fighter->m_kInfo.group, fighter->m_kInfo.btBattleTeam, cmd->data );
				int targetY = countY( this->m_teamAmout, fighter->m_kInfo.group, fighter->m_kInfo.btBattleTeam, cmd->data );
				if ( fighter->moveTo( targetX, targetY ) )
				{
					fighter->m_kInfo.btStations = cmd->data;
					fighter->setOriginPos( targetX, targetY );
				}
			}
			break;
		case BATTLE_EFFECT_TYPE_PLAY_ANIMATION:// 对象身上播放指定动画
			{
				stringstream ss;
				ss << "sm_effect_" << cmd->data << ".spr";
				string file = NDPath::GetAniPath(ss.str().c_str());
				addSkillEffectToFighter(fighter,file.c_str(),0,g_ArrayEfectProp[cmd->data].iPos,g_ArrayEfectProp[cmd->data].bRevers);
			}
			break;
		case BATTLE_EFFECT_TYPE_SKILL_EFFECT:
			//处理技能光效
			NDLog(@"add effect:%d",cmd->data);
			if ( fighter->isDieOK() )
				break;
			if(cmd->data!=0){//光效播放在自已身上
				int delay=0;//(skill->GetLookfaceID()/10)%100;
				int pos=0;//skill->GetLookfaceID()%10;
				stringstream ss;
				ss << "sm_effect_" << cmd->data << ".spr";
				string file = NDPath::GetAniPath(ss.str().c_str());
				//++Guosen 2012.6.28//播放特效动画须指定的位置及翻转设定
				//addSkillEffectToFighter(fighter,file,delay,pos);
				addSkillEffectToFighter(fighter,file.c_str(),delay,g_ArrayEfectProp[cmd->data].iPos,g_ArrayEfectProp[cmd->data].bRevers);
			}
			break;
		default:
			break;
		}
	}
}

void Battle::normalAttack(FightAction* action)
{
	Fighter* theActor = action->m_pkActor;
	if (theActor->m_action == Fighter::ATTACK)
	{
		NDBaseRole* role = theActor->GetRole();
		if (role->IsAnimationComplete())
		{
			NDLog("%d:normalATK", theActor->m_kInfo.idObj);
			for (int i = 0; i < action->m_vCmdList.size(); i++)
			{
				FIGHTER_CMD* cmd = action->m_vCmdList.at(i);
				dealWithFighterCmd(cmd);
			}
			//			theActor.m_vCmdList.clear();
			//			Fighter* theTarget = theActor.m_mainTarget;
			//			if (theActor.m_bMissAtk) {
			//				theTarget->setDodgeOK(true);
			//				dodgeAction(*theTarget);
			//				
			//				if (role->IsAnimationComplete()) {
			//					theActor.m_action = (Fighter::MOVEBACK);
			//					moveBackAction(theActor);
			//				}
			//			} else {
			//				int currentHP = theTarget->m_kInfo.nLife;
			//				int hurtHP = theTarget->getHurt(&theActor, 1, 0, HURT_TYPE_ACTIVE).second.hurtHP;
			//				currentHP += hurtHP;
			//				theTarget->hurted(hurtHP);
			//				if (!IsPracticeBattle()) {
			//					theTarget->setCurrentHP(currentHP);
			//				}
			//				if (theTarget->m_kInfo.nLife > 0) {// hurt
			//					theTarget->setHurtOK(true);
			//					hurtAction(*theTarget);
			//				} else {// die
			//					theTarget->setDieOK(true);
			//					dieAction(*theTarget);
			//				}
			//				theActor.m_action = (Fighter::MOVEBACK);
			//				moveBackAction(theActor);
			//				if (theTarget->protector) {
			//					theTarget->protector->m_action = (Fighter::MOVEBACK);
			//					moveBackAction(*theTarget->protector);
			//					theTarget->protector->hurted(theTarget->protector->hurtInprotect);
			//					theTarget->protector->hurtInprotect = 0;
			//				}
			//			}
			//			// 动作后触发状态变化
			//			handleStatusActions(theActor.getArrayStatusTarget());
			if (!action->m_bIsCombo)
			{
				theActor->m_action = (Fighter::MOVEBACK);
				moveBackAction(*theActor);
			}
			else
			{
				theActor->m_action = (Fighter::WAIT);
				theActor->setActionOK(true);
				battleStandAction(*theActor);
				action->m_eActionStatus = ACTION_STATUS_FINISH;
			}
		}
	}
}

void Battle::moveBack(FightAction* action)
{
	Fighter* theActor = action->m_pkActor;
	if (theActor->m_action == Fighter::MOVEBACK)
	{
		if (theActor->moveTo(theActor->getOriginX(), theActor->getOriginY()))
		{
			theActor->m_action = (Fighter::WAIT);
			theActor->setActionOK(true);
			battleStandAction(*theActor);
			action->m_eActionStatus = ACTION_STATUS_FINISH;
			//			if (theActor.protectTarget) {
			//				theActor.protectTarget->protector = NULL;
			//				theActor.protectTarget = NULL;
			//			}
		}
	}
}

void Battle::addSkillEffectToFighter(Fighter* fighter, const char* sprfile, int delay, int pos, bool bRevers)
{
	NDLog("add skill effect");
	NDAnimationGroup* effect = new NDAnimationGroup;
	effect->initWithSprFile(sprfile);
	NDSubAniGroup sa;
	sa.role = fighter->GetRole();
	sa.fighter = fighter;
	sa.aniGroup = effect;//
	sa.frameRec = new NDFrameRunRecord;
	sa.isFromOut = true;
	sa.startFrame = delay;
	sa.reverse = bRevers;
	sa.pos = pos;
	m_vSubAniGroup.push_back(sa);

	//effect->release();
}

void Battle::addSkillEffect(Fighter& theActor, bool user/*=false*/)
{
//	int skillId = theActor.getUseSkill()->getId();
//	// 动作
//	int actId = skillId / 1000000;
//	
//	NDBaseRole *role = theActor.GetRole();
//	
//	if( user && role && (actId == 24 || actId == 22) )
//	{
//		actId = role->GetWeaponType() == ONE_HAND_WEAPON ? 22 : 24;
//	}
//	
//	if (user)
//		roleAction(theActor, actId);
//	else
//		petAction(theActor, actId);
//	// 光效id为999的时候为无光效
//	if (skillId != 999) {
//		int effectId = skillId / 1000 % 1000;
//		int effectDelay = skillId / 10 % 100;
//		
//		if (effectId > 899) return;
//		
//		stringstream ss;
//		ss << "effect_" << effectId << ".spr";
//		NSString file = [NSString stringWithUTF8String:GetAniPath(ss.str().c_str())];
//		NDAnimationGroup* effect = [[NDAnimationGroup alloc] initWithSprFile:file];
//		
//		int target = skillId % 10;
//		switch (target) {
//			case 0:// 0光效在目标身上
//			{
//				VEC_FIGHTER& allTarget = theActor.getArrayTarget();
//				int size = allTarget.size();
//				for (int i = 0; i < size; i++) {
//					if (allTarget.at(i)->m_kInfo.group == theActor.m_mainTarget->m_kInfo.group) {
//						NDSubAniGroup sa;
//						sa.role = theActor.GetRole();
//						sa.fighter = allTarget.at(i);
//						sa.aniGroup = [effect retain];
//						sa.frameRec = [[NDFrameRunRecord alloc] init];
//						sa.isFromOut = true;
//						sa.startFrame = effectDelay;
//						m_vSubAniGroup.push_back(sa);
//					}
//				}
//			}
//				break;
//			case 1: // 1光效在施法者身上
//			{
//				NDSubAniGroup sa;
//				sa.role = theActor.GetRole(); // add by jhzheng 2011.10.13
//				sa.fighter = &theActor;
//				sa.aniGroup = [effect retain];
//				sa.isFromOut = true;
//				sa.frameRec = [[NDFrameRunRecord alloc] init];
//				m_vSubAniGroup.push_back(sa);
//				sa.startFrame = effectDelay;
//				break;
//			}
//			default:
//				break;
//		}
//		
//		[effect release];
//	}
}

void Battle::aimTarget(FightAction* action)
{
	Fighter* theActor = action->m_pkActor;
	if(action->m_bIsDritical)
	{
		theActor->showAtkDritical();//++Guosen显示暴击动画目前没有……
	}
	if (theActor->m_action == Fighter::AIMTARGET)
	{
		if (action->m_eEffectType == BATTLE_EFFECT_TYPE_ATK)
		{
			theActor->m_action = (Fighter::DISTANCEATTACK);
			attackAction(*theActor);
		}
		else if (action->m_eEffectType == BATTLE_EFFECT_TYPE_SKILL)
		{
			theActor->m_action = (Fighter::DISTANCESKILLATTACK);
			//处理技能动作
			BattleSkill* skill = action->m_pkSkill;
			theActor->setSkillName(skill->getName());
			theActor->showSkillName(true);
			int actId = skill->GetActId();
//			if(theActor->m_lookfaceType==LOOKFACE_MANUAL){
			roleAction(*theActor, actId);
//			}else{
//				petAction(*theActor, 0);
//			}
			//处理技能光效
			int effectId=skill->getSelfEffect();///1000;

			//技能声效播放
			int skillidSelf = skill->getId();
			if(skillidSelf == 999999)
			{
				ScriptMgrObj.excuteLuaFunc("PlayBattleSoundEffect", "Music",1098,500);
			}else
			{
				ScriptMgrObj.excuteLuaFunc("PlayBattleSoundEffect", "Music",effectId);
			}


			NDLog("add effect to self effectid:%d", effectId);
			if(effectId != 0)
			{
				//光效播放在自已身上
				int delay = 0;//(skill->GetLookfaceID()/10)%100;
				int pos = 0;//skill->GetLookfaceID()%10;
				stringstream ss;
				ss << "sm_effect_" << effectId << ".spr";
				string file = NDPath::GetAniPath(ss.str().c_str());
				addSkillEffectToFighter(theActor,file.c_str(),delay,g_ArrayEfectProp[effectId].iPos,g_ArrayEfectProp[effectId].bRevers);//++Guosen 2012.6.28
			}
			effectId = skill->getTargetEffect();///1000;//光效播放在目标身上
			NDLog("add effect to target effectid:%d",effectId);

			//技能声效播放
			int skillidTarget = skill->getId();
			ScriptMgrObj.excuteLuaFunc("PlayBattleSoundEffect", "Music",effectId);


			if(effectId != 0)
			{
				int delay = 0;//(skill->GetLookfaceTargetID()/10)%100;
				int pos = 0;//skill->GetLookfaceTargetID()%10;
				stringstream ss;
				ss << "sm_effect_" << effectId << ".spr";
				string file = NDPath::GetAniPath(ss.str().c_str());
				for (UInt32 i = 0; i < action->m_kFighterList.size(); i++)
				{	
					Fighter* f=action->m_kFighterList.at(i);
					//addSkillEffectToFighter(f, file,delay,pos);
					addSkillEffectToFighter(f,file.c_str(),delay,g_ArrayEfectProp[effectId].iPos,g_ArrayEfectProp[effectId].bRevers);//++Guosen 2012.6.28
				}
			}

			//			if (theActor.m_kInfo.fighterType == FIGHTER_TYPE_PET) { // 玩家
			//				/*
			//				int skillId = theActor.getUseSkill()->getSkillTypeID();
			//				while (skillId >= 100) {
			//					skillId = skillId /10;
			//				}
			//				int prof = skillId % 10;
			//				if (prof == PROFESSION_TYPE_SOLDIER) {
			//					warriorSkillAction(theActor);
			//				} else if (prof == PROFESSION_TYPE_ASN) {
			//					assasinSkillAction(theActor);
			//				} else if (prof == PROFESSION_TYPE_MAGE) {
			//					wizzardSkillAction(theActor);
			//				}
			//				*/
			//				// 新的玩家技能表现(可配置)
			//				addSkillEffect(theActor, true);
			//			} else { // 宠物或怪物
			//				addSkillEffect(theActor);
			//			}
		}
		//		else if (theActor.m_actionType == Fighter::ACTION_TYPE_USEITEM) {
		////			theActor.m_action = (Fighter::USEITEM);
		////			useItemAction(theActor);
		//		} else if (theActor.m_actionType == Fighter::ACTION_TYPE_CATCH) { //添加捕捉动画
		//			theActor.m_action = (Fighter::CATCH_PET);
		//			catchPetAction(theActor);
		//		}
	}
}

void Battle::normalDistanceAttack(FightAction* action)
{
	Fighter* theActor = action->m_pkActor;
	if (theActor->m_action == Fighter::DISTANCEATTACK)
	{
		NDBaseRole* role = theActor->GetRole();
		if (role->IsAnimationComplete())
		{
			NDLog("%d:normalDistanceATK", theActor->m_kInfo.idObj);
			for (int i = 0; i < action->m_vCmdList.size(); i++)
			{
				FIGHTER_CMD* cmd = action->m_vCmdList.at(i);
				dealWithFighterCmd(cmd);
			}
			//			if (theActor.m_bMissAtk) {
			//				target->setDodgeOK(true);
			//				dodgeAction(*target);
			//				if (role->IsAnimationComplete()) {
			//					theActor.m_action = (Fighter::DISTANCEATTACKOVER);
			//					battleStandAction(theActor);
			//				}
			//			} else {
			//				int currentHP = target->m_kInfo.nLife;
			//				int hurtHP = target->getHurt(&theActor, 1, 0, HURT_TYPE_ACTIVE).second.hurtHP;
			//				currentHP += hurtHP;
			//				target->hurted(hurtHP);
			//				if (!IsPracticeBattle()) {
			//					target->setCurrentHP(currentHP);
			//				}
			//				if (target->m_kInfo.nLife > 0) {// hurt
			//					target->setHurtOK(true);
			//					hurtAction(*target);
			//					battleStandAction(theActor);
			//				} else {// die
			//					target->setDieOK(true);
			//					dieAction(*target);
			//				}
			//				theActor.m_action = (Fighter::DISTANCEATTACKOVER);
			//				if (target->protector) {
			//					target->protector->m_action = (Fighter::MOVEBACK);
			//					moveBackAction(*target->protector);
			//					target->protector->hurted(target->protector->hurtInprotect);
			//					target->protector->hurtInprotect = 0;
			//				}
			//			}
			// 动作后触发状态变化
			//			handleStatusActions(theActor.getArrayStatusTarget());
			if (!action->m_bIsCombo)
			{
				theActor->m_action = (Fighter::DISTANCEATTACKOVER);
				//				moveBackAction(*theActor);
			}
			else
			{
				theActor->m_action = (Fighter::WAIT);
				theActor->setActionOK(true);
				battleStandAction(*theActor);
				action->m_eActionStatus = ACTION_STATUS_FINISH;
			}
		}
	}
}

void Battle::distanceAttackOver(FightAction* action)
{
	Fighter* theActor = action->m_pkActor;
	if (theActor->m_action == Fighter::DISTANCEATTACKOVER)
	{
		if (theActor->GetRole()->IsAnimationComplete())
		{
			theActor->m_action = (Fighter::WAIT);
			theActor->setActionOK(true);
			battleStandAction(*theActor);
			action->m_eActionStatus = ACTION_STATUS_FINISH;
		}
	}
}

void Battle::fighterSomeActionChangeToWait(VEC_FIGHTER& fighterList)
{
	for (size_t i = 0; i < fighterList.size(); i++)
	{
		Fighter& f = *(fighterList.at(i));
		if (!f.isAlive() || !f.isVisiable())
		{
			f.setHurtOK(false);
			f.setDieOK(false);
			f.setDodgeOK(false);
			f.setDefenceOK(false);
			continue;
		}
		if (f.isHurtOK())
		{ //被攻击过程
			if (f.GetRole()->IsAnimationComplete())
			{
				if (f.m_action == Fighter::DEFENCE)
				{
					defenceAction(f);
				}
				else
				{
					battleStandAction(f);
				}
				f.setHurtOK(false);
			}
		}
		if (f.isDieOK())
		{ //死亡过程
			if (f.GetRole()->IsAnimationComplete())
			{
				if (f.m_kInfo.idObj == NDPlayer::defaultHero().m_nID)
				{ // 如果是自己死了
					// ，就观战
					watchBattle = true;
				}
				f.setActionOK(true);					//整组动作结束
				f.setAlive(false);
				f.setDieOK(false);
			}
		}

		if (f.isDodgeOK())
		{ //闪避过程
			if (f.GetRole()->IsAnimationComplete())
			{

				if (f.m_action == Fighter::DEFENCE)
				{
					defenceAction(f);
				}
				else
				{
					battleStandAction(f);
				}
				f.setDodgeOK(false);
			}
		}

		if (f.isDefenceOK())
		{
			if (f.GetRole()->IsAnimationComplete())
			{
				f.m_bDefenceAtk = false;
				if (f.m_action == Fighter::DEFENCE)
				{
					defenceAction(f);
				}
				else
				{
					battleStandAction(f);
				}
				f.setDefenceOK(false);
			}
		}
	}
}

void Battle::drawFighterHurt(VEC_FIGHTER& fighterList)
{
	for (size_t i = 0; i < fighterList.size(); i++)
	{
		Fighter& f = *fighterList.at(i);
		f.drawHurtNumber();
	}
}

void Battle::drawAllFighterHurtNumber()
{
	drawFighterHurt (m_vAttaker);
	drawFighterHurt (m_vDefencer);
}

//--Guosen 2012.6.28//不显示动作名称（防御，逃跑，闪避）
//NDPicture* Battle::getActionWord(ACTION_WORD index)
//{
//	switch (index) {
//		case AW_DEF:
//			return this->m_picActionWordDef;
//		case AW_FLEE:
//			return this->m_picActionWordFlee;
//		case AW_DODGE:
//			return this->m_picActionWordDodge;
//		default:
//			return NULL;
//	}
//}

void Battle::skillAttack(FightAction* action)
{
	Fighter* theActor = action->m_pkActor;
	BattleSkill* skill = action->m_pkSkill;
	if (theActor->m_action == Fighter::SKILLATTACK)
	{
		if (theActor->GetRole()->IsAnimationComplete())
		{
			NDLog("%d:SkillATK", theActor->m_kInfo.idObj);
			for (int i = 0; i < action->m_vCmdList.size(); i++)
			{
				FIGHTER_CMD* cmd = action->m_vCmdList.at(i);
				dealWithFighterCmd(cmd);
			}
			//			VEC_FIGHTER& arrayTarget = theActor.getArrayTarget();
			//			
			//			for (size_t i = 0; i < arrayTarget.size(); i++) {
			//				Fighter& target = *(arrayTarget.at(i));
			//				if (target.protector) {
			//					target.protector->m_action = (Fighter::MOVEBACK);
			//					moveBackAction(*target.protector);
			//					target.protector->hurted(target.protector->hurtInprotect);
			//					target.protector->hurtInprotect = 0;
			//				}
			//				int currentHP = target.m_kInfo.nLife;
			//				
			//				Hurt hurt = target.getHurt(&theActor, 0, theActor.getUseSkill()->getId(), HURT_TYPE_ACTIVE).second;
			//				int hurtHP = hurt.hurtHP;
			//				currentHP += hurtHP;
			//				target.hurted(hurtHP);
			//				if (!IsPracticeBattle()) {
			//					target.setCurrentHP(currentHP);
			//				}
			//				currentHP = target.m_kInfo.nLife;
			//				if (hurtHP <= 0) {
			//					if (currentHP > 0) {// hurt
			//						target.setHurtOK(true);
			//						hurtAction(target);
			//					} else {// die
			//						target.setDieOK(true);
			//						dieAction(target);
			//					}
			//				}
			//			}
			//			
			//			// 动作后触发状态变化
			//			handleStatusActions(theActor.getArrayStatusTarget());

			theActor->m_action = (Fighter::MOVEBACK);
			moveBackAction(*theActor);
		}
	}
}

void Battle::distanceSkillAttack(FightAction* action)
{
	Fighter* theActor = action->m_pkActor;
	if (theActor->m_action == Fighter::DISTANCESKILLATTACK)
	{
		if (theActor->GetRole()->IsAnimationComplete())
		{
			NDLog("%d:distanceSkillATK", theActor->m_kInfo.idObj);
			for (int i = 0; i < action->m_vCmdList.size(); i++)
			{
				FIGHTER_CMD* cmd = action->m_vCmdList.at(i);
				dealWithFighterCmd(cmd);
			}

			//			VEC_FIGHTER& arrayTarget = theActor.getArrayTarget();
			//			
			//			for (size_t i = 0; i < arrayTarget.size(); i++) {
			//				Fighter& target = *(arrayTarget.at(i));
			//				if (target.protector) {
			//					target.protector->m_action = (Fighter::MOVEBACK);
			//					moveBackAction(*target.protector);
			//					target.protector->hurted(target.protector->hurtInprotect);
			//					target.protector->hurtInprotect = 0;
			//				}
			//				int currentHP = target.m_kInfo.nLife;
			//				
			//				Hurt hurt = target.getHurt(&theActor, 0, theActor.getUseSkill()->getId(), HURT_TYPE_ACTIVE).second;
			//				int hurtHP = hurt.hurtHP;
			//				currentHP += hurtHP;
			//				target.hurted(hurtHP);
			//				if (!IsPracticeBattle()) {
			//					target.setCurrentHP(currentHP);
			//				}
			//				currentHP = target.m_kInfo.nLife;
			//				if (hurtHP < 0) {
			//					if (currentHP > 0) {// hurt
			//						target.setHurtOK(true);
			//						hurtAction(target);
			//					} else {// die
			//						target.setDieOK(true);
			//						dieAction(target);
			//					}
			//				}
			//				
			//				// 处理复活
			//				if (!target.isAlive() && hurtHP > 0) {
			//					target.setAlive(true);
			//					clearFighterStatus(target);
			//					battleStandAction(target);
			//					watchBattle = false;
			//				}
			//			}
			//			
			//			// 动作后触发状态变化
			//			handleStatusActions(theActor.getArrayStatusTarget());

			theActor->m_action = (Fighter::DISTANCEATTACKOVER);
			battleStandAction(*theActor);
		}
	}
}

void Battle::clearWillBeAtk(VEC_FIGHTER& fighterList)
{
	for (size_t i = 0; i < fighterList.size(); i++)
	{
		Fighter& f = *fighterList.at(i);
		f.setWillBeAtk(false);
	}
}

void Battle::clearAllWillBeAtk()
{
	clearWillBeAtk(GetOurSideList());
	clearWillBeAtk(GetEnemySideList());
}

Fighter* Battle::getFighterByPos(VEC_FIGHTER& fighterList, int pos, int line)
{
	Fighter* result = NULL;
	for (size_t i = 0; i < fighterList.size(); i++)
	{
		Fighter* f = fighterList.at(i);
		if (f->m_kInfo.btStations == pos)
		{
			result = f;
			break;
		}
	}
	return result;
}

Fighter* Battle::getUpNearFighter(VEC_FIGHTER& fighterList, Fighter* f)
{			// 找上面贴着的一个fighter
	Fighter* result = NULL;
	if (!f)
	{
		return NULL;
	}

	if (f->m_kInfo.btStations == 1 || f->m_kInfo.btStations == 4
			|| f->m_kInfo.btStations == 7)
	{			// 最上面
		result = NULL;
	}
	else
	{
		Byte pos = f->m_kInfo.btStations;
		result = getFighterByPos(fighterList, pos - 1, 0);
	}
	return result;
}

Fighter* Battle::getDownNearFighter(VEC_FIGHTER& fighterList, Fighter* f)
{			// 找下面贴着的一个fighter
	Fighter* result = NULL;
	if (f == NULL)
	{
		return NULL;
	}
	if (f->m_kInfo.btStations == 3 || f->m_kInfo.btStations == 6
			|| f->m_kInfo.btStations == 9)
	{			// 最上面
		result = NULL;
	}
	else
	{
		Byte pos = f->m_kInfo.btStations;
		result = getFighterByPos(fighterList, pos + 1, 0);
	}
	return result;
}

void Battle::setWillBeAtk(VEC_FIGHTER& fighterList)
{
//	clearAllWillBeAtk();
//	int area = 0;
//	
//	switch (m_battleStatus) {
//		case BS_CHOOSE_ENEMY_MAG_ATK: // 玩家技能攻击
//		case BS_CHOOSE_OUR_SIDE_MAG_ATK:
//		{
//			if (GetMainUser() == NULL) return;
//			
//			BattleSkill* useSkill = GetMainUser()->getUseSkill();
//			if (!useSkill) {
//				return;
//			}
//			area = useSkill->getArea();
//		}
//			break;
//		case BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON:
//		{
//			BattleSkill* useSkill = getMainEudemon()->getUseSkill();
//			if (!useSkill) {
//				return;
//			}
//			area = useSkill->getArea();
//		}
//			break;
//		default:
//			return;
//	}
//	
//	if (!m_highlightFighter) {
//		return;
//	}
//	
//	Fighter* f = m_highlightFighter;
//	m_highlightFighter->setWillBeAtk(true);
//	
//	
//	if (area == 2) {
//		Fighter* nextF = getUpNearFighter(fighterList, f);
//		if (nextF == NULL || (nextF != NULL && !nextF->isVisiable())) {
//			nextF = getDownNearFighter(fighterList, f);
//		}
//		if (nextF != NULL && nextF->isVisiable()) {
//			nextF->setWillBeAtk(true);
//		}
//	} else if (area == 3) {
//		Fighter* upF = getUpNearFighter(fighterList, f);
//		if (upF != NULL && upF->isVisiable()) {
//			upF->setWillBeAtk(true);
//		}
//		Fighter* downF = getDownNearFighter(fighterList, f);
//		if (downF != NULL && downF->isVisiable()) {
//			downF->setWillBeAtk(true);
//		}
//	} else if (area == 4) {
//		Fighter* upF1 = getUpNearFighter(fighterList, f);
//		if (upF1 != NULL && upF1->isVisiable()) {
//			upF1->setWillBeAtk(true);
//		}
//		Fighter* upF2 = getUpNearFighter(fighterList, upF1);
//		if (upF2 != NULL && upF2->isVisiable()) {
//			upF2->setWillBeAtk(true);
//		}
//		Fighter* downF1 = getDownNearFighter(fighterList, f);
//		if (downF1 != NULL && downF1->isVisiable()) {
//			downF1->setWillBeAtk(true);
//		}
//		if (upF1 == NULL) {
//			Fighter* downF2 = getDownNearFighter(fighterList, downF1);
//			if (downF2 != NULL && downF2->isVisiable()) {
//				downF2->setWillBeAtk(true);
//			}
//		}
//	} else if (area == 5) {
//		Fighter* upF1 = getUpNearFighter(fighterList, f);
//		if (upF1 != NULL && upF1->isVisiable()) {
//			upF1->setWillBeAtk(true);
//		}
//		Fighter* upF2 = getUpNearFighter(fighterList, upF1);
//		if (upF2 != NULL && upF2->isVisiable()) {
//			upF2->setWillBeAtk(true);
//		}
//		Fighter* downF1 = getDownNearFighter(fighterList, f);
//		if (downF1 != NULL && downF1->isVisiable()) {
//			downF1->setWillBeAtk(true);
//		}
//		Fighter* downF2 = getDownNearFighter(fighterList, downF1);
//		if (downF2 != NULL && downF2->isVisiable()) {
//			downF2->setWillBeAtk(true);
//		}
//	} else if (area == 10) {// 全部都是被攻击对象
//		VEC_FIGHTER& list = getHighlightList();
//		for (size_t i = 0; i < list.size(); i++) {
//			Fighter* fighter = list.at(i);
//			fighter->setWillBeAtk(true);
//		}
//	}
}

VEC_FIGHTER& Battle::getHighlightList()
{
	for (VEC_FIGHTER_IT it = m_vAttaker.begin(); it != m_vAttaker.end();
			it++)
	{
		if (m_highlightFighter == *it)
		{
			return m_vAttaker;
		}
	}
	return m_vDefencer;
}

void Battle::addSubAniGroup(NDSprite* role, NDAnimationGroup* group, Fighter* f)
{
	NDSubAniGroup subAniGroup;
	subAniGroup.role = role;
	subAniGroup.aniGroup = group;
	subAniGroup.fighter = f;
	subAniGroup.frameRec = new NDFrameRunRecord;

	m_vSubAniGroup.push_back(subAniGroup);
}

void Battle::handleStatusActions(VEC_STATUS_ACTION& statusActions)
{
	//	for (size_t i = 0; i < statusActions.size(); i++) {
	//		StatusAction& sa = statusActions.at(i);
	//		Fighter* target = GetFighter(sa.idTarget);
	//		PAIR_GET_HURT pairHurt;
	//		if (sa.action == StatusAction::ADD_STATUS) {
	//			pairHurt = target->getHurt(NULL,
	//					      EFFECT_CHANGE_LIFE_TYPE_SKILL_STATUS_ADD,
	//					      sa.status->m_idStatus, HURT_TYPE_PASSIVE);
	//		} else {
	//			pairHurt = target->getHurt(NULL,
	//					      EFFECT_CHANGE_LIFE_TYPE_SKILL_STATUS_LOST,
	//					      sa.status->m_idStatus, HURT_TYPE_PASSIVE);
	//		}
	//		// 状态去血
	//		if (pairHurt.first) {
	//			Hurt& hurt = pairHurt.second;
	//			int currentHP = target->m_kInfo.nLife;
	//			if (currentHP > 0) {
	//				int hurtHP = hurt.hurtHP;
	//				currentHP += hurtHP;
	//				
	//				target->hurted(hurtHP);
	//				if (hurtHP < 0) {
	//					if (currentHP > 0) {// hurt
	//						target->setHurtOK(true);
	//						hurtAction(*target);
	//					} else {// die
	//						target->setDieOK(true);
	//						dieAction(*target);
	//					}
	//				}
	//				target->setCurrentHP(currentHP);
	//			}
	//		}
	//		if (sa.action == StatusAction::ADD_STATUS) {
	//			target->addAStatus(sa.status);
	//		} else {
	//			target->removeAStatusAniGroup(sa.status->m_idStatus);
	//		}
	//	}
}

void Battle::SetFighterOnline(int idFighter, bool bOnline)
{
	Fighter* f = GetFighter(idFighter);
	if (f)
	{
		f->setOnline(bOnline);
	}
}

/*void Battle::CreateCancleAutoFightButton()
 {
 if (!m_btnCancleAutoFight) 
 {
 m_btnCancleAutoFight = new NDUIButton();
 m_btnCancleAutoFight->Initialization();
 m_btnCancleAutoFight->SetFrameRect(CCRectMake(0, 0, 60, 30));
 m_btnCancleAutoFight->SetDelegate(this);
 m_btnCancleAutoFight->SetTag(BTN_CANCLE_AUTO);
 m_btnCancleAutoFight->SetBackgroundColor(ccc4(107, 158, 156, 255));
 m_btnCancleAutoFight->SetTitle("取消");
 AddChild(m_btnCancleAutoFight);
 }
 else 
 {
 m_btnCancleAutoFight->SetVisible(true);
 }
 }
 
 void Battle::RemoveCancleAutoFightButton()
 {
 if (m_btnCancleAutoFight) 
 {
 m_btnCancleAutoFight->SetVisible(false);
 }	
 }*/

void Battle::TurnStart()
{
//	// 自动战斗，返回
//	if (m_bWatch || s_bAuto || m_bTurnStart == false) {
//		m_bTurnStart = false;
//		m_bTurnStartPet = true;
//		return;
//	}
//	
//	//	m_fighterRight->SetGray(false);
//	//	
//	//	m_fighterLeft->SetGray(false);
//	Fighter* mainFighter = GetMainUser();
//	if (mainFighter == NULL || mainFighter->isEscape() || !mainFighter->isAlive() || mainFighter->isDieOK()) 
//	{
//		m_bSendCurTurnUserAction = true;
//		m_bTurnStartPet = true;
//		m_bTurnStart = false;
//		return;
//	}
//	
//	//	RefreshSkillBar();
//	//	
//	//	m_fighterLeft->SetPage(m_lastSkillPageUser);
//	//	
//	////	m_fighterBottom->SetGray(false);
//	//	
//	//	RefreshItemBar();
//	//	
//	//	// 根据玩家上回合的操作修改
//	//	m_fighterRight->SetShrink(m_bShrinkRight);
//	//	m_fighterLeft->SetShrink(m_bShrinkLeft);
//	//	m_fighterBottom->SetShrink(m_bShrinkBottom);
//	
//	// 无可捕捉目标，捕捉变灰
//	VEC_FIGHTER& enemyList = GetEnemySideList();
//	Fighter* f;
//	bool bCatchGray = true;
//	for (size_t i = 0; i < enemyList.size(); i++) {
//		f = enemyList.at(i);
//		if (f->isVisiable() && f->isCatchable()) {
//			bCatchGray = false;
//			break;
//		}
//	}
//	
//	//	if (bCatchGray) {
//	//		m_fighterRight->SetGray(bCatchGray, 0);
//	//	}
//	
//	m_bTurnStart = false;
//	
//	// 默认选择缓存上一回合攻击和技能指令以及目标
//	// 如果上回合目标死亡，默认一个新目标
//	// 技能本回合不可用，则改为普通攻击
//	if (BATTLE_ACT_PHY_ATK == m_defaultActionUser) {
//		if (m_defaultTargetUser == NULL || !m_defaultTargetUser->isVisiable()) {
//			OnBtnAttack();
//			m_defaultTargetUser = m_highlightFighter;
//		} else {
//			OnBtnAttack();
//			HighlightFighter(m_defaultTargetUser);
//		}
//		
//	} else if (BATTLE_ACT_MAG_ATK == m_defaultActionUser) {
//		if (m_setBattleSkillList.count(m_defaultSkillID) <= 0) {
//			m_defaultActionUser = BATTLE_ACT_PHY_ATK;
//			OnBtnAttack();
//			m_defaultTargetUser = m_highlightFighter;
//		} else {
//			m_curBattleAction->btAction = BATTLE_ACT_MAG_ATK;
//			m_curBattleAction->vData.clear();
//			
//			s_lastTurnActionUser.btAction = BATTLE_ACT_MAG_ATK;
//			s_lastTurnActionUser.vData.clear();
//			
//			m_curBattleAction->vData.push_back(m_defaultSkillID);
//			s_lastTurnActionUser.vData.push_back(m_defaultSkillID);
//			s_lastTurnActionUser.vData.push_back(0);
//			
//			BattleSkill* skill = BattleMgrObj.GetBattleSkill(m_defaultSkillID);
//			
//			if (skill) {
//				int targetType = skill->getAtkType();
//				GetMainUser()->setUseSkill(skill);
//				
//				if (m_defaultTargetUser == NULL || !m_defaultTargetUser->isVisiable()) {
//					if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
//						setBattleStatus(BS_CHOOSE_ENEMY_MAG_ATK);
//						
//						VEC_FIGHTER& enemyList = GetEnemySideList();
//						Fighter* f;
//						for (size_t i = 0; i < enemyList.size(); i++) {
//							f = enemyList.at(i);
//							if (f->isVisiable()) {
//								m_defaultTargetUser = f;
//								HighlightFighter(f);
//								break;
//							}
//						}
//						
//					} else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
//						setBattleStatus(BS_CHOOSE_OUR_SIDE_MAG_ATK);
//						
//						VEC_FIGHTER& ourList = GetOurSideList();
//						Fighter* f;
//						for (size_t i = 0; i < ourList.size(); i++) {
//							f = ourList.at(i);
//							if (f->isVisiable()) {
//								m_defaultTargetUser = f;
//								HighlightFighter(f);
//								break;
//							}
//						}
//					}
//				} else {
//					if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
//						setBattleStatus(BS_CHOOSE_ENEMY_MAG_ATK);
//						HighlightFighter(m_defaultTargetUser);
//						
//					} else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
//						setBattleStatus(BS_CHOOSE_OUR_SIDE_MAG_ATK);
//						HighlightFighter(m_defaultTargetUser);
//						
//					} else if ((targetType & SKILL_ATK_TYPE_SELF) == SKILL_ATK_TYPE_SELF) {
//						setBattleStatus(BS_CHOOSE_SELF_MAG_ATK);
//						HighlightFighter(m_defaultTargetUser);
//					}
//				}
//			}
//		}
//	}
}

void Battle::TurnStartPet()
{
//	if (m_bWatch || s_bAuto || m_bTurnStartPet == false) {
//		m_bTurnStartPet = false;
//		return;
//	}
//	
//	m_bTurnStartPet = false;
//	
//	Fighter* mainEudemon = getMainEudemon();
//	if (mainEudemon == NULL || mainEudemon->isEscape() || !mainEudemon->isAlive() || mainEudemon->isDieOK())
//	{
//		//		m_fighterRight->SetGray(true);
//		//		m_fighterLeft->SetGray(true);
//		return;
//	}
//	
//	// 捕捉按钮变灰
//	//	m_fighterRight->SetGray(true, 0);
//	
//	RefreshSkillBarPet();
//	
//	//	m_fighterLeft->SetPage(m_lastSkillPageEudemon);
//	
//	if (BATTLE_ACT_PET_PHY_ATK == m_defaultActionEudemon) {
//		if (m_defaultTargetEudemon == NULL || !m_defaultTargetEudemon->isVisiable()) {
//			OnEudemonAttack();
//			m_defaultTargetEudemon = m_highlightFighter;
//		} else {
//			OnEudemonAttack();
//			HighlightFighter(m_defaultTargetEudemon);
//		}
//		
//	} else if (BATTLE_ACT_PET_MAG_ATK == m_defaultActionEudemon) {
//		// 上回合宠物技能可用
//		if (m_defaultSkillIDEudemon > ID_NONE) {
//			m_curBattleAction->btAction = BATTLE_ACT_PET_MAG_ATK;
//			m_curBattleAction->vData.clear();
//			
//			s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_MAG_ATK;
//			s_lastTurnActionEudemon.vData.clear();
//			
//			m_curBattleAction->vData.push_back(m_defaultSkillIDEudemon);
//			s_lastTurnActionEudemon.vData.push_back(m_defaultSkillIDEudemon);
//			s_lastTurnActionEudemon.vData.push_back(0);
//			
//			BattleSkill* skill = BattleMgrObj.GetBattleSkill(m_defaultSkillIDEudemon);
//			if (skill) {
//				int targetType = skill->getAtkType();
//				
//				// 上回合目标死亡
//				if (m_defaultTargetUser == NULL || !m_defaultTargetUser->isVisiable()) {
//					if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
//						setBattleStatus(BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON);
//						
//						VEC_FIGHTER& enemyList = GetEnemySideList();
//						Fighter* f;
//						for (size_t i = 0; i < enemyList.size(); i++) {
//							f = enemyList.at(i);
//							if (f->isVisiable()) {
//								m_defaultTargetEudemon = f;
//								HighlightFighter(f);
//								break;
//							}
//						}
//						
//					} else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
//						setBattleStatus(BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON);
//						
//						VEC_FIGHTER& ourList = GetOurSideList();
//						Fighter* f;
//						for (size_t i = 0; i < ourList.size(); i++) {
//							f = ourList.at(i);
//							if (f->isVisiable()) {
//								m_defaultTargetEudemon = f;
//								HighlightFighter(f);
//								break;
//							}
//						}
//						
//					}
//				} else {
//					if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
//						setBattleStatus(BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON);
//						HighlightFighter(m_defaultTargetEudemon);
//						
//					} else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
//						setBattleStatus(BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON);
//						HighlightFighter(m_defaultTargetEudemon);
//						
//					} else if ((targetType & SKILL_ATK_TYPE_SELF) == SKILL_ATK_TYPE_SELF) {
//						setBattleStatus(BS_CHOOSE_SELF_MAG_ATK_EUDEMON);
//						HighlightFighter(m_defaultTargetEudemon);
//						
//					}
//				}
//			}
//		} else {
//			m_defaultActionEudemon = BATTLE_ACT_PET_PHY_ATK;
//			OnEudemonAttack();
//			m_defaultTargetEudemon = m_highlightFighter;
//		}
//	}
}

void Battle::RefreshSkillBarPet()
{
	// 获取宠物技能
	PetInfo* petInfo = PetMgrObj.GetMainPet(NDPlayer::defaultHero().m_nID);
	if (petInfo)
		return;

// 	SET_BATTLE_SKILL_LIST& petSkillList = PetMgrObj.GetSkillList(SKILL_TYPE_ATTACK, petInfo->data.int_PET_ID);
// 	SpeedBarInfo skillInfo;
// 	BattleMgr& bm = BattleMgrObj;
// 	BattleSkill* bs = NULL;
// 	SET_BATTLE_SKILL_LIST_IT itSkill = petSkillList.begin();
// 
// 	int nPetMp = getMainEudemon()->m_kInfo.nMana;
// 
// 	int nFocus = -1;
// 	for (int i = 0; i < MAX_SKILL_NUM; i++) {
// 		if (itSkill != petSkillList.end()) {
// 			skillInfo.push_back(SpeedBarCellInfo());
// 			SpeedBarCellInfo& ci = skillInfo.back();
// 			bs = bm.GetBattleSkill(*itSkill);
// 			if (bs) {
// 				ci.foreground = GetSkillIconByIconIndex(bs->getIconIndex(), true);;
// 
// 				ci.gray = bs->getMpRequire() > nPetMp;
// 				ci.param1 = bs->getId();
// 				ci.param2 = bs->getCd();
// 
// 				if (ci.param2 != 0 && !ci.gray)
// 				{
// 					CoolDownRecord_IT it = m_recordCoolDown.find(ci.param1);
// 					if (it != m_recordCoolDown.end())
// 						ci.gray = (it->second < ci.param2);
// 				}
// 
// 				// 上回合使用的技能
// 				if (m_defaultSkillIDEudemon == ci.param1 && !ci.gray) {
// 					nFocus = i;
// 				} else {
// 					// 上回合技能清零，表示该技能失效
// 					m_defaultSkillIDEudemon = ID_NONE;
// 				}
// 
// 			}
// 			itSkill++;
// 		}
// 	}

	//	m_fighterLeft->refresh(skillInfo);
	//	if (nFocus > -1 && !s_bAuto) {
	//		m_fighterLeft->SetFoucusByIndex(nFocus);
	//		m_fighterRight->defocus();
	//		m_fighterBottom->defocus();
	//	}

	//	if (m_fighterLeft)
	//		m_fighterLeft->DealSkillTurn();
}

void Battle::RefreshSkillBar()
{
	//SpeedBarInfo skillInfo;
	//
	//BattleMgr& bm = BattleMgrObj;
	//BattleSkill* bs = NULL;
	//SET_BATTLE_SKILL_LIST_IT itSkill = m_setBattleSkillList.begin();
	//
	//if (GetMainUser() == NULL) return;
	//
	//int nPlayerMp = GetMainUser()->m_kInfo.nMana;
	//
	//int nFocus = -1;
	//int i = 0;
	//for (; i < MAX_SKILL_NUM; i++) {
	//	if (itSkill != m_setBattleSkillList.end()) {
	//		skillInfo.push_back(SpeedBarCellInfo());
	//		SpeedBarCellInfo& ci = skillInfo.back();
	//		bs = bm.GetBattleSkill(*itSkill);
	//		if (bs && bs->getType() == SKILL_TYPE_ATTACK) {
	//			ci.foreground = GetSkillIconByIconIndex(bs->getIconIndex(), true);
	//			
	//			ci.gray = bs->getMpRequire() > nPlayerMp;
	//			ci.param1 = bs->getId();
	//			ci.param2 = bs->getCd();
	//			// 上回合使用的技能
	//			if (m_defaultSkillID == ci.param1 && !ci.gray) {
	//				nFocus = i;
	//			} else {
	//				m_defaultSkillID = ID_NONE;
	//			}
	//			
	//		}
	//		itSkill++;
	//	}
	//	else
	//	{
	//		break;
	//	}
	//}
	//
	//size_t size = skillInfo.size();
	//SET_BATTLE_SKILL_LIST& skills =  NDPlayer::defaultHero().GetSkillList(SKILL_TYPE_ATTACK);
	//if (size < size_t(MAX_SKILL_NUM) && skills.size() > 0)
	//{
	//	
	//	SET_BATTLE_SKILL_LIST_IT itSkill = skills.begin();
	//	for (; itSkill != skills.end(); itSkill++) {
	//		OBJID skillID = *itSkill;
	//		BattleSkill* bs = BattleMgrObj.GetBattleSkill(skillID);
	//		
	//		if (!bs || !bs->IsSkillOwnByPlayer()) continue;
	//		
	//		if (bs->getType() == SKILL_TYPE_PASSIVE) continue;
	//		
	//		if (m_setBattleSkillList.count(skillID) == 0 && size < size_t(MAX_SKILL_NUM)) {
	//			skillInfo.push_back(SpeedBarCellInfo());
	//			SpeedBarCellInfo& ci = skillInfo.back();
	//			ci.foreground = GetSkillIconByIconIndex(bs->getIconIndex(), true);
	//			
	//			ci.gray = true;
	//			ci.param1 = bs->getId();
	//			ci.param2 = bs->getCd();
	//			// 上回合使用的技能
	//			if (m_defaultSkillID == ci.param1) {
	//				m_defaultSkillID = ID_NONE;
	//			}
	//			
	//			size++;
	//		}
	//	}
	//}
	//
	//	m_fighterLeft->refresh(skillInfo);
	//	if (nFocus > -1 && !s_bAuto) {
	//		m_fighterLeft->SetFoucusByIndex(nFocus);
	//		m_fighterRight->defocus();
	//		m_fighterBottom->defocus();
	//	}
	//	
	//	if (m_recordCoolDown.size())
	//		m_fighterLeft->DealSkillTurn();
}

void Battle::RefreshItemBar()
{
	//SpeedBarInfo speedbarBottom;
	//
	//// 已经在物品栏中的物品类型
	//set<int> itemSet;
	//
	//// 战斗内可用物品集合
	//ItemMgr& rItemMgr = ItemMgrObj;
	//VEC_ITEM vBagItems;
	//rItemMgr.GetBattleUsableItem(vBagItems);
	//
	//// 战斗内物品栏设置
	//NDItemBarDataPersist& itemBarSetting = NDItemBarDataPersist::DefaultInstance();
	//VEC_ITEM_BAR_CELL vItemSetting;
	//itemBarSetting.GetItemBarConfigInBattle(NDPlayer::defaultHero().m_id, vItemSetting);
	//
	//Item* pItem = NULL;
	//
	//VEC_ITEM_BAR_CELL::iterator itItemSetting = vItemSetting.begin();
	//for (int i = 0; i < 15; i++) {
	//	speedbarBottom.push_back(SpeedBarCellInfo());
	//	SpeedBarCellInfo& cellinfo = speedbarBottom.back();
	//	//cellinfo.index = i;
	//	
	//	// 如果该格有配置，则用配置的物品图标
	//	if (itItemSetting != vItemSetting.end()) {
	//		ItemBarCellInfo& cell = *itItemSetting;
	//		if (cell.nPos == i && cell.idItemType > 0) {
	//			cellinfo.foreground = ItemImage::GetItemPicByType(cell.idItemType, true, true);
	//			cellinfo.gray = (rItemMgr.GetBagItemByType(cell.idItemType) == NULL);
	//			cellinfo.param1 = cell.idItemType;
	//			itemSet.insert(cell.idItemType);
	//		}
	//		itItemSetting++;
	//	}
	//}
	//
	//// 遍历战斗内可使用物品
	//m_mapUseItem.clear();
	//MAP_USEITEM_IT itUseItem;
	//
	//SpeedBarInfo::iterator it = speedbarBottom.begin();
	//for (VEC_ITEM::iterator itItem = vBagItems.begin(); itItem != vBagItems.end(); itItem++) {
	//	pItem = *itItem;
	//	if (!pItem) {
	//		continue;
	//	}
	//	
	//	itUseItem = m_mapUseItem.find(pItem->iItemType);
	//	if (itUseItem != m_mapUseItem.end()) {
	//		itUseItem->second.second += pItem->iAmount;
	//	} else {
	//		m_mapUseItem[pItem->iItemType] = make_pair(pItem->iID, pItem->iAmount);
	//	}
	//	
	//	if (itemSet.count(pItem->iItemType) == 0) {
	//		// 查找空白栏位
	//		for (; it != speedbarBottom.end(); it++) {
	//			if ((*it).foreground == NULL) {
	//				itemSet.insert(pItem->iItemType);
	//				(*it).param1 = pItem->iItemType;
	//				(*it).foreground = ItemImage::GetItemPicByType(pItem->iItemType, true, true);
	//				(*it).gray = false;
	//				it++;
	//				break;
	//			}
	//		}
	//	}
	//}

	//	m_fighterBottom->refresh(speedbarBottom);
}

//快捷栏
// Battle::speed bar
void Battle::InitSpeedBar()
{
	if (m_bWatch)
	{
		return;
	}

	//	m_fighterBottom = new FighterBottom;
	//	m_fighterBottom->Initialization();
	//	m_fighterBottom->SetDelegate(this);
	//	
	//	if (s_bAuto) {
	//		RefreshItemBar();
	//	}
	//	
	//	AddChild(m_fighterBottom);

	//	m_fighterLeft = new FighterLeft;
	//	m_fighterLeft->Initialization();
	//	m_fighterLeft->SetDelegate(this);
	//	
	//	if (s_bAuto) {
	//		RefreshSkillBar();
	//	}
	//	
	//	AddChild(m_fighterLeft);
	//	
	//	//AddChild(m_btnQuickTalk);
	//
	//	m_fighterRight = new FighterRight;
	//	m_fighterRight->SetDelegate(this);
	//	m_fighterRight->Initialization();

// 	SpeedBarInfo speedbarRight;
// 
// 	// 捕捉
// 	speedbarRight.push_back(SpeedBarCellInfo());
// 	SpeedBarCellInfo& ciCatch = speedbarRight.back();
// 	NDPicture* pic = new NDPicture(true);
// 	pic->Initialization(NDPath::GetImgPathBattleUI("menucatch.png").c_str());
// 	ciCatch.foreground = pic;
// 	ciCatch.param1 = CELL_TAG_CATCH;
// 
// 	// 逃跑
// 	speedbarRight.push_back(SpeedBarCellInfo());
// 	SpeedBarCellInfo& ciFlee = speedbarRight.back();
// 	pic = new NDPicture(true);
// 	pic->Initialization(NDPath::GetImgPathBattleUI("menuescape.png").c_str());
// 	ciFlee.foreground = pic;
// 	ciFlee.param1 = CELL_TAG_FLEE;
// 
// 	// 防御
// 	speedbarRight.push_back(SpeedBarCellInfo());
// 	SpeedBarCellInfo& ciDef = speedbarRight.back();
// 	pic = new NDPicture(true);
// 	pic->Initialization(NDPath::GetImgPathBattleUI("menudefence.png").c_str());
// 	ciDef.foreground = pic;
// 	ciDef.param1 = CELL_TAG_DEF;
// 
// 	// 攻击
// 	speedbarRight.push_back(SpeedBarCellInfo());
// 	SpeedBarCellInfo& ciAtk = speedbarRight.back();
// 	pic = new NDPicture(true);
// 	pic->Initialization(NDPath::GetImgPathBattleUI("menuattack.png").c_str());
// 	ciAtk.foreground = pic;
// 	ciAtk.param1 = CELL_TAG_ATK;
// 
// 	// 查看
// 	speedbarRight.push_back(SpeedBarCellInfo());
// 	SpeedBarCellInfo& ciViewStatus = speedbarRight.back();
// 	pic = new NDPicture(true);
// 	pic->Initialization(NDPath::GetImgPathBattleUI("menuwatch.png").c_str());
// 	ciViewStatus.foreground = pic;
// 	ciViewStatus.param1 = CELL_TAG_VIEWSTATUS;

	//	m_fighterRight->refresh(speedbarRight);
	//	
	//	AddChild(m_fighterRight);
}
//
//void Battle::OnNDUISpeedBarEvent(NDUISpeedBar* speedbar, const SpeedBarCellInfo& info, bool focused)
//{
//	static double begin = [NSDate timeIntervalSinceReferenceDate];
//	static bool   first = true;
//	
//	double end = [NSDate timeIntervalSinceReferenceDate];
//	
//	if (!first)
//	{
//		if (int((end-begin)*1000) < 300)
//		{
//#if ND_DEBUG_STATE == 1
//			std::stringstream ss;
//			ss << "战斗gui太快了[" << int((end-begin)*1000) << "]毫秒";
//			Chat::DefaultChat()->AddMessage(ChatTypeSystem, ss.str().c_str());
//#endif
//			begin = end;
//			return;
//		}
//	}
//	else
//	{
//		first = false;
//	}
//	
//	begin = end;
//	
//	//	if (speedbar == m_fighterLeft) 
//	//	{
//	//		if (info.param1 > 0) {
//	//			if (IsUserOperating()) {
//	//				if (focused) {
//	//					NDTouch touch;
//	//					TouchEnd(&touch);
//	//					
//	//				} else {
//	//					m_curBattleAction->vData.clear();
//	//					m_curBattleAction->btAction = BATTLE_ACT_MAG_ATK;
//	//					
//	//					s_lastTurnActionUser.btAction = BATTLE_ACT_MAG_ATK;
//	//					s_lastTurnActionUser.vData.clear();
//	//					
//	//					m_defaultActionUser = BATTLE_ACT_MAG_ATK;
//	//					m_defaultSkillID = info.param1;
//	//					
//	//					m_curBattleAction->vData.push_back(info.param1);
//	//					s_lastTurnActionUser.vData.push_back(info.param1);
//	//					s_lastTurnActionUser.vData.push_back(0);
//	//					
//	//					BattleSkill* skill = BattleMgrObj.GetBattleSkill(info.param1);
//	//					if (skill && GetMainUser()) {
//	//						int targetType = skill->getAtkType();
//	//						GetMainUser()->setUseSkill(skill);
//	//						
//	//						if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
//	//							setBattleStatus(BS_CHOOSE_ENEMY_MAG_ATK);
//	//							VEC_FIGHTER& enemyList = GetEnemySideList();
//	//							Fighter* f;
//	//							for (size_t i = 0; i < enemyList.size(); i++) {
//	//								f = enemyList.at(i);
//	//								if (f->isVisiable()) {
//	//									m_defaultTargetUser = f;
//	//									HighlightFighter(f);
//	//									break;
//	//								}
//	//							}
//	//							
//	//						} else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
//	//							setBattleStatus(BS_CHOOSE_OUR_SIDE_MAG_ATK);
//	//							
//	//							VEC_FIGHTER& ourList = GetOurSideList();
//	//							Fighter* f;
//	//							for (size_t i = 0; i < ourList.size(); i++) {
//	//								f = ourList.at(i);
//	//								if (f->isVisiable()) {
//	//									m_defaultTargetUser = f;
//	//									HighlightFighter(f);
//	//									break;
//	//								}
//	//							}
//	//							
//	//						} else if ((targetType & SKILL_ATK_TYPE_SELF) == SKILL_ATK_TYPE_SELF) {
//	//							m_defaultTargetUser = GetMainUser();
//	//							m_curBattleAction->vData.push_back(GetMainUser()->m_kInfo.idObj);
//	//							SendBattleAction(*m_curBattleAction);
//	//							
//	//						}
//	//					}
//	//				}
//	//				
//	//			} else if (IsEudemonOperating()) {
//	//				if (focused) {
//	//					NDTouch touch;
//	//					TouchEnd(&touch);
//	//					
//	//				} else {
//	//					m_curBattleAction->btAction = BATTLE_ACT_PET_MAG_ATK;
//	//					
//	//					s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_MAG_ATK;
//	//					s_lastTurnActionEudemon.vData.clear();
//	//					
//	//					m_defaultActionEudemon = BATTLE_ACT_PET_MAG_ATK;
//	//					m_defaultSkillIDEudemon = info.param1;
//	//					
//	//					m_curBattleAction->vData.push_back(info.param1);
//	//					s_lastTurnActionEudemon.vData.push_back(info.param1);
//	//					s_lastTurnActionEudemon.vData.push_back(0);
//	//					
//	//					BattleSkill* skill = BattleMgrObj.GetBattleSkill(info.param1);
//	//					if (skill) {
//	//						if (getMainEudemon()->m_kInfo.nMana >= skill->getMpRequire()) {
//	//							int targetType = skill->getAtkType();
//	//							
//	//							if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
//	//								setBattleStatus(BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON);
//	//								
//	//								VEC_FIGHTER& enemyList = GetEnemySideList();
//	//								Fighter* f;
//	//								for (size_t i = 0; i < enemyList.size(); i++) {
//	//									f = enemyList.at(i);
//	//									if (f->isVisiable()) {
//	//										m_defaultTargetEudemon = f;
//	//										HighlightFighter(f);
//	//										break;
//	//									}
//	//								}
//	//								
//	//							} else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
//	//								setBattleStatus(BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON);
//	//								
//	//								VEC_FIGHTER& ourList = GetOurSideList();
//	//								Fighter* f;
//	//								for (size_t i = 0; i < ourList.size(); i++) {
//	//									f = ourList.at(i);
//	//									if (f->isVisiable()) {
//	//										m_defaultTargetEudemon = f;
//	//										HighlightFighter(f);
//	//										break;
//	//									}
//	//								}
//	//								
//	//							} else if ((targetType & SKILL_ATK_TYPE_SELF) == SKILL_ATK_TYPE_SELF) {
//	//								m_defaultTargetEudemon = getMainEudemon();
//	//								m_curBattleAction->vData.push_back(getMainEudemon()->m_kInfo.idObj);
//	//								SendBattleAction(*m_curBattleAction);
//	//								
//	//							}
//	//						}
//	//					}
//	//				}
//	//			}
//	//		}
//	//	}
//	//	else if (speedbar == m_fighterBottom) 
//	//	{
//	//		if (info.param1 > 0) {
//	//			if (IsUserOperating()) {
//	//				if (focused) {
//	//					NDTouch touch;
//	//					TouchEnd(&touch);
//	//				} else {
//	//					m_curBattleAction->btAction = BATTLE_ACT_USEITEM;
//	//					setBattleStatus(BS_CHOOSE_OUR_SIDE_USE_ITEM_USER);
//	//				}
//	//				
//	//			} else if (IsEudemonOperating()) {
//	//				if (focused) {
//	//					NDTouch touch;
//	//					TouchEnd(&touch);
//	//				} else {
//	//					m_curBattleAction->btAction = BATTLE_ACT_PET_USEITEM;
//	//					setBattleStatus(BS_CHOOSE_OUR_SIDE_USE_ITEM_EUDEMON);
//	//				}
//	//			}
//	//			
//	//			if (m_battleStatus == BS_CHOOSE_OUR_SIDE_USE_ITEM_USER || m_battleStatus == BS_CHOOSE_OUR_SIDE_USE_ITEM_EUDEMON) {
//	//				m_curBattleAction->vData.clear();
//	//				
//	//				MAP_USEITEM_IT it = m_mapUseItem.find(info.param1);
//	//				
//	//				if (it != m_mapUseItem.end()) {
//	//					m_curBattleAction->vData.push_back(it->second.first);
//	//				}
//	//				
//	//				VEC_FIGHTER& ourSideList = GetOurSideList();
//	//				Fighter* f;
//	//				for (size_t i = 0; i < ourSideList.size(); i++) {
//	//					f = ourSideList.at(i);
//	//					if (f->isVisiable()) {
//	//						HighlightFighter(f);
//	//						break;
//	//					}
//	//				}
//	//			}
//	//		}
//	//	}
//	//	else if (speedbar == m_fighterRight) 
//	//	{
//	//		switch (info.param1) {
//	//			case CELL_TAG_ATK:
//	//				if (IsUserOperating()) {
//	//					if (focused) {
//	//						NDTouch touch;
//	//						TouchEnd(&touch);
//	//					} else {
//	//						stopAuto();
//	//						OnBtnAttack();
//	//						m_defaultActionUser = BATTLE_ACT_PHY_ATK;
//	//						m_defaultTargetUser = m_highlightFighter;
//	//					}
//	//				} else if (IsEudemonOperating()) {
//	//					if (focused) {
//	//						NDTouch touch;
//	//						TouchEnd(&touch);
//	//					} else {
//	//						OnEudemonAttack();
//	//						m_defaultActionEudemon = BATTLE_ACT_PET_PHY_ATK;
//	//						m_defaultTargetEudemon = m_highlightFighter;
//	//					}
//	//				}
//	//				break;
//	//			case CELL_TAG_DEF:
//	//				if (IsUserOperating()) {
//	//					stopAuto();
//	//					OnBtnDefence();
//	//				} else if (IsEudemonOperating()) {
//	//					BattleAction actioin(BATTLE_ACT_PET_PHY_DEF);
//	//					s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_PHY_DEF;
//	//					SendBattleAction(actioin);
//	//				}
//	//				break;
//	//			case CELL_TAG_CATCH:
//	//				if (IsUserOperating()) {
//	//					if (focused) {
//	//						NDTouch touch;
//	//						TouchEnd(&touch);
//	//					} else {
//	//						stopAuto();
//	//						OnBtnCatch();
//	//					}
//	//				}
//	//				break;
//	//			case CELL_TAG_FLEE:
//	//				if (IsUserOperating()) {
//	//					stopAuto();
//	//					OnBtnRun();
//	//				} else if (IsEudemonOperating()) {
//	//					BattleAction actioin(BATTLE_ACT_PET_ESCAPE);
//	//					SendBattleAction(actioin);
//	//				}
//	//				break;
//	//			case CELL_TAG_VIEWSTATUS:
//	//			{
//	//				if (focused) {
//	//					NDTouch touch;
//	//					TouchEnd(&touch);
//	//				} else {
//	//					Fighter* f = NULL;
//	//					VEC_FIGHTER& enemyList = GetEnemySideList();
//	//					for (VEC_FIGHTER_IT it = enemyList.begin(); it != enemyList.end(); it++) {
//	//						if ((*it)->isVisiable()) {
//	//							f = *it;
//	//							break;
//	//						}
//	//					}
//	//					
//	//					if (IsUserOperating()) {
//	//						setBattleStatus(BS_CHOOSE_VIEW_FIGHTER_STATUS);
//	//						HighlightFighter(f);
//	//					} else if (IsEudemonOperating()) {
//	//						setBattleStatus(BS_CHOOSE_VIEW_FIGHTER_STATUS_PET);
//	//						HighlightFighter(f);
//	//					}
//	//				}
//	//
//	//			}
//	//				break;
//	//			default:
//	//				break;
//	//		}
//	//	}
//	
//	//	if(speedbar != m_fighterLeft)
//	//	{
//	//		m_fighterLeft->defocus();
//	//	}
//	//	
//	//	if(speedbar != m_fighterRight)
//	//	{
//	//		m_fighterRight->defocus();
//	//	}
//	//	
//	//	if(speedbar != m_fighterBottom)
//	//	{
//	//		m_fighterBottom->defocus();
//	//	}
//}
//
//void Battle::OnNDUISpeedBarSet(NDUISpeedBar* speedbar)
//{
//	//	if (speedbar == m_fighterBottom) 
//	//	{
//	//		if (m_bShowChatTextField) {
//	//			ShowChatTextField(false);
//	//			m_bChatTextFieldShouldShow = true;
//	//		}
//	//		
//	//		// 物品设置后，切换为普通攻击
//	//		if (IsUserOperating()) {
//	//			OnBtnAttack();
//	//		} else if (IsEudemonOperating()) {
//	//			OnEudemonAttack();
//	//		}
//	//		
//	//		GameUIItemConfig *config = new GameUIItemConfig;
//	//		config->Initialization();
//	//		config->SetDelegate(this);
//	//		AddChild(config, 97);
//	//	}
//}
//
//void Battle::OnNDUISpeedBarShrinkClick(NDUISpeedBar* speedbar, bool fromShrnk)
//{
//	//	if (m_fighterRight == speedbar) {
//	//		m_bShrinkRight = !fromShrnk;
//	//	} else if (m_fighterLeft == speedbar) {
//	//		m_bShrinkLeft = !fromShrnk;
//	//	} else if (m_fighterBottom == speedbar) {
//	//		m_bShrinkBottom = !fromShrnk;
//	//	}
//}
//
//
//void Battle::OnRefreshFinish(NDUISpeedBar* speedbar, unsigned int page)
//{
//	//	if (speedbar == m_fighterLeft) {
//	//		if (IsUserOperating()) {
//	//			m_lastSkillPageUser = page;
//	//		} else if (IsEudemonOperating()) {
//	//			m_lastSkillPageEudemon = page;
//	//		}
//	//	}
//}
//
//void Battle::OnNDUISpeedBarEventLongTouch(NDUISpeedBar* speedbar, const SpeedBarCellInfo& info)
//{
//	//	if (speedbar == m_fighterLeft) 
//	//	{
//	//		BattleSkill*bs = BattleMgrObj.GetBattleSkill(info.param1);
//	//		
//	//		if (bs)
//	//			showDialog("", bs->getFullDes().c_str());
//	//	}
//	//	else if (speedbar == m_fighterBottom)
//	//	{
//	//		NDItemType* itemtype = ItemMgrObj.QueryItemType(info.param1);
//	//		
//	//		if (!itemtype) return;
//	//		
//	//		Item item(info.param1);
//	//		
//	//		showDialog(item.getItemNameWithAdd().c_str(), item.makeItemDes(false, true).c_str());
//	//	}
//}

void Battle::OnItemConfigFinish()
{
	RefreshItemBar();
	if (m_bChatTextFieldShouldShow)
	{
		ShowChatTextField(true);
	}
}

bool Battle::IsUserOperating()
{
//	switch (m_battleStatus) {
//		case BS_CHOOSE_VIEW_FIGHTER_STATUS:
//		case BS_CHOOSE_ENEMY_PHY_ATK:
//		case BS_CHOOSE_ENEMY_MAG_ATK:
//		case BS_CHOOSE_OUR_SIDE_MAG_ATK:
//		case BS_CHOOSE_ENEMY_CATCH:
//		case BS_CHOOSE_OUR_SIDE_USE_ITEM_USER:
//			return true;
//			break;
//		default:
//			return false;
//			break;
//	}
	return false;
}

bool Battle::IsEudemonOperating()
{
//	switch (m_battleStatus) {
//		case BS_CHOOSE_VIEW_FIGHTER_STATUS_PET:
//		case BS_CHOOSE_ENEMY_PHY_ATK_EUDEMON:
//		case BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON:
//		case BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON:
//		case BS_CHOOSE_OUR_SIDE_USE_ITEM_EUDEMON:
//			return true;
//			break;
//		default:
//			return false;
//			break;
//	}
	return false;
}

bool Battle::OnRoleDisapper(int iRoleID)
{
	bool ret = false;

	VEC_FIGHTER_IT it = m_vActionFighterList.begin();

	for (size_t index = 0; it != m_vActionFighterList.end(); it++, index++)
	{
		Fighter* f = *it;

		if (f->GetRole() && f->GetRole()->m_nID == iRoleID)
		{

			size_t idx = m_actionFighterPoint;

			if (idx == index)
			{
				m_vActionFighterList.erase(it);

				if (m_vActionFighterList.size())
				{
					m_actionFighterPoint = (index + 1)
							% m_vActionFighterList.size();

					if (m_actionFighterPoint
							< int(m_vActionFighterList.size()))
					{
						m_vActionFighterList[m_actionFighterPoint]->setActionOK(
								true);
					}
				}
			}
			else
			{
				m_vActionFighterList.erase(it);
			}

			ret = true;

			break;
		}
	}

	for (it = m_vAttaker.begin(); it != m_vAttaker.end(); it++)
	{
		Fighter* f = *it;
		if (f->GetRole() && f->GetRole()->m_nID == iRoleID)
		{
			CC_SAFE_DELETE(*it);
			m_vAttaker.erase(it);
			return true;
		}
	}

	for (it = m_vDefencer.begin(); it != m_vDefencer.end(); it++)
	{
		Fighter* f = *it;
		if (f->GetRole() && f->GetRole()->m_nID == iRoleID)
		{
			CC_SAFE_DELETE(*it);
			m_vDefencer.erase(it);
			return true;
		}
	}

	if (m_mainFighter && m_mainFighter->GetRole()
			&& m_mainFighter->GetRole()->m_nID == iRoleID)
	{
		m_mainFighter = NULL;
		ret = true;
	}

	return ret;
}

bool Battle::CanPetFreeUseSkill()
{
	if (m_battleType == BATTLE_TYPE_MONSTER
			|| m_battleType == BATTLE_TYPE_ELITE_MONSTER
			|| m_battleType == BATTLE_TYPE_NPC
			|| m_battleType == BATTLE_TYPE_PRACTICE)
		return true;

	return false;
}

void Battle::UseSkillDealOfCooldown(int skillID)
{
	BattleSkill *bs = BattleMgrObj.GetBattleSkill(skillID);

	if (!bs || bs->getCd() == 0)
		return;

	CoolDownRecord_IT it = m_recordCoolDown.find(skillID);

	m_recordCoolDown[skillID] = -1;
}

void Battle::AddTurnDealOfCooldown()
{
	/*
	 MAP_BATTLE_SKILL& skills = BattleMgrObj.GetBattleSkills();
	 
	 for (MAP_BATTLE_SKILL_IT it = skills.begin(); it != skills.end(); it++) {
	 BattleSkill* bs = it->second;
	 CoolDownID skillID = CoolDownID(it->first);
	 if (bs->getCd() != 0 && 
	 m_recordCoolDown.find(skillID) == m_recordCoolDown.end()) {
	 m_recordCoolDown[skillID] = 0;
	 }
	 }
	 */

	CoolDownRecord_IT it = m_recordCoolDown.begin();

	for (; it != m_recordCoolDown.end(); it++)
	{
		if (m_turn > 1)
			m_recordCoolDown[it->first] = m_recordCoolDown[it->first] + 1;
	}

	//if (m_fighterLeft && m_recordCoolDown.size())
	//m_fighterLeft->DealSkillTurn();
}

void Battle::setBattleStatus(BATTLE_STATUS status)
{
	if (status == m_battleStatus)
		return;

	m_battleStatus = status;
}

void Battle::SetBattleOver(void)
{
	m_Team1_status=TEAM_OVER;  
	m_Team2_status=TEAM_OVER;
	m_Team3_status=TEAM_OVER;
}
