/*
 *  QuickFunc.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-20.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "QuickFunc.h"
#include "NDUtility.h"
#include "NDPlayer.h"
#include "ChatRecordManager.h"
#include "VipStoreScene.h"
#include "ItemMgr.h"
#include "NDUISynLayer.h"
#include "SocialScene.h"
#include "SystemAndCustomScene.h"
#include "NewHelpScene.h"
#include "SocialElement.h"
#include "NewChatScene.h"
#include "GameScene.h"
//#include "PlayerInfoScene.h"
#include "TaskInfoScene.h"

enum  
{
	FUNC_TARGET = 1000,
	FUNC_TASK,
	FUNC_PAIHANG,
	FUNC_SOCIAL,
	FUNC_CHAT,
	FUNC_MALL,
};

#define RIGHT_RECT CGRectMake(480-85, (254-239)/2+66-8, 85, 239)

IMPLEMENT_CLASS(QuickFunc, NDUISpeedBar)

QuickFunc::QuickFunc()
{
	m_sizeBtn = CGSizeMake(43, 39);
	
	m_pointBorder = CGPointMake(42, 0);
	
	m_uiInterval = 1;
	
	m_align = SpeedBarAlignmentRight;
	
	//memset(m_lbText, 0, sizeof(m_lbText));
	
	m_taskFinishTip = NULL;
}

QuickFunc::~QuickFunc()
{
	for (int i = 0; i < 5; i++) 
	{
		if (m_picItem[i])
		{
			delete m_picItem[i];
			
			m_picItem[i] = NULL;
		}
	}
}

void QuickFunc::Initialization(bool bShrink/*=false*/)
{
	NDUISpeedBar::Initialization(6, 1);
	
	this->SetDragOverEnabled(true);
	
	this->SwallowDragOverEvent(true);
	
	this->SetFrameRect(RIGHT_RECT);
	
	this->SetShrink(bShrink, false);
	
	SpeedBarInfo speedbarRight;
	
	// 目标
	speedbarRight.push_back(SpeedBarCellInfo());
	SpeedBarCellInfo& ciTarget = speedbarRight.back();
	NDPicture* pic = new NDPicture(true);
	pic->Initialization(GetImgPathNew("quickfunc_target.png"));
	ciTarget.foreground = pic;
	ciTarget.param1 = FUNC_TARGET;
	
	// 系统
	speedbarRight.push_back(SpeedBarCellInfo());
	SpeedBarCellInfo& ciSystem = speedbarRight.back();
	pic = new NDPicture(true);
	pic->Initialization(GetImgPathBattleUI("task.png"));
	ciSystem.foreground = pic;
	ciSystem.param1 = FUNC_TASK;
	
	// 排行
	speedbarRight.push_back(SpeedBarCellInfo());
	SpeedBarCellInfo& ciPaiHang = speedbarRight.back();
	pic = new NDPicture(true);
	pic->Initialization(GetImgPathNew("quickfunc_paihang.png"));
	ciPaiHang.foreground = pic;
	ciPaiHang.param1 = FUNC_PAIHANG;
	
	// 社交
	speedbarRight.push_back(SpeedBarCellInfo());
	SpeedBarCellInfo& ciSocial = speedbarRight.back();
	pic = new NDPicture(true);
	pic->Initialization(GetImgPathNew("quickfunc_social.png"));
	ciSocial.foreground = pic;
	ciSocial.param1 = FUNC_SOCIAL;
	
	// 聊天
	speedbarRight.push_back(SpeedBarCellInfo());
	SpeedBarCellInfo& ciChat = speedbarRight.back();
	pic = new NDPicture(true);
	pic->Initialization(GetImgPathNew("quickfunc_chat.png"));
	ciChat.foreground = pic;
	ciChat.param1 = FUNC_CHAT;
	
	// 商城
	speedbarRight.push_back(SpeedBarCellInfo());
	SpeedBarCellInfo& ciMall = speedbarRight.back();
	pic = new NDPicture(true);
	pic->Initialization(GetImgPathNew("quickfunc_mall.png"));
	ciMall.foreground = pic;
	ciMall.param1 = FUNC_MALL;
	
	this->refresh(speedbarRight);
	
	SAFE_DELETE_NODE(m_imageFocus);
	
	SAFE_DELETE_NODE(m_focus);
	
	this->SetDelegate(this);
}

void QuickFunc::Layout()
{
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	CGRect frame = RIGHT_RECT;
	
	m_btnShrink = new NDUIButton;
	
	m_btnShrink->Initialization();
	
	//m_btnShrink->SetTitle("收缩");
	m_picShrink = pool.AddPicture(GetImgPathBattleUI("handlearraw.png"));
	
	CGSize sizeShrink = m_picShrink->GetSize();
	
	m_btnShrink->SetFrameRect(CGRectMake(0, (frame.size.height-42)/2, 42, 40));
	
	m_btnShrink->SetImage(m_picShrink, true, CGRectMake((42-sizeShrink.width)/2+8, (40-sizeShrink.height)/2, sizeShrink.width, sizeShrink.height), false);
	
	m_btnShrink->SetDelegate(this);
	
	SetShrinkDis(43);
	
	this->AddChild(m_btnShrink);
	
	m_picBackGround = pool.AddPicture(GetImgPathBattleUI("menuback.png"));
	
	m_picBackGroundShrink = pool.AddPicture(GetImgPathBattleUI("verticalhandle.png"));
	

	
	for (int i = 0; i < 6; i++) 
	{
		m_picItem[i] = pool.AddPicture(GetImgPathBattleUI("menuchildback.png"), true);
	}
	
	/*
	CGSize sizetext = getStringSize("捕捉", 11);
	
	std::string text[5] = { "捕捉", "逃跑", "防御", "攻击", "查看",};
	
	for (int i = 0; i < 5; i++) 
	{
		m_lbText[i] = new NDUILabel;
		m_lbText[i]->Initialization();
		m_lbText[i]->SetFontSize(11);
		m_lbText[i]->SetText(text[i].c_str());
		m_lbText[i]->SetFontColor(ccc4(0, 0, 0, 200));
		m_lbText[i]->SetFrameRect(CGRectMake(m_pointBorder.x+(m_sizeBtn.width-sizetext.width)/2, m_pointBorder.y+(m_sizeBtn.height+m_uiInterval)*i+m_sizeBtn.height-sizetext.height, sizetext.width, sizetext.height));
		this->AddChild(m_lbText[i]);
	}
	*/
	
	//this->SetFocusImage(GetImgPathBattleUI("menuchildsel.png"));
}

void QuickFunc::DrawBackground()
{
	CGRect scrRect = this->GetScreenRect();
	
	if (m_picBackGround) 
	{
		CGSize bg = m_picBackGround->GetSize(), frame = scrRect.size;
		
		m_picBackGround->DrawInRect(CGRectMake(scrRect.origin.x+(frame.width-bg.width), scrRect.origin.y+(frame.height-bg.height)/2, bg.width, bg.height));
	}
	
	if (m_picBackGroundShrink) 
	{
		
		CGSize bg = m_picBackGroundShrink->GetSize(), frame = scrRect.size;
		
		m_picBackGroundShrink->DrawInRect(CGRectMake(scrRect.origin.x+m_pointBorder.x-bg.width+8, scrRect.origin.y+(frame.height-bg.height)/2, bg.width, bg.height));
	}
	
	if (m_picShrink)
		m_picShrink->Rotation(IsShrink() ? PictureRotation180 : PictureRotation0);
	
	for (int i = 0; i < 6; i++) 
	{
		if (m_picItem[i])
		{
			unsigned int index = m_uiCurPage * m_uiFuncNum + i;
			
			m_picItem[i]->SetGrayState(false);
			
			if (index < m_vecInfo.size() && m_vecInfo[index].info.isGray()) 
			{
				m_picItem[i]->SetGrayState(true);
			}
			
			m_picItem[i]->DrawInRect(CGRectMake(scrRect.origin.x+m_pointBorder.x+2, scrRect.origin.y+m_pointBorder.y+i*(39+m_uiInterval), 43, 39));
		}
	}
}

void QuickFunc::OnDrawAjustUI()
{
	/*
	if (m_imageFocus && m_imageFocus->IsVisibled()) 
	{
		CGRect rect = m_imageFocus->GetFrameRect();
		rect.origin.x += 2;
		rect.origin.y += 1;
		m_imageFocus->SetFrameRect(rect);
	}
	*/
}

void QuickFunc::DealFunc(int func)
{
	ShowMask(false);
	
	switch (func) {
		case FUNC_TARGET:
		{
			NDPlayer::defaultHero().NextFocusTarget();
		}
			break;
		case FUNC_TASK:
		{
			GameScene* scene = GameScene::GetCurGameScene();
			if (scene) scene->ShowTaskFinish(false, "");
			
			NDScene* runningScene = NDDirector::DefaultDirector()->GetRunningScene();
			/*
			if (runningScene && !runningScene->IsKindOfClass(RUNTIME_CLASS(PlayerInfoScene))) {
				PlayerInfoScene* scene = PlayerInfoScene::Scene();
				NDDirector::DefaultDirector()->PushScene(scene);
				scene->SetTabFocusOnIndex(3, true);
			}
			*/
			if (runningScene && !runningScene->IsKindOfClass(RUNTIME_CLASS(TaskInfoScene))) {
				TaskInfoScene* scene = TaskInfoScene::Scene();
				NDDirector::DefaultDirector()->PushScene(scene);
			}
		}
			break;
		case FUNC_PAIHANG:
		{
			ShowProgressBar;
			NDTransData bao(_MSG_BILLBOARD_QUERY);
			SEND_DATA(bao);
		}
			break;
		case FUNC_SOCIAL:
		{
			SocialScene *scene = SocialScene::Scene();
			NDDirector::DefaultDirector()->PushScene(scene);
			scene->SetTabFocusOnIndex(0);
			
			RequestTutorAndFriendInfo();
		}
			break;
		case FUNC_CHAT:
		{
			//ChatRecordManager::DefaultManager()->Show();
			NewChatScene::DefaultManager()->Show();
		}
			break;
		case FUNC_MALL:
		{
			NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
			
			if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
			{
				return;
			}
			
			((GameScene*)scene)->ShowShopAndRecharge();
			/*
			 map_vip_item& items = ItemMgrObj.GetVipStore();
			 if (items.empty()) 
			 {
			 NDTransData bao(_MSG_SHOP_CENTER);
			 bao << (unsigned char)0;
			 SEND_DATA(bao);
			 ShowProgressBar;
			 } 
			 else 
			 {
			 NDDirector::DefaultDirector()->PushScene(VipStoreScene::Scene());
			 }
			 */
		}
			break;
		default:
			break;
	}
}

void QuickFunc::OnNDUISpeedBarEvent(NDUISpeedBar* speedbar, const SpeedBarCellInfo& info, bool focused)
{
	if (speedbar != this) return;
	
	DealFunc(info.param1);
}

void QuickFunc::OnBattleBegin()
{
}

void QuickFunc::ShowMask(bool show, NDPicture* pic/*=NULL*/)
{

#define QUICK_FUNC_MASK_IMAGE_TAG (100)

	if (!show)
	{
		if (m_layerMask)
		{
			NDUIMaskLayer *layerMask = m_layerMask.Pointer();
			SAFE_DELETE_NODE(layerMask);
		}
		
		return;
	}
	
	if (show && !pic) return;
	
	if (!m_layerMask)
	{
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		
		if (!scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
			return;
			
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		CGSize picsize = pic->GetSize();
			
		CGRect rectMask = CGRectMake(0, 0, winsize.width, winsize.height);
		
		NDUIMaskLayer* layerMask = new NDUIMaskLayer;
		layerMask->Initialization();
		layerMask->SetFrameRect(rectMask);
		scene->AddChild(layerMask, MAP_MASKLAYER_Z);
		
		m_layerMask = layerMask->QueryLink();
		
		NDUIImage *image = new NDUIImage;
		image->Initialization();
		image->SetFrameRect(CGRectMake((rectMask.size.width-picsize.width)/2, 
									   (rectMask.size.height-picsize.height)/2, 
									   picsize.width, picsize.height));
		image->SetTag(QUICK_FUNC_MASK_IMAGE_TAG);
		layerMask->AddChild(image);
	}
	
	if (!m_layerMask) return;
	
	NDUIImage *image = (NDUIImage *)m_layerMask->GetChild(QUICK_FUNC_MASK_IMAGE_TAG);
	
	if (image)
		image->SetPicture(pic);
}

//  点击功能需要清除蒙板
bool QuickFunc::OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch)
{
	// 不做任何处理
	return true;
}

bool QuickFunc::OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange)
{
	// 清除蒙板
	
	ShowMask(false);
		
	return true;
}

bool QuickFunc::OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch)
{
	// 同点击功能
	
	int func = GetFuncByKey(desButton->GetTag());
	
	if (func != 0)
		DealFunc(func);

	return true;
}

bool QuickFunc::OnButtonDragOver(NDUIButton* overButton, bool inRange)
{
	// 显示蒙板
	ShowMask(inRange, GetPictureByUIKey(overButton->GetTag()));

	return true;
}

bool QuickFunc::OnButtonLongClick(NDUIButton* button)
{
	// 同点击功能
	NDUISpeedBar::OnButtonLongClick(button);
	
	int func = GetFuncByKey(button->GetTag());
	
	if (func != 0)
		DealFunc(func);
	
	return true;
}

bool QuickFunc::OnButtonLongTouch(NDUIButton* button)
{
	// 显示蒙板
	
	ShowMask(true, GetPictureByUIKey(button->GetTag()));
	
	return true;
}

void QuickFunc::OnButtonDown(NDUIButton* button)
{
	ShowMask(true, GetPictureByUIKey(button->GetTag()));
}

void QuickFunc::OnButtonUp(NDUIButton* button)
{
	if (GetFuncByKey(button->GetTag()) == 0) return;
	
	ShowMask(false);
}

NDPicture* QuickFunc::GetPictureByUIKey(int key)
{
	std::vector<CellInfo>::iterator it = m_vecInfo.begin();
	
	for (; it != m_vecInfo.end(); it++) 
	{
		if ( (unsigned int)key == (*it).key )
		{
			if ((*it).info.param1 == FUNC_TARGET)
				return NULL;
			else
				return (*it).info.foreground;
		}
	}
	
	return NULL;
}

int QuickFunc::GetFuncByKey(int key)
{
	std::vector<CellInfo>::iterator it = m_vecInfo.begin();
	
	for (; it != m_vecInfo.end(); it++) 
	{
		if ( (unsigned int)key == (*it).key )
		{
			if ((*it).info.param1 == FUNC_TARGET)
				return 0;
			else
				return (*it).info.param1;
		}
	}
	
	return 0;
}

void QuickFunc::ShowTaskTip(bool show,std::string tip)
{
	if (!show)
	{
		SAFE_DELETE_NODE(m_taskFinishTip);
		
		return;
	}
	
	if (!m_taskFinishTip)
	{
		m_taskFinishTip = new LayerTip;
		m_taskFinishTip->Initialization();
		m_taskFinishTip->SetFrameRect(CGRectMake(-50, 0, 120, 320));
		m_taskFinishTip->SetTriangleAlign(TipTriangleAlignRight);
		m_taskFinishTip->SetTextFontSize(13);
		m_taskFinishTip->SetWidth(120);
		m_taskFinishTip->SetTextColor(ccc4(199, 89, 0, 255));
		m_taskFinishTip->SetTalkStyle(true);
		this->AddChild(m_taskFinishTip);
	}
	
	m_taskFinishTip->SetText(tip);
	CGSize size = m_taskFinishTip->GetTipSize();
	m_taskFinishTip->SetFrameRect(CGRectMake(45-size.width, 40-size.height, 120, 320));
	m_taskFinishTip->Show();
}

