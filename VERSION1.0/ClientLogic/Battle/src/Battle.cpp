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
///< #include "NDMapMgr.h" 临时性注释 郭浩

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
#include "NDPath.h"
#include "GlobalDialog.h"

IMPLEMENT_CLASS(QuickTalkCell, NDUINode)

QuickTalkCell::QuickTalkCell()
{
	m_clrFocus = ccc4(9, 54, 55, 255);
	m_clrText = ccc4(155, 255, 255, 255);
	m_clrFocusText = ccc4(249, 229, 64, 255);
	m_lbText = NULL;
}

QuickTalkCell::~QuickTalkCell()
{
	
}

void QuickTalkCell::Initialization(const char* pszText, const CGSize& size)
{
	NDUINode::Initialization();
	
	NDUIImage* img = new NDUIImage;
	img->Initialization();
	NDPicture* pic = new NDPicture;
	pic->Initialization(NDPath::GetImgPathBattleUI("chat_icon_sys.png"));
	img->SetPicture(pic, true);
	img->SetFrameRect(CGRectMake(3.0f, 9.0f, 9.0f, 9.0f));
	this->AddChild(img);
	
	img = new NDUIImage;
	img->Initialization();
	pic = new NDPicture;
	pic->Initialization(NDPath::GetImgPathBattleUI("battle_chat_line.png"), 10, 1);
	img->SetPicture(pic, true);
	img->SetFrameRect(CGRectMake(0.0f, size.height - 6.0f, size.width, 2.0f));
	this->AddChild(img);
	
	CGRect rectText = CGRectMake(15.0f, 5.0f, size.width - 15.0f, size.height - 7.0f);
	
	m_lbText = new NDUILabel;
	m_lbText->Initialization();
	m_lbText->SetFontSize(13);
	m_lbText->SetFontColor(m_clrText);
	m_lbText->SetText(pszText);
	m_lbText->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbText->SetFrameRect(rectText);
	this->AddChild(m_lbText);
}

void QuickTalkCell::draw()
{
	NDNode* parentNode = this->GetParent();

	if (parentNode && parentNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
	{
		NDUILayer* uiLayer = (NDUILayer*)parentNode;

		if (uiLayer->GetFocus() == this) 
		{ // 当前处于焦点,绘制焦点色
			//DrawRecttangle(this->GetScreenRect(), m_clrFocus); ///< 临时性注释 郭浩
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
	if (m_lbText) {
		return m_lbText->GetText();
	}
	
	return "";
}


IMPLEMENT_CLASS(HighlightTipStatusBar, NDUINode)
IMPLEMENT_CLASS(HighlightTip, NDUILayer)

HighlightTip::HighlightTip()
{
	m_picBubble = NULL;
	m_hpBar = NULL;
	m_mpBar = NULL;
}
HighlightTip::~HighlightTip()
{
	CC_SAFE_DELETE(m_picBubble);
}

void HighlightTip::Initialization()
{
	NDUILayer::Initialization();
	
	m_picBubble = new NDPicture;
	m_picBubble->Initialization(NDPath::GetImgPath("ui_map.png"), 70, 60);
	
	NDUIImage* pImgBubble = new NDUIImage;
	pImgBubble->Initialization();
	pImgBubble->SetFrameRect(CGRectMake(0, 0, m_picBubble->GetSize().width, m_picBubble->GetSize().height));
	pImgBubble->SetPicture(m_picBubble, false);
	this->AddChild(pImgBubble);
	
	NDUIImage* imgHp = new NDUIImage;
	imgHp->Initialization();
	NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("hp.png"));
	imgHp->SetPicture(pic);
	imgHp->SetFrameRect(CGRectMake(2, 20, pic->GetSize().width, pic->GetSize().height));
	this->AddChild(imgHp);
	
	NDUIImage* imgMp = new NDUIImage;
	imgMp->Initialization();
	pic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("mp.png"));
	imgMp->SetPicture(pic);
	imgMp->SetFrameRect(CGRectMake(2, 35, pic->GetSize().width, pic->GetSize().height));
	this->AddChild(imgMp);
	
	m_hpBar = new HighlightTipStatusBar(0xC7321A);
	m_hpBar->Initialization();
	this->AddChild(m_hpBar);
	
	m_mpBar = new HighlightTipStatusBar(0x3C4ACF);
	m_mpBar->Initialization();
	this->AddChild(m_mpBar);
	
	this->m_imgNumHp = new ImageNumber;
	m_imgNumHp->Initialization();
	m_imgNumHp->SetFrameRect(CGRectMake(16, 25, 40, 10));
	this->AddChild(m_imgNumHp);
	
	this->m_imgNumMp = new ImageNumber;
	m_imgNumMp->Initialization();
	m_imgNumMp->SetFrameRect(CGRectMake(16, 43, 40, 10));
	this->AddChild(m_imgNumMp);
	
	this->EnableEvent(false);
}

void HighlightTip::SetFighter(Fighter* f)
{
	if (!f) {
		return;
	}
	
	NDBaseRole* role = f->GetRole();
	CGPoint pt = CGPointMake(f->getX(), f->getY());
	
	CGRect rect = CGRectMake(pt.x, pt.y, m_picBubble->GetSize().width, m_picBubble->GetSize().height);
	
	rect.origin.x -= rect.size.width / 2;

	if (rect.origin.x < 0)
	{
		rect.origin.x = 0;
	}
	
	rect.origin.y = rect.origin.y - role->GetHeight() - rect.size.height;

	if (rect.origin.y < 0)
	{
		rect.origin.y = 0;
	}
	
	this->SetFrameRect(rect);
	
	m_hpBar->SetNum(f->m_info.nLife, f->m_info.nLifeMax);
	m_hpBar->SetFrameRect(CGRectMake(rect.origin.x + 16, rect.origin.y + 20, 40, 10));
	m_imgNumHp->SetSmallRedTwoNumber(f->m_info.nLife, f->m_info.nLifeMax);
	
	m_mpBar->SetNum(f->m_info.nMana, f->m_info.nManaMax);
	m_mpBar->SetFrameRect(CGRectMake(rect.origin.x + 16, rect.origin.y + 38, 40, 10));
	m_imgNumMp->SetSmallRedTwoNumber(f->m_info.nMana, f->m_info.nManaMax);
	
	NDUILabel* name = (NDUILabel*)this->GetChild(TAG_NAME);

	if (!name)
	{
		name = new NDUILabel;
		name->SetFontColor(ccc4(255, 255, 255, 255));
		name->Initialization();
		name->SetTag(TAG_NAME);
		this->AddChild(name);
	}
	std::stringstream ss; ss << role->m_name << "Lv" << role->m_nLevel;
	//	if (f->m_info.fighterType == Fighter_TYPE_RARE_MONSTER)
	//	{
	//		ss << "【" << NDCommonCString("xiyou") << "】"; 
	//	}
	name->SetText(ss.str().c_str());
	CGSize sizeName = getStringSize(ss.str().c_str(), 15);
	name->SetFrameRect(CGRectMake((rect.size.width - sizeName.width) / 2,
		0, sizeName.width, sizeName.height));
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

const char* TEXT_VIEW_STATUS = NDCommonCString("ViewState");

bool Battle::s_bAuto = false;
BattleAction Battle::s_lastTurnActionUser(BATTLE_ACT_PHY_ATK);
BattleAction Battle::s_lastTurnActionEudemon(BATTLE_ACT_PET_PHY_ATK);

IMPLEMENT_CLASS(Battle, NDUILayer)

void Battle::ResetLastTurnBattleAction()
{
	s_bAuto = false;
	s_lastTurnActionUser.btAction = BATTLE_ACT_PHY_ATK;
	s_lastTurnActionUser.vData.clear();
	s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_PHY_ATK;
	s_lastTurnActionEudemon.vData.clear();
}

Battle::Battle()
{
	this->Init();
}

Battle::Battle(Byte btType)
{
	this->Init();
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
	
	this->CloseChatInput();
	//[m_chatDelegate release];
	if (eraseInOutEffect)
	{
		NDEraseInOutEffect *eioEffect = eraseInOutEffect.Pointer();
		SAFE_DELETE_NODE(eioEffect);
	}
	CC_SAFE_DELETE(m_picActionWordDef);
	CC_SAFE_DELETE(m_picActionWordDodge);
	CC_SAFE_DELETE(m_picActionWordFlee);
	CC_SAFE_DELETE(m_battleBg);
	
	//	SAFE_DELETE(m_picTalk);
	//	SAFE_DELETE(m_picQuickTalk);
	//	SAFE_DELETE(m_picAuto);
	//	SAFE_DELETE(m_picAutoCancel);
	//	SAFE_DELETE(m_picLeave);
	
	// 设置战斗状态
	NDPlayer::defaultHero().UpdateState(USERSTATE_FIGHTING, false);
	
	CC_SAFE_DELETE(m_curBattleAction);
	
	if (m_dlgBattleResult) {
		m_dlgBattleResult->RemoveFromParent(true);
	}
	//	if(m_orignalMapId!=NDMapMgrObj.m_iMapID){
	//		NDMapMgrObj.loadSceneByMapID(m_orignalMapId);
	//		NDMapMgrObj.AddAllNpcToMap();
	//		NDMapMgrObj.AddAllMonsterToMap();
	//	}
	NDDirector* director = NDDirector::DefaultDirector();
//	director->PopScene(true);
	GameScene* gameScene = (GameScene*)director->GetRunningScene();

	
	/***
	* 临时性注释 郭浩 begin
	*/
// 	NDMapLayer* mapLayer = NDMapMgrObj.getMapLayerOfScene(gameScene);
// 	if (mapLayer) {
// 		//		mapLayer->SetScreenCenter(m_orignalPos);
// 		//mapLayer->SetBattleBackground(false);
// 		mapLayer->replaceMapData(sceneMapId, sceneCenterX, sceneCenterY);
// 		ScriptMgrObj.excuteLuaFunc("SetUIVisible", "",1);
// 		int theId=NDMapMgrObj.GetMotherMapID();
// 		if(theId/100000000==9){
// 			ScriptMgrObj.excuteLuaFunc("showDynMapUI", "",0);
// 		}else{
// 			ScriptMgrObj.excuteLuaFunc("showCityMapUI", "",0);
// 		}
// 		//		mapLayer->AddChild(&(NDPlayer::defaultHero()));
// 	}

	/***
	* 临时性注释 郭浩
	* end
	*/

	gameScene->OnBattleEnd();
	//	if (m_btnLeave) {
	//		this->RemoveChild(m_btnLeave, false);
	//		SAFE_DELETE(m_btnLeave);
	//	}
	
	//	if (m_battleOpt) {
	//		this->RemoveChild(m_battleOpt, false);
	//		SAFE_DELETE(m_battleOpt);
	//	}
	//	if (m_eudemonOpt) {
	//		this->RemoveChild(m_eudemonOpt, false);
	//		SAFE_DELETE(m_eudemonOpt);
	//	}
	
	//	SAFE_DELETE(m_picWhoAmI);
	//	SAFE_DELETE(m_picLingPai);
	CC_SAFE_DELETE(m_picBaoJi);
	//	SAFE_DELETE(m_picBoji);
	
	//	if (s_bAuto) {
	//		this->RemoveChild(m_lbAuto, false);
	//		this->RemoveChild(m_imgAutoCount, false);
	//		SAFE_DELETE(m_imgAutoCount);
	//		SAFE_DELETE(m_lbAuto);
	//	}
	
	this->ReleaseCommandList();
	
	for (VEC_FIGHTER_IT it = m_vAttaker.begin(); it != m_vAttaker.end(); it++)
	{
		Fighter* fighter = *it;
		fighter->GetRole()->RemoveFromParent(false);
	}
	
	for (VEC_FIGHTER_IT it = m_vDefencer.begin(); it != m_vDefencer.end(); it++)
	{
		Fighter* fighter = *it;
		fighter->GetRole()->RemoveFromParent(false);
	}
	
	for (VEC_SUB_ANI_GROUP_IT it = this->m_vSubAniGroup.begin();
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
			((GameScene*)gameScene)->ShowRelieve(true);
		}
	}
	else
	{
		// 使用自动恢复药
		if (player.m_nLife < player.m_nMaxLife || player.m_nMana < player.m_nMaxMana)
		{
			ItemMgr& items = ItemMgrObj;
			Item* recover = items.GetBagItemByType(IT_RECOVER);

			if (recover && recover->active)
			{
				sendItemUse(*recover);
			}
		}
	}
	
	//if (player.IsInState(USERSTATE_BF_WAIT_RELIVE))
	//{
	//	BattleFieldRelive::Show();
	//}
	//
	if (this->m_rewardContent.size() > 2)
	{
		GlobalShowDlg(NDCommonCString("BattleRes"), m_rewardContent.c_str(), 3.0f);
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
		//		switch (this->m_battleStatus) {
		//			case BS_USE_ITEM_MENU:
		//			case BS_USER_SKILL_MENU:
		//				this->m_battleStatus = BS_USER_MENU;
		//				//this->AddChild(m_battleOpt);
		//				break;
		//			case BS_EUDEMON_SKILL_MENU:
		//				this->m_battleStatus = BS_EUDEMON_MENU;
		//				//this->AddChild(this->m_eudemonOpt);
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
	
	this->AddChild(role);
	if (role->IsKindOfClass(RUNTIME_CLASS(NDPlayer)))
	{
		//		this->m_playerHead->SetBattlePlayer(f);
		this->m_ourGroup = group;
	}
	
	//	if (role->IsKindOfClass(RUNTIME_CLASS(NDBattlePet))) {
	//		if (f->m_info.line == BATTLE_LINE_FRONT && f->m_info.posIdx == 0) { // 玩家战宠
	//			if (NULL == this->m_petHead) {
	//				m_petHead = new PetHead;
	//				m_petHead->Initialization(f);
	//				this->AddChild(m_petHead);
	//			}
	//		}
	//	}
	
	if (BATTLE_GROUP_DEFENCE == group)
	{
		role->m_faceRight = false;
		m_vAttaker.push_back(f);
	}
	else
	{
		role->m_faceRight = true;
		m_vDefencer.push_back(f);
	}
	f->setPosition(m_teamAmout);
	f->showFighterName(true);
	//	if (f->m_info.bRoleMonster) {
	//		role->m_faceRight = !role->m_faceRight;
	//	}
	
	battleStandAction(*f);
}

void Battle::clearHighlight()
{
	this->RemoveChild(TAG_LINGPAI, true);
	this->RemoveChild(TAG_NAME, true);
	this->clearAllWillBeAtk();
	//if (this->m_highlightFighter)
	//		this->m_highlightFighter->setWillBeAtk(false);
	this->m_highlightFighter = NULL;
}

void Battle::CloseViewStatus()
{
	this->RemoveChild(TAG_VIEW_FIGHTER_STATUS, true);
	this->clearHighlight();
	
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
//	if (this->m_dlgHint) {
//		m_dlgHint->RemoveFromParent(true);
//		m_dlgHint = NULL;
//	} else if (this->m_skillOpt) {
//		this->RemoveChild(m_skillOpt, true);
//		m_skillOpt = NULL;
//		this->RemoveChild(TAG_SKILL_MEMO, true);
//	}
//}

//void Battle::CloseItemMenu()
//{
//	if (m_dlgHint) {
//		m_dlgHint->RemoveFromParent(true);
//		m_dlgHint = NULL;
//	} else if (m_itemOpt) {
//		m_mapUseItem.clear();
//		this->RemoveChild(m_itemOpt, true);
//		m_itemOpt = NULL;
//	}
//}

void Battle::ShowQuickChat(bool bShow)
{
	//	if (bShow) {
	//		this->AddChild(m_imgQuickTalkBg);
	//		this->AddChild(m_tlQuickTalk);
	//		m_layerBtnQuitTalk->SetFrameRect(CGRectMake(35, 136, 48, 20));
	//	} else {
	//		this->RemoveChild(m_imgQuickTalkBg, false);
	//		this->RemoveChild(m_tlQuickTalk, false);
	//		m_layerBtnQuitTalk->SetFrameRect(CGRectMake(35, 300, 48, 20));
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
	//		this->AddChild(m_imgChat);
	//		this->AddChild(m_btnSendChat);
	//		
	//		if (NULL == m_chatDelegate.tfChat) {
	//			UITextField* tfChat = [[UITextField alloc] init];
	//			tfChat.transform = CGAffineTransformMakeRotation(3.141592f/2.0f);
	//			tfChat.frame = CGRectMake(290.0f, 54.0f, 25.0f, 326.0f);
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
	//		this->RemoveChild(m_imgChat, false);
	//		this->RemoveChild(m_btnSendChat, false);
	//		[m_chatDelegate.tfChat removeFromSuperview];
	//	}
}

void Battle::OnButtonClick(NDUIButton* button)
{
	//	if (button == m_btnLeave) {
	//		if (this->m_bWatch) {
	//			ShowProgressBar;
	//			NDTransData bao(_MSG_BATTLEACT);
	//			bao << BATTLE_ACT_LEAVE << Byte(0) << Byte(0);
	//			// SEND_DATA(bao);
	//			return;
	//		}
	//		
	//	} else if (button == m_btnAuto) {
	//		if (s_bAuto) {
	//			this->stopAuto();
	//		} else {
	//			this->OnBtnAuto(this->m_battleStatus < BS_SET_FIGHTER);
	//		}
	//		
	//		/*switch (m_battleStatus) {
	//			case BS_USER_MENU:
	//			case BS_EUDEMON_MENU:
	//			{
	//				this->stopAuto();
	//				VEC_FIGHTER& enemyList = this->GetEnemySideList();
	//				for (VEC_FIGHTER_IT it = enemyList.begin(); it != enemyList.end(); it++) {
	//					if ((*it)->isVisiable()) {
	//						if (this->m_battleStatus == BS_EUDEMON_MENU) {
	//							this->m_battleStatus = BS_CHOOSE_VIEW_FIGHTER_STATUS_PET;
	//							this->RemoveChild(this->m_eudemonOpt, false);
	//						} else {
	//							m_battleStatus = BS_CHOOSE_VIEW_FIGHTER_STATUS;
	//							this->RemoveChild(m_battleOpt, false);
	//						}
	//						
	//						this->HighlightFighter(*it);
	//						
	//						CGSize size = NDDirector::DefaultDirector()->GetWinSize();
	//						NDUILabel* lbViewFighter = new NDUILabel;
	//						lbViewFighter->Initialization();
	//						lbViewFighter->SetText(TEXT_VIEW_STATUS);
	//						lbViewFighter->SetFontColor(ccc4(255, 255, 255, 255));
	//						CGSize sizeText = getStringSize(TEXT_VIEW_STATUS, 15);
	//						lbViewFighter->SetTag(TAG_VIEW_FIGHTER_STATUS);
	//						lbViewFighter->SetFrameRect(CGRectMake((size.width - sizeText.width) / 2
	//										       , 260, sizeText.width, sizeText.height));
	//						this->AddChild(lbViewFighter);
	//						return;
	//					}
	//				}
	//			}
	//				break;
	//			case BS_CHOOSE_VIEW_FIGHTER_STATUS:
	//				this->CloseViewStatus();
	//				this->AddChild(m_battleOpt);
	//				m_battleStatus = BS_USER_MENU;
	//				break;
	//			case BS_CHOOSE_VIEW_FIGHTER_STATUS_PET:
	//				this->CloseViewStatus();
	//				this->AddChild(this->m_eudemonOpt);
	//				m_battleStatus = BS_EUDEMON_MENU;
	//				break;
	//			case BS_USE_ITEM_MENU:
	//				this->CloseItemMenu();
	//				this->m_battleStatus = BS_USER_MENU;
	//				this->AddChild(m_battleOpt);
	//				break;
	//			case BS_EUDEMON_USE_ITEM_MENU:
	//				this->CloseItemMenu();
	//				this->m_battleStatus = BS_EUDEMON_MENU;
	//				this->AddChild(m_eudemonOpt);
	//				break;
	//			case BS_USER_SKILL_MENU:
	//				this->CloseSkillMenu();
	//				this->m_battleStatus = BS_USER_MENU;
	//				this->AddChild(m_battleOpt);
	//				break;
	//			case BS_EUDEMON_SKILL_MENU:
	//				this->CloseSkillMenu();
	//				this->m_battleStatus = BS_EUDEMON_MENU;
	//				this->AddChild(this->m_eudemonOpt);
	//				break;
	//			case BS_CHOOSE_ENEMY_CATCH:
	//			case BS_CHOOSE_ENEMY_PHY_ATK:
	//			case BS_CHOOSE_ENEMY_MAG_ATK:
	//			case BS_CHOOSE_OUR_SIDE_MAG_ATK:
	//				this->clearHighlight();
	//				this->AddChild(m_battleOpt);
	//				this->m_battleStatus = BS_USER_MENU;
	//				break;
	//			case BS_CHOOSE_OUR_SIDE_USE_ITEM_USER:
	//				this->clearHighlight();
	//				this->OnBtnUseItem(BS_USE_ITEM_MENU);
	//				break;
	//			case BS_CHOOSE_OUR_SIDE_USE_ITEM_EUDEMON:
	//				this->clearHighlight();
	//				this->OnBtnUseItem(BS_EUDEMON_USE_ITEM_MENU);
	//				break;
	//			case BS_CHOOSE_ENEMY_PHY_ATK_EUDEMON:
	//			case BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON:
	//			case BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON:
	//				this->clearHighlight();
	//				this->AddChild(this->m_eudemonOpt);
	//				this->m_battleStatus = BS_EUDEMON_MENU;
	//				break;
	//			default:
	//				break;
	//		}*/
	//	} else if (button == m_btnTalk) 
	//	{
	//		//ChatRecordManager::DefaultManager()->Show();
	//		// 直接显示聊天输入框
	//		//this->ShowChatTextField(!m_bShowChatTextField);
	//		NewChatScene::DefaultManager()->Show();
	//	} else if (button == m_btnQuickTalk) {
	//		// 快捷聊天
	//		this->ShowQuickChat(m_imgQuickTalkBg->GetParent() == NULL);
	//		
	//	} else if (button == m_btnSendChat) {
	//		NSString* msg = this->m_chatDelegate.tfChat.text;
	//		if ([msg length] > 0) {
	//			ChatInput::SendChatDataToServer(ChatTypeSection, [msg UTF8String]);
	//			this->m_chatDelegate.tfChat.text = @"";
	//			string speaker = NDPlayer::defaultHero().m_name;
	//			speaker += "：";
	//			Chat::DefaultChat()->AddMessage(ChatTypeSection, [msg UTF8String], speaker.c_str());
	//		}
	//	}
	//	else if (button == m_btnCancleAutoFight)
	//	{
	//		//取消自动战斗
	//		this->RemoveCancleAutoFightButton();
	//		s_bAuto = false;
	//	}
}

void Battle::Initialization(int action)
{
	NDUILayer::Initialization();
	
	this->SetScrollEnabled(true);
	
	if (action == BATTLE_STAGE_WATCH) {
		this->m_bWatch = true;
	}
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_battleBg = new NDUILayer();
	m_battleBg->Initialization();
	m_battleBg->SetBackgroundColor(ccc4(0, 0, 0, 188));
	m_battleBg->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));
	
	//	m_picTalk = new NDPicture();
	//	m_picTalk->Initialization(GetImgPathBattleUI("battle_chat.png"));
	//	
	//	m_picQuickTalk = new NDPicture;
	//	m_picQuickTalk->Initialization(GetImgPathBattleUI("battle_fast_handle.png"));
	//	
	//	m_btnTalk = new NDUIButton();
	//	m_btnTalk->Initialization();
	//	m_btnTalk->SetImage(m_picTalk);
	//	m_btnTalk->SetFrameRect(CGRectMake(0, 263, 47, 57));
	//	m_btnTalk->SetTag(BTN_TALK);
	//	m_btnTalk->SetDelegate(this);
	//	this->AddChild(m_btnTalk);
	//	
	//	m_layerBtnQuitTalk = new NDUILayer;
	//	m_layerBtnQuitTalk->Initialization();
	//	m_layerBtnQuitTalk->SetBackgroundColor(ccc4(0, 0, 0, 0));
	//	m_layerBtnQuitTalk->SetFrameRect(CGRectMake(40, 300, 48, 20));
	//	this->AddChild(m_layerBtnQuitTalk, 1);
	//	
	//	m_btnQuickTalk = new NDUIButton();
	//	m_btnQuickTalk->Initialization();
	//	m_btnQuickTalk->SetImage(m_picQuickTalk);
	//	m_btnQuickTalk->SetFrameRect(CGRectMake(0, 0, 48, 20));
	//	m_btnQuickTalk->SetDelegate(this);
	//	m_layerBtnQuitTalk->AddChild(m_btnQuickTalk);
	//	
	//	
	//	if (this->m_bWatch) {
	//		m_picLeave = new NDPicture();
	//		m_picLeave->Initialization(GetImgPathBattleUI("battle_cancel.png"));
	//		
	//		m_btnLeave = new NDUIButton();
	//		m_btnLeave->Initialization();
	//		m_btnLeave->SetImage(m_picLeave);
	//		m_btnLeave->SetDelegate(this);
	//		m_btnLeave->SetFrameRect(CGRectMake(420, 260, 60, 60));
	//		this->AddChild(m_btnLeave);
	//	} else {
	//		m_picAuto = new NDPicture();
	//		m_picAuto->Initialization(GetImgPathBattleUI("battle_auto.png"));
	//		
	//		m_picAutoCancel = new NDPicture();
	//		m_picAutoCancel->Initialization(GetImgPathBattleUI("battle_auto_cancel.png"));
	//		
	//		m_btnAuto = new NDUIButton();
	//		m_btnAuto->Initialization();
	//		m_btnAuto->SetImage(s_bAuto ? m_picAutoCancel : m_picAuto);
	//		m_btnAuto->SetFrameRect(CGRectMake(420, 260, 60, 60));
	//		m_btnAuto->SetDelegate(this);
	//		this->AddChild(m_btnAuto);
	//	}
	//	
	//	m_imgTimer = new NDUIImage;
	//	m_imgTimer->Initialization();
	//	NDPicture* pic = new NDPicture;
	//	pic->Initialization(GetImgPathBattleUI("timerback.png"));
	//	m_imgTimer->SetPicture(pic, true);
	//	m_imgTimer->SetFrameRect(CGRectMake(185.0f, 75.0f, 111.0f, 46.0f));
	//	this->AddChild(m_imgTimer);
	//	
	//	m_lbTimerTitle = new NDUILabel;
	//	m_lbTimerTitle->?ialization();
	//	m_lbTimerTitle->SetFontSize(14);
	//	m_lbTimerTitle->SetFontColor(ccc4(255, 255, 255, 255));
	//	m_lbTimerTitle->SetText(NDCommonCString("DaoJiShi"));
	//	m_lbTimerTitle->SetFrameRect(CGRectMake(218.0f, 81.0f, 60.0f, 20.0f));
	//	this->AddChild(m_lbTimerTitle);
	//	
	//	m_lbTimer = new NDUILabel;
	//	m_lbTimer->Initialization();
	//	m_lbTimer->SetFontSize(14);
	//	m_lbTimer->SetFontColor(ccc4(255, 255, 255, 255));
	//	m_lbTimer->SetText("30");
	//	m_lbTimer->SetFrameRect(CGRectMake(233.0f, 103.0f, 60.0f, 20.0f));
	//	this->AddChild(m_lbTimer);
	//	
	//	m_imgTurn = new NDUIImage;
	//	m_imgTurn->Initialization();
	//	pic = new NDPicture;
	//	pic->Initialization(GetImgPathBattleUI("turnback.png"));
	//	m_imgTurn->SetPicture(pic, true);
	//	m_imgTurn->SetFrameRect(CGRectMake(185.0f, 155.0f, 111.0f, 46.0f));
	//	this->AddChild(m_imgTurn);
	//	
	//	m_lbTurnTitle = new NDUILabel;
	//	m_lbTurnTitle->Initialization();
	//	m_lbTurnTitle->SetFontSize(14);
	//	m_lbTurnTitle->SetFontColor(ccc4(255, 255, 255, 255));
	//	m_lbTurnTitle->SetText(NDCommonCString("HuiHe"));
	//	m_lbTurnTitle->SetFrameRect(CGRectMake(225.0f, 160.0f, 60.0f, 20.0f));
	//	this->AddChild(m_lbTurnTitle);
	//	
	//	m_lbTurn = new NDUILabel;
	//	m_lbTurn->Initialization();
	//	m_lbTurn->SetFontSize(14);
	//	m_lbTurn->SetFontColor(ccc4(255, 255, 255, 255));
	//	m_lbTurn->SetText("1/30");
	//	m_lbTurn->SetFrameRect(CGRectMake(226.0f, 177.0f, 60.0f, 20.0f));
	//	this->AddChild(m_lbTurn);
	//	
	//	m_timer.SetTimer(this, TIMER_TIMELEFT, 1);
	//	
//		NDEraseInOutEffect *eioEffect = new NDEraseInOutEffect;
//		eioEffect->Initialization();
//		eraseInOutEffect = eioEffect->QueryLink();
	//	
	//	m_imgChat = new NDUIImage;
	//	m_imgChat->Initialization();
	//	pic = new NDPicture;
	//	pic->Initialization(GetImgPathBattleUI("input_edit.png"));
	//	m_imgChat->SetPicture(pic, true);
	//	m_imgChat->SetFrameRect(CGRectMake(44.0f, 0.0f, 392.0f, 38.0f));
	//	//this->AddChild(m_imgChat);
	//	
	//	m_btnSendChat = new NDUIButton;
	//	m_btnSendChat->Initialization();
	//	pic = new NDPicture;
	//	pic->Initialization(GetImgPathBattleUI("chat_btn_normal.png"));
	//	m_btnSendChat->SetImage(pic, false, CGRectMake(0, 0, 0, 0), true);
	//	m_btnSendChat->SetFrameRect(CGRectMake(386.0f, 3.0f, 25.0f, 26.0f));
	//	m_btnSendChat->SetDelegate(this);
	//	//this->AddChild(m_btnSendChat);
	//	
	//	m_imgQuickTalkBg = new NDUIImage;
	//	m_imgQuickTalkBg->Initialization();
	//	pic = new NDPicture;
	//	pic->Initialization(GetImgPathBattleUI("battle_fast_bg.png"), 10, 10);
	//	m_imgQuickTalkBg->SetPicture(pic, true);
	//	m_imgQuickTalkBg->SetFrameRect(CGRectMake(1.0f, 154.0f, 210.0f, 166.0f));
	//	//this->AddChild(m_imgQuickTalkBg);
	//	
	//	m_tlQuickTalk = new NDUITableLayer;
	//	m_tlQuickTalk->Initialization();
	//	m_tlQuickTalk->VisibleSectionTitles(false);
	//	
	//	m_tlQuickTalk->SetBackgroundColor(ccc4(0, 0, 0, 0));
	//	NDDataSource *ds = new NDDataSource;
	//	NDSection *sec = new NDSection;
	//	
	//	//NDQuickTalkDataPersist& quickTalk = NDQuickTalkDataPersist::DefaultInstance();
	//	//vector<string> vTalk;
	//	//quickTalk.GetAllQuickTalkString(NDPlayer::defaultHero().m_id, vTalk);
	//	
	//	QuickTalkCell *talk = new QuickTalkCell;
	//	talk->Initialization([kSysQuickTalk1 UTF8String], CGSizeMake(195.0f, 32.0f));
	//	sec->AddCell(talk);
	//	
	//	talk = new QuickTalkCell;
	//	talk->Initialization([kSysQuickTalk2 UTF8String], CGSizeMake(195.0f, 32.0f));
	//	sec->AddCell(talk);
	//	
	//	talk = new QuickTalkCell;
	//	talk->Initialization([kSysQuickTalk3 UTF8String], CGSizeMake(195.0f, 32.0f));
	//	sec->AddCell(talk);
	//	
	//	talk = new QuickTalkCell;
	//	talk->Initialization([kSysQuickTalk4 UTF8String], CGSizeMake(195.0f, 32.0f));
	//	sec->AddCell(talk);
	//	
	//	talk = new QuickTalkCell;
	//	talk->Initialization([kSysQuickTalk5 UTF8String], CGSizeMake(195.0f, 32.0f));
	//	sec->AddCell(talk);
	//	
	//	sec->SetFocusOnCell(0);
	//	m_tlQuickTalk->SetFrameRect(CGRectMake(3.0f, 160.0f, 204.0f, 165.0f));
	//	
	//	ds->AddSection(sec);
	//	m_tlQuickTalk->SetDelegate(this);
	//	m_tlQuickTalk->SetDataSource(ds);
	//this->AddChild(m_tlQuickTalk);
	
	if (this->m_bWatch) { // 观战不需要其他操作
		return;
	}
	
	//	m_imgWhoAmI = new NDUIImage();
	//	m_imgWhoAmI->Initialization();
	//	m_picWhoAmI = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("whoami.png"));
	//	m_picLingPai = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("lingpai.png"));
	//	m_imgWhoAmI->SetFrameRect(CGRectMake(0, 0, m_picWhoAmI->GetSize().width, m_picWhoAmI->GetSize().height));
	//	m_imgWhoAmI->SetPicture(m_picWhoAmI);
	//	this->AddChild(m_imgWhoAmI);
	
	/*m_battleOpt = new NDUITableLayer;
	 m_battleOpt->Initialization();
	 m_battleOpt->VisibleSectionTitles(false);
	 NDDataSource *ds = new NDDataSource;
	 NDSection *sec = new NDSection;
	 
	 // 攻击
	 NDUIButton  *btnAttack = new NDUIButton;
	 btnAttack->Initialization();
	 btnAttack->SetTag(BTN_ATTATCK);
	 btnAttack->SetFocusColor(ccc4(253, 253, 253, 255));
	 btnAttack->SetTitle("攻  击");
	 sec->AddCell(btnAttack);
	 
	 // 物品
	 NDUIButton  *btnUseItem = new NDUIButton;
	 btnUseItem->Initialization();
	 btnUseItem->SetTitle("物  品");
	 btnUseItem->SetTag(BTN_ITEM);
	 btnUseItem->SetFocusColor(ccc4(253, 253, 253, 255));
	 sec->AddCell(btnUseItem);
	 
	 // 技能
	 NDUIButton  *btnSkill = new NDUIButton;
	 btnSkill->Initialization();
	 btnSkill->SetTitle("技  能");
	 btnSkill->SetTag(BTN_SKILL);
	 btnSkill->SetFocusColor(ccc4(253, 253, 253, 255));
	 sec->AddCell(btnSkill);
	 
	 // 防御
	 NDUIButton  *btnDefence = new NDUIButton;
	 btnDefence->Initialization();
	 btnDefence->SetTitle("防  御");
	 btnDefence->SetTag(BTN_DEFENCE);
	 btnDefence->SetFocusColor(ccc4(253, 253, 253, 255));
	 sec->AddCell(btnDefence);
	 
	 // 自动
	 NDUIButton  *btnAuto = new NDUIButton;
	 btnAuto->Initialization();
	 btnAuto->SetTitle("自  动");
	 btnAuto->SetTag(BTN_AUTO);
	 btnAuto->SetFocusColor(ccc4(253, 253, 253, 255));
	 sec->AddCell(btnAuto);
	 
	 // 逃跑
	 NDUIButton  *btnRun = new NDUIButton;
	 btnRun->Initialization();
	 if (this->m_battleType != BATTLE_TYPE_PRACTICE) {
	 btnRun->SetTitle("逃  跑");
	 } else {
	 btnRun->SetTitle("退  出");
	 }
	 
	 btnRun->SetTag(BTN_FLEE);
	 btnRun->SetFocusColor(ccc4(253, 253, 253, 255));
	 sec->AddCell(btnRun);
	 
	 // 捕捉
	 if (this->m_battleType != BATTLE_TYPE_PRACTICE) {
	 NDUIButton  *btnCatch = new NDUIButton;
	 btnCatch->Initialization();
	 btnCatch->SetTitle("捕  捉");
	 btnCatch->SetTag(BTN_CATCH);
	 btnCatch->SetFocusColor(ccc4(253, 253, 253, 255));
	 sec->AddCell(btnCatch);
	 }
	 
	 sec->SetFocusOnCell(0);
	 m_battleOpt->SetFrameRect(CGRectMake((winSize.width / 2) - 30, winSize.height / 2 - 115, 60, TEXT_BTN_HEIGHT * sec->Count()));
	 
	 ds->AddSection(sec);
	 m_battleOpt->SetDelegate(this);
	 m_battleOpt->SetDataSource(ds);
	 this->AddChild(m_battleOpt);*/
	
	if (s_bAuto) {
		this->SetAutoCount();
	}
	
	//	this->m_playerHead = new PlayerHead(&NDPlayer::defaultHero());
	//	m_playerHead->Initialization(true);
	//	this->AddChild(m_playerHead);
	
	if (s_bAuto) 
	{
		//this->RemoveChild(m_battleOpt, false);
		m_timer.SetTimer(this, TIMER_AUTOFIGHT, 0.5f);
	}
}

void Battle::InitEudemonOpt()
{
	// 有战宠
	this->getMainEudemon();
	
	/*if (this->getMainEudemon()) {
	 CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	 m_eudemonOpt = new NDUITableLayer;
	 m_eudemonOpt->Initialization();
	 m_eudemonOpt->VisibleSectionTitles(false);
	 m_eudemonOpt->SetFrameRect(CGRectMake((winSize.width / 2) - 30, winSize.height / 2 - 115, 60, TEXT_BTN_HEIGHT * 5));
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
 NDUIMemo* skillMemo = (NDUIMemo*)this->GetChild(TAG_SKILL_MEMO);
 
 if (this->m_battleStatus == BS_USER_SKILL_MENU) {
 this->m_curBattleAction->btAction = BATTLE_ACT_MAG_ATK;
 s_lastTurnActionUser.btAction = BATTLE_ACT_MAG_ATK;
 s_lastTurnActionUser.vData.clear();
 
 SET_BATTLE_SKILL_LIST_IT itSkill = this->m_setBattleSkillList.begin();
 size_t n = 0;
 for (; n < cellIndex; n++) {
 itSkill++;
 }
 
 if (n < this->m_setBattleSkillList.size()) {
 this->m_curBattleAction->vData.push_back(*itSkill);
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
 } else if (this->m_battleStatus == BS_EUDEMON_SKILL_MENU) {
 
 NDBattlePet* pet = NDPlayer::defaultHero().battlepet;
 NDAsssert(pet != NULL);
 SET_BATTLE_SKILL_LIST petBattleSkillList = pet->GetSkillList(SKILL_TYPE_ATTACK);
 
 this->m_curBattleAction->btAction = BATTLE_ACT_PET_MAG_ATK;
 
 s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_MAG_ATK;
 s_lastTurnActionEudemon.vData.clear();
 
 SET_BATTLE_SKILL_LIST_IT itSkill = petBattleSkillList.begin();
 size_t n = 0;
 for (; n < cellIndex; n++) {
 itSkill++;
 }
 
 if (n < petBattleSkillList.size()) {
 this->m_curBattleAction->vData.push_back(*itSkill);
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
	//			this->ShowQuickChat(false);
	//		}
	//	}
}
/*void Battle::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
 {	
 if (m_battleOpt == table) {
 switch ((cellIndex + 1))
 {
 case BTN_ATTATCK:
 this->stopAuto();
 this->OnBtnAttack();
 break;
 case BTN_FLEE:
 this->stopAuto();
 this->OnBtnRun();
 break;
 case BTN_DEFENCE:
 this->stopAuto();
 this->OnBtnDefence();
 break;
 case BTN_CATCH:
 this->stopAuto();
 this->OnBtnCatch();
 break;
 case BTN_AUTO:
 this->OnBtnAuto(true);
 break;
 //			case BTN_ITEM:
 //				this->stopAuto();
 //				this->OnBtnUseItem(BS_USE_ITEM_MENU);
 //				break;
 case BTN_SKILL:
 this->stopAuto();
 //this->OnBtnSkill();
 break;
 default:
 break;
 }
 } else if (m_itemOpt == table) {
 if (m_battleStatus == BS_USE_ITEM_MENU) {
 m_curBattleAction->btAction = BATTLE_ACT_USEITEM;
 this->m_battleStatus = BS_CHOOSE_OUR_SIDE_USE_ITEM_USER;
 } else {
 m_curBattleAction->btAction = BATTLE_ACT_PET_USEITEM;
 this->m_battleStatus = BS_CHOOSE_OUR_SIDE_USE_ITEM_EUDEMON;
 }
 
 m_curBattleAction->vData.clear();
 
 MAP_USEITEM_IT it = m_mapUseItem.begin();
 for (unsigned int i = 0; it != m_mapUseItem.end() && i < cellIndex; it++, i++) {
 }
 
 if (it != m_mapUseItem.end()) {
 m_curBattleAction->vData.push_back(it->second.first);
 }
 
 VEC_FIGHTER& ourSideList = this->GetOurSideList();
 Fighter* f;
 for (size_t i = 0; i < ourSideList.size(); i++) {
 f = ourSideList.at(i);
 if (f->isVisiable()) {
 this->HighlightFighter(f);
 break;
 }
 }
 
 this->RemoveChild(m_itemOpt, true);
 m_itemOpt = NULL;
 } else if (m_eudemonOpt == table) {
 switch (cell->GetTag()) {
 case BTN_EUD_ATK:
 this->OnEudemonAttack();
 break;
 case BTN_EUD_SKILL:
 //this->OnEudemonSkill();
 break;
 case BTN_EUD_DEF:
 {
 BattleAction actioin(BATTLE_ACT_PET_PHY_DEF);
 s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_PHY_DEF;
 this->SendBattleAction(actioin);
 }
 break;
 case BTN_EUD_FLEE:
 {
 BattleAction actioin(BATTLE_ACT_PET_ESCAPE);
 this->SendBattleAction(actioin);
 }
 break;
 //			case BTN_EUD_ITEM:
 //				this->OnBtnUseItem(BS_EUDEMON_USE_ITEM_MENU);
 //				break;
 default:
 break;
 }
 } else if (this->m_skillOpt == table) {
 this->m_curBattleAction->vData.clear();
 
 if (this->m_battleStatus == BS_USER_SKILL_MENU) {
 this->m_curBattleAction->btAction = BATTLE_ACT_MAG_ATK;
 s_lastTurnActionUser.btAction = BATTLE_ACT_MAG_ATK;
 s_lastTurnActionUser.vData.clear();
 
 SET_BATTLE_SKILL_LIST_IT itSkill = this->m_setBattleSkillList.begin();
 size_t n = 0;
 for (; n < cellIndex; n++) {
 itSkill++;
 }
 
 if (n < this->m_setBattleSkillList.size()) {
 this->m_curBattleAction->vData.push_back(*itSkill);
 s_lastTurnActionUser.vData.push_back(*itSkill);
 s_lastTurnActionUser.vData.push_back(0);
 }
 BattleSkill* skill = BattleMgrObj.GetBattleSkill(*itSkill);
 if (!skill) {
 return;
 }
 
 int targetType = skill->getAtkType();
 this->GetMainUser()->setUseSkill(skill);
 
 if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
 
 this->m_battleStatus = BS_CHOOSE_ENEMY_MAG_ATK;
 
 VEC_FIGHTER& enemyList = this->GetEnemySideList();
 Fighter* f;
 for (size_t i = 0; i < enemyList.size(); i++) {
 f = enemyList.at(i);
 if (f->isVisiable()) {
 this->HighlightFighter(f);
 break;
 }
 }
 
 } else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
 
 this->m_battleStatus = BS_CHOOSE_OUR_SIDE_MAG_ATK;
 
 VEC_FIGHTER& ourList = this->GetOurSideList();
 Fighter* f;
 for (size_t i = 0; i < ourList.size(); i++) {
 f = ourList.at(i);
 if (f->isVisiable()) {
 this->HighlightFighter(f);
 break;
 }
 }
 
 } else if ((targetType & SKILL_ATK_TYPE_SELF) == SKILL_ATK_TYPE_SELF) {
 this->m_curBattleAction->vData.push_back(this->GetMainUser()->m_info.idObj);
 this->SendBattleAction(*m_curBattleAction);
 
 }
 } else if (this->m_battleStatus == BS_EUDEMON_SKILL_MENU) {
 
 NDBattlePet* pet = NDPlayer::defaultHero().battlepet;
 NDAsssert(pet != NULL);
 SET_BATTLE_SKILL_LIST petBattleSkillList = pet->GetSkillList(SKILL_TYPE_ATTACK);
 
 this->m_curBattleAction->btAction = BATTLE_ACT_PET_MAG_ATK;
 
 s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_MAG_ATK;
 s_lastTurnActionEudemon.vData.clear();
 
 SET_BATTLE_SKILL_LIST_IT itSkill = petBattleSkillList.begin();
 size_t n = 0;
 for (; n < cellIndex; n++) {
 itSkill++;
 }
 
 if (n < petBattleSkillList.size()) {
 this->m_curBattleAction->vData.push_back(*itSkill);
 s_lastTurnActionEudemon.vData.push_back(*itSkill);
 s_lastTurnActionEudemon.vData.push_back(0);
 }
 BattleSkill* skill = BattleMgrObj.GetBattleSkill(*itSkill);
 if (!skill) {
 return;
 }
 
 // 宠物mp不足提示
 if (this->getMainEudemon()->m_info.nMana < skill->getMpRequire()) {
 m_dlgHint = new NDUIDialog;
 m_dlgHint->Initialization();
 m_dlgHint->SetDelegate(this);
 m_dlgHint->Show("法力不足", "您的宝宝法力不够啦！", NULL, NULL);
 } else {
 int targetType = skill->getAtkType();
 
 if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
 
 this->m_battleStatus = BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON;
 
 VEC_FIGHTER& enemyList = this->GetEnemySideList();
 Fighter* f;
 for (size_t i = 0; i < enemyList.size(); i++) {
 f = enemyList.at(i);
 if (f->isVisiable()) {
 this->HighlightFighter(f);
 break;
 }
 }
 
 } else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
 
 this->m_battleStatus = BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON;
 
 VEC_FIGHTER& ourList = this->GetOurSideList();
 Fighter* f;
 for (size_t i = 0; i < ourList.size(); i++) {
 f = ourList.at(i);
 if (f->isVisiable()) {
 this->HighlightFighter(f);
 break;
 }
 }
 
 } else if ((targetType & SKILL_ATK_TYPE_SELF) == SKILL_ATK_TYPE_SELF) {
 this->m_curBattleAction->vData.push_back(this->getMainEudemon()->m_info.idObj);
 this->SendBattleAction(*m_curBattleAction);
 
 }
 }
 }
 this->RemoveChild(this->m_skillOpt, true);
 m_skillOpt = NULL;
 this->RemoveChild(TAG_SKILL_MEMO, true);
 }
 }*/

void Battle::processBattleSkillList(NDTransData& data, int len)
{
	//	this->m_setBattleSkillList.clear();
	//	int nCount = data.ReadShort();
	//	for (int i = 0; i < nCount; i++) {
	//		this->m_setBattleSkillList.insert(data.ReadInt());
	//	}
	//	
	//	if (s_bAuto) {
	//		this->RefreshSkillBar();
	//		m_fighterLeft->SetGray(true);
	//	}
}

/*void Battle::OnBtnSkill()
 {
 this->m_battleStatus = BS_USER_SKILL_MENU;
 this->RemoveChild(this->m_battleOpt, false);
 
 // 没有技能
 if (this->m_setBattleSkillList.size() <= 0) {
 m_dlgHint = new NDUIDialog;
 m_dlgHint->Initialization();
 m_dlgHint->SetDelegate(this);
 m_dlgHint->Show(NULL, "本回合无可用技能", NULL, NULL);
 return;
 }
 
 // 打开技能列表
 NDAsssert (m_skillOpt == NULL);
 
 CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
 int height = 0;
 
 this->m_skillOpt = new NDUITableLayer;
 m_skillOpt->Initialization();
 m_skillOpt->VisibleSectionTitles(false);
 
 NDDataSource *ds = new NDDataSource;
 NDSection *sec = new NDSection;
 
 BattleMgr& bm = BattleMgrObj;
 BattleSkill* bs = NULL;
 
 SET_BATTLE_SKILL_LIST_IT itSkill = this->m_setBattleSkillList.begin();
 BattleSkill* firstSkill = bm.GetBattleSkill(*itSkill);
 for (; itSkill != this->m_setBattleSkillList.end(); itSkill++) {
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
 m_skillOpt->SetFrameRect(CGRectMake((winSize.width / 2) - 80, winSize.height / 2, 160, height));
 this->AddChild(m_skillOpt);
 
 // 技能说明
 NDUIMemo* skillMemo = new NDUIMemo();
 skillMemo->Initialization();
 skillMemo->SetTag(TAG_SKILL_MEMO);
 skillMemo->SetBackgroundColor(ccc4(228, 219, 169, 255));
 skillMemo->SetText(firstSkill->getSimpleDes(true).c_str());
 skillMemo->SetFrameRect(CGRectMake((winSize.width / 2) - 80, 30, 160, winSize.height / 2 - 35));
 this->AddChild(skillMemo);
 }*/

/*void Battle::OnBtnUseItem(BATTLE_STATUS bs)
 {
 this->m_battleStatus = bs;
 if (m_battleOpt) 
 {
 this->RemoveChild(m_battleOpt, false);
 }	
 if (m_eudemonOpt) 
 {
 this->RemoveChild(m_eudemonOpt, false);
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
 
 CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
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
 m_itemOpt->SetFrameRect(CGRectMake((winSize.width / 2) - 80, winSize.height / 2 - 115, 160, height));
 this->AddChild(m_itemOpt);
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
//	VEC_FIGHTER& enemyList = this->GetEnemySideList();
//	Fighter* f;
//	for (size_t i = 0; i < enemyList.size(); i++) {
//		f = enemyList.at(i);
//		if (f->isCatchable()) {
//			this->HighlightFighter(f);
//			return;
//		}
//	}
//	
//	Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("CantCatch"));
}

void Battle::OnBtnDefence()
{
	//m_battleOpt->RemoveFromParent(false);
	
	s_lastTurnActionUser.btAction = BATTLE_ACT_PHY_DEF;
	
	BattleAction actioin(BATTLE_ACT_PHY_DEF);
	this->SendBattleAction(actioin);
}

void Battle::OnBtnRun()
{
	//m_battleOpt->RemoveFromParent(false);
	
	BattleAction actioin(BATTLE_ACT_ESCAPE);
	this->SendBattleAction(actioin);
}

/*void Battle::OnEudemonSkill()
 {
 this->m_battleStatus = BS_EUDEMON_SKILL_MENU;
 this->RemoveChild(this->m_eudemonOpt, false);
 
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
 
 CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
 int height = 0;
 
 this->m_skillOpt = new NDUITableLayer;
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
 m_skillOpt->SetFrameRect(CGRectMake((winSize.width / 2) - 80, winSize.height / 2, 160, height));
 this->AddChild(m_skillOpt);
 
 // 技能说明
 NDUIMemo* skillMemo = new NDUIMemo();
 skillMemo->Initialization();
 skillMemo->SetTag(TAG_SKILL_MEMO);
 skillMemo->SetBackgroundColor(ccc4(228, 219, 169, 255));
 skillMemo->SetText(firstSkill->getSimpleDes(true).c_str());
 skillMemo->SetFrameRect(CGRectMake((winSize.width / 2) - 80, 30, 160, winSize.height / 2 - 35));
 this->AddChild(skillMemo);
 }*/

void Battle::OnEudemonAttack()
{
//	if (BS_CHOOSE_ENEMY_PHY_ATK_EUDEMON == this->m_battleStatus) {
//		return;
//	}
//	
//	//this->m_eudemonOpt->RemoveFromParent(false);
//	setBattleStatus(BS_CHOOSE_ENEMY_PHY_ATK_EUDEMON);
//	//	m_fighterRight->SetFoucusByIndex(3);
//	//	m_fighterLeft->defocus();
//	//	m_fighterBottom->defocus();
//	
//	this->m_curBattleAction->btAction = BATTLE_ACT_PET_PHY_ATK;
//	this->m_curBattleAction->vData.clear();
//	
//	VEC_FIGHTER& enemyList = this->GetEnemySideList();
//	
//	Fighter* f;
//	for (size_t i = 0; i < enemyList.size(); i++) {
//		f = enemyList.at(i);
//		if (f->isVisiable()) {
//			s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_PHY_ATK;
//			s_lastTurnActionEudemon.vData.clear();
//			this->HighlightFighter(f);
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
//	this->m_curBattleAction->btAction = BATTLE_ACT_PHY_ATK;
//	this->m_curBattleAction->vData.clear();
//	
//	VEC_FIGHTER& enemyList = this->GetEnemySideList();
//	
//	Fighter* f;
//	for (size_t i = 0; i < enemyList.size(); i++) {
//		f = enemyList.at(i);
//		if (f->isVisiable()) {
//			s_lastTurnActionUser.btAction = BATTLE_ACT_PHY_ATK;
//			this->HighlightFighter(f);
//			return;
//		}
//	}
}

void Battle::stopAuto()
{
	if (s_bAuto) {
		//		m_timer.KillTimer(this, TIMER_AUTOCOUNT);
		//		this->RemoveChild(m_lbAuto, false);
		//		this->RemoveChild(m_imgAutoCount, false);
		//		SAFE_DELETE(m_lbAuto);
		//		SAFE_DELETE(m_imgAutoCount);
		//		this->m_autoCount = AUTO_COUNT;
		s_bAuto = false;
		//		m_btnAuto->SetImage(m_picAuto);
	}
}

void Battle::SetAutoCount()
{
	//	m_lbAuto = new NDUILabel;
	//	m_lbAuto->Initialization();
	//	m_lbAuto->SetText("自动");
	//	m_lbAuto->SetFontColor(ccc4(255, 255, 255, 255));
	//	CGSize sizeText = getStringSize("自动", 15);
	//	m_lbAuto->SetFrameRect(CGRectMake(2, 2, sizeText.width, sizeText.height));
	//	this->AddChild(m_lbAuto);
	//	
	//	m_imgAutoCount = new ImageNumber();
	//	m_imgAutoCount->Initialization();
	//	m_imgAutoCount->SetBigRedNumber(this->m_autoCount, false);
	//	m_imgAutoCount->SetFrameRect(CGRectMake(40, 2, m_imgAutoCount->GetNumberSize().width, m_imgAutoCount->GetNumberSize().height));
	//	this->AddChild(m_imgAutoCount);
	//	
	//	m_timer.SetTimer(this, TIMER_AUTOCOUNT, 1);
}

void Battle::OnBtnAuto(bool bSendAction)
{
	//this->RemoveChild(m_battleOpt, false);
	
	//CreateCancleAutoFightButton();
	
	this->m_autoCount = 0;
	
	if (!s_bAuto) {
		s_bAuto = true;
		//this->SetAutoCount();
		//		m_btnAuto->SetImage(m_picAutoCancel);
		//		m_fighterRight->SetShrink(true);
		//		m_fighterLeft->SetShrink(true);
		//		m_fighterBottom->SetShrink(true);
	}
	
	if (!bSendAction) {
		return;
	}
	
	if (!this->m_bSendCurTurnUserAction && this->GetMainUser() && this->GetMainUser()->isAlive()) {
		bool bUserActionSend = false;
		switch (s_lastTurnActionUser.btAction) {
			case BATTLE_ACT_PHY_ATK:
				s_lastTurnActionUser.vData.clear();
				s_lastTurnActionUser.vData.push_back(0);
				break;
			case BATTLE_ACT_PHY_DEF:
				s_lastTurnActionUser.vData.clear();
				break;
			case BATTLE_ACT_MAG_ATK:
			{
				if (this->m_setBattleSkillList.count(s_lastTurnActionUser.vData.at(0)) == 0) { // 该技能本回合已不可使用
					BattleAction atk(BATTLE_ACT_PHY_ATK);
					atk.vData.push_back(0);
					this->SendBattleAction(atk);
					bUserActionSend = true;
				}
			}
				break;
			default:
				s_lastTurnActionUser.btAction = BATTLE_ACT_PHY_ATK;
				s_lastTurnActionUser.vData.clear();
				s_lastTurnActionUser.vData.push_back(0);
				break;
		}
		
		if (!bUserActionSend) {
			this->SendBattleAction(s_lastTurnActionUser);
		}
	}
	
	// 宠物自动战斗
	if (this->m_mainEudemon && m_mainEudemon->isAlive() && !m_mainEudemon->isEscape()) 
	{
		switch (s_lastTurnActionEudemon.btAction) 
		{
			case BATTLE_ACT_PET_PHY_DEF:
				s_lastTurnActionEudemon.vData.clear();
				break;
			case BATTLE_ACT_PET_MAG_ATK:
				break;
			default:
				s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_PHY_ATK;
				s_lastTurnActionEudemon.vData.clear();
				s_lastTurnActionEudemon.vData.push_back(0);
				break;
		}
		this->SendBattleAction(s_lastTurnActionEudemon);
	}
}

void Battle::HighlightFighter(Fighter* f)
{
	m_highlightFighter = f;
	
	NDUILabel *name = (NDUILabel*)this->GetChild(TAG_NAME);
	NDUIImage *lingpai = (NDUIImage*)this->GetChild(TAG_LINGPAI);
	
	NDBaseRole* role = f->GetRole();
	CGPoint pt = CGPointMake(f->getX(), f->getY());
	
	if (!lingpai)
	{
		//		lingpai = new NDUIImage;
		//		lingpai->Initialization();
		//		lingpai->SetTag(TAG_LINGPAI);
		//		lingpai->SetPicture(m_picBoji);
		//		this->AddChild(lingpai);
	}
	
	
	//	if (m_picBoji) m_picBoji->SetReverse(f->GetGroup() == BATTLE_GROUP_DEFENCE);
	//	
	//	CGRect rect = CGRectMake(f->getX() + role->GetWidth() / 2 + 5,
	//							 f->getY() - 15,
	//							 m_picBoji->GetSize().width,
	//							 m_picBoji->GetSize().height);
	//							 
	//	if (f->GetGroup() == BATTLE_GROUP_DEFENCE) {
	//		rect.origin.x = rect.origin.x - role->GetWidth() - 10;
	//	}
	//	
	//	lingpai->SetFrameRect(rect);
	
	//CGRect frameLingpai = lingpai->GetFrameRect();
	if (!name)
	{
		name = new NDUILabel;
		name->SetFontColor(ccc4(255, 255, 255, 255));
		name->Initialization();
		name->SetTag(TAG_NAME);
		this->AddChild(name);
	}
	std::stringstream ss; ss << role->m_name << "Lv" << role->m_nLevel;
	//	if (f->m_info.fighterType == Fighter_TYPE_RARE_MONSTER)
	//	{
	//		ss << "【" << NDCommonCString("xiyou") << "】"; 
	//	}
	name->SetText(ss.str().c_str());
	CGSize sizeName = getStringSize(ss.str().c_str(), 15);
	name->SetFrameRect(CGRectMake(pt.x - sizeName.width / 2, pt.y - role->getGravityY() - sizeName.height, sizeName.width, sizeName.height));
	
	this->setWillBeAtk(this->getHighlightList());
	
	//f->setWillBeAtk(true);	
}

void Battle::OnTimer(OBJID tag)
{
	NDUILayer::OnTimer(tag);
	
	if (tag == TIMER_TIMELEFT) 
	{
		if (m_timeLeft > 0)
		{
			if (m_bWatch) {
				if (this->m_battleStatus != BS_SHOW_FIGHT && this->m_battleStatus != BS_FIGHTER_SHOW_PAS) {
					m_timeLeft--;
					stringstream ss;
					ss << m_timeLeft;
					//					m_lbTimer->SetText(ss.str().c_str());
					//m_imgTimer->SetBigRedNumber(m_timeLeft, false);
				}
			} else {
				if (this->IsUserOperating() || this->IsEudemonOperating()) {
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
	//				this->OnBtnAuto();
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
//	dieAniGroup=NULL;
	m_bChatTextFieldShouldShow = false;
	//	m_imgTurn = NULL;
	//	m_imgTimer = NULL;
	//	m_imgQuickTalkBg = NULL;
	//	m_tlQuickTalk = NULL;
	m_orignalMapId=0;
	m_lastSkillPageUser = 0;
	m_lastSkillPageEudemon = 0;
	//this->m_chatDelegate = [[ChatTextFieldDelegate alloc] init];
	m_bShowChatTextField = false;
	//	m_imgChat = NULL;
	//	m_btnSendChat = NULL;
	this->m_mapLayer=NULL;
	m_bSendCurTurnUserAction = false;
	
	//m_btnCancleAutoFight = NULL;
	
	m_dlgStatus = NULL;
	theActor = NULL;
	theTarget = NULL;
	this->m_bWatch = false;
	//m_battleOpt = NULL;
	//	m_playerHead = NULL;
	//	m_petHead = NULL;
	m_battleBg = NULL;
	//m_eudemonOpt = NULL;
	m_picActionWordDef = new NDPicture;
	m_picActionWordDef->Initialization(NDPath::GetImgPath("actionWord.png"));
	m_picActionWordDef->Cut(CGRectMake(0.0f, 0.0f, 37.0f, 18.0f));
	m_picActionWordFlee = new NDPicture;
	m_picActionWordDodge = new NDPicture;
	m_picActionWordDodge->Initialization(NDPath::GetImgPath("actionWord.png"));
	m_picActionWordDodge->Cut(CGRectMake(0.0f, 18.0f, 37.0f, 18.0f));
	m_picActionWordFlee->Initialization(NDPath::GetImgPath("actionWord.png"));
	m_picActionWordFlee->Cut(CGRectMake(0.0f, 36.0f, 37.0f, 18.0f));
	
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
	this->m_ourGroup = BATTLE_GROUP_ATTACK;
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
	
	m_picBaoJi = new NDPicture;
	m_picBaoJi->Initialization(NDPath::GetImgPath("bo.png"));
	//	
	//	m_picBoji = new NDPicture;
	//	m_picBoji->Initialization(GetImgPath("boji.png"));
	
	m_defaultActionUser = BATTLE_ACT_PHY_ATK;
	m_defaultTargetUser = NULL;
	m_defaultSkillID = ID_NONE;
	
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

Fighter* Battle::GetTouchedFighter(VEC_FIGHTER& fighterList, CGPoint pt)
{
	VEC_FIGHTER_IT itBegin = fighterList.begin();
	VEC_FIGHTER_IT itEnd = fighterList.end();
	
	Fighter *f;
	for (; itBegin != itEnd; itBegin++)
	{
		f = (*itBegin);
		if (!(f->isVisiable() && f->isVisibleStatus))
		{
			continue;
		}
		
		NDBaseRole* role = f->GetRole();
		CGPoint fPos = role->GetPosition();
		
		int w = role->GetWidth();
		int h = role->GetHeight();
		
		fPos.x -= (w >> 1);
		fPos.y -= h;
		
		if (IsPointInside(pt, CGRectMake(fPos.x, fPos.y, w, h)))
		{
			return f;
		}
	}
	
	return NULL;
}

bool Battle::TouchEnd(NDTouch* touch)
{
/***
* 临时性注释 郭浩
* begin
*/
// 	if (m_dlgStatus)
// 	{
// 		this->CloseStatusDlg();
// 	}
// 	
// 	if (touch && touch->GetLocation().x > 0.0001f && touch->GetLocation().y > 0.0001f) {
// 		if (NDUILayer::TouchEnd(touch)) {
// 			return false;
// 		}
// 	}
// 	
// 	Fighter* f = this->GetTouchedFighter(this->GetOurSideList(), touch->GetLocation());
// 	if(!f){
// 		f=this->GetTouchedFighter(this->GetEnemySideList(), touch->GetLocation());
// 	}
// 	
// 	if(f)
// 	{
// 		NDLog("touch fighter");
// 		if(this->currentShowFighter>0)
// 		{
// 			ScriptMgrObj.excuteLuaFunc("CloseFighterInfo","FighterInfo",0);
// 		}
// 		this->currentShowFighter=f->m_info.idObj;
// 		
// 		int idType=f->m_info.idType;
// 		int skillId=-1;
// 		if(f->m_info.fighterType==FIGHTER_TYPE_PET)
// 		{
// 			skillId=ScriptDBObj.GetN("pet_config",idType,DB_PET_CONFIG_SKILL);
// 		}else if(f->m_info.fighterType==FIGHTER_TYPE_MONSTER)
// 		{
// 			skillId=ScriptDBObj.GetN("monstertype",idType,DB_MONSTERTYPE_SKILL);
// 		}
// 		std::string skillName=ScriptDBObj.GetS("skill_config",skillId,DB_SKILL_CONFIG_NAME);
// 		ScriptMgrObj.excuteLuaFunc("LoadUI", "FighterInfo",f->getOriginX(),f->getOriginY());
// 		ScriptMgrObj.excuteLuaFunc<bool>("SetFighterInfo","FighterInfo",f->GetRole()->m_name,skillName);
// 		ScriptMgrObj.excuteLuaFunc("UpdateHp","FighterInfo",f->m_info.nLife,f->m_info.nLifeMax);
// 		ScriptMgrObj.excuteLuaFunc("UpdateMp","FighterInfo",f->m_info.nMana,f->m_info.nManaMax);
// 	}
/***
* 临时性注释 郭浩
* end
*/

//	switch (m_battleStatus)
//	{
//		case BS_CHOOSE_VIEW_FIGHTER_STATUS:
//		case BS_CHOOSE_VIEW_FIGHTER_STATUS_PET:
//		{
//			Fighter* f = this->GetTouchedFighter(this->GetEnemySideList(), touch->GetLocation());
//			if (!f) {
//				f = this->GetTouchedFighter(this->GetOurSideList(), touch->GetLocation());
//			}
//			
//			if (f) {
//				if (m_highlightFighter != f) {
//					this->HighlightFighter(f);
//					break;
//				}
//			}
//			
//			if (m_highlightFighter) {
//				m_dlgStatus = new StatusDialog;
//				m_dlgStatus->Initialization(m_highlightFighter);
//				m_dlgStatus->SetFrameRect(CGRectMake(0, 0, NDDirector::DefaultDirector()->GetWinSize().width,
//													 NDDirector::DefaultDirector()->GetWinSize().height));
//				this->AddChild(m_dlgStatus);
//			}
//		}
//			break;
//		case BS_CHOOSE_ENEMY_PHY_ATK:
//		case BS_CHOOSE_ENEMY_PHY_ATK_EUDEMON:
//		case BS_CHOOSE_ENEMY_MAG_ATK:
//		case BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON:
//		{
//			Fighter* f = this->GetTouchedFighter(this->GetEnemySideList(), touch->GetLocation());
//			if (f)
//			{
//				if (m_highlightFighter == f)
//				{
//					// 发送攻击指令
//					this->m_curBattleAction->vData.push_back(m_highlightFighter->m_info.idObj);
//					this->SendBattleAction(*m_curBattleAction);
//				}
//				else
//				{
//					if (m_battleStatus == BS_CHOOSE_ENEMY_PHY_ATK || m_battleStatus == BS_CHOOSE_ENEMY_MAG_ATK) {
//						m_defaultTargetUser = f;
//					} else {
//						m_defaultTargetEudemon = f;
//					}
//					this->HighlightFighter(f);
//				}
//			} else {
//				if (m_highlightFighter) {
//					// 发送攻击指令
//					this->m_curBattleAction->vData.push_back(m_highlightFighter->m_info.idObj);
//					this->SendBattleAction(*m_curBattleAction);
//				}
//			}
//			
//		}
//			break;
//		case BS_CHOOSE_ENEMY_CATCH:
//		{
//			Fighter* f = this->GetTouchedFighter(this->GetEnemySideList(), touch->GetLocation());
//			if (f)
//			{
//				if (f->isCatchable()) {
//					// 发送捕捉指令
//					BattleAction actioin(BATTLE_ACT_CATCH);
//					actioin.vData.push_back(f->m_info.idObj);
//					this->SendBattleAction(actioin);
//				} else {
//					Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("DestCantCatch"));
//				}
//				
//			} else {
//				if (m_highlightFighter) {
//					// 发送捕捉指令
//					BattleAction actioin(BATTLE_ACT_CATCH);
//					actioin.vData.push_back(m_highlightFighter->m_info.idObj);
//					this->SendBattleAction(actioin);
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
//			Fighter* f = this->GetTouchedFighter(this->GetOurSideList(), touch->GetLocation());
//			if (f)
//			{
//				if (m_highlightFighter == f)
//				{
//					m_curBattleAction->vData.push_back(m_highlightFighter->m_info.idObj);
//					this->SendBattleAction(*m_curBattleAction);
//				}
//				else
//				{
//					if (m_battleStatus == BS_CHOOSE_OUR_SIDE_MAG_ATK) {
//						m_defaultTargetUser = f;
//					} else if (m_battleStatus == BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON) {
//						m_defaultTargetEudemon = f;
//					}
//					this->HighlightFighter(f);
//				}
//			} else {
//				if (m_highlightFighter) {
//					m_curBattleAction->vData.push_back(m_highlightFighter->m_info.idObj);
//					this->SendBattleAction(*m_curBattleAction);
//				}
//			}
//		}
//			break;
//		case BS_CHOOSE_SELF_MAG_ATK:
//		case BS_CHOOSE_SELF_MAG_ATK_EUDEMON:
//			if (m_highlightFighter) {
//				m_curBattleAction->vData.push_back(m_highlightFighter->m_info.idObj);
//				this->SendBattleAction(*m_curBattleAction);
//			}
//		default:
//			break;
//	}
	
	return true;
}

void Battle::SendBattleAction(const BattleAction& action)
{
	// 移除令牌和名字显示，加入等待显示
	this->clearHighlight();
	
	if (!this->GetChild(TAG_WAITING) && this->m_mainFighter)
	{
		CGPoint pt = m_mainFighter->GetRole()->GetPosition();
		NDUILabel* waiting = new NDUILabel;
		waiting->Initialization();
		waiting->SetFontColor(ccc4(255, 255, 255, 255));
		waiting->SetTag(TAG_WAITING);
		waiting->SetText(NDCommonCString("wait"));
		CGSize sizeText = getStringSize(NDCommonCString("wait"), 15);
		waiting->SetFrameRect(CGRectMake(pt.x - sizeText.width / 2, pt.y, sizeText.width, sizeText.height));
		this->AddChild(waiting);
	}
	
	NDTransData data(_MSG_BATTLEACT);
	Byte btDataCount = action.vData.size();
	data << action.btAction
	<< Byte(this->m_turn - 1)
	<< btDataCount;
	
	for (int i = 0; i < btDataCount; i++)
	{
		data << action.vData.at(i);
	}
	
	NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
	
	if ((action.btAction == BATTLE_ACT_MAG_ATK ||
		 action.btAction == BATTLE_ACT_PET_MAG_ATK) 
		&& btDataCount > 0)
	{
		if ( !( (action.btAction == BATTLE_ACT_PET_MAG_ATK || action.btAction == BATTLE_ACT_MAG_ATK)
			   && CanPetFreeUseSkill()) )
		{
			int useSkillID = action.vData[0];
			UseSkillDealOfCooldown(useSkillID);
		}
	}
	
	// 有宠物，且非自动战斗
//	if (this->m_mainEudemon && this->m_mainEudemon->isAlive() &&
//	    !this->m_mainEudemon->isEscape() && !s_bAuto) {
//		switch (this->m_battleStatus) {
//			case BS_USER_MENU:
//			case BS_USER_SKILL_MENU:
//			case BS_CHOOSE_ENEMY_PHY_ATK:
//			case BS_CHOOSE_ENEMY_CATCH:
//			case BS_CHOOSE_OUR_SIDE_USE_ITEM_USER:
//			case BS_CHOOSE_ENEMY_MAG_ATK:
//			case BS_CHOOSE_OUR_SIDE_MAG_ATK:
//				//this->m_battleStatus = BS_EUDEMON_MENU;
//				//this->AddChild(this->m_eudemonOpt);
//				this->m_bSendCurTurnUserAction = true;
//				this->m_bTurnStartPet = true;
//				return;
//			default:
//				//this->RemoveChild(this->m_eudemonOpt, false);
//				break;
//		}
//	}
	
	setBattleStatus(BS_WAITING_SERVER_MESSAGE);
	
	//	m_fighterRight->SetShrink(true);
	//	m_fighterLeft->SetShrink(true);
	//	m_fighterBottom->SetShrink(true);
	//	
	//	m_fighterRight->SetGray(true);
	//	m_fighterLeft->SetGray(true);
	//	m_fighterBottom->SetGray(true);
}


void Battle::setBattleMap(int mapId,int posX,int posY){
	//	m_orignalMapId=NDMapMgrObj.m_iMapID;
	//	m_orignalPos=NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene())->GetScreenCenter();
	//	NDMapMgrObj.ClearNpc();
	//	NDMapMgrObj.ClearMonster();
	//	NDMapMgrObj.ClearGP();

	/***
	* 临时性注释 郭浩
	* begin
	*/
	// 	NDMapLayer* mapLayer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
// 	if(mapLayer){
// 		this->sceneMapId = mapLayer->GetMapIndex();
// 		this->sceneCenterX = mapLayer->GetScreenCenter().x;
// 		this->sceneCenterY = mapLayer->GetScreenCenter().y;
// 		//mapLayer->SetBattleBackground(true);
// 		mapLayer->replaceMapData(mapId, posX, posY);

		//mapLayer->SetNeedShowBackground(false);
	//}

	/***
	* 临时性注释 郭浩
	* end
	***/
	
//	return NDMapMgrObj.loadBattleSceneByMapID(mapId,posX*MAP_UNITSIZE,posY*MAP_UNITSIZE);
	
	//	mapLayer = NDMapMgrObj.getBattleMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
	//	mapLayer->SetScreenCenter(ccp(posX*MAP_UNITSIZE,posY*MAP_UNITSIZE));
}

void Battle::drawSubAniGroup()
{
	bool bErase = false;

	for (VEC_SUB_ANI_GROUP_IT it = this->m_vSubAniGroup.begin(); it != this->m_vSubAniGroup.end(); it++) {
		NDSprite* role = it->role;
		if (!role) {
			continue;
		}
		
		if(!(it->isCanStart)){
			it->isCanStart=true;
		}
		if(!(it->isCanStart)){
			continue;
		}
//		if(it->startFrame>0){
//			it->startFrame--;
//			continue;
//		}
		//NDLog("draw subanigroup");
//		it->bComplete = NDEngine::DrawSubAnimation(role, *it); ///< 临时性注释 郭浩
		if (it->bComplete) {
			NDLog("subanigroup complete");
			bErase = true;
			if (it->isFromOut) {
				it->aniGroup->release();
			}
			it->frameRec->release();
			it->frameRec = NULL;
		}
	}
	
	if (bErase) {
		this->m_vSubAniGroup.erase(remove_if(m_vSubAniGroup.begin(), m_vSubAniGroup.end(), IsSubAniGroupComplete()), m_vSubAniGroup.end());
	}
}

void Battle::sortFighterList(VEC_FIGHTER& fighterList)
{
	Fighter* fTemp = NULL;
	for (VEC_FIGHTER_IT itHead = fighterList.begin(); itHead != fighterList.end(); itHead++) {
		for (VEC_FIGHTER_IT itMin = itHead + 1; itMin != fighterList.end(); itMin++) {
			if ((*itMin)->getOriginY() < (*itHead)->getOriginY()) {
				fTemp = *itMin;
				*itMin = *itHead;
				*itHead = fTemp;
			}
		}
	}
}

void Battle::sortFighterList()
{
	this->sortFighterList(m_vDefencer);
	this->sortFighterList(m_vAttaker);
	
	for (VEC_FIGHTER_IT it = m_vDefencer.begin(); it != m_vDefencer.end(); it++) {
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
		if (f->isVisiable()) {
			f->updatePos();
			f->draw();
			f->drawActionWord();
		}
	}
	
	for (VEC_FIGHTER_IT it = m_vDefencer.begin(); it != m_vDefencer.end(); it++)
	{
		f = *it;
		if (f->isVisiable()) {
			f->updatePos();
			f->draw();
			f->drawActionWord();
		}
	}
	
	//	if (this->m_mainFighter && !this->watchBattle)
	//	{
	//		NDBaseRole* role = m_mainFighter->GetRole();
	//		CGPoint pt = role->GetPosition();
	//		m_imgWhoAmI->SetFrameRect(CGRectMake(pt.x - 6, pt.y - role->GetHeight(), m_picWhoAmI->GetSize().width, m_picWhoAmI->GetSize().height));
	//	}
}

void Battle::draw()
{
	if (eraseInOutEffect && !eraseInOutEffect->isChangeComplete()) {
		return;
	}
	
	if (!this->IsVisibled()) {
		this->SetVisible(true);
		//		NDMapLayer* mapLayer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
		//		mapLayer->SetBattleBackground(true);
		//		mapLayer->SetNeedShowBackground(false);
	}
	
	NDDirector::DefaultDirector()->EnableDispatchEvent(true);
	//	
	//	if(this->m_mapLayer){
	//		this->m_mapLayer->draw();
	//	}
	
	//	m_battleBg->draw();
	
	//if (eraseInOutEffect->isChangeComplete())
	this->battleRefresh();
	
	// 绘制参战单位
	drawFighter();
	
	//	if (!eraseInOutEffect->isChangeComplete()) {
	//		return;
	//	}
	
	// 绘制去血
	drawAllFighterHurtNumber();
	
//	switch (this->m_battleStatus) {
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
	
	this->drawSubAniGroup();
	
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
			for (VEC_FIGHTER_IT it = m_vAttaker.begin(); it != m_vAttaker.end(); it++)
			{
				if ((*it)->m_info.idObj == player.m_id)
				{
					m_mainFighter = (*it);
				}
			}
		}
		else
		{
			for (VEC_FIGHTER_IT it = m_vDefencer.begin(); it != m_vDefencer.end(); it++)
			{
				if ((*it)->m_info.idObj == player.m_id)
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
	Fighter* f=action->m_Actor;
	int team=0;
	if(f){
		team=(f->m_info.btBattleTeam-1)%3+1;
	}else{
		team=(action->team_Atk-1)%3+1;
	}
	
	switch(team){
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
			NDLog("can not addAction %d",team);
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
		Command* cmdNext = (*it)->cmdNext;
		while (cmdNext) {
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
	for (; it != m_vAttaker.end(); it++) {
		if ((*it)->m_info.idObj == idFighter) {
			return *it;
		}
	}
	
	for (it = m_vDefencer.begin(); it != m_vDefencer.end(); it++) {
		if ((*it)->m_info.idObj == idFighter) {
			return *it;
		}
	}
	
	return NULL;
}

void Battle::AddAnActionFighter(Fighter* fAction)
{
	for (VEC_FIGHTER_IT it = m_vActionFighterList.begin(); it != m_vActionFighterList.end(); it++)
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
	
	switch (this->battleCompleteResult) {
		case BATTLE_COMPLETE_WIN:
			psz = NDCommonCString("BattleSucc");
			break;
		case BATTLE_COMPLETE_LOSE:
			psz = NDCommonCString("BattleFail");
			break;
		case BATTLE_COMPLETE_NO:
			psz = NDCommonCString("BattleEnd");
			break;
//		case BATTLE_COMPLETE_END:
//			psz = NDCommonCString("BattleEnd");
//			break;
		default:
			psz = NDCommonCString("BattleShouGong");
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
	fighterSomeActionChangeToWait(m_vAttaker);
	fighterSomeActionChangeToWait(m_vDefencer);
	
	if (m_battleStatus == BS_SHOW_FIGHT && m_startWait <= 0) {
		
		this->ShowFight();
		
	} else if (m_battleStatus == BS_FIGHTER_SHOW_PAS) {
		if(AllFighterActionOK()){
			this->ShowPas();
		}
		
	} 
//	else {
//		if (!m_bWatch) {
//			if (m_bTurnStart) {
//				this->TurnStart();
//			} else if (m_bTurnStartPet) {
//				this->TurnStartPet();
//			}
//		}
//	}
	
	if (m_startWait>0)
	{
		m_startWait--;
	}
	
	//this->refreshFighterData();
}

bool Battle::sideRightAtk() {
	bool result = false;
	
	for (size_t i = 0; i < this->m_vActionFighterList.size(); i++) {
		Fighter& f = *m_vActionFighterList.at(i);
		if (f.m_info.group == BATTLE_GROUP_ATTACK) {
			if (f.m_action == Fighter::ATTACK || f.m_action == Fighter::SKILLATTACK) {
				result = true;
				break;
			}
		}
	}
	return result;
}

bool Battle::sideAttakerAtk() {
	bool result = false;
	
	for (size_t i = 0; i < m_vActionFighterList.size(); i++) {
		Fighter& f = *m_vActionFighterList.at(i);
		if (f.m_info.group == BATTLE_GROUP_ATTACK) {
			if (f.m_action == Fighter::ATTACK || f.m_action == Fighter::SKILLATTACK) {
				result = true;
				break;
			}
		}
	}
	return result;
}

void Battle::ShowTimerAndTurn(bool bShow)
{
	//	if (bShow) {
	//		this->AddChild(m_imgTimer);
	//		this->AddChild(m_lbTimer);
	//		this->AddChild(m_lbTimerTitle);
	//		
	//		this->AddChild(m_imgTurn);
	//		this->AddChild(m_lbTurn);
	//		this->AddChild(m_lbTurnTitle);
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
		setBattleStatus(BS_SET_FIGHTER);
		
		for (int i = 0; i < this->m_vCmdList.size(); i++)
		{
			NDLog("%d action",i);
			Command* cmd = this->m_vCmdList.at(i);
			
			if (cmd->complete)
			{// 针对连锁cmd
				continue;
			}
			FightAction* action=NULL;
			switch (cmd->btEffectType) {
				case BATTLE_EFFECT_TYPE_ATK://攻击
					NDLog("%d effect_atk",cmd->idActor);
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
					action=new FightAction(this->GetFighter(cmd->idActor),this->GetFighter(cmd->idTarget),BATTLE_EFFECT_TYPE(cmd->btEffectType));
					break;
				case BATTLE_EFFECT_TYPE_SKILL://技能
					NDLog("%d effect_skill",cmd->idActor);
					action=new FightAction(this->GetFighter(cmd->idActor),this->GetFighter(cmd->idTarget),BATTLE_EFFECT_TYPE(cmd->btEffectType));
					action->skill=cmd->skill;
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
					action->data=cmd->nHpLost;
					break;
					//				case BATTLE_EFFECT_TYPE_DODGE:// 闪避
					//					if (!theActor || !theTarget) {
					//						return;
					//					}
					//					
					//					theActor->m_effectType = EFFECT_TYPE(cmd->btEffectType);
					//					theActor->m_mainTarget = theTarget;
					//					theTarget->m_actor = (theActor);
					//					theActor->m_bMissAtk = (true);
					//					if (theActor->GetNormalAtkType() == ATKTYPE_NEAR) {
					//						theActor->m_action = (Fighter::MOVETOTARGET);
					//					} else if (theActor->GetNormalAtkType() == ATKTYPE_DISTANCE) {
					//						theActor->m_action = (Fighter::AIMTARGET);
					//					}
					//					theActor->m_actionType = (Fighter::ACTION_TYPE_NORMALATK);
					//					theActor->m_changeLifeType = EFFECT_CHANGE_LIFE_TYPE(cmd->btType);
					//					this->AddAnActionFighter(theActor);
					//					break;
					//					
					//				case EFFECT_TYPE_CHANGELIFE: // 去血
					//					if (cmd->btType == EFFECT_CHANGE_LIFE_TYPE_PHY_ATK || cmd->btType == EFFECT_CHANGE_LIFE_TYPE_PHY_HARDATK) {
					//						if (!theActor || !theTarget) {
					//							return;
					//						}
					//						
					//						theActor->m_changeLifeType = EFFECT_CHANGE_LIFE_TYPE(cmd->btType);
					//						theActor->m_effectType = EFFECT_TYPE(cmd->btEffectType);
					//						theActor->m_actionType = (Fighter::ACTION_TYPE_NORMALATK);
					//						theActor->m_mainTarget = theTarget;
					//						theTarget->m_actor = (theActor);
					//						
					//						theTarget->AddAHurt(theActor, cmd->btType, cmd->nHpLost, cmd->nMpLost, cmd->dwData, HURT_TYPE_ACTIVE);
					//						this->AddAnActionFighter(theActor);
					//						
					//						theTarget->m_bHardAtk = cmd->btType == EFFECT_CHANGE_LIFE_TYPE_PHY_HARDATK;
					//						
					//						if (cmd->triggerProtect && theTarget->protector) {
					//							theTarget->protector->m_action = (Fighter::MOVETOTARGET);
					//							theTarget->protector->m_actionType = Fighter::ACTION_TYPE_PROTECT;
					//						}
					//						
					//						// 状态为移向目标（近身），或者攻击（远程）
					//						if (theActor->GetNormalAtkType() == ATKTYPE_NEAR) {
					//							theActor->m_action = (Fighter::MOVETOTARGET);
					//						} else if (theActor->GetNormalAtkType() == ATKTYPE_DISTANCE) {
					//							theActor->m_action = (Fighter::AIMTARGET);
					//						}
					//					} else if (cmd->btType == EFFECT_CHANGE_LIFE_TYPE_USE_SKILL) {
					//						theActor->m_info.nMana += cmd->nMpLost;
					//						theActor->m_info.nLife += cmd->nHpLost;
					//						
					//					} else if (cmd->btType == EFFECT_CHANGE_LIFE_TYPE_SKILL_ATK || cmd->btType == EFFECT_CHANGE_LIFE_TYPE_SKILL_HARDATK) {
					//						theActor->m_changeLifeType = EFFECT_CHANGE_LIFE_TYPE(cmd->btType);
					//						theActor->m_effectType = EFFECT_TYPE(cmd->btEffectType);
					//						theActor->m_actionType = (Fighter::ACTION_TYPE_SKILLATK);
					//						
					//						theActor->m_mainTarget = theTarget;
					//						theActor->AddATarget(theTarget);
					//						theTarget->m_actor = (theActor);
					//						
					//						this->AddAnActionFighter(theActor);
					//						
					//						if (cmd->triggerProtect && theTarget->protector) {
					//							theTarget->protector->m_action = (Fighter::MOVETOTARGET);
					//							theTarget->protector->m_actionType = (Fighter::ACTION_TYPE_PROTECT);
					//						}
					//						
					//						theTarget->AddAHurt(theActor, cmd->btType, cmd->nHpLost, cmd->nMpLost, cmd->dwData, HURT_TYPE_ACTIVE);
					//						
					//						BattleSkill* skill = cmd->skill;
					//						if (skill) {
					//							theActor->setUseSkill(skill);
					//							if ((theActor->getUseSkill()->getAtkType() & SKILL_ATK_TYPE_NEAR) == SKILL_ATK_TYPE_NEAR) {
					//								theActor->m_action = (Fighter::MOVETOTARGET);
					//								theActor->setSkillAtkType(ATKTYPE_NEAR);
					//							} else if ((theActor->getUseSkill()->getAtkType() & SKILL_ATK_TYPE_REMOTE) == SKILL_ATK_TYPE_REMOTE) {
					//								theActor->m_action = (Fighter::AIMTARGET);
					//								theActor->setSkillAtkType(ATKTYPE_DISTANCE);
					//							}
					//						}
					//						
					//						theTarget->m_bHardAtk = cmd->btType == EFFECT_CHANGE_LIFE_TYPE_SKILL_HARDATK;
					//						
					//						Command* nextCmd = cmd->cmdNext;
					//						while (nextCmd) {
					//							if ((nextCmd->btType == EFFECT_CHANGE_LIFE_TYPE_SKILL_HARDATK
					//							     || nextCmd->btType == EFFECT_CHANGE_LIFE_TYPE_SKILL_ATK)
					//							    && nextCmd->idActor == cmd->idActor) {
					//								// 连锁技能
					//								theTarget = GetFighter(nextCmd->idTarget);
					//								theTarget->AddAHurt(theActor, cmd->btType,
					//										   nextCmd->nHpLost, nextCmd->nMpLost,
					//										   nextCmd->dwData, HURT_TYPE_ACTIVE);
					//								theActor->AddATarget(theTarget);
					//								theTarget->m_actor = (theActor);
					//								nextCmd->complete = (true);
					//							}
					//							theTarget->m_bHardAtk = cmd->btType == EFFECT_CHANGE_LIFE_TYPE_SKILL_HARDATK;
					//							nextCmd = nextCmd->cmdNext;
					//						}
					//					} else if (cmd->btType == EFFECT_CHANGE_LIFE_TYPE_SKILL_STATUS
					//						   || cmd->btType == EFFECT_CHANGE_LIFE_TYPE_CHG_MAX) {
					//						
					//						theTarget->m_changeLifeTypePas = EFFECT_CHANGE_LIFE_TYPE(cmd->btType);
					//						theTarget->AddPasStatus(cmd->dwData);
					//						
					//						theTarget->AddAHurt(NULL, cmd->btType, cmd->nHpLost, cmd->nMpLost, cmd->dwData, HURT_TYPE_PASSIVE);// 状态去血不要指定是被谁打的
					//						this->AddAnActionFighter(theTarget);
					//					} else if (cmd->btType == EFFECT_CHANGE_LIFE_TYPE_USE_ITEM) {
					//						
					//						theActor->m_idUsedItem = (cmd->dwData);
					//						theActor->m_changeLifeType = EFFECT_CHANGE_LIFE_TYPE(cmd->btType);
					//						theActor->m_effectType = EFFECT_TYPE(cmd->btEffectType);
					//						
					//						theActor->m_actionType = (Fighter::ACTION_TYPE_USEITEM);
					//						theActor->m_action = (Fighter::AIMTARGET);
					//						theActor->m_mainTarget = theTarget;
					//						theTarget->m_actor = (theActor);
					//						
					//						theTarget->AddAHurt(theActor, cmd->btType, cmd->nHpLost, cmd->nMpLost, cmd->dwData, HURT_TYPE_ACTIVE);
					//						this->AddAnActionFighter(theActor);
					//					} else if (cmd->btType == EFFECT_CHANGE_LIFE_TYPE_SKILL_STATUS_ADD
					//						   || cmd->btType == EFFECT_CHANGE_LIFE_TYPE_SKILL_STATUS_LOST) {
					//						// 在回合初收到状态消息，则马上处理
					//						Fighter* target = GetFighter(cmd->idTarget);
					//						
					//						target->addAStatus(cmd->status);
					//						Command* c = cmd->cmdNext;
					//						while (c) {
					//							target = GetFighter(c->idTarget);
					//							if (c->btType == EFFECT_CHANGE_LIFE_TYPE_SKILL_STATUS_ADD) {
					//								target->addAStatus(c->status);
					//							} else if (c->btType == EFFECT_CHANGE_LIFE_TYPE_SKILL_STATUS_LOST) {
					//								target->removeAStatusAniGroup(c->dwData);
					//							}
					//							c = c->cmdNext;
					//						}
					//					}
					//					if (cmd->btType == EFFECT_CHANGE_LIFE_TYPE_PROTECTED) {
					//						theActor->m_changeLifeType = EFFECT_CHANGE_LIFE_TYPE(cmd->btType);
					//						// 保护
					//						theActor->protectTarget = theActor->m_mainTarget;
					//						theActor->m_mainTarget->protector = theActor;
					//						theActor->hurtInprotect = cmd->nHpLost;
					//					}
					//					break;
					//					
					//				case EFFECT_TYPE_ESCAPE:
					//					if (!theActor) {
					//						return;
					//					}
					//					theActor->m_effectType = EFFECT_TYPE(cmd->btEffectType);
					//					
					//					theActor->m_action = (Fighter::FLEE_SUCCESS);
					//					this->AddAnActionFighter(theActor);
					//					theActor->m_bFleeNoDie = (true);
					//					break;
					//					
					//				case EFFECT_TYPE_ESCAPE_FAIL:
					//					if (!theActor) {
					//						return;
					//					}
					//					theActor->m_effectType = EFFECT_TYPE(cmd->btEffectType);
					//					
					//					theActor->m_action = (Fighter::FLEE_FAIL);
					//					this->AddAnActionFighter(theActor);
					//					break;
					//					
					//				case EFFECT_TYPE_DEFENCE:
					//					if (!theActor) {
					//						return;
					//					}
					//					theActor->m_effectType = EFFECT_TYPE(cmd->btEffectType);
					//					
					//					theActor->m_bDefenceOK = (true);
					//					theActor->m_action = (Fighter::DEFENCE);
					//					defenceAction(*theActor);
					//					this->AddAnActionFighter(theActor);
					//					break;
					//					
					//				case EFFECT_TYPE_LEFT:
					//					m_timeLeftMax = 29;
					//					break;
					//				case EFFECT_TYPE_CATCH:
					//					theActor->m_effectType = (EFFECT_TYPE_CATCH);
					//					theActor->m_actionType = (Fighter::ACTION_TYPE_CATCH);
					//					theActor->m_action = (Fighter::AIMTARGET);
					//					theActor->m_mainTarget = (theTarget);
					//					theActor->AddATarget(theTarget);
					//					theTarget->m_actor = (theActor);
					//					this->AddAnActionFighter(theActor);
					//					break;
					//				case EFFECT_TYPE_CATCH_FAIL:
					//					theActor->m_effectType = (EFFECT_TYPE_CATCH_FAIL);
					//					theActor->m_actionType = (Fighter::ACTION_TYPE_CATCH);
					//					theActor->m_action = (Fighter::AIMTARGET);
					//					theActor->m_mainTarget = (theTarget);
					//					theActor->AddATarget(theTarget);
					//					theTarget->m_actor = (theActor);
					//					this->AddAnActionFighter(theActor);
					//					break;
				default:
					break;
			}
			//处理主要动作后的连锁动作
			if (action) {
				Command* nextCmd = cmd->cmdNext;
				while (nextCmd) {
					
					FIGHTER_CMD* fcmd=new FIGHTER_CMD();
					
					switch(nextCmd->btEffectType){
						case BATTLE_EFFECT_TYPE_LIFE:
							NDLog("%d chageLife",nextCmd->idActor);
							fcmd->actor=nextCmd->idActor;
							fcmd->effect_type=BATTLE_EFFECT_TYPE_LIFE;
							fcmd->data=(int)nextCmd->nHpLost;
							break;
						case BATTLE_EFFECT_TYPE_MANA:
							NDLog("%d chageMana",nextCmd->idActor);
							fcmd->actor=nextCmd->idActor;
							fcmd->effect_type=BATTLE_EFFECT_TYPE_MANA;
							fcmd->data=(int)nextCmd->nMpLost;
							break;
						case BATTLE_EFFECT_TYPE_SKILL_TARGET:
							NDLog("%d skill_target",nextCmd->idTarget);
							if(action->effect_type==BATTLE_EFFECT_TYPE_SKILL){
								action->m_FighterList.push_back(GetFighter(nextCmd->idTarget));
								if(action->m_Target==NULL){
									action->m_Target=GetFighter(nextCmd->idTarget);
								}
							}
							nextCmd = nextCmd->cmdNext;
							continue;
						case BATTLE_EFFECT_TYPE_DODGE:
							NDLog("%d dodge",nextCmd->idActor);
							fcmd->actor=nextCmd->idActor;
							fcmd->effect_type=BATTLE_EFFECT_TYPE_DODGE;
							break;
						case BATTLE_EFFECT_TYPE_DRITICAL:
							NDLog("%d dritical",nextCmd->idActor);
							fcmd->actor=nextCmd->idActor;
							fcmd->effect_type=BATTLE_EFFECT_TYPE_DRITICAL;
							//							fcmd->data=(int)nextCmd->nHpLost;
							break;
						case BATTLE_EFFECT_TYPE_BLOCK:
							NDLog("%d block",nextCmd->idActor);
							fcmd->actor=nextCmd->idActor;
							fcmd->effect_type=BATTLE_EFFECT_TYPE_BLOCK;
							break;
						case BATTLE_EFFECT_TYPE_COMBO:
							NDLog("%d combo",nextCmd->idActor);
							action->isCombo=true;
							this->AddActionCommand(action);
							action=new FightAction(this->GetFighter(cmd->idActor),this->GetFighter(cmd->idTarget),BATTLE_EFFECT_TYPE(cmd->btEffectType));
							fcmd->actor=cmd->idTarget;
							fcmd->effect_type=BATTLE_EFFECT_TYPE_LIFE;
							fcmd->data=(int)nextCmd->nHpLost;
							action->addCommand(fcmd);
							nextCmd = nextCmd->cmdNext;
							continue;
						case BATTLE_EFFECT_TYPE_STATUS_ADD:
							fcmd->actor=nextCmd->idActor;
							fcmd->effect_type=BATTLE_EFFECT_TYPE_STATUS_ADD;
							fcmd->status=nextCmd->status;
							break;
						case BATTLE_EFFECT_TYPE_STATUS_LOST:
							fcmd->actor=nextCmd->idActor;
							fcmd->effect_type=BATTLE_EFFECT_TYPE_STATUS_LOST;
							fcmd->status=nextCmd->status;
							break;
						case BATTLE_EFFECT_TYPE_DEAD:
							fcmd->actor=nextCmd->idActor;
							fcmd->effect_type=BATTLE_EFFECT_TYPE_DEAD;
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
			}
			NDLog("addAction");
			this->AddActionCommand(action);
		}
		

		
		//		if (m_vActionFighterList.size() > 0) {
		//			Fighter* f = m_vActionFighterList.at(0);
		//			f->setBeginAction(true);
		//		}
		
		this->m_actionFighterPoint = 0;
		
		this->m_foreBattleStatus = 0;
		
		setBattleStatus(BS_SHOW_FIGHT);
		m_startWait=25;
	}
}

void Battle::RestartFight()
{
	this->ShowTimerAndTurn(false);
	
	this->RemoveChild(TAG_WAITING, true);
	this->clearHighlight();
	
	this->m_currentActionIndex1=0;
	this->m_currentActionIndex2=0;
	this->m_currentActionIndex3=0;
	this->m_Team1_status=TEAM_WAIT;
	this->m_Team2_status=TEAM_WAIT;
	this->m_Team3_status=TEAM_WAIT;
	
	setBattleStatus(BS_SHOW_FIGHT);
	m_startWait=25;
}

void Battle::StartFight()
{
	this->ShowTimerAndTurn(false);
	//this->RemoveChild(TAG_TIMER, false);
	if (!this->m_bWatch) {
		this->RemoveChild(TAG_WAITING, true);
		this->clearHighlight();
		if (s_bAuto) {
			//			this->RemoveChild(m_imgAutoCount, false);
			//			this->RemoveChild(m_lbAuto, false);
		}
		
//		switch (m_battleStatus) {
//			case BS_USER_MENU:
//				//this->RemoveChild(m_battleOpt, false);
//				break;
//			case BS_USE_ITEM_MENU:
//				//this->CloseItemMenu();
//				break;
//			case BS_CHOOSE_VIEW_FIGHTER_STATUS:
//				this->CloseViewStatus();
//				break;
//			case BS_USER_SKILL_MENU:
//				//this->CloseSkillMenu();
//				break;
//			default:
//				break;
//		}
	}
	dealWithCommand();
	this->m_currentActionIndex1=0;
	this->m_currentActionIndex2=0;
	this->m_currentActionIndex3=0;
	this->m_Team1_status=TEAM_WAIT;
	this->m_Team2_status=TEAM_WAIT;
	this->m_Team3_status=TEAM_WAIT;
}

bool Battle::AllFighterActionOK()
{
	bool result = true;
	
	//test 预防actionOK不了超时的问题。
	for (size_t i = 0; i < this->m_vActionFighterList.size(); i++) {
		Fighter* f = m_vActionFighterList.at(i);
		if(f->getActionTime() > 200) {
			f->setActionOK(true);
		}
	}
	
	// 判断action是否ok
	for (size_t i = 0; i < m_vActionFighterList.size(); i++) {
		Fighter* f = m_vActionFighterList.at(i);
		if (!f->isVisiable() || f->isActionOK() || (!f->isEscape() && !f->isAlive())) {
			continue;
		} else {
			result = false;
			break;
		}
	}
	// 判断状态动作是否完成。
	if (result == true) {
		return fighterStatusOK(m_vAttaker) && fighterStatusOK(m_vDefencer);
	}
	return result;
}

bool Battle::fighterStatusOK(VEC_FIGHTER& fighterList) {
	bool result = true;
	for (size_t i = 0; i < fighterList.size(); i++) {
		Fighter* f = fighterList.at(i);
		if (!f->isHurtOK() && !f->isDodgeOK() && !f->isDieOK()) {
			continue;
		} else {
			result = false;
			break;
		}
	}
	return result;
}

void Battle::notifyNextFighterBeginAction() {
	size_t idx = this->m_actionFighterPoint;
	
	if (idx >= m_vActionFighterList.size()) 
		return;
	
	Fighter* f = m_vActionFighterList.at(idx);
	Fighter* fNext = NULL;
	size_t i = 0;
	if (idx < m_vActionFighterList.size() - 1) {
		for (i = idx + 1; i < m_vActionFighterList.size(); i++) {
			Fighter* ftmp = m_vActionFighterList.at(i);
			if (ftmp->isAlive() && ftmp->isVisiable() && !ftmp->isBeginAction()) {
				fNext = ftmp;
				break;
			}
		}
	}
	if (fNext) {
		if (f->m_info.group == fNext->m_info.group) {// 同边的很快就开始动作
			if (f->completeOneAction()) {
				fNext->setBeginAction(true);
				this->m_actionFighterPoint = i;
			}
		} else {
			if (f->isActionOK() && !fNext->isHurtOK() && !fNext->isDodgeOK()
			    && !fNext->isDieOK()
			    || f->m_actionType == Fighter::ACTION_TYPE_PROTECT) {
				fNext->setBeginAction(true);
				this->m_actionFighterPoint = i;
			}
		}
	}
}

bool Battle::isPasClear() {
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

bool Battle::noOneCanAct(VEC_FIGHTER& fighterList) {
	bool result = false;
	if (fighterList.size() == 0) {
		result = true;
	}
	for (size_t i = 0; i < fighterList.size(); i++) {
		Fighter& f = *fighterList.at(i);
		if (f.isVisiable() && f.isAlive()) {
			break;
		} else if (i == fighterList.size() - 1) {
			result = true;
		}
	}
	return result;
}

BATTLE_COMPLETE Battle::battleComplete() {
	BATTLE_COMPLETE result =BATTLE_COMPLETE(this->serverBattleResult);
//	if (noOneCanAct(this->GetEnemySideList())) {
//		result = BATTLE_COMPLETE_WIN;
//		if (this->GetMainUser() == NULL || this->GetMainUser()->m_info.nLife > 0) {
//			monsterResult(this->GetEnemySideList());
//		}
//	}else if (noOneCanAct(this->GetOurSideList())) {
//		result = BATTLE_COMPLETE_LOSE;
//	}
//	
//	if(getServerBattleResult() != -2) {
//		result = BATTLE_COMPLETE(getServerBattleResult());
//	}
	monsterResult(this->GetEnemySideList());
	monsterResult(this->GetOurSideList());
	return result;
}

VEC_FIGHTER& Battle::GetOurSideList()
{
	if (m_ourGroup == BATTLE_GROUP_ATTACK) {
		return m_vAttaker;
	} else {
		return m_vDefencer;
	}
}

VEC_FIGHTER& Battle::GetEnemySideList()
{
	if (m_ourGroup == BATTLE_GROUP_DEFENCE) {
		return m_vAttaker;
	} else {
		return m_vDefencer;
	}
}

Fighter* Battle::getMainEudemon()
{
	if (!m_mainEudemon) {
		//Fighter* user = GetMainUser();
		//		if (user) {
		//PetInfo* petInfo = PetMgrObj.GetMainPet(NDPlayer::defaultHero().m_id);
		//if (petInfo) {
		//	VEC_FIGHTER& euList = GetOurSideList();
		//	for (size_t i = 0; i < euList.size(); i++) {
		//		Fighter* f =  euList.at(i);
		//		//					if (f->m_info.idPet == petInfo->data.int_PET_ID) {
		//		//						m_mainEudemon = f;
		//		//						break;
		//		//					}
		//		
		//	}
		//}
		
		//		}
	}
	
	return m_mainEudemon;
}

void Battle::setFighterToWait(VEC_FIGHTER& fighterList) {
	for (size_t i = 0; i < fighterList.size(); i++) {
		Fighter& f = *fighterList.at(i);
		if (!f.isVisiable()) {
			continue;
		}
		f.m_action = (Fighter::WAIT);
		if (f.isAlive()) {
			battleStandAction(f);
		}
	}
}

void Battle::setAllFightersToWait() {
	setFighterToWait(m_vAttaker);
	setFighterToWait(m_vDefencer);
}

void Battle::clearFighterStatus(Fighter& f) {
	f.clearFighterStatus();
	f.setBeginAction(false);
	f.m_bMissAtk = false;
	f.setHurtOK(false);
	f.setDodgeOK(false);
	f.setActionOK(false);
	f.setDefenceOK(false);
	f.setActionTime(0);
}

void Battle::clearActionFighterStatus() {
	for (size_t i = 0; i < m_vActionFighterList.size(); i++) {
		Fighter& f = *m_vActionFighterList.at(i);
		clearFighterStatus(f);
	}
	m_vActionFighterList.clear();
}

void Battle::FinishBattle()
{
	/***
	* 临时性注释 郭浩
	*/
// 	NDMapMgrObj.BattleEnd(BattleMgrObj.GetBattleReward()->battleResult);
// 	//m_timer.SetTimer(this, TIMER_BACKTOGAME, 1);
// 	BattleMgrObj.quitBattle();
}

void Battle::ShowPas()
{
	setBattleStatus(BS_BATTLE_COMPLETE);
	this->battleCompleteResult = battleComplete();
	//this->showBattleComplete();
	// 退出战斗,地图逻辑处理
	
	if(this->currentShowFighter>0)
	{
		//ScriptMgrObj.excuteLuaFunc("CloseFighterInfo","FighterInfo",0); ///< 临时性注释 郭浩
	}
	BattleMgrObj.showBattleResult();
	//	if (isPasClear() && AllFighterActionOK()) {
	//		this->battleCompleteResult = battleComplete();
	//		
	//		if (this->battleCompleteResult != BATTLE_COMPLETE_NO) {
	//			setBattleStatus(BS_BATTLE_COMPLETE);
	//			this->showBattleComplete();
	//		} else {// 战斗还未结束,回合结束
	//			if (m_vCmdList.size() > 0) {// 已经存了不少服务端提前发来的指令。不再收集玩家指令了。
	//				setBattleStatus(BS_SET_FIGHTER);
	//				
	//			} else {
	//				if (this->GetMainUser()) {
	//					setBattleStatus(BS_USER_MENU);// 先进入玩家指令状态，在根据具体情况改变。
	//					
	//					if (!this->GetMainUser()->isAlive()) {// 如果玩家死了，有宠物就弹出宠物的指令
	//						if (this->getMainEudemon()) {// 如果玩家有宠物
	//							if (this->getMainEudemon()->isVisiable()) {
	//								setBattleStatus(BS_EUDEMON_MENU);
	//							}
	//						} else {// 玩家又没有宠物
	//							setBattleStatus(BS_USER_MENU);// 进入该状态，应为玩家的死亡状态等，指令框不会弹出
	//						}
	//					} else {// 如果玩家活着
	//						if (GetMainUser()->isVisiable()) {// 而且玩家没有逃跑，就是用玩家指令
	//							setBattleStatus(BS_USER_MENU);
	//							this->m_bSendCurTurnUserAction = false;
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
	//							//this->AddChild(this->m_battleOpt);
	//							m_bTurnStart = true;
	//						}
	//					} 
	//					else if (m_battleStatus == BS_EUDEMON_MENU) 
	//					{
	//						if (s_bAuto) {
	//							this->OnBtnAuto(true);
	//						} else {
	//							//this->AddChild(this->m_eudemonOpt);
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
	//						if (this->getMainEudemon()) {// 如果玩家有宠物
	//							if (this->getMainEudemon()->isVisiable()) {
	//								setBattleStatus(BS_EUDEMON_MENU);
	//								if (s_bAuto) {
	//									this->OnBtnAuto(true);
	//								} else {
	//									//this->AddChild(this->m_eudemonOpt);
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
	//			this->m_timeLeft = this->m_timeLeftMax;
	//			{
	//				stringstream ss;
	//				ss << this->m_timeLeft;
	////				m_lbTimer->SetText(ss.str().c_str());
	//			}
	//			this->ShowTimerAndTurn(true);
	//			//m_imgTimer->SetBigRedNumber(, false);
	////			if (m_lbTimer->GetParent() == NULL) {
	////				this->AddChild(m_lbTimer);
	////			}
	//			
	//			// 更新倒计时
	////			if (s_bAuto && this->m_mainFighter->isAlive()) {
	////				this->AddChild(m_imgAutoCount);
	////				this->AddChild(m_lbAuto);
	////				this->m_autoCount = AUTO_COUNT;
	////				m_imgAutoCount->SetBigRedNumber(this->m_autoCount, false);
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

void Battle::performStatus(Fighter& theTarget) {
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
	//				addHP = hurtHP - theTarget.m_info.nLifeMax;
	//				theTarget.m_info.nLifeMax = (hurtHP);
	//				currentHP = theTarget.m_info.nLife;
	//				currentHP += addHP;
	//				theTarget.hurted(addHP);
	//				
	//			} else {
	//				currentHP = theTarget.m_info.nLife;
	//				currentHP += hurtHP;
	//				theTarget.hurted(hurtHP);
	//			}
	//			if (!this->IsPracticeBattle()) {
	//				theTarget.setCurrentHP(currentHP);
	//			}
	//			currentHP = theTarget.m_info.nLife;
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
	//				addMP = hurtMP - theTarget.m_info.nManaMax;
	//				theTarget.m_info.nManaMax = (hurtMP);
	//				currentMP = theTarget.m_info.nMana;
	//				currentMP += addMP;
	//				theTarget.hurted(addMP);
	//				theTarget.setCurrentMP(currentMP);
	//			} else {
	//				currentMP = theTarget.m_info.nMana;
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

bool Battle::isActionCanBegin(FightAction* action){
	Fighter* fighter=action->m_Actor;
	if(fighter){
		if(!fighter->isAlive()){
			action->action_status=ACTION_STATUS_FINISH;
			NDLog("fighter already dead,action skip");
			return false;
		}
		if (fighter->isActionOK() && !fighter->isHurtOK() && !fighter->isDodgeOK()&&!fighter->isDefenceOK()
			&& !fighter->isDieOK()){
			return true;
		}else{
			return false;
		}
	}else{
		if(action->effect_type==EFFECT_TYPE_BATTLE_BEGIN){
			TEAM_STATUS status;
			switch(action->team_Atk){
				case 1:
					status=m_Team1_status;
					break;
				case 2:
					status=m_Team2_status;
					break;
				case 3:
					status=m_Team3_status;
					break;
				default:
					break;
			}
			if(status==TEAM_WAIT){
				return true;
			}else{
				return false;
			}
		}
		return true;
	}
}

VEC_FIGHTER& Battle::getDefFightersByTeam(int team){
		VEC_FIGHTER v_team;
		for (VEC_FIGHTER::iterator it = m_vDefencer.begin(); it != m_vDefencer.end(); it++) {
			Fighter* f = *it;
			if (f->m_info.btBattleTeam==team) {
	
				v_team.push_back(f);
			}
		}
		return v_team;
}

void Battle::startAction(FightAction* action){
	switch (action->effect_type) {
		case BATTLE_EFFECT_TYPE_ATK:
			if (action->m_Actor->GetNormalAtkType() == ATKTYPE_NEAR) {
				action->m_Actor->m_action=Fighter::MOVETOTARGET;
			} else if (action->m_Actor->GetNormalAtkType() == ATKTYPE_DISTANCE) {
				action->m_Actor->m_action=Fighter::AIMTARGET;
			}
			break;
		case BATTLE_EFFECT_TYPE_SKILL:
			if(action->skill->getAtkType()==SKILL_ATK_TYPE_REMOTE){
				action->m_Actor->m_action=Fighter::AIMTARGET;
			}else{
				action->m_Actor->m_action=Fighter::MOVETOTARGET;
			}
			break;
		case EFFECT_TYPE_BATTLE_BEGIN:
			//			NDLog("START_MOVE_TEAM");
			for (VEC_FIGHTER_IT it = m_vAttaker.begin(); it != m_vAttaker.end(); it++) {
				Fighter* f = *it;
				if (f->m_info.btBattleTeam==action->team_def) {
					f->m_action=Fighter::MOVETOTARGET;
					f->targetX=countX(this->m_teamAmout,f->m_info.group,(action->team_def-1)%3+1,f->m_info.btStations);
					f->targetY=countY(this->m_teamAmout,f->m_info.group,(action->team_def-1)%3+1,f->m_info.btStations);
					action->m_FighterList.push_back(f);
				}
			}
			switch(action->team_Atk){
				case 1:
					m_Team1_status=TEAM_FIGHT;
					break;
				case 2:
					m_Team2_status=TEAM_FIGHT;
					break;
				case 3:
					m_Team3_status=TEAM_FIGHT;
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
	action->action_status=ACTION_STATUS_PLAY;
}

void Battle::runAction(int teamId){
	int currentIndex=0;
	VEC_FIGHTACTION* actionList;
	switch (teamId) {
		case 1:
			currentIndex=m_currentActionIndex1;
			actionList=&(BattleMgrObj.m_vActionList1);
			break;
		case 2:
			currentIndex=m_currentActionIndex2;
			actionList=&(BattleMgrObj.m_vActionList2);
			break;
		case 3:
			currentIndex=m_currentActionIndex3;
			actionList=&(BattleMgrObj.m_vActionList3);
			break;
		default:
			break;
	}
	
	FightAction* fa=NULL;
	if(currentIndex<actionList->size()){
		fa=actionList->at(currentIndex);
	}else {//actio列表已取完
		//NDLog("%d no more action,battle end",teamId);
		switch (teamId) {
			case 1:
				m_Team1_status=TEAM_OVER;
				break;
			case 2:
				m_Team2_status=TEAM_OVER;
				break;
			case 3:
				m_Team3_status=TEAM_OVER;
				break;
			default:
				break;
		}
		return;
	}
	
	
	notifyNextFighterBeginAction();
	
	if (fa) {
		if(fa->m_Actor){
			fa->m_Actor->actionTimeIncrease();
		}
		
		if (fa->action_status==ACTION_STATUS_FINISH) {
			currentIndex++;
			switch (teamId) {
				case 1:
					m_currentActionIndex1=currentIndex;
					break;
				case 2:
					m_currentActionIndex2=currentIndex;
					break;
				case 3:
					m_currentActionIndex3=currentIndex;
					break;
				default:
					break;
			}
			if(currentIndex<actionList->size()){
				fa=actionList->at(currentIndex);
				//NDLog("team:%d index %d",teamId,currentIndex);
				if(isActionCanBegin(fa)){
					startAction(fa);
				}else{
					return;
				}
			}else{
				return;
			}
		}else if(fa->action_status==ACTION_STATUS_WAIT){
			if(isActionCanBegin(fa)){
				startAction(fa);
			}else{
				return;
			}
		}
		
		
		
		switch (fa->effect_type) {
			case BATTLE_EFFECT_TYPE_ATK:
				if (fa->m_Actor->GetNormalAtkType() == ATKTYPE_NEAR) {
					moveToTarget(fa);
					//						if (f->m_mainTarget->protector) {
					//							moveToTarget(*f->m_mainTarget->protector);
					//						}
					normalAttack(fa);
					moveBack(fa);
					//						if (f->m_mainTarget->protector) {
					//							moveBack(*f->m_mainTarget->protector);
					//						}
				} else if (fa->m_Actor->GetNormalAtkType() == ATKTYPE_DISTANCE) {
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
				if(fa->skill->getAtkType()==SKILL_ATK_TYPE_REMOTE){
					aimTarget(fa);
					//						if (f->m_mainTarget->protector) {
					//							moveToTarget(*f->m_mainTarget->protector);
					//						}
					distanceSkillAttack(fa);
					distanceAttackOver(fa);
				}else{
					moveToTarget(fa);
					skillAttack(fa);
					moveBack(fa);
				}
				//						if (f->m_mainTarget->protector) {
				//							moveBack(*f->m_mainTarget->protector);
				//						}
				//					}
				break;
			case EFFECT_TYPE_BATTLE_BEGIN://战斗开始时，把队伍移动到战斗位
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
				switch(fa->team_Atk){
					case 1:
						m_Team1_status=TEAM_WAIT;
						break;
					case 2:
						m_Team2_status=TEAM_WAIT;
						break;
					case 3:
						m_Team3_status=TEAM_WAIT;
						break;
					default:
						break;
				}
				fa->action_status=ACTION_STATUS_FINISH;
				break;
			case BATTLE_EFFECT_TYPE_STATUS_LIFE://状态去血
				fa->m_Actor->hurted(fa->data);
				fa->m_Actor->setCurrentHP((fa->m_Actor->m_info.nLife)+(fa->data));
				if (fa->m_Actor->m_info.nLife > 0) {// hurt
					fa->m_Actor->setHurtOK(true);
					hurtAction(*(fa->m_Actor));
				} else {// die
					fa->m_Actor->setDieOK(true);
					stringstream ss;
					ss << "die_action.spr";
					const char* file = NDPath::GetAniPath(ss.str().c_str());
					NDAnimationGroup* dieAniGroup = new NDAnimationGroup;
					dieAniGroup->initWithSprFile(file);
					addSkillEffectToFighter(fa->m_Actor,dieAniGroup,0);
					fa->m_Actor->showFighterName(false);
					dieAction(*(fa->m_Actor));
				}
				fa->action_status=ACTION_STATUS_FINISH;
				break;
			default:
				break;
		}
	}
	
	
}

void Battle::ShowFight()
{
	if(m_Team1_status!=TEAM_OVER){
		runAction(1);
	}
	if(m_Team2_status!=TEAM_OVER){
		runAction(2);
	}
	if(m_Team3_status!=TEAM_OVER){
		runAction(3);
	}
	if(m_Team1_status==TEAM_OVER&&m_Team2_status==TEAM_OVER&&m_Team3_status==TEAM_OVER){
		setBattleStatus(BS_FIGHTER_SHOW_PAS);
		//ReleaseActionList();
		this->ReleaseCommandList();

	}
	//	if (this->AllFighterActionOK()) {
	//		setBattleStatus(BS_FIGHTER_SHOW_PAS);
	//	}
}

void Battle::useItem(Fighter& theActor) {
	if (theActor.m_action == Fighter::USEITEM) {// 暂时没有使用道具的动作，而且是对自己使用补充物品
		if (theActor.GetRole()->IsAnimationComplete()) {
			Fighter& target = *theActor.m_mainTarget;
			
			Hurt hurt = target.getHurt(&theActor, 0, theActor.m_idUsedItem, HURT_TYPE_ACTIVE).second;
			
			int hurtHP = hurt.hurtHP;
			
			if (hurtHP > 0) {
				int currentHP = target.m_info.nLife;
				int addHP = hurtHP;
				currentHP += addHP;
				if (currentHP > target.m_info.nLifeMax) {
					currentHP = target.m_info.nLifeMax;
				}
				target.hurted(addHP);
				if (!this->IsPracticeBattle()) {
					target.setCurrentHP(currentHP);
				}
				//处理复活
				if (!target.isAlive()) {
					target.setAlive(true);
					clearFighterStatus(target);
					battleStandAction(target);
					watchBattle = false;
				}
			}
			
			int hurtMP = hurt.hurtMP;
			
			if (hurtMP > 0) {
				int currentMP = target.m_info.nMana;
				int addMP = hurtMP;
				currentMP += addMP;
				if (currentMP > target.m_info.nManaMax) {
					currentMP = target.m_info.nManaMax;
				}
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

void Battle::catchPet(Fighter& f) {
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
	//			handleStatusActions(this->theActor->getArrayStatusTarget());
	//			// 设置下一状态
	//			f.m_action = (Fighter::DISTANCEATTACKOVER);
	//			battleStandAction(f);
	//		}
	//	}
}

void Battle::defence(Fighter& theActor) {
	if (theActor.m_action == Fighter::DEFENCE) {
		if (theActor.GetRole()->IsAnimationComplete()) {
			theActor.setActionOK(true);
			// 动作后触发状态变化
			handleStatusActions(theActor.getArrayStatusTarget());
		}
	}
}

void Battle::fleeFail(Fighter& theActor) {
	if (theActor.m_action == Fighter::FLEE_FAIL) {
		if (!this->bActionSet) {
			fleeFailAction(theActor);
			this->bActionSet = true;
		}
		if (theActor.GetRole()->IsAnimationComplete()) {
			theActor.setActionOK(true);
			// 动作后触发状态变化
			handleStatusActions(theActor.getArrayStatusTarget());
			battleStandAction(theActor);
			this->bActionSet = false;
		}
	}
}

void Battle::fleeSuccess(Fighter& theActor) {
	if (theActor.m_action == Fighter::FLEE_SUCCESS) {
		if (!this->bActionSet) {
			this->bActionSet = true;
			fleeSuccessAction(theActor);
		}
		if (theActor.GetRole()->IsAnimationComplete()) {
			if (theActor.m_info.idObj == NDPlayer::defaultHero().m_id) {// 如果是自己逃跑了或者死了
				// ，就观战
				this->watchBattle = true;
				//				this->m_imgWhoAmI->RemoveFromParent(true);
				//				m_imgWhoAmI = NULL;
			}
			// 动作后触发状态变化
			handleStatusActions(theActor.getArrayStatusTarget());
			theActor.setActionOK(true);
			theActor.setEscape(true);
			this->bActionSet = false;
		}
	}
}

void Battle::moveTeam(FightAction* action){
	
	VEC_FIGHTER* v_fighters=&(action->m_FighterList);
	bool isOk=true;
	if(v_fighters){
		for(int i=0;i<v_fighters->size();i++){
			Fighter* f=v_fighters->at(i);
			if (f->StandInOrigin()) {
				moveToTargetAction(*f);
			}
			if(f->moveTo(f->targetX,f->targetY)){
				f->m_action = (Fighter::WAIT);
				battleStandAction(*f);
				f->setOriginPos(f->targetX, f->targetY);
				f->setActionOK(true);
			}else{
				isOk=false;
			}
		}
	}
	if(isOk){
		action->action_status=ACTION_STATUS_FINISH;
		for (int i = 0; i < action->m_vCmdList.size(); i++)
		{
			FIGHTER_CMD* cmd = action->m_vCmdList.at(i);
			dealWithFighterCmd(cmd);
		}
	}
}

void Battle::moveToTarget(FightAction* action) {
	Fighter* theActor=action->m_Actor;
	if (theActor->m_action == Fighter::MOVETOTARGET) {
		
		NDBaseRole* role = theActor->GetRole();
		
		int coordw = role->GetWidth() >> 1;
		//		if (theActor.m_info.group != this->m_ourGroup) {
		//			coordw = -coordw;
		//		}
		if (theActor->m_info.group == BATTLE_GROUP_ATTACK) {
			coordw = -coordw;
		}
		
		if (theActor->m_actionType == Fighter::ACTION_TYPE_PROTECT) {
			coordw = -coordw;
		}
		
		if (theActor->StandInOrigin()) {
			moveToTargetAction(*(action->m_Actor));
		}
		
		int roleOffset = 0;
		
		
		//		if (role->IsKindOfClass(RUNTIME_CLASS(NDManualRole)) &&
		//		    theActor.m_mainTarget->GetRole()->IsKindOfClass(RUNTIME_CLASS(NDManualRole))) {
		//			roleOffset = theActor.m_info.group == BATTLE_GROUP_ATTACK ? 60 : -60;
		//		}
		if(action->m_Target){
			if (theActor->moveTo(action->m_Target->getOriginX() + coordw + roleOffset, action->m_Target->getOriginY())) {// 如果返回到达目的地
				if (action->effect_type==BATTLE_EFFECT_TYPE_ATK) {
					theActor->m_action = (Fighter::ATTACK);
					attackAction(*theActor);
				} else if (action->effect_type==BATTLE_EFFECT_TYPE_SKILL) {

					theActor->m_action = (Fighter::SKILLATTACK);
					//处理技能动作
					BattleSkill* skill=action->skill;
					theActor->setSkillName(skill->getName());
					theActor->showSkillName(true);
					int actId=skill->GetActId();
//					if(theActor->m_lookfaceType==LOOKFACE_MANUAL){
						roleAction(*theActor, MANUELROLE_ATTACK);
//					}else{
//						petAction(*theActor, actId);
//					}
					//处理技能光效
//					int effectId=skill->GetLookfaceID()/100;
//					if(effectId!=0){//光效播放在自已身上
//						int delay=skill->GetLookfaceID()%100;
//						stringstream ss;
//						ss << "effect_" << effectId << ".spr";
//						NSString* file = [NSString stringWithUTF8String:GetAniPath(ss.str().c_str())];
//						NDAnimationGroup* effect = [[NDAnimationGroup alloc] initWithSprFile:file];
//						NDLog("add self effect");
//						addSkillEffectToFighter(theActor,effect,delay);
//					}
//					effectId=skill->GetLookfaceTargetID()/100;//光效播放在目标身上
//					if(effectId!=0){
//						int delay=skill->GetLookfaceTargetID()%100;
//						stringstream ss;
//						ss << "effect_" << effectId << ".spr";
//						NSString* file = [NSString stringWithUTF8String:GetAniPath(ss.str().c_str())];
//						NDAnimationGroup* effect = [[NDAnimationGroup alloc] initWithSprFile:file];
//						for (int i = 0; i < action->m_FighterList.size(); i++)
//						{	
//							Fighter* f=action->m_FighterList.at(i);
//							addSkillEffectToFighter(f, effect,delay);
//						}
//					}
				}
			}
		}else{
			if (action->effect_type==BATTLE_EFFECT_TYPE_ATK) {
				theActor->m_action = (Fighter::ATTACK);
				attackAction(*theActor);
			} else if (action->effect_type==BATTLE_EFFECT_TYPE_SKILL) {
				
				theActor->showSkillName(true);
				theActor->m_action = (Fighter::SKILLATTACK);
				//处理技能动作
				BattleSkill* skill=action->skill;
				int actId=skill->GetActId();
//				if(theActor->m_lookfaceType==LOOKFACE_MANUAL){
					roleAction(*theActor, MANUELROLE_ATTACK);
//				}else{
//					petAction(*theActor, 0);
//				}
				//处理技能光效
//				int effectId=skill->GetLookfaceID()/100;
//				if(effectId!=0){//光效播放在自已身上
//					int delay=skill->GetLookfaceID()%100;
//					stringstream ss;
//					ss << "effect_" << effectId << ".spr";
//					NSString* file = [NSString stringWithUTF8String:GetAniPath(ss.str().c_str())];
//					NDAnimationGroup* effect = [[NDAnimationGroup alloc] initWithSprFile:file];
//					
//					addSkillEffectToFighter(theActor,effect,delay);
//				}
//				effectId=skill->GetLookfaceTargetID()/100;//光效播放在目标身上
//				if(effectId!=0){
//					int delay=skill->GetLookfaceTargetID()%100;
//					stringstream ss;
//					ss << "effect_" << effectId << ".spr";
//					NSString* file = [NSString stringWithUTF8String:GetAniPath(ss.str().c_str())];
//					NDAnimationGroup* effect = [[NDAnimationGroup alloc] initWithSprFile:file];
//					for (int i = 0; i < action->m_FighterList.size(); i++)
//					{	
//						NDLog("add effect");
//						Fighter* f=action->m_FighterList.at(i);
//						addSkillEffectToFighter(f, effect,delay);
//					}
//				}
			}
		}
	}
}

void Battle::dealWithFighterCmd(FIGHTER_CMD* cmd){
	Fighter* fighter=GetFighter(cmd->actor);
	NDLog("%d cmd:%d",cmd->actor,cmd->effect_type);
	if(fighter){
		switch(cmd->effect_type){
			case BATTLE_EFFECT_TYPE_LIFE:
				fighter->m_bHardAtk=false;
				fighter->hurted(cmd->data);
				NDLog("hurt %d",cmd->data);
				fighter->setCurrentHP((fighter->m_info.nLife)+(cmd->data));
				if (fighter->m_info.nLife > 0) {// hurt
					fighter->setHurtOK(true);
					if(cmd->data<0){
						hurtAction(*fighter);
					}
				} else {// die
					fighter->setDieOK(true);
					dieAction(*fighter);
					stringstream ss;
					ss << "die_action.spr";
					const char* file = NDPath::GetAniPath(ss.str().c_str());
					NDAnimationGroup* dieAniGroup = new NDAnimationGroup;
					dieAniGroup->initWithSprFile(file);
					fighter->showFighterName(false);
					addSkillEffectToFighter(fighter,dieAniGroup,0);
				}
				break;
			case BATTLE_EFFECT_TYPE_MANA:
				fighter->setCurrentMP((fighter->m_info.nMana)+(cmd->data));
				break;
			case BATTLE_EFFECT_TYPE_DODGE:
				fighter->setDodgeOK(true);
				dodgeAction(*fighter);
				break;
			case BATTLE_EFFECT_TYPE_DRITICAL:
				fighter->m_bHardAtk=true;
				//				fighter->hurted(cmd->data);
				//				fighter->setCurrentHP((fighter->m_info.nLife)+(cmd->data));
				//				if (fighter->m_info.nLife > 0) {// hurt
				//					fighter->setHurtOK(true);
				//					if(cmd->data<0){
				//						hurtAction(*fighter);
				//					}
				//				} else {// die
				//					fighter->setDieOK(true);
				//					dieAction(*fighter);
				//				}
				break;
			case BATTLE_EFFECT_TYPE_BLOCK:
				fighter->setDefenceOK(true);
				defenceAction(*fighter);
				break;
			case BATTLE_EFFECT_TYPE_STATUS_ADD:
//				if (cmd->status->m_LastEffectID  != 999) {
//					stringstream ss;
//					ss << "effect_" << cmd->status->m_LastEffectID  << ".spr";
//					NDAsssert(cmd->status->m_aniGroup == NULL);
//					//				ss << "effect_" << cmd->status->m_StartEffectID << ".spr";
//					NSString* file = [NSString stringWithUTF8String:GetAniPath(ss.str().c_str())];
//					cmd->status->m_aniGroup=new NDSubAniGroup;
//					NDAnimation* effect=[[NDAnimationGroup alloc] initWithSprFile:file];
//					cmd->status->m_aniGroup->aniGroup = [effect retain];
//					//subAniGroup.aniGroup.position=CGPointMake(this->x, this->y);
//					
//					cmd->status->m_aniGroup->role = fighter->GetRole();
//					
//					cmd->status->m_aniGroup->fighter = fighter;
//					cmd->status->m_aniGroup->frameRec = [[NDFrameRunRecord alloc] init];
//					[effect release];
//				}
//				fighter->addAStatus(cmd->status);
//				if(cmd->status->m_StartEffectID!=0){
//					stringstream ss;
//					ss << "effect_" << cmd->status->m_StartEffectID << ".spr";
//					NSString* file = [NSString stringWithUTF8String:GetAniPath(ss.str().c_str())];
//					NDAnimationGroup* effect = [[NDAnimationGroup alloc] initWithSprFile:file];
//					
//					addSkillEffectToFighter(fighter,effect,0);
//				}
				break;
			case BATTLE_EFFECT_TYPE_STATUS_LOST:
//				fighter->removeAStatusAniGroup(cmd->status);
				break;
			default:
				break;
		}
	}
}

void Battle::normalAttack(FightAction* action) {
	Fighter* theActor=action->m_Actor;
	if (theActor->m_action == Fighter::ATTACK) {
		NDBaseRole* role = theActor->GetRole();
		if (role->IsAnimationComplete()) {
			NDLog("%d:normalATK",theActor->m_info.idObj);
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
			//				int currentHP = theTarget->m_info.nLife;
			//				int hurtHP = theTarget->getHurt(&theActor, 1, 0, HURT_TYPE_ACTIVE).second.hurtHP;
			//				currentHP += hurtHP;
			//				theTarget->hurted(hurtHP);
			//				if (!this->IsPracticeBattle()) {
			//					theTarget->setCurrentHP(currentHP);
			//				}
			//				if (theTarget->m_info.nLife > 0) {// hurt
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
			if(!action->isCombo){
				theActor->m_action = (Fighter::MOVEBACK);
				moveBackAction(*theActor);
			}else{
				theActor->m_action = (Fighter::WAIT);
				theActor->setActionOK(true);
				battleStandAction(*theActor);
				action->action_status=ACTION_STATUS_FINISH;
			}
		}
	}
}

void Battle::moveBack(FightAction* action) {
	Fighter* theActor=action->m_Actor;
	if (theActor->m_action == Fighter::MOVEBACK) {
		if (theActor->moveTo(theActor->getOriginX(), theActor->getOriginY())) {
			theActor->m_action = (Fighter::WAIT);
			theActor->setActionOK(true);
			battleStandAction(*theActor);
			action->action_status=ACTION_STATUS_FINISH;
			//			if (theActor.protectTarget) {
			//				theActor.protectTarget->protector = NULL;
			//				theActor.protectTarget = NULL;
			//			}
		}
	}
}

void Battle::addSkillEffectToFighter(Fighter* fighter,NDAnimationGroup* effect,int delay) {
	//	Fighter* theActor=action->m_Actor;
	
	//	//处理技能动作
	//	int actId=0;
	//	if(fighter>m_role->IsKindOfClass(RUNTIME_CLASS(NDManualRole))){
	//		roleAction(*fighter, actId);
	//	}else{
	//		petAction(*fighter, actId);
	//	}
	//	   
	//	//处理光效
	//	int effectId=0;
	//	int effectDelay=0;
	//	if (effectId > 899) return;
	
	//	stringstream ss;
	//	ss << "effect_" << effectId << ".spr";
	//	NSString* file = [NSString stringWithUTF8String:GetAniPath(ss.str().c_str())];
	//	NDAnimationGroup* effect = [[NDAnimationGroup alloc] initWithSprFile:file];
	
	NDLog("add skill effect");
	NDSubAniGroup sa;
	sa.role = fighter->GetRole();
	sa.fighter = fighter;
	sa.aniGroup = effect;
	sa.frameRec = new NDFrameRunRecord;
	sa.isFromOut = true;
	sa.startFrame = delay;
	this->m_vSubAniGroup.push_back(sa);
	
	//effect->release();
}

void Battle::addSkillEffect(Fighter& theActor, bool user/*=false*/) {
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
//		NSString* file = [NSString stringWithUTF8String:GetAniPath(ss.str().c_str())];
//		NDAnimationGroup* effect = [[NDAnimationGroup alloc] initWithSprFile:file];
//		
//		int target = skillId % 10;
//		switch (target) {
//			case 0:// 0光效在目标身上
//			{
//				VEC_FIGHTER& allTarget = theActor.getArrayTarget();
//				int size = allTarget.size();
//				for (int i = 0; i < size; i++) {
//					if (allTarget.at(i)->m_info.group == theActor.m_mainTarget->m_info.group) {
//						NDSubAniGroup sa;
//						sa.role = theActor.GetRole();
//						sa.fighter = allTarget.at(i);
//						sa.aniGroup = [effect retain];
//						sa.frameRec = [[NDFrameRunRecord alloc] init];
//						sa.isFromOut = true;
//						sa.startFrame = effectDelay;
//						this->m_vSubAniGroup.push_back(sa);
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
//				this->m_vSubAniGroup.push_back(sa);
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

void Battle::aimTarget(FightAction* action) {
	Fighter* theActor=action->m_Actor;
	if (theActor->m_action == Fighter::AIMTARGET) {
		if (action->effect_type == BATTLE_EFFECT_TYPE_ATK) {
			theActor->m_action = (Fighter::DISTANCEATTACK);
			attackAction(*theActor);
		} else if (action->effect_type == BATTLE_EFFECT_TYPE_SKILL) {
			theActor->m_action = (Fighter::DISTANCESKILLATTACK);
			//处理技能动作
			BattleSkill* skill=action->skill;
			theActor->setSkillName(skill->getName());
			theActor->showSkillName(true);
			int actId=skill->GetActId();
//			if(theActor->m_lookfaceType==LOOKFACE_MANUAL){
				roleAction(*theActor, MANUELROLE_ATTACK);
//			}else{
//				petAction(*theActor, 0);
//			}
			//处理技能光效
//			int effectId=skill->GetLookfaceID()/100;
//			if(effectId!=0){//光效播放在自已身上
//				int delay=skill->GetLookfaceID()%100;
//				stringstream ss;
//				ss << "effect_" << effectId << ".spr";
//				NSString* file = [NSString stringWithUTF8String:GetAniPath(ss.str().c_str())];
//				NDAnimationGroup* effect = [[NDAnimationGroup alloc] initWithSprFile:file];
//				
//				addSkillEffectToFighter(theActor,effect,delay);
//			}
//			effectId=skill->GetLookfaceTargetID()/100;//光效播放在目标身上
//			if(effectId!=0){
//				int delay=skill->GetLookfaceTargetID()%100;
//				stringstream ss;
//				ss << "effect_" << effectId << ".spr";
//				NSString* file = [NSString stringWithUTF8String:GetAniPath(ss.str().c_str())];
//				NDAnimationGroup* effect = [[NDAnimationGroup alloc] initWithSprFile:file];
//				for (int i = 0; i < action->m_FighterList.size(); i++)
//				{	
//					Fighter* f=action->m_FighterList.at(i);
//					addSkillEffectToFighter(f, effect,delay);
//				}
//			}
			
			//			if (theActor.m_info.fighterType == FIGHTER_TYPE_PET) { // 玩家
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

void Battle::normalDistanceAttack(FightAction* action) {
	Fighter* theActor=action->m_Actor;
	if (theActor->m_action == Fighter::DISTANCEATTACK) {
		NDBaseRole* role = theActor->GetRole();
		if (role->IsAnimationComplete()) {
			NDLog("%d:normalDistanceATK",theActor->m_info.idObj);
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
			//				int currentHP = target->m_info.nLife;
			//				int hurtHP = target->getHurt(&theActor, 1, 0, HURT_TYPE_ACTIVE).second.hurtHP;
			//				currentHP += hurtHP;
			//				target->hurted(hurtHP);
			//				if (!this->IsPracticeBattle()) {
			//					target->setCurrentHP(currentHP);
			//				}
			//				if (target->m_info.nLife > 0) {// hurt
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
			if(!action->isCombo){
				theActor->m_action = (Fighter::DISTANCEATTACKOVER);
				//				moveBackAction(*theActor);
			}else{
				theActor->m_action = (Fighter::WAIT);
				theActor->setActionOK(true);
				battleStandAction(*theActor);
				action->action_status=ACTION_STATUS_FINISH;
			}
		}
	}
}

void Battle::distanceAttackOver(FightAction* action) {
	Fighter* theActor=action->m_Actor;
	if (theActor->m_action == Fighter::DISTANCEATTACKOVER) {
		if (theActor->GetRole()->IsAnimationComplete()) {
			theActor->m_action = (Fighter::WAIT);
			theActor->setActionOK(true);
			battleStandAction(*theActor);
			action->action_status=ACTION_STATUS_FINISH;
		}
	}
}

void Battle::fighterSomeActionChangeToWait(VEC_FIGHTER& fighterList) {
	for (size_t i = 0; i < fighterList.size(); i++) {
		Fighter& f = *(fighterList.at(i));
		if (!f.isAlive() || !f.isVisiable()) {
			f.setHurtOK(false);
			f.setDieOK(false);
			f.setDodgeOK(false);
			f.setDefenceOK(false);
			continue;
		}
		if (f.isHurtOK()) { //被攻击过程
			if (f.GetRole()->IsAnimationComplete()) {
				if (f.m_action == Fighter::DEFENCE) {
					defenceAction(f);
				} else {
					battleStandAction(f);
				}
				f.setHurtOK(false);
			}
		}
		if (f.isDieOK()) { //死亡过程
			if (f.GetRole()->IsAnimationComplete()) {
				if (f.m_info.idObj == NDPlayer::defaultHero().m_id) {// 如果是自己死了
					// ，就观战
					this->watchBattle = true;
				}
				f.setActionOK(true);//整组动作结束
				f.setAlive(false);
				f.setDieOK(false);
			}
		}
		
		if (f.isDodgeOK()) { //闪避过程
			if (f.GetRole()->IsAnimationComplete()) {
				
				if (f.m_action == Fighter::DEFENCE) {
					defenceAction(f);
				} else {
					battleStandAction(f);
				}
				f.setDodgeOK(false);
			}
		}
		
		if(f.isDefenceOK()){
			if (f.GetRole()->IsAnimationComplete()) {
				f.m_bDefenceAtk=false;
				if (f.m_action == Fighter::DEFENCE) {
					defenceAction(f);
				} else {
					battleStandAction(f);
				}
				f.setDefenceOK(false);
			}
		}
	}
}

void Battle::drawFighterHurt(VEC_FIGHTER& fighterList) {
	for (size_t i = 0; i < fighterList.size(); i++) {
		Fighter& f = *fighterList.at(i);
		f.drawHurtNumber();
	}
}

void Battle::drawAllFighterHurtNumber() {
	drawFighterHurt(m_vAttaker);
	drawFighterHurt(m_vDefencer);
}

NDPicture* Battle::getActionWord(ACTION_WORD index)
{
	switch (index) {
		case AW_DEF:
			return this->m_picActionWordDef;
		case AW_FLEE:
			return this->m_picActionWordFlee;
		case AW_DODGE:
			return this->m_picActionWordDodge;
		default:
			return NULL;
	}
}

void Battle::skillAttack(FightAction* action) {
	Fighter* theActor=action->m_Actor;
	BattleSkill* skill=action->skill;
	if (theActor->m_action == Fighter::SKILLATTACK) {
		if (theActor->GetRole()->IsAnimationComplete()) {
			NDLog("%d:SkillATK",theActor->m_info.idObj);
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
			//				int currentHP = target.m_info.nLife;
			//				
			//				Hurt hurt = target.getHurt(&theActor, 0, theActor.getUseSkill()->getId(), HURT_TYPE_ACTIVE).second;
			//				int hurtHP = hurt.hurtHP;
			//				currentHP += hurtHP;
			//				target.hurted(hurtHP);
			//				if (!this->IsPracticeBattle()) {
			//					target.setCurrentHP(currentHP);
			//				}
			//				currentHP = target.m_info.nLife;
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

void Battle::distanceSkillAttack(FightAction* action) {
	Fighter* theActor=action->m_Actor;
	if (theActor->m_action == Fighter::DISTANCESKILLATTACK) {
		if (theActor->GetRole()->IsAnimationComplete()) {
			NDLog("%d:distanceSkillATK",theActor->m_info.idObj);
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
			//				int currentHP = target.m_info.nLife;
			//				
			//				Hurt hurt = target.getHurt(&theActor, 0, theActor.getUseSkill()->getId(), HURT_TYPE_ACTIVE).second;
			//				int hurtHP = hurt.hurtHP;
			//				currentHP += hurtHP;
			//				target.hurted(hurtHP);
			//				if (!this->IsPracticeBattle()) {
			//					target.setCurrentHP(currentHP);
			//				}
			//				currentHP = target.m_info.nLife;
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
			//					this->watchBattle = false;
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

void Battle::clearWillBeAtk(VEC_FIGHTER& fighterList) {
	for (size_t i = 0; i < fighterList.size(); i++) {
		Fighter& f = *fighterList.at(i);
		f.setWillBeAtk(false);
	}
}

void Battle::clearAllWillBeAtk() {
	clearWillBeAtk(this->GetOurSideList());
	clearWillBeAtk(this->GetEnemySideList());
}

Fighter* Battle::getFighterByPos(VEC_FIGHTER& fighterList, int pos, int line) {
	Fighter* result = NULL;
	for (size_t i = 0; i < fighterList.size(); i++) {
		Fighter* f = fighterList.at(i);
		if (f->m_info.btStations == pos) {
			result = f;
			break;
		}
	}
	return result;
}

Fighter* Battle::getUpNearFighter(VEC_FIGHTER& fighterList, Fighter* f) {// 找上面贴着的一个fighter
	Fighter* result = NULL;
	if (!f) {
		return NULL;
	}
	
	if (f->m_info.btStations == 1||f->m_info.btStations == 4||f->m_info.btStations == 7) {// 最上面
		result = NULL;
	} else {	
		Byte pos=f->m_info.btStations;
		result = getFighterByPos(fighterList, pos-1, 0);
	}
	return result;
}

Fighter* Battle::getDownNearFighter(VEC_FIGHTER& fighterList, Fighter* f) {// 找下面贴着的一个fighter
	Fighter* result = NULL;
	if (f == NULL) {
		return NULL;
	}
	if (f->m_info.btStations == 3||f->m_info.btStations == 6||f->m_info.btStations == 9) {// 最上面
		result = NULL;
	} else {	
		Byte pos=f->m_info.btStations;
		result = getFighterByPos(fighterList, pos+1, 0);
	}
	return result;
}

void Battle::setWillBeAtk(VEC_FIGHTER& fighterList) {
//	clearAllWillBeAtk();
//	int area = 0;
//	
//	switch (this->m_battleStatus) {
//		case BS_CHOOSE_ENEMY_MAG_ATK: // 玩家技能攻击
//		case BS_CHOOSE_OUR_SIDE_MAG_ATK:
//		{
//			if (this->GetMainUser() == NULL) return;
//			
//			BattleSkill* useSkill = this->GetMainUser()->getUseSkill();
//			if (!useSkill) {
//				return;
//			}
//			area = useSkill->getArea();
//		}
//			break;
//		case BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON:
//		{
//			BattleSkill* useSkill = this->getMainEudemon()->getUseSkill();
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
//	if (!this->m_highlightFighter) {
//		return;
//	}
//	
//	Fighter* f = this->m_highlightFighter;
//	this->m_highlightFighter->setWillBeAtk(true);
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
	for (VEC_FIGHTER_IT it = this->m_vAttaker.begin(); it != m_vAttaker.end(); it++) {
		if (this->m_highlightFighter == *it) {
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
	
	this->m_vSubAniGroup.push_back(subAniGroup);
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
	//			int currentHP = target->m_info.nLife;
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
	Fighter* f = this->GetFighter(idFighter);
	if (f) {
		f->setOnline(bOnline);
	}
}

/*void Battle::CreateCancleAutoFightButton()
 {
 if (!m_btnCancleAutoFight) 
 {
 m_btnCancleAutoFight = new NDUIButton();
 m_btnCancleAutoFight->Initialization();
 m_btnCancleAutoFight->SetFrameRect(CGRectMake(0, 0, 60, 30));
 m_btnCancleAutoFight->SetDelegate(this);
 m_btnCancleAutoFight->SetTag(BTN_CANCLE_AUTO);
 m_btnCancleAutoFight->SetBackgroundColor(ccc4(107, 158, 156, 255));
 m_btnCancleAutoFight->SetTitle("取消");
 this->AddChild(m_btnCancleAutoFight);
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
//	if (this->m_bWatch || s_bAuto || m_bTurnStart == false) {
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
//		this->m_bSendCurTurnUserAction = true;
//		this->m_bTurnStartPet = true;
//		m_bTurnStart = false;
//		return;
//	}
//	
//	//	this->RefreshSkillBar();
//	//	
//	//	m_fighterLeft->SetPage(m_lastSkillPageUser);
//	//	
//	////	m_fighterBottom->SetGray(false);
//	//	
//	//	this->RefreshItemBar();
//	//	
//	//	// 根据玩家上回合的操作修改
//	//	m_fighterRight->SetShrink(m_bShrinkRight);
//	//	m_fighterLeft->SetShrink(m_bShrinkLeft);
//	//	m_fighterBottom->SetShrink(m_bShrinkBottom);
//	
//	// 无可捕捉目标，捕捉变灰
//	VEC_FIGHTER& enemyList = this->GetEnemySideList();
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
//			this->OnBtnAttack();
//			m_defaultTargetUser = m_highlightFighter;
//		} else {
//			this->OnBtnAttack();
//			this->HighlightFighter(m_defaultTargetUser);
//		}
//		
//	} else if (BATTLE_ACT_MAG_ATK == m_defaultActionUser) {
//		if (this->m_setBattleSkillList.count(this->m_defaultSkillID) <= 0) {
//			m_defaultActionUser = BATTLE_ACT_PHY_ATK;
//			this->OnBtnAttack();
//			m_defaultTargetUser = m_highlightFighter;
//		} else {
//			this->m_curBattleAction->btAction = BATTLE_ACT_MAG_ATK;
//			this->m_curBattleAction->vData.clear();
//			
//			s_lastTurnActionUser.btAction = BATTLE_ACT_MAG_ATK;
//			s_lastTurnActionUser.vData.clear();
//			
//			this->m_curBattleAction->vData.push_back(this->m_defaultSkillID);
//			s_lastTurnActionUser.vData.push_back(m_defaultSkillID);
//			s_lastTurnActionUser.vData.push_back(0);
//			
//			BattleSkill* skill = BattleMgrObj.GetBattleSkill(m_defaultSkillID);
//			
//			if (skill) {
//				int targetType = skill->getAtkType();
//				this->GetMainUser()->setUseSkill(skill);
//				
//				if (m_defaultTargetUser == NULL || !m_defaultTargetUser->isVisiable()) {
//					if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
//						setBattleStatus(BS_CHOOSE_ENEMY_MAG_ATK);
//						
//						VEC_FIGHTER& enemyList = this->GetEnemySideList();
//						Fighter* f;
//						for (size_t i = 0; i < enemyList.size(); i++) {
//							f = enemyList.at(i);
//							if (f->isVisiable()) {
//								m_defaultTargetUser = f;
//								this->HighlightFighter(f);
//								break;
//							}
//						}
//						
//					} else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
//						setBattleStatus(BS_CHOOSE_OUR_SIDE_MAG_ATK);
//						
//						VEC_FIGHTER& ourList = this->GetOurSideList();
//						Fighter* f;
//						for (size_t i = 0; i < ourList.size(); i++) {
//							f = ourList.at(i);
//							if (f->isVisiable()) {
//								m_defaultTargetUser = f;
//								this->HighlightFighter(f);
//								break;
//							}
//						}
//					}
//				} else {
//					if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
//						setBattleStatus(BS_CHOOSE_ENEMY_MAG_ATK);
//						this->HighlightFighter(m_defaultTargetUser);
//						
//					} else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
//						setBattleStatus(BS_CHOOSE_OUR_SIDE_MAG_ATK);
//						this->HighlightFighter(m_defaultTargetUser);
//						
//					} else if ((targetType & SKILL_ATK_TYPE_SELF) == SKILL_ATK_TYPE_SELF) {
//						setBattleStatus(BS_CHOOSE_SELF_MAG_ATK);
//						this->HighlightFighter(m_defaultTargetUser);
//					}
//				}
//			}
//		}
//	}
}

void Battle::TurnStartPet()
{
//	if (this->m_bWatch || s_bAuto || m_bTurnStartPet == false) {
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
//	this->RefreshSkillBarPet();
//	
//	//	m_fighterLeft->SetPage(m_lastSkillPageEudemon);
//	
//	if (BATTLE_ACT_PET_PHY_ATK == m_defaultActionEudemon) {
//		if (m_defaultTargetEudemon == NULL || !m_defaultTargetEudemon->isVisiable()) {
//			this->OnEudemonAttack();
//			m_defaultTargetEudemon = m_highlightFighter;
//		} else {
//			this->OnEudemonAttack();
//			this->HighlightFighter(m_defaultTargetEudemon);
//		}
//		
//	} else if (BATTLE_ACT_PET_MAG_ATK == m_defaultActionEudemon) {
//		// 上回合宠物技能可用
//		if (this->m_defaultSkillIDEudemon > ID_NONE) {
//			this->m_curBattleAction->btAction = BATTLE_ACT_PET_MAG_ATK;
//			this->m_curBattleAction->vData.clear();
//			
//			s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_MAG_ATK;
//			s_lastTurnActionEudemon.vData.clear();
//			
//			this->m_curBattleAction->vData.push_back(m_defaultSkillIDEudemon);
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
//						VEC_FIGHTER& enemyList = this->GetEnemySideList();
//						Fighter* f;
//						for (size_t i = 0; i < enemyList.size(); i++) {
//							f = enemyList.at(i);
//							if (f->isVisiable()) {
//								this->m_defaultTargetEudemon = f;
//								this->HighlightFighter(f);
//								break;
//							}
//						}
//						
//					} else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
//						setBattleStatus(BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON);
//						
//						VEC_FIGHTER& ourList = this->GetOurSideList();
//						Fighter* f;
//						for (size_t i = 0; i < ourList.size(); i++) {
//							f = ourList.at(i);
//							if (f->isVisiable()) {
//								this->m_defaultTargetEudemon = f;
//								this->HighlightFighter(f);
//								break;
//							}
//						}
//						
//					}
//				} else {
//					if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
//						setBattleStatus(BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON);
//						this->HighlightFighter(this->m_defaultTargetEudemon);
//						
//					} else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
//						setBattleStatus(BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON);
//						this->HighlightFighter(this->m_defaultTargetEudemon);
//						
//					} else if ((targetType & SKILL_ATK_TYPE_SELF) == SKILL_ATK_TYPE_SELF) {
//						setBattleStatus(BS_CHOOSE_SELF_MAG_ATK_EUDEMON);
//						this->HighlightFighter(m_defaultTargetEudemon);
//						
//					}
//				}
//			}
//		} else {
//			m_defaultActionEudemon = BATTLE_ACT_PET_PHY_ATK;
//			this->OnEudemonAttack();
//			m_defaultTargetEudemon = m_highlightFighter;
//		}
//	}
}

void Battle::RefreshSkillBarPet()
{
	// 获取宠物技能
	PetInfo* petInfo = PetMgrObj.GetMainPet(NDPlayer::defaultHero().m_id);
	if (petInfo) return;
	
	//SET_BATTLE_SKILL_LIST& petSkillList = PetMgrObj.GetSkillList(SKILL_TYPE_ATTACK, petInfo->data.int_PET_ID);
	//SpeedBarInfo skillInfo;
	//BattleMgr& bm = BattleMgrObj;
	//BattleSkill* bs = NULL;
	//SET_BATTLE_SKILL_LIST_IT itSkill = petSkillList.begin();
	//
	//int nPetMp = this->getMainEudemon()->m_info.nMana;
	//
	//int nFocus = -1;
	//for (int i = 0; i < MAX_SKILL_NUM; i++) {
	//	if (itSkill != petSkillList.end()) {
	//		skillInfo.push_back(SpeedBarCellInfo());
	//		SpeedBarCellInfo& ci = skillInfo.back();
	//		bs = bm.GetBattleSkill(*itSkill);
	//		if (bs) {
	//			ci.foreground = GetSkillIconByIconIndex(bs->getIconIndex(), true);;
	//			
	//			ci.gray = bs->getMpRequire() > nPetMp;
	//			ci.param1 = bs->getId();
	//			ci.param2 = bs->getCd();
	//			
	//			if (ci.param2 != 0 && !ci.gray)
	//			{
	//				CoolDownRecord_IT it = m_recordCoolDown.find(ci.param1);
	//				if (it != m_recordCoolDown.end())
	//					ci.gray = (it->second < ci.param2);
	//			}
	//			
	//			// 上回合使用的技能
	//			if (this->m_defaultSkillIDEudemon == ci.param1 && !ci.gray) {
	//				nFocus = i;
	//			} else {
	//				// 上回合技能清零，表示该技能失效
	//				this->m_defaultSkillIDEudemon = ID_NONE;
	//			}
	//			
	//		}
	//		itSkill++;
	//	}
	//}
	
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
	//SET_BATTLE_SKILL_LIST_IT itSkill = this->m_setBattleSkillList.begin();
	//
	//if (this->GetMainUser() == NULL) return;
	//
	//int nPlayerMp = this->GetMainUser()->m_info.nMana;
	//
	//int nFocus = -1;
	//int i = 0;
	//for (; i < MAX_SKILL_NUM; i++) {
	//	if (itSkill != this->m_setBattleSkillList.end()) {
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
	//			if (this->m_defaultSkillID == ci.param1 && !ci.gray) {
	//				nFocus = i;
	//			} else {
	//				this->m_defaultSkillID = ID_NONE;
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
	//		if (this->m_setBattleSkillList.count(skillID) == 0 && size < size_t(MAX_SKILL_NUM)) {
	//			skillInfo.push_back(SpeedBarCellInfo());
	//			SpeedBarCellInfo& ci = skillInfo.back();
	//			ci.foreground = GetSkillIconByIconIndex(bs->getIconIndex(), true);
	//			
	//			ci.gray = true;
	//			ci.param1 = bs->getId();
	//			ci.param2 = bs->getCd();
	//			// 上回合使用的技能
	//			if (this->m_defaultSkillID == ci.param1) {
	//				this->m_defaultSkillID = ID_NONE;
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

// Battle::speed bar
void Battle::InitSpeedBar()
{
	if (m_bWatch) {
		return;
	}
	
	//	m_fighterBottom = new FighterBottom;
	//	m_fighterBottom->Initialization();
	//	m_fighterBottom->SetDelegate(this);
	//	
	//	if (s_bAuto) {
	//		this->RefreshItemBar();
	//	}
	//	
	//	this->AddChild(m_fighterBottom);
	
	//	m_fighterLeft = new FighterLeft;
	//	m_fighterLeft->Initialization();
	//	m_fighterLeft->SetDelegate(this);
	//	
	//	if (s_bAuto) {
	//		this->RefreshSkillBar();
	//	}
	//	
	//	this->AddChild(m_fighterLeft);
	//	
	//	//this->AddChild(m_btnQuickTalk);
	//
	//	m_fighterRight = new FighterRight;
	//	m_fighterRight->SetDelegate(this);
	//	m_fighterRight->Initialization();
	
	//SpeedBarInfo speedbarRight;
	//
	//// 捕捉
	//speedbarRight.push_back(SpeedBarCellInfo());
	//SpeedBarCellInfo& ciCatch = speedbarRight.back();
	//NDPicture* pic = new NDPicture(true);
	//pic->Initialization(GetImgPathBattleUI("menucatch.png"));
	//ciCatch.foreground = pic;
	//ciCatch.param1 = CELL_TAG_CATCH;
	//
	//// 逃跑
	//speedbarRight.push_back(SpeedBarCellInfo());
	//SpeedBarCellInfo& ciFlee = speedbarRight.back();
	//pic = new NDPicture(true);
	//pic->Initialization(GetImgPathBattleUI("menuescape.png"));
	//ciFlee.foreground = pic;
	//ciFlee.param1 = CELL_TAG_FLEE;
	//
	//// 防御
	//speedbarRight.push_back(SpeedBarCellInfo());
	//SpeedBarCellInfo& ciDef = speedbarRight.back();
	//pic = new NDPicture(true);
	//pic->Initialization(GetImgPathBattleUI("menudefence.png"));
	//ciDef.foreground = pic;
	//ciDef.param1 = CELL_TAG_DEF;
	//
	//// 攻击
	//speedbarRight.push_back(SpeedBarCellInfo());
	//SpeedBarCellInfo& ciAtk = speedbarRight.back();
	//pic = new NDPicture(true);
	//pic->Initialization(GetImgPathBattleUI("menuattack.png"));
	//ciAtk.foreground = pic;
	//ciAtk.param1 = CELL_TAG_ATK;
	//
	//// 查看
	//speedbarRight.push_back(SpeedBarCellInfo());
	//SpeedBarCellInfo& ciViewStatus = speedbarRight.back();
	//pic = new NDPicture(true);
	//pic->Initialization(GetImgPathBattleUI("menuwatch.png"));
	//ciViewStatus.foreground = pic;
	//ciViewStatus.param1 = CELL_TAG_VIEWSTATUS;
	
	//	m_fighterRight->refresh(speedbarRight);
	//	
	//	this->AddChild(m_fighterRight);
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
//	//			if (this->IsUserOperating()) {
//	//				if (focused) {
//	//					NDTouch touch;
//	//					this->TouchEnd(&touch);
//	//					
//	//				} else {
//	//					this->m_curBattleAction->vData.clear();
//	//					this->m_curBattleAction->btAction = BATTLE_ACT_MAG_ATK;
//	//					
//	//					s_lastTurnActionUser.btAction = BATTLE_ACT_MAG_ATK;
//	//					s_lastTurnActionUser.vData.clear();
//	//					
//	//					this->m_defaultActionUser = BATTLE_ACT_MAG_ATK;
//	//					this->m_defaultSkillID = info.param1;
//	//					
//	//					this->m_curBattleAction->vData.push_back(info.param1);
//	//					s_lastTurnActionUser.vData.push_back(info.param1);
//	//					s_lastTurnActionUser.vData.push_back(0);
//	//					
//	//					BattleSkill* skill = BattleMgrObj.GetBattleSkill(info.param1);
//	//					if (skill && this->GetMainUser()) {
//	//						int targetType = skill->getAtkType();
//	//						this->GetMainUser()->setUseSkill(skill);
//	//						
//	//						if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
//	//							setBattleStatus(BS_CHOOSE_ENEMY_MAG_ATK);
//	//							VEC_FIGHTER& enemyList = this->GetEnemySideList();
//	//							Fighter* f;
//	//							for (size_t i = 0; i < enemyList.size(); i++) {
//	//								f = enemyList.at(i);
//	//								if (f->isVisiable()) {
//	//									m_defaultTargetUser = f;
//	//									this->HighlightFighter(f);
//	//									break;
//	//								}
//	//							}
//	//							
//	//						} else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
//	//							setBattleStatus(BS_CHOOSE_OUR_SIDE_MAG_ATK);
//	//							
//	//							VEC_FIGHTER& ourList = this->GetOurSideList();
//	//							Fighter* f;
//	//							for (size_t i = 0; i < ourList.size(); i++) {
//	//								f = ourList.at(i);
//	//								if (f->isVisiable()) {
//	//									m_defaultTargetUser = f;
//	//									this->HighlightFighter(f);
//	//									break;
//	//								}
//	//							}
//	//							
//	//						} else if ((targetType & SKILL_ATK_TYPE_SELF) == SKILL_ATK_TYPE_SELF) {
//	//							m_defaultTargetUser = this->GetMainUser();
//	//							this->m_curBattleAction->vData.push_back(this->GetMainUser()->m_info.idObj);
//	//							this->SendBattleAction(*m_curBattleAction);
//	//							
//	//						}
//	//					}
//	//				}
//	//				
//	//			} else if (this->IsEudemonOperating()) {
//	//				if (focused) {
//	//					NDTouch touch;
//	//					this->TouchEnd(&touch);
//	//					
//	//				} else {
//	//					this->m_curBattleAction->btAction = BATTLE_ACT_PET_MAG_ATK;
//	//					
//	//					s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_MAG_ATK;
//	//					s_lastTurnActionEudemon.vData.clear();
//	//					
//	//					this->m_defaultActionEudemon = BATTLE_ACT_PET_MAG_ATK;
//	//					this->m_defaultSkillIDEudemon = info.param1;
//	//					
//	//					this->m_curBattleAction->vData.push_back(info.param1);
//	//					s_lastTurnActionEudemon.vData.push_back(info.param1);
//	//					s_lastTurnActionEudemon.vData.push_back(0);
//	//					
//	//					BattleSkill* skill = BattleMgrObj.GetBattleSkill(info.param1);
//	//					if (skill) {
//	//						if (this->getMainEudemon()->m_info.nMana >= skill->getMpRequire()) {
//	//							int targetType = skill->getAtkType();
//	//							
//	//							if ((targetType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
//	//								setBattleStatus(BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON);
//	//								
//	//								VEC_FIGHTER& enemyList = this->GetEnemySideList();
//	//								Fighter* f;
//	//								for (size_t i = 0; i < enemyList.size(); i++) {
//	//									f = enemyList.at(i);
//	//									if (f->isVisiable()) {
//	//										this->m_defaultTargetEudemon = f;
//	//										this->HighlightFighter(f);
//	//										break;
//	//									}
//	//								}
//	//								
//	//							} else if ((targetType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
//	//								setBattleStatus(BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON);
//	//								
//	//								VEC_FIGHTER& ourList = this->GetOurSideList();
//	//								Fighter* f;
//	//								for (size_t i = 0; i < ourList.size(); i++) {
//	//									f = ourList.at(i);
//	//									if (f->isVisiable()) {
//	//										this->m_defaultTargetEudemon = f;
//	//										this->HighlightFighter(f);
//	//										break;
//	//									}
//	//								}
//	//								
//	//							} else if ((targetType & SKILL_ATK_TYPE_SELF) == SKILL_ATK_TYPE_SELF) {
//	//								this->m_defaultTargetEudemon = this->getMainEudemon();
//	//								this->m_curBattleAction->vData.push_back(this->getMainEudemon()->m_info.idObj);
//	//								this->SendBattleAction(*m_curBattleAction);
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
//	//			if (this->IsUserOperating()) {
//	//				if (focused) {
//	//					NDTouch touch;
//	//					this->TouchEnd(&touch);
//	//				} else {
//	//					m_curBattleAction->btAction = BATTLE_ACT_USEITEM;
//	//					setBattleStatus(BS_CHOOSE_OUR_SIDE_USE_ITEM_USER);
//	//				}
//	//				
//	//			} else if (this->IsEudemonOperating()) {
//	//				if (focused) {
//	//					NDTouch touch;
//	//					this->TouchEnd(&touch);
//	//				} else {
//	//					m_curBattleAction->btAction = BATTLE_ACT_PET_USEITEM;
//	//					setBattleStatus(BS_CHOOSE_OUR_SIDE_USE_ITEM_EUDEMON);
//	//				}
//	//			}
//	//			
//	//			if (this->m_battleStatus == BS_CHOOSE_OUR_SIDE_USE_ITEM_USER || this->m_battleStatus == BS_CHOOSE_OUR_SIDE_USE_ITEM_EUDEMON) {
//	//				m_curBattleAction->vData.clear();
//	//				
//	//				MAP_USEITEM_IT it = m_mapUseItem.find(info.param1);
//	//				
//	//				if (it != m_mapUseItem.end()) {
//	//					m_curBattleAction->vData.push_back(it->second.first);
//	//				}
//	//				
//	//				VEC_FIGHTER& ourSideList = this->GetOurSideList();
//	//				Fighter* f;
//	//				for (size_t i = 0; i < ourSideList.size(); i++) {
//	//					f = ourSideList.at(i);
//	//					if (f->isVisiable()) {
//	//						this->HighlightFighter(f);
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
//	//				if (this->IsUserOperating()) {
//	//					if (focused) {
//	//						NDTouch touch;
//	//						this->TouchEnd(&touch);
//	//					} else {
//	//						this->stopAuto();
//	//						this->OnBtnAttack();
//	//						m_defaultActionUser = BATTLE_ACT_PHY_ATK;
//	//						m_defaultTargetUser = m_highlightFighter;
//	//					}
//	//				} else if (this->IsEudemonOperating()) {
//	//					if (focused) {
//	//						NDTouch touch;
//	//						this->TouchEnd(&touch);
//	//					} else {
//	//						this->OnEudemonAttack();
//	//						m_defaultActionEudemon = BATTLE_ACT_PET_PHY_ATK;
//	//						m_defaultTargetEudemon = m_highlightFighter;
//	//					}
//	//				}
//	//				break;
//	//			case CELL_TAG_DEF:
//	//				if (this->IsUserOperating()) {
//	//					this->stopAuto();
//	//					this->OnBtnDefence();
//	//				} else if (this->IsEudemonOperating()) {
//	//					BattleAction actioin(BATTLE_ACT_PET_PHY_DEF);
//	//					s_lastTurnActionEudemon.btAction = BATTLE_ACT_PET_PHY_DEF;
//	//					this->SendBattleAction(actioin);
//	//				}
//	//				break;
//	//			case CELL_TAG_CATCH:
//	//				if (this->IsUserOperating()) {
//	//					if (focused) {
//	//						NDTouch touch;
//	//						this->TouchEnd(&touch);
//	//					} else {
//	//						this->stopAuto();
//	//						this->OnBtnCatch();
//	//					}
//	//				}
//	//				break;
//	//			case CELL_TAG_FLEE:
//	//				if (this->IsUserOperating()) {
//	//					this->stopAuto();
//	//					this->OnBtnRun();
//	//				} else if (this->IsEudemonOperating()) {
//	//					BattleAction actioin(BATTLE_ACT_PET_ESCAPE);
//	//					this->SendBattleAction(actioin);
//	//				}
//	//				break;
//	//			case CELL_TAG_VIEWSTATUS:
//	//			{
//	//				if (focused) {
//	//					NDTouch touch;
//	//					this->TouchEnd(&touch);
//	//				} else {
//	//					Fighter* f = NULL;
//	//					VEC_FIGHTER& enemyList = this->GetEnemySideList();
//	//					for (VEC_FIGHTER_IT it = enemyList.begin(); it != enemyList.end(); it++) {
//	//						if ((*it)->isVisiable()) {
//	//							f = *it;
//	//							break;
//	//						}
//	//					}
//	//					
//	//					if (this->IsUserOperating()) {
//	//						setBattleStatus(BS_CHOOSE_VIEW_FIGHTER_STATUS);
//	//						this->HighlightFighter(f);
//	//					} else if (this->IsEudemonOperating()) {
//	//						setBattleStatus(BS_CHOOSE_VIEW_FIGHTER_STATUS_PET);
//	//						this->HighlightFighter(f);
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
//	//			this->ShowChatTextField(false);
//	//			m_bChatTextFieldShouldShow = true;
//	//		}
//	//		
//	//		// 物品设置后，切换为普通攻击
//	//		if (this->IsUserOperating()) {
//	//			this->OnBtnAttack();
//	//		} else if (this->IsEudemonOperating()) {
//	//			this->OnEudemonAttack();
//	//		}
//	//		
//	//		GameUIItemConfig *config = new GameUIItemConfig;
//	//		config->Initialization();
//	//		config->SetDelegate(this);
//	//		this->AddChild(config, 97);
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
//	//		if (this->IsUserOperating()) {
//	//			m_lastSkillPageUser = page;
//	//		} else if (this->IsEudemonOperating()) {
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
	if (m_bChatTextFieldShouldShow) {
		this->ShowChatTextField(true);
	}
}

bool Battle::IsUserOperating()
{
//	switch (this->m_battleStatus) {
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
//	switch (this->m_battleStatus) {
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
		
		if (f->GetRole() && f->GetRole()->m_id == iRoleID) 
		{
			
			size_t idx = this->m_actionFighterPoint;
			
			if (idx == index)
			{
				m_vActionFighterList.erase(it);
				
				if (m_vActionFighterList.size())
				{ 
					this->m_actionFighterPoint = (index+1)%m_vActionFighterList.size();
					
					if (this->m_actionFighterPoint < int(m_vActionFighterList.size())) 
					{
						m_vActionFighterList[this->m_actionFighterPoint]->setActionOK(true);
					}
				}
			}
			else
			{
				m_vActionFighterList.erase(it);
			}
			
			ret =true;
			
			break;
		}
	}
	
	for (it = m_vAttaker.begin(); it != m_vAttaker.end(); it++) {
		Fighter* f = *it;
		if (f->GetRole() && f->GetRole()->m_id == iRoleID) {
			CC_SAFE_DELETE(*it);
			m_vAttaker.erase(it);
			return true;
		}
	}
	
	for (it = m_vDefencer.begin(); it != m_vDefencer.end(); it++) {
		Fighter* f = *it;
		if (f->GetRole() && f->GetRole()->m_id == iRoleID) {
			CC_SAFE_DELETE(*it);
			m_vDefencer.erase(it);
			return true;
		}
	}
	
	if (this->m_mainFighter && this->m_mainFighter->GetRole() && this->m_mainFighter->GetRole()->m_id == iRoleID)
	{
		this->m_mainFighter = NULL;
		ret =true;
	}
	
	return ret;
}

bool Battle::CanPetFreeUseSkill()
{
	if (
		m_battleType == BATTLE_TYPE_MONSTER ||
		m_battleType == BATTLE_TYPE_ELITE_MONSTER ||
		m_battleType == BATTLE_TYPE_NPC ||
		m_battleType == BATTLE_TYPE_PRACTICE
		)
		return true;
	
	return false;
}

void Battle::UseSkillDealOfCooldown(int skillID)
{
	BattleSkill *bs = BattleMgrObj.GetBattleSkill(skillID);
	
	if (!bs || bs->getCd() == 0) return;
	
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
	
	for (; it != m_recordCoolDown.end(); it++) {
		if (m_turn > 1)
			m_recordCoolDown[it->first] = m_recordCoolDown[it->first] + 1;
	}
	
	//if (m_fighterLeft && m_recordCoolDown.size())
	//m_fighterLeft->DealSkillTurn();
}

void Battle::setBattleStatus(BATTLE_STATUS status) {
	if (status == m_battleStatus)
		return;
	
	this->m_battleStatus = status;
}
