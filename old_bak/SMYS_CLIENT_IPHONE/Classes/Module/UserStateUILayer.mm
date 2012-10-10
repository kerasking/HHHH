/*
 *  UserStateUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-22.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "UserStateUILayer.h"
#include "NDDirector.h"
#include "NDUISynLayer.h"
#include "NDPlayer.h"
#include "NDMsgDefine.h"
#include <sstream>
#include "SocialTextLayer.h"
#include "GameScene.h"
#include "PlayerSkillInfo.h"

IMPLEMENT_CLASS(UserStateUILayer, NDUIMenuLayer)

UserStateUILayer* UserStateUILayer::s_instance = NULL;

MAP_USER_STATE UserStateUILayer::s_mapUserState;

MAP_USER_STATE& UserStateUILayer::getAllUserState()
{
	return s_mapUserState;
}

void UserStateUILayer::processMsgUserState(NDTransData& data)
{
	NDUISynLayer::Close();
	int count = data.ReadByte();
	for (int i = 0; i < count; i++) {
		int idState = data.ReadInt();
		
		UserState* state = getUserStateByID(idState);
		if (!state) {
			state = new UserState;
			s_mapUserState[idState] = state;
			state->idState = idState;
		}
		
		state->nData = data.ReadInt();
		state->endTime = data.ReadInt();
		
		// TODO: 新增图标索引等4个字段
		state->iconIndex = data.ReadInt();
		state->stateName = data.ReadUnicodeString();
		state->iconName = data.ReadUnicodeString();
		state->shortTip = data.ReadUnicodeString();
		state->descript = data.ReadUnicodeString();
		
		// 计算状态类型和结束时间
		//state->m_text1 = getStateNameByID(idState);
		//state->m_text2 = getStringTime(endTime);
		chgUserAttr(*state, true);
		
		//string str = getStateShowStr(*state);
		NDScene* scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
		if (scene) {
			((GameScene*)scene)->AddUserState(idState, state->shortTip);
		}
	}
	if (s_instance) {
		s_instance->refreshMainList();
	}
}

void UserStateUILayer::processMsgUserStateChg(NDTransData& data)
{
	NDUISynLayer::Close();
	int idState = data.ReadInt();
	delUserStateByID(idState);
}

void UserStateUILayer::delUserStateByID(int idState) {
	MAP_USER_STATE_IT it = s_mapUserState.find(idState);
	if (it != s_mapUserState.end()) {
		chgUserAttr(*(it->second), false);
		SAFE_DELETE(it->second);
		s_mapUserState.erase(it);
		
		NDScene* scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
		if (scene) {
			((GameScene*)scene)->DelUserState(idState);
		}
		
		UserStateIconLayer::OnDelUserState();
	}
}

void UserStateUILayer::chgUserAttr(UserState& state, bool bSet) {
	int nData = state.nData;
	NDPlayer& role = NDPlayer::defaultHero();
	
	switch (state.idState / 1000 % 100) {
		case 3: { // 力量
			if (bSet) {
				role.phyAdd = nData;
			} else {
				role.phyAdd = 0;
			}
			break;
		}
		case 4: { // 敏捷
			if (bSet) {
				role.dexAdd = nData;
			} else {
				role.dexAdd = 0;
			}
			break;
		}
		case 5: { // 体力
			if (bSet) {
				role.defAdd = nData;
			} else {
				role.defAdd = 0;
			}
			break;
		}
		case 6: { // 智力
			if (bSet) {
				role.magAdd = nData;
			} else {
				role.magAdd = 0;
			}
			break;
		}
		case 7: { // 物攻
			if (bSet) {
				role.wuGongAdd = nData;
			} else {
				role.wuGongAdd = 0;
			}
			break;
		}
		case 8: { // 物防
			if (bSet) {
				role.wuFangAdd = nData;
			} else {
				role.wuFangAdd = 0;
			}
			break;
		}
		case 9: { // 法攻
			if (bSet) {
				role.faGongAdd = nData;
			} else {
				role.faGongAdd = 0;
			}
			break;
		}
		case 10: { // 法防
			if (bSet) {
				role.faFangAdd = nData;
			} else {
				role.faFangAdd = 0;
			}
			break;
		}
		case 11: { // 闪避
			if (bSet) {
				role.sanBiAdd = nData;
			} else {
				role.sanBiAdd = 0;
			}
			break;
		}
		case 12: { // 暴击
			if (bSet) {
				role.baoJiAdd = nData;
			} else {
				role.baoJiAdd = 0;
			}
			break;
		}
		case 14: { // 变形
			if (bSet) {
				role.updateTransform(nData);
			} else {
				role.updateTransform(0);
			}
			break;
		}
		case 17: { // 命中
			if (bSet) {
				role.wuLiMingZhongAdd = nData;
			} else {
				role.wuLiMingZhongAdd = 0;
			}
			break;
		}
	}
}

/*string UserStateUILayer::getStateNameByID(int idState) {
	string stateName = "null text";
	switch (idState / 1000 % 100) {
		case 1: {
			stateName = ("HP上限");
			break;
		}
		case 2: {
			stateName = ("MP上限");
			break;
		}
		case 3: {
			stateName = ("力量");
			break;
		}
		case 4: {
			stateName = ("敏捷");
			break;
		}
		case 5: {
			stateName = ("体质");
			break;
		}
		case 6: {
			stateName = ("智力");
			break;
		}
		case 7: {
			stateName = ("物理攻击力");
			break;
		}
		case 8: {
			stateName = ("物理防御力");
			break;
		}
		case 9: {
			stateName = ("法术攻击力");
			break;
		}
		case 10: {
			stateName = ("法术防御力");
			break;
		}
		case 11: {
			stateName = ("闪避");
			break;
		}
		case 12: {
			stateName = ("暴击");
			break;
		}
		case 13: {
			stateName = ("隐形效果");
			break;
		}
		case 14: {
			stateName = ("变形效果");
			break;
		}
		case 15: {
			stateName = ("经验");
			break;
		}
		case 16: {
			stateName = ("免PK");
			break;
		}
		case 17: {
			stateName = ("命中");
			break;
		}
		case 52: {
			stateName = "劫匪";
			break;
		}
	}
	return stateName;
}*/

/*string UserStateUILayer::getStateDetail(SocialElement& state) {
	stringstream stateDetail;
	switch (state.m_id / 1000 % 100) {
		case 1: {
			stateDetail << "短期HP上限提升:" << state.m_param;
			break;
		}
		case 2: {
			stateDetail << "短期MP上限提升:" << state.m_param;
			break;
		}
		case 3: {
			stateDetail << "短期提升力量:" << state.m_param;
			break;
		}
		case 4: {
			stateDetail << "短期提升敏捷:" << state.m_param;
			break;
		}
		case 5: {
			stateDetail << "短期提升体质:" << state.m_param;
			break;
		}
		case 6: {
			stateDetail << "短期提升智力:" << state.m_param;
			break;
		}
		case 7: {
			stateDetail << "短期提升物攻:" << state.m_param;
			break;
		}
		case 8: {
			stateDetail << "短期提升物防:" << state.m_param;
			break;
		}
		case 9: {
			stateDetail << "短期提升法术攻击力:" << state.m_param;
			break;
		}
		case 10: {
			stateDetail << "短期提升法术抗性:" << state.m_param;
			break;
		}
		case 11: {
			stateDetail << "短期提升闪避:" << state.m_param;
			break;
		}
		case 12: {
			stateDetail << "短期提升暴击:" << state.m_param;
			break;
		}
		case 13: {
			stateDetail << "短时间隐形";
			break;
		}
		case 14: {
			stateDetail << "短时间变形";
			break;
		}
		case 15: {
			stateDetail << "获得经验提升";
			break;
		}
		case 16: {
			stateDetail << "免PK";
			break;
		}
		case 17: {
			stateDetail << "短期提升命中:" << state.m_param;
			break;
		}
		case 52: {
			stateDetail << "大侠快去劫富济贫吧！";
			break;
		}
	}
	return stateDetail.str();
}*/

/*string UserStateUILayer::getStateShowStr(SocialElement& state) {
	string str;
	switch (state.m_id / 1000 % 100) {
		case 1: {
			str = ("HP");
			break;
		}
		case 2: {
			str = ("MP");
			break;
		}
		case 3: {
			str = ("力");
			break;
		}
		case 4: {
			str = ("敏");
			break;
		}
		case 5: {
			str = ("体");
			break;
		}
		case 6: {
			str = ("智");
			break;
		}
		case 7: {
			str = ("物攻");
			break;
		}
		case 8: {
			str = ("物防");
			break;
		}
		case 9: {
			str = ("法攻");
			break;
		}
		case 10: {
			str = ("法防");
			break;
		}
		case 11: {
			str = ("闪");
			break;
		}
		case 12: {
			str = ("暴");
			break;
		}
		case 13: {
			str = ("隐");
			break;
		}
		case 14: {
			str = ("变");
			break;
		}
		case 15: {
			str = ("双");
			break;
		}
		case 16: {
			str = ("免PK");
			break;
		}
		case 17: {
			str = ("准");
			break;
		}
	}
	return str;
}*/

void UserStateUILayer::reset()
{
	for (MAP_USER_STATE_IT it = s_mapUserState.begin(); it != s_mapUserState.end(); it++) {
		SAFE_DELETE(it->second);
	}
	s_mapUserState.clear();
}

UserState* UserStateUILayer::getUserStateByID(int idState)
{
	MAP_USER_STATE_IT it = s_mapUserState.find(idState);
	return it == s_mapUserState.end() ? NULL : it->second;
}

void UserStateUILayer::delUserStealth() {
	for (MAP_USER_STATE_IT it = s_mapUserState.begin(); it != s_mapUserState.end(); it++) {
		UserState& state = *(it->second);
		if (state.idState  / 1000 % 100 == 13) {
			NDTransData bao(_MSG_USER_STATE_CHG);
			bao << (state.idState);
			SEND_DATA(bao);
			return;
		}
	}
}

UserStateUILayer::UserStateUILayer()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	m_tlUserState = NULL;
	m_curSelEle = NULL;
	m_optLayer = NULL;
}

UserStateUILayer::~UserStateUILayer()
{
	s_instance = NULL;
}

void UserStateUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (this->m_tlUserState == table) {
		this->m_curSelEle = ((SocialTextLayer*)cell)->GetSocialElement();
		// 显示操作选项
		NDUITableLayer* opt = new NDUITableLayer;
		opt->Initialization();
		opt->VisibleSectionTitles(false);
		opt->SetDelegate(this);
		
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - 60) / 2, 94, 60));
		
		NDDataSource* ds = new NDDataSource;
		NDSection* sec = new NDSection;
		ds->AddSection(sec);
		opt->SetDataSource(ds);
		
		NDUIButton* btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle(NDCommonCString("ViewDetail"));
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle(NDCommonCString("YiChu"));
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		
		sec->SetFocusOnCell(0);
		
		this->m_optLayer = new NDOptLayer;
		this->m_optLayer->Initialization(opt);
		this->AddChild(m_optLayer);
	} else if (this->m_optLayer && this->m_optLayer->GetOpt() == table) {
		switch (cellIndex) {
			case 0: // 查看详细
			{
				//NDUIDialog* dlg = new NDUIDialog;
				//dlg->Initialization();
				//dlg->Show("状态详细", getStateDetail(*(this->m_curSelEle)).c_str(), NULL, NULL);
			}
				break;
			case 1: // 移除
			{
				NDTransData bao(_MSG_USER_STATE_CHG);
				bao << this->m_curSelEle->m_id;
				SEND_DATA(bao);
			}
				break;
			default:
				break;
		}
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
}

void UserStateUILayer::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (this->m_optLayer) {
			this->m_optLayer->RemoveFromParent(true);
			this->m_optLayer = NULL;
		} else {
			if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
			{
				((GameScene*)(this->GetParent()))->SetUIShow(false);
				this->RemoveFromParent(true);
			}
		}
	}
}

void UserStateUILayer::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUILabel* title = new NDUILabel;
	title->Initialization();
	title->SetText(NDCommonCString("PaticularState"));
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentCenter);
	title->SetFrameRect(CGRectMake(0, 5, winsize.width, 15));
	title->SetFontColor(ccc4(255, 240, 0,255));
	this->AddChild(title);
	
	NDUILayer* columnTitle = new NDUILayer;
	columnTitle->Initialization();
	columnTitle->SetBackgroundColor(ccc4(115, 117, 115, 255));
	columnTitle->SetFrameRect(CGRectMake(7, 29, 466, 17));
	this->AddChild(columnTitle);
	
	title = new NDUILabel;
	title->Initialization();
	title->SetText(NDCommonCString("state"));
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentLeft);
	title->SetFrameRect(CGRectMake(8, 30, 316, 17));
	title->SetFontColor(ccc4(0, 0, 0,255));
	this->AddChild(title);
	
	title = new NDUILabel;
	title->Initialization();
	title->SetText(NDCommonCString("deadline"));
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentRight);
	title->SetFrameRect(CGRectMake(8, 30, 316, 17));
	title->SetFontColor(ccc4(0, 0, 0,255));
	this->AddChild(title);
	
	this->m_tlUserState = new NDUITableLayer;
	m_tlUserState->Initialization();
	m_tlUserState->SetDelegate(this);
	m_tlUserState->SetFrameRect(CGRectMake(2, 48, 476, 230));
	m_tlUserState->VisibleSectionTitles(false);
	m_tlUserState->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->AddChild(m_tlUserState);
	m_tlUserState->SetDataSource(new NDDataSource);
	
	this->refreshMainList();
}

void UserStateUILayer::refreshMainList()
{
	// 清除相关数据
	this->m_curSelEle = NULL;
	
	if (this->m_optLayer) {
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
	
	NDDataSource *ds = this->m_tlUserState->GetDataSource();
	ds->Clear();
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	/*bool bChangeClr = false;
	for (MAP_USER_STATE_IT it = s_mapUserState.begin(); it != s_mapUserState.end(); it++) {
		SocialTextLayer* st = new SocialTextLayer;
		st->Initialization(CGRectMake(5.0f, 0.0f, 460.0f, 27.0f),
				   CGRectMake(5.0f, 0.0f, 330.0f, 27.0f), it->second);
		if (bChangeClr) {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
		} else {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
		}
		
		bChangeClr = !bChangeClr;
		sec->AddCell(st);
	}*/
	sec->SetFocusOnCell(0);
	
	this->m_tlUserState->ReflashData();
}