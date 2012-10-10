/*
 *  GameUIPlayerList.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-10.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GameUIPlayerList.h"
#include "NDUIBaseGraphics.h"
#include "NDDirector.h"
#include "NDUIBaseGraphics.h"
#include "NDMapMgr.h"
#include "NDPlayer.h"
#include "NDUtility.h"
#include "GameScene.h"
#include "NDUIButton.h"
#include "EnumDef.h"
#include "NDUISynLayer.h"
#include "ChatInput.h"
#include "NDUISpecialLayer.h"
#include <sstream>

////////////////////////////////////////////////
IMPLEMENT_CLASS(NDUIPlayerInfo, NDUILayer)

NDUIPlayerInfo::NDUIPlayerInfo()
{
	m_lbName = NULL; m_lbInfo = NULL;
}

NDUIPlayerInfo::~NDUIPlayerInfo()
{
}

void NDUIPlayerInfo::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetBackgroundColor(ccc4(255, 255, 255,0));
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_crBG = new NDUICircleRect;
	m_crBG->Initialization();
	m_crBG->SetRadius(5);
	m_crBG->SetFillColor(ccc4(255, 218, 36, 255));
	this->AddChild(m_crBG);
	
	m_lbName = new NDUILabel;
	m_lbName->Initialization();
	m_lbName->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbName->SetFontSize(eFontSize);
	m_lbName->SetFrameRect(CGRectMake(ePlayerNameDisX, 0, winsize.width, eFontSize));
	this->AddChild(m_lbName);
	
	m_lbInfo = new NDUILabel;
	m_lbInfo->Initialization();
	m_lbInfo->SetFontSize(eFontSize);
	m_lbInfo->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbInfo->SetFrameRect(CGRectMake(ePlayerNameInfoDisX, 0, winsize.width, eFontSize));
	this->AddChild(m_lbInfo);
}

void NDUIPlayerInfo::draw()
{
	//调整文本显示
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	CGRect rect = this->GetFrameRect();
	m_lbName->SetFrameRect(CGRectMake(ePlayerNameDisX, (rect.size.height-eFontSize)/2, winsize.width, eFontSize));
	m_lbInfo->SetFrameRect(CGRectMake(ePlayerNameInfoDisX, (rect.size.height-eFontSize)/2, winsize.width, eFontSize));
	m_crBG->SetFrameRect(CGRectMake(0, 0, rect.size.width, rect.size.height));
	
	if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
	{
		NDUILayer *node = (NDUILayer*)(this->GetParent());
		if (node->GetFocus() == this)
		{
			m_crBG->SetFillColor(focuscolor);
		}
		else
		{
			m_crBG->SetFillColor(defocuscolor);
		}
	}
	
	NDUILayer::draw();
}

void NDUIPlayerInfo::SetPlayerName(std::string text)
{
	if (m_lbName)
	{
		m_lbName->SetText(text.c_str());
	}
}
void NDUIPlayerInfo::SetPlayerNameColor(ccColor4B color)
{
	if (m_lbName)
	{
		m_lbName->SetFontColor(color);
	}
}
void NDUIPlayerInfo::SetPlayerInfo(std::string text)
{
	if (m_lbInfo)
	{
		m_lbInfo->SetText(text.c_str());
	}
}
void NDUIPlayerInfo::SetPlayerInfoColor(ccColor4B color)
{
	if (m_lbInfo)
	{
		m_lbInfo->SetFontColor(color);
	}
}

////////////////////////////////////////////////

////////////////////////////////////////////////
#define title_height 28
#define bottom_height 42
#define MAIN_TB_X (5)

#define BTN_W (85)
#define BTN_H (23)

#define DIS_COUNT (20)

IMPLEMENT_CLASS(GameUIPlayerList, NDUIMenuLayer)

GameUIPlayerList::GameUIPlayerList()
{
	m_lbTitle = NULL;
	m_tlMain = NULL;
	m_btnPrev = NULL;
	m_picPrev = NULL;
	m_btnNext = NULL;
	m_picNext = NULL;
	m_topLayerEx = NULL;
	m_lbPage = NULL;
	m_tlOperate = NULL;
	m_iCurPage = 0;
}

GameUIPlayerList::~GameUIPlayerList()
{
	SAFE_DELETE(m_picPrev);
	SAFE_DELETE(m_picNext);
}

void GameUIPlayerList::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 245, 0, 255));
	this->AddChild(m_lbTitle);
	
	NDUILayer *tmpLayer = new NDUILayer;
	tmpLayer->Initialization();
	tmpLayer->SetFrameRect(CGRectMake(MAIN_TB_X, title_height+2, winsize.width-2*MAIN_TB_X, 20));
	tmpLayer->SetBackgroundColor(ccc4(119,119,119,255));
	this->AddChild(tmpLayer);
	
	NDUILabel *tmpName = new NDUILabel;
	tmpName->Initialization();
	tmpName->SetTextAlignment(LabelTextAlignmentLeft);
	tmpName->SetText("玩家名字");
	tmpName->SetFontSize(15);
	tmpName->SetFontColor(ccc4(0, 0, 0, 255));
	tmpName->SetFrameRect(CGRectMake(10, (20-15)/2, winsize.width, 15));
	tmpLayer->AddChild(tmpName);
	
	NDUILabel *tmpState = new NDUILabel;
	tmpState->Initialization();
	tmpState->SetTextAlignment(LabelTextAlignmentLeft);
	tmpState->SetText("状态");
	tmpState->SetFontSize(15);
	tmpState->SetFontColor(ccc4(0, 0, 0, 255));
	tmpState->SetFrameRect(CGRectMake(260, (20-15)/2, winsize.width, 15));
	tmpLayer->AddChild(tmpState);
	
	m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetVisible(false);
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->AddChild(m_tlMain);
	
	m_picPrev = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picPrev->Cut(CGRectMake(319, 144, 48, 19));
	CGSize prevSize = m_picPrev->GetSize();
	
	m_picNext = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picNext->Cut(CGRectMake(318, 164, 47, 17));
	CGSize nextSize = m_picNext->GetSize();
	
	m_btnPrev = new NDUIButton();
	m_btnPrev->Initialization();
	m_btnPrev->SetFrameRect(CGRectMake((winsize.width-BTN_W*2)/2, winsize.height-bottom_height-BTN_H, BTN_W, BTN_H));
	m_btnPrev->SetImage(m_picPrev, true,CGRectMake((BTN_W-prevSize.width)/2, (BTN_H-prevSize.height)/2, prevSize.width, prevSize.height));
	m_btnPrev->SetDelegate(this);
	this->AddChild(m_btnPrev);
	
	m_btnNext = new NDUIButton();
	m_btnNext->Initialization();
	m_btnNext->SetFrameRect(CGRectMake((winsize.width-BTN_W*2)/2+BTN_W, winsize.height-bottom_height-BTN_H, BTN_W, BTN_H));
	m_btnNext->SetImage(m_picNext, true,CGRectMake((BTN_W-nextSize.width)/2, (BTN_H-nextSize.height)/2, nextSize.width, nextSize.height));
	m_btnNext->SetDelegate(this);
	this->AddChild(m_btnNext);
	
	m_lbPage = new NDUILabel;
	m_lbPage->Initialization();
	m_lbPage->SetFontSize(15);
	m_lbPage->SetFontColor(ccc4(17, 9, 144, 255));
	m_lbPage->SetTextAlignment(LabelTextAlignmentCenter); 
	m_lbPage->SetFrameRect(CGRectMake(0, winsize.height-bottom_height-BTN_H, winsize.width, BTN_H));
	m_lbPage->SetText("1/1");
	this->AddChild(m_lbPage);
	
	m_topLayerEx = new NDUITopLayerEx;
	m_topLayerEx->Initialization();
	m_topLayerEx->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	this->AddChild(m_topLayerEx);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetDelegate(this);
	m_tlOperate->SetVisible(false);
	m_topLayerEx->AddChild(m_tlOperate);
	
	refresh(true);
}

void GameUIPlayerList::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
		{
			((GameScene*)(this->GetParent()))->SetUIShow(false);
			this->RemoveFromParent(true);
		}
	}
	else if (button == m_btnPrev)
	{
		if (m_iCurPage > 0) 
		{
			m_iCurPage--;
			refresh(true);
		} 
		else
		{
			showDialog("温馨提示", "该页已经是第一页");
		}
	}
	else if (button == m_btnNext)
	{
		if (m_iCurPage+1 < GetPageNum())
		{
			m_iCurPage++;
			refresh(true);
		} 
		else
		{
			showDialog("温馨提示", "该页已经是最后一页");
		}
	}
}

void GameUIPlayerList::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlMain)
	{
		if (int(cellIndex)+m_iCurPage*DIS_COUNT >= int(m_vecSocialInfo.size()))
		{
			return;
		}
		
		SocialInfo& info = m_vecSocialInfo[cellIndex+m_iCurPage*DIS_COUNT];
		NDManualRole *role = NDMapMgrObj.GetManualRole(info.iRoleID);
		if (!role)
		{
			showDialog("温馨提示", "该玩家已离开该区域");
			return;
		}
		
		NDPlayer& player = NDPlayer::defaultHero();
		std::vector<std::string> vec_str;
		std::vector<int> vec_id;
		int iID = 0;
		vec_str.push_back("玩家信息"); vec_id.push_back(iID); iID++;
		vec_str.push_back("查看装备"); vec_id.push_back(iID); iID++;
		
		if (!player.isTeamMember())
		{
			if (role->isTeamMember())
			{
				vec_str.push_back("加入队伍"); vec_id.push_back(iID); iID++;
			}
			else
			{
				vec_str.push_back("邀请组队"); vec_id.push_back(iID); iID++;
			}
		}
		else if (player.isTeamLeader()) 
		{
			if (!role->isTeamMember())
			{
				vec_str.push_back("邀请组队"); vec_id.push_back(iID); iID++;
			}
		}
		
		vec_str.push_back("交易"); vec_id.push_back(iID); iID++;
		vec_str.push_back("添加好友"); vec_id.push_back(iID); iID++;
		vec_str.push_back("私聊"); vec_id.push_back(iID); iID++;
		
		if (!role->IsInState(USERSTATE_PVE))
		{
			vec_str.push_back("PK"); vec_id.push_back(iID); iID++;
		}
		
		vec_str.push_back("比武"); vec_id.push_back(iID); iID++;
	
		if (role->IsInState(USERSTATE_FIGHTING))
		{
			vec_str.push_back("观战"); vec_id.push_back(iID); iID++;
		}
		
		//if (role->battlepet != NULL)
		//{
		//	vec_str.push_back("查看宠物"); vec_id.push_back(iID); iID++;
		//}
		if (player.level < 20 && role->level >= 20) 
		{
			vec_str.push_back("拜师"); vec_id.push_back(iID); iID++;
		} 
		else if (player.level >= 20 && role->level < 20)
		{
			vec_str.push_back("收徒"); vec_id.push_back(iID); iID++;
		}
		
		InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
		m_tlOperate->SetTag(info.iRoleID);
	}
	else if (table == m_tlOperate)
	{
		NDManualRole *role = NDMapMgrObj.GetManualRole(table->GetTag());

		if (!role)
		{
			showDialog("温馨提示", "该玩家已离开该区域");
			return;
		}
		
		if (!cell->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
		{
			return;
		}
		
		NDPlayer& player = NDPlayer::defaultHero();
		NDUIButton *btn = (NDUIButton*)cell;
		std::string title = btn->GetTitle();
		if (title == "玩家信息")
		{
			sendQueryPlayer(role->m_id, _SEE_USER_INFO);
		}
		else if (title == "查看装备")
		{
			sendQueryPlayer(role->m_id, SEE_EQUIP_INFO);
		}
		else if (title == "加入队伍")
		{
			NDTransData bao(_MSG_TEAM);
			bao << (unsigned short)MSG_TEAM_JOIN << player.m_id << role->m_id;
			SEND_DATA(bao);
		}
		else if (title == "邀请组队")
		{
			NDTransData bao(_MSG_TEAM);
			bao << (unsigned short)MSG_TEAM_INVITE << player.m_id << role->m_id;
			SEND_DATA(bao);
		}
		else if (title == "交易")
		{
			//if (AutoFindPath.getInstance().isWork()) {
//				if (!AutoFindPath.getInstance().isClickScreenMode()) {
//					GameScreen.getInstance().initNewChat(new ChatRecordManager(5, "系统", "您正在使用自动导航，不能进行交易！"));
//					break;
//				}
//				AutoFindPath.getInstance().stop();
//			} todo
			trade(role->m_id, 0);
		}
		else if (title == "添加好友")
		{
			sendAddFriend(role->m_name);
		}
		else if (title == "私聊")
		{
			PrivateChatInput::DefaultInput()->SetLinkMan(role->m_name.c_str());
			PrivateChatInput::DefaultInput()->Show();
		}
		else if (title == "PK")
		{
			sendPKAction(*role, BATTLE_ACT_PK);
		}
		else if (title == "比武")
		{
			sendRehearseAction(role->m_id, REHEARSE_APPLY);
		}
		else if (title == "观战")
		{
			ShowProgressBar;
			NDTransData bao(_MSG_BATTLEACT);
			bao << Byte(BATTLE_ACT_WATCH) << Byte(0) << Byte(1) << int(role->m_id);
			SEND_DATA(bao);
		}
		else if (title == "查看宠物")
		{
			sendQueryPlayer(role->m_id, SEE_PET_INFO);
		}
		else if (title == "拜师")
		{
			NDTransData bao(_MSG_TUTOR);
			bao << (unsigned char)1 << role->m_id;
			SEND_DATA(bao);
		}
		else if (title == "收徒")
		{
			NDTransData bao(_MSG_TUTOR);
			bao << (unsigned char)4 << role->m_id;
			SEND_DATA(bao);
		}
		
		m_tlOperate->SetVisible(false);
	}

}

void GameUIPlayerList::refresh(bool bUpGUI /*= true*/)
{
	m_vecSocialInfo.clear();
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	NDMapMgr::map_manualrole& roles = NDMapMgrObj.GetManualRoles();
	NDMapMgr::map_manualrole_it it = roles.begin();
	for (; it != roles.end(); it++)
	{
		NDManualRole *role = it->second;
		if (!role->IsInState(USERSTATE_STEALTH)) //非隐形状态
		{
			 SocialInfo info;
			 info.iRoleID		= role->m_id;
			 info.iState		= SocialInfo::STATE_ONLINE;
			 info.name			= role->m_name;
			 
			 // 队伍状态
			 if (role->isTeamLeader())
			 {
				 info.info = "队长";
			 } 
			 else if (role->isTeamMember())
			 {
				 info.info = "队员";
			 } 
			 else if (role->IsInState(USERSTATE_DEAD)) 
			 {
				 info.info = "死亡";
			 } 
			 else if (role->IsInState(USERSTATE_BOOTH)) 
			 {
				 info.info = "摆摊";
			 } 
			 else 
			 {
				 info.info = "正常";
			 }
			 m_vecSocialInfo.push_back(info);
		}
	}
	
	if (bUpGUI)
	{
		int curCount = m_iCurPage * DIS_COUNT;
		std::stringstream temp;
		if (int(m_vecSocialInfo.size()) > 0)
		{
			temp << "玩家列表[" << (curCount + 1) << " ~ " << (m_vecSocialInfo.size()) << "]";
		} 
		else 
		{
			temp << "玩家列表";
		}
		m_lbTitle->SetText(temp.str().c_str());
		CGSize dim = getStringSizeMutiLine(temp.str().c_str(), 15);
		m_lbTitle->SetFrameRect(CGRectMake((winsize.width-dim.width)/2, (title_height-dim.height)/2, dim.width, dim.height));

		std::stringstream strpage;
		strpage << m_iCurPage+1 << "/" << GetPageNum();
		m_lbPage->SetText(strpage.str().c_str());
		UpdateMainUI();
	}
}

void GameUIPlayerList::draw()
{
	NDUIMenuLayer::draw();
}

void GameUIPlayerList::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
{
#define fastinit(text, iid) \
do \
{ \
NDUIButton *btn = new NDUIButton(); \
btn->Initialization(); \
btn->SetFontSize(15); \
btn->SetTitle(text); \
btn->SetTag(iid); \
btn->SetFontColor(ccc4(0, 0, 0, 255)); \
btn->SetFrameRect(CGRectMake(0, 0, 120, 30)); \
btn->SetFocusColor(ccc4(253, 253, 253, 255)); \
section->AddCell(btn); \
} while (0)
	
	if (!tl || vec_str.empty() || vec_id.empty() || vec_str.size() != vec_id.size() )
	{
		NDLog(@"GameUIPlayerList::InitTLContentWithVec初始化失败");
		return;
	}
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	int iSize = vec_str.size();
	for (int i = 0; i < iSize; i++)
	{
		fastinit(vec_str[i].c_str(), vec_id[i]);
	}
	section->SetFocusOnCell(0);
	dataSource->AddSection(section);
	
	tl->SetFrameRect(CGRectMake((480-120)/2, (320-30*vec_str.size()-vec_str.size()-1)/2, 120, 30*vec_str.size()+vec_str.size()+1));
	tl->SetVisible(true);
	
	if (tl->GetDataSource())
	{
		tl->SetDataSource(dataSource);
		tl->ReflashData();
	}
	else
	{
		tl->SetDataSource(dataSource);
	}
	
#undef fastinit	
}
		
void GameUIPlayerList::UpdateMainUI()
{
	if (!m_tlMain)
	{
		return;
	}
	
	if ( m_vecSocialInfo.empty() )
	{
		if (m_tlMain->GetDataSource()) 
		{
			NDDataSource *source = m_tlMain->GetDataSource();
			source->Clear();
			m_tlMain->ReflashData();
		}
		return;
	}
	
	if (m_iCurPage >= GetPageNum())
	{
		return;
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	int iStart = m_iCurPage * DIS_COUNT;
	int iEnd = (m_iCurPage + 1)* DIS_COUNT >= int(m_vecSocialInfo.size()) ? m_vecSocialInfo.size() : (m_iCurPage + 1)* DIS_COUNT;
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	//section->UseCellHeight(true);
	for (int i = iStart; i < iEnd; i++)
	{
		SocialInfo& socialinfo = m_vecSocialInfo[i];
		NDUIPlayerInfo * info = new NDUIPlayerInfo;
		info->Initialization();
		info->SetPlayerName(socialinfo.name);
		info->SetPlayerNameColor(ccc4(119, 48, 0, 255));
		info->SetPlayerInfo(socialinfo.info);
		info->SetPlayerInfoColor(ccc4(119, 48, 0, 255));
		info->SetFrameRect(CGRectMake(0, 0, winsize.width, 28));
		section->AddCell(info);
	}
	
	if (section->Count() > 0) 
	{
		section->SetFocusOnCell(0);
	}
	dataSource->AddSection(section);
	
	int iHeigh = (iEnd - iStart)*30;//+(iEnd - iStart)+1;
	int iHeighMax = winsize.height-title_height-bottom_height-BTN_H-2*2-20;
	iHeigh = iHeigh < iHeighMax ? iHeigh : iHeighMax;
	
	m_tlMain->SetFrameRect(CGRectMake(MAIN_TB_X, title_height+2+20, winsize.width-2*MAIN_TB_X, iHeigh));
	
	m_tlMain->SetVisible(true);
	
	if (m_tlMain->GetDataSource())
	{
		m_tlMain->SetDataSource(dataSource);
		m_tlMain->ReflashData();
	}
	else
	{
		m_tlMain->SetDataSource(dataSource);
	}
}

int GameUIPlayerList::GetPageNum()
{
	int iCount = m_vecSocialInfo.size()/DIS_COUNT;
	if (m_vecSocialInfo.size()%DIS_COUNT != 0)
	 {
		iCount += 1;
	}
	return iCount;
}
////////////////////////////////////////////////

