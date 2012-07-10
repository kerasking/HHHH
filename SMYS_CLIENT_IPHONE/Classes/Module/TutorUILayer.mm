/*
 *  TutorUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-21.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "TutorUILayer.h"
#include "NDDirector.h"
#include "SocialTextLayer.h"
#include "GameScene.h"
#include "NDUISynLayer.h"
#include "NDConstant.h"
#include "NDMapMgr.h"
#include "ChatInput.h"
#include "NewMailSend.h"
#include "SocialScene.h"
#include <sstream>

#define TAG_BTN_XUNLU 1
#define TAG_BTN_CHAKAN_ZILIAO 2
#define TAG_BTN_JIECHU_GUANXI 3

#define TAG_DLG_CHANGE_MAP 1
#define TAG_DLG_JIECHU_GUANXI 2

enum
{
	eTutorOpBegin = 2135,
	eTutorOpPanshi = eTutorOpBegin,
	eTutorOpMail,
	eTutorOpChat,
	eTutorOpQuZhu,
	eTutorOpXunLu,
	eTutorOpEnd,
};

IMPLEMENT_CLASS(TutorInfo, NDUILayer)

TutorInfo::TutorInfo()
{
	m_figure = NULL;
	
	m_info = NULL;
	
	m_btnClose = NULL;
	
	m_socialEle = NULL;
	
	m_daoshi = false;
}

TutorInfo::~TutorInfo()
{
	for_vec(m_vOpBtn, std::vector<NDUIButton*>::iterator)
	{
		NDUIButton*& btn = *it;
		
		if (btn && btn->GetParent() == NULL) 
		{
			delete btn;
		}
	}
}

void TutorInfo::Initialization(CGPoint pos, bool daoshi/*=false*/)
{
	NDUILayer::Initialization();
	
	m_daoshi = daoshi;
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture* picBg = pool.AddPicture(GetImgPathNew("bag_left_bg.png"));
	
	CGSize sizeBg = picBg->GetSize();
	
	this->SetBackgroundImage(picBg, true);
	
	this->SetFrameRect(CGRectMake(pos.x, pos.y, sizeBg.width, sizeBg.height));
	
	m_figure = new SocialFigure;
	
	m_figure->Initialization(!m_daoshi);
	
	m_figure->SetFrameRect(CGRectMake(11, 9, 178, 112));
	
	this->AddChild(m_figure);
	
	m_info = new SocialEleInfo;
	
	m_info->Initialization(CGRectMake(0, 123, 197, 83));
	
	this->AddChild(m_info);
	
	if (!m_daoshi)
	{
		NDPicture *picClose = pool.AddPicture(GetImgPathNew("bag_left_close.png"));
		
		CGSize sizeClose = picClose->GetSize();
		
		m_btnClose = new NDUIButton;
		
		m_btnClose->Initialization();
		
		m_btnClose->SetFrameRect(CGRectMake(0, 209, sizeClose.width, sizeClose.height));
		
		
		m_btnClose->SetImage(picClose, false, CGRectZero, true);
		
		m_btnClose->SetDelegate(this);
		
		this->AddChild(m_btnClose);
	}
}

void TutorInfo::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnClose)
	{
		this->ChangeTutor(NULL);
		if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(TutorUILayer))) {
			((TutorUILayer*)this->GetParent())->ShowTudiInfo(false);
		}
	}
	else
	{
		if (!m_socialEle) return;
		
		int op = button->GetTag();
		
		switch (op) 
		{
			case eTutorOpQuZhu:
			case eTutorOpPanshi:
			{
				NDUIDialog* dlg = new NDUIDialog;
				dlg->Initialization();
				dlg->SetDelegate(this);
				dlg->SetTag(TAG_DLG_JIECHU_GUANXI);
				dlg->Show(NDCommonCString("DismissRelation"), NDCommonCString("DismissRelationTip"), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
			}
				break;
			case eTutorOpMail:
			{
				NDDirector::DefaultDirector()->PushScene(NewMailSendScene::Scene(m_socialEle->m_text1.c_str()));
			}
				break;
			case eTutorOpChat:
			{
				PrivateChatInput::DefaultInput()->SetLinkMan(m_socialEle->m_text1.c_str());
				PrivateChatInput::DefaultInput()->Show();
			}
				break;
			case eTutorOpXunLu:
			{
				NDUISynLayer::Show();
				NDTransData bao(_MSG_SEE);
				bao << Byte(6) << this->m_socialEle->m_id;
				SEND_DATA(bao);
			}
				break;
			default:
				break;
		}
	}
}

void TutorInfo::ChangeTutor(SocialElement* se)
{
	m_socialEle = se;
	
	if (m_figure)
		m_figure->ChangeFigure(m_socialEle);
		
	SocialData data;
		
	// 获取信息
	if (m_socialEle 
		&& !SocialScene::hasSocialData(m_socialEle->m_id)
		&& m_socialEle->m_state == ES_ONLINE)
	{
		SendSocialRequest(m_socialEle->m_id);
		
		if (m_figure)
			m_figure->ShowLevel(false, 1);
	}
	else
	{
		refreshSocialData();
	}
	
	// 更新操作
	std::vector<std::string> vec_str;
	std::vector<int> vec_op;
	
	if (m_socialEle) 
	{
		vec_str.push_back(m_daoshi ? NDCommonCString("PangShi") : NDCommonCString("QuZhu"));
		vec_op.push_back(m_daoshi ? eTutorOpPanshi : eTutorOpQuZhu);
		
		vec_str.push_back(NDCommonCString("mail"));
		vec_op.push_back(eTutorOpMail);
		
		if (this->m_socialEle->m_state == ES_ONLINE) 
		{
			vec_str.push_back(NDCommonCString("XunLu"));
			vec_op.push_back(eTutorOpXunLu);
			
			vec_str.push_back(NDCommonCString("PrivateChat"));
			vec_op.push_back(eTutorOpChat);
		}
	}
	
	size_t sizeOperate = vec_op.size();
	
	if (sizeOperate != vec_str.size()) 
	{
		return;
	}
	
	size_t sizeBtns = m_vOpBtn.size();
	
	size_t max = sizeBtns;
	
	if (sizeOperate > sizeBtns) 
	{
		m_vOpBtn.resize(sizeOperate, NULL);
		
		max = sizeOperate;
	}
	
	int startx = m_daoshi ? 7 : 36, starty = 208, btnw = 43, btnh = 24, interval = 5, col = m_daoshi ? 4 : 3;
	
	for (size_t i = 0; i < max; i++) 
	{
		NDUIButton*& btn = m_vOpBtn[i];
		if (!btn) 
		{
			NDPicturePool& pool = *(NDPicturePool::DefaultPool());
			btn = new NDUIButton;
			
			btn->Initialization();
			
			btn->SetFontColor(ccc4(255, 255, 255, 255));
			
			btn->SetFontSize(12);
			
			btn->CloseFrame();
			
			btn->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("bag_btn_normal.png"), btnw, 0),
									  pool.AddPicture(GetImgPathNew("bag_btn_click.png"), btnw, 0),
									  false, CGRectZero, true);
			btn->SetDelegate(this);							 
			
			this->AddChild(btn);
		}
		
		btn->SetFrameRect(CGRectMake(startx+(btnw+interval)*(i%col),
									 starty+(btnh+interval)*(i/col), 
									 btnw, 
									 btnh));
		
		if (i >= sizeOperate) 
		{
			btn->SetTitle("");
			
			btn->SetTag(eTutorOpEnd);
			
			if (btn->GetParent() != NULL) 
			{
				btn->RemoveFromParent(false);
			}
			
			continue;
		}
		
		if (btn->GetParent() == NULL) 
		{
			this->AddChild(btn);
		}
		
		btn->SetTag(vec_op[i]);
		
		btn->SetTitle(vec_str[i].c_str());
	}
}

void TutorInfo::refreshSocialData()
{
	if (m_info)
		m_info->ChaneSocialEle(m_socialEle);
	
	if (m_figure)
		m_figure->ChangeFigure(m_socialEle);
		
	if (m_figure && (!m_socialEle || !SocialScene::hasSocialData(m_socialEle->m_id)))
		m_figure->ShowLevel(false, 1);
	
	if (!m_socialEle) return;
	
	m_info->SetVisible(this->IsVisibled());
	
	m_figure->SetVisible(this->IsVisibled());
}

void TutorInfo::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	int tag = dialog->GetTag();
	dialog->Close();
	
	if (!m_socialEle) return;
	
	switch (tag) {
		case TAG_DLG_JIECHU_GUANXI:
		{
			NDTransData bao(_MSG_TUTOR);
			if (m_daoshi) { // 叛师
				bao << (Byte)10 << m_socialEle->m_id;
			} else { // 逐出师门
				bao << (Byte)11 << m_socialEle->m_id;
			}
			SEND_DATA(bao);
		}
			break;
		default:
			break;
	}
}


IMPLEMENT_CLASS(TutorUILayer, NDUIMenuLayer)

TutorUILayer* TutorUILayer::s_instance = NULL;
SocialElement* TutorUILayer::s_seDaoshi = NULL;
VEC_TUDI_ELEMENT TutorUILayer::s_vTudi;
map_social_data TutorUILayer::s_mapTurtorData;

void TutorUILayer::processUserPos(NDTransData& data)
{
	if (!s_instance) {
		return;
	}
	
	data.ReadInt();
    	s_instance->m_idDestMap = data.ReadInt();
    	s_instance->m_destX = data.ReadShort();
    	s_instance->m_destY = data.ReadShort();
    	
	NDUISynLayer::Close();
	
	NDPlayer& role = NDPlayer::defaultHero();
	
	if (role.idCurMap == s_instance->m_idDestMap) {
		int destX = s_instance->m_destX;
		int destY = s_instance->m_destY;
			
		NDDirector::DefaultDirector()->PopScene();
			
		role.Walk(CGPointMake(destX * 16, destY * 16), SpriteSpeedStep4);
	} else { // 不同地图的,飞过去
		NDUIDialog* dlg = new NDUIDialog;
		dlg->Initialization();
		dlg->SetDelegate(s_instance);
		dlg->SetTag(TAG_DLG_CHANGE_MAP);
		dlg->Show(NDCommonCString("XunLu"), NDCommonCString("XunLuJuanZhouTip"), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
	}
}

void TutorUILayer::processTutorList(NDTransData& data)
{
	reset();
	
	int nCount = data.ReadByte();
	
	int flag = 0;
	for (int i = nCount; i > 0; i--) {
		SocialElement* element = new SocialElement;
		element->m_id = data.ReadInt();
		flag = data.ReadByte();
		
		// 低1位: 是否在线
		if ((flag & 0x01) == 0x01) {
			element->m_state = ES_ONLINE;
			element->m_text2 = NDCommonCString("online");
		} else {
			element->m_state = ES_OFFLINE;
			element->m_text2 = NDCommonCString("offline");
		}
		
		// 低2位: 是否导师
		if (0x02 == (flag & 0x02)) {
			s_seDaoshi = element;
		} else {
			s_vTudi.push_back(element);
		}
		
		// 低3位: 是否出师
		element->m_param = (flag & 0x04) == 0x04 ? 1 : 0;
		element->m_text1 = data.ReadUnicodeString(); // 名字
		element->m_text3 = element->m_param == 1 ? NDCommonCString("ChuShi") : NDCommonCString("normal");
	}
}

void TutorUILayer::processMsgTutor(NDTransData& data)
{
	unsigned char action = 0; data >> action;
	int idRole = 0; data >> idRole;
	std::string roleName = data.ReadUnicodeString();
	
	RequsetInfo info;
	switch (action) {
		case 1: // 拜师申请
			info.set(idRole, roleName, RequsetInfo::ACTION_BAISHI);
			NDMapMgrObj.addRequst(info);
			break;
		case 2: // 同意当导师
		case 14: // 同意当徒弟成功回馈
			SAFE_DELETE(s_seDaoshi);
			s_seDaoshi = new SocialElement;
			s_seDaoshi->m_id = idRole;
			s_seDaoshi->m_state = ES_ONLINE;
			s_seDaoshi->m_text1 = roleName;
			s_seDaoshi->m_text2 = NDCommonCString("online");
			s_seDaoshi->m_text3 = NDCommonCString("normal");
			if (s_instance) {
				s_instance->refreshMainList();
			}
			break;
		case 4: // 收徒申请
			info.set(idRole, roleName, RequsetInfo::ACTION_SOUTU);
			NDMapMgrObj.addRequst(info);
			break;
		case 5: // 同意当徒弟
		case 13: // 同意当导师成功回馈
		{
			SocialElement* tudi = new SocialElement;
			tudi->m_id = idRole;
			tudi->m_state = ES_ONLINE;
			tudi->m_text1 = roleName;
			tudi->m_text2 = NDCommonCString("online");
			tudi->m_text3 = NDCommonCString("normal");
			s_vTudi.push_back(tudi);
			
			if (s_instance) {
				s_instance->refreshMainList();
			}
		}
			break;
		case 7: // 上线
		case 8: // 下线
		{
			ELEMENT_STATE es = action == 7 ? ES_ONLINE : ES_OFFLINE;
			string str;
			if (s_seDaoshi && s_seDaoshi->m_id == idRole) {
				s_seDaoshi->m_state = es;
				s_seDaoshi->m_text2 = es == ES_ONLINE ? NDCommonCString("online") : NDCommonCString("offline");
				str = NDCommonCString("YourMaster") + s_seDaoshi->m_text1;
				
				if (es == ES_ONLINE) {
					str += NDCommonCString("OnlineTip");
				} else {
					str += NDCommonCString("OfflineTip");
				}
			} else {
				for (VEC_TUDI_ELEMENT_IT it = s_vTudi.begin(); it != s_vTudi.end(); it++) {
					SocialElement& tudi = *(*it);
					if (tudi.m_id == idRole) {
						tudi.m_state = es;
						tudi.m_text2 = es == ES_ONLINE ? NDCommonCString("online") : NDCommonCString("offline");
						str = NDCommonCString("YourTuDi") + tudi.m_text1;
						if (es == ES_ONLINE) {
							str += NDCommonCString("OnlineTip");
						} else {
							str += NDCommonCString("OfflineTip");
						}
						break;
					}
				}
			}
			
			if (!str.empty()) {
				Chat::DefaultChat()->AddMessage(ChatTypeSystem, str.c_str());
			}
			
			if (s_instance) {
				s_instance->refreshMainList();
			}
		}
			break;
		case 9: // 出师
			if (s_seDaoshi && s_seDaoshi->m_id == idRole) {
				s_seDaoshi->m_param = 1;
				s_seDaoshi->m_text3 = NDCommonCString("ChuShi");
				NDUISynLayer::Close();
			} else {
				for (VEC_TUDI_ELEMENT_IT it = s_vTudi.begin(); it != s_vTudi.end(); it++) {
					SocialElement& tudi = *(*it);
					if (tudi.m_id == idRole) {
						tudi.m_param = 1;
						tudi.m_text3 = NDCommonCString("ChuShi");
						break;
					}
				}
			}
			if (s_instance) {
				s_instance->refreshMainList();
			}
			break;
		case 10: // 解除关系
		case 11:
			if (s_seDaoshi && s_seDaoshi->m_id == idRole) {
				SAFE_DELETE(s_seDaoshi);
			} else {
				for (VEC_TUDI_ELEMENT_IT it = s_vTudi.begin(); it != s_vTudi.end(); it++) {
					if ((*it)->m_id == idRole) {
						s_vTudi.erase(it);
						break;
					}
				}
			}

			if (s_instance) {
				s_instance->refreshMainList();
			}
			break;
		case 12: // 玩家删除角色
		{
			string str;
			if (s_seDaoshi && s_seDaoshi->m_id == idRole) {
				str = NDCommonCString("YourMaster") + s_seDaoshi->m_text1;
				str += NDCommonCString("LeaveGameTip");
				SAFE_DELETE(s_seDaoshi);
			} else {
				for (VEC_TUDI_ELEMENT_IT it = s_vTudi.begin(); it != s_vTudi.end(); it++) {
					if ((*it)->m_id == idRole) {
						str = NDCommonCString("YourTuDi") + (*it)->m_text1;
						str += NDCommonCString("LeaveGameTip");
						s_vTudi.erase(it);
						break;
					}
				}
			}

			if (!str.empty()) {
				Chat::DefaultChat()->AddMessage(ChatTypeSystem, str.c_str());
			}
			
			if (s_instance) {
				s_instance->refreshMainList();
			}
		}
			break;
		case 19: // npc 注册拜师,不在线
			SAFE_DELETE(s_seDaoshi);
			s_seDaoshi = new SocialElement;
			s_seDaoshi->m_id = idRole;
			s_seDaoshi->m_state = ES_ONLINE;
			s_seDaoshi->m_text1 = roleName;
			s_seDaoshi->m_text2 = NDCommonCString("offline");
			s_seDaoshi->m_text3 = NDCommonCString("normal");
			
			if (s_instance) {
				s_instance->refreshMainList();
			}
			break;
	}
}

void TutorUILayer::reset()
{
	SAFE_DELETE(s_seDaoshi);
	for (VEC_TUDI_ELEMENT_IT it = s_vTudi.begin(); it != s_vTudi.end(); it++) {
		SAFE_DELETE(*it);
	}
	s_vTudi.clear();
}

void TutorUILayer::processSocialData(/*SocialData& data*/)
{
	/*
	bool find = false;
	
	do 
	{
		if (s_seDaoshi && s_seDaoshi->m_id == data.iId)
		{
			find = true;
			break;
		}
		
		for_vec(s_vTudi, VEC_TUDI_ELEMENT_IT)
		{
			if ((*it)->m_id == data.iId)
			{
				find = true;
				break;
			}
		}
	} while (0);
	
	if (!find) return;
	
	SocialData& tutor = s_mapTurtorData[data.iId];
	tutor = data;
	*/
	if (s_instance) 
		s_instance->refreshSocialData();
}

void TutorUILayer::processSeeEquip(int targetId, int lookface)
{
	if (s_instance) 
		s_instance->ShowEquipInfo(true, lookface, targetId);
}

void TutorUILayer::refreshScroll()
{
	if (s_instance) {
		s_instance->refreshMainList();
	}
}

TutorUILayer::TutorUILayer()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	m_tlTudi = NULL;
	m_curSelEle = NULL;
	m_idDestMap = 0;
	m_destX = 0;
	m_destY = 0;
	m_infoTuDiShow  = false;
	m_infoEquip = NULL;
}

TutorUILayer::~TutorUILayer()
{
	s_instance = NULL;
}

void TutorUILayer::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	int tag = dialog->GetTag();
	dialog->Close();
	switch (tag) {
		case TAG_DLG_CHANGE_MAP:
		{
			NDDirector::DefaultDirector()->PopScene();
			NDMapMgrObj.throughMap(this->m_destX, this->m_destY, this->m_idDestMap);
		}
			break;
		case TAG_DLG_JIECHU_GUANXI:
		{
			/*
			this->m_optLayer->RemoveFromParent(true);
			this->m_optLayer = NULL;
			
			NDTransData bao(_MSG_TUTOR);
			if (this->m_curSelEle == s_seDaoshi) { // 叛师
    				bao << (Byte)10 << s_seDaoshi->m_id;
    			} else { // 逐出师门
    				bao << (Byte)11 << this->m_curSelEle->m_id;
    			}
    			SEND_DATA(bao);
			*/
		}
			break;
		default:
			break;
	}
}

void TutorUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table != m_tlTudi || !cell->IsKindOfClass(RUNTIME_CLASS(NDSocialCell))) return;
	
	NDSocialCell *sc = (NDSocialCell*)cell;
	
	if (m_infoTuDi)
	{
		m_infoTuDi->ChangeTutor(sc->GetSocialElement());
		ShowTudiInfo(true);
	}
	
	return;
	/*	
	if (this->m_optLayer && this->m_optLayer->GetOpt() == table) {
		switch (cell->GetTag()) {
			case TAG_BTN_XUNLU:
			{
				NDUISynLayer::Show();
				NDTransData bao(_MSG_SEE);
				bao << Byte(6) << this->m_curSelEle->m_id;
				SEND_DATA(bao);
			}
				break;
			case TAG_BTN_CHAKAN_ZILIAO:
				sendQueryPlayer(this->m_curSelEle->m_id, _SEE_USER_INFO);
				break;
			case TAG_BTN_JIECHU_GUANXI:
			{
				NDUIDialog* dlg = new NDUIDialog;
				dlg->Initialization();
				dlg->SetDelegate(this);
				dlg->SetTag(TAG_DLG_JIECHU_GUANXI);
				dlg->Show("解除关系", "解除师徒关系后,将不能恢复,请三思确认要断绝关系？", "取消", "确定", NULL);
			}
				break;
			default:
				break;
		}
	} else {
		this->m_curSelEle = ((SocialTextLayer*)cell)->GetSocialElement();
		// 显示操作选项
		NDUITableLayer* opt = new NDUITableLayer;
		opt->Initialization();
		opt->VisibleSectionTitles(false);
		opt->SetDelegate(this);
		
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		int nOptHeight = 0;
		
		NDDataSource* ds = new NDDataSource;
		NDSection* sec = new NDSection;
		ds->AddSection(sec);
		opt->SetDataSource(ds);
		
		if (this->m_curSelEle->m_state == ES_ONLINE) { // 在线
			NDUIButton* btn = new NDUIButton;
			btn->Initialization();
			btn->SetTitle("寻路");
			btn->SetTag(TAG_BTN_XUNLU);
			btn->SetFocusColor(ccc4(253, 253, 253, 255));
			sec->AddCell(btn);
			
			btn = new NDUIButton;
			btn->Initialization();
			btn->SetTitle("查看资料");
			btn->SetTag(TAG_BTN_CHAKAN_ZILIAO);
			btn->SetFocusColor(ccc4(253, 253, 253, 255));
			sec->AddCell(btn);
			
			nOptHeight += 60;
			
			if (this->m_curSelEle->m_param == 0) { // 未出师
				btn = new NDUIButton;
				btn->Initialization();
				btn->SetTitle("解除关系");
				btn->SetTag(TAG_BTN_JIECHU_GUANXI);
				btn->SetFocusColor(ccc4(253, 253, 253, 255));
				sec->AddCell(btn);
				
				nOptHeight += 30;
			}
			sec->SetFocusOnCell(0);
		} else { // 不在线
			if (this->m_curSelEle->m_param == 0) { // 未出师
				NDUIButton* btn = new NDUIButton;
				btn->Initialization();
				btn->SetTitle("解除关系");
				btn->SetTag(TAG_BTN_JIECHU_GUANXI);
				btn->SetFocusColor(ccc4(253, 253, 253, 255));
				sec->AddCell(btn);
				nOptHeight += 30;
				sec->SetFocusOnCell(0);
			} else {
				SAFE_DELETE(opt);
				return;
			}
		}

		opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - nOptHeight) / 2, 94, nOptHeight));
		
		this->m_optLayer = new NDOptLayer;
		this->m_optLayer->Initialization(opt);
		this->AddChild(m_optLayer);
	}
	*/
}

void TutorUILayer::OnButtonClick(NDUIButton* button)
{
	/*
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
	*/
}

void TutorUILayer::Initialization()
{
	NDUILayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_infoDaoShi = new TutorInfo;
	
	m_infoDaoShi->Initialization(CGPointMake(0, 48), true);
	
	this->AddChild(m_infoDaoShi);

	refreshDaoShi();
	
	
	//m_tlTudi = new NDUITableLayer;
	
	//m_tlTudi->Initialization();
	
	int width = 252;//, height = 274;
	do 
	{
		m_tlTudi = new NDUITableLayer;
		m_tlTudi->Initialization();
		m_tlTudi->SetSelectEvent(false);
		m_tlTudi->SetBackgroundColor(ccc4(0, 0, 0, 0));
		m_tlTudi->VisibleSectionTitles(false);
		m_tlTudi->SetFrameRect(CGRectMake(6+200, 17+37, width-10, 226));
		m_tlTudi->VisibleScrollBar(false);
		m_tlTudi->SetCellsInterval(2);
		m_tlTudi->SetCellsRightDistance(0);
		m_tlTudi->SetCellsLeftDistance(0);
		m_tlTudi->SetDelegate(this);
		
		NDDataSource *dataSource = new NDDataSource;
		NDSection *section = new NDSection;
		section->UseCellHeight(true);
		
		for_vec(s_vTudi, VEC_TUDI_ELEMENT_IT)
		{
			NDSocialCell *cell = new NDSocialCell;
			cell->Initialization();
			cell->ChangeSocialElement(*it);
			section->AddCell(cell);
		}
		
		section->SetFocusOnCell(0);
		
		dataSource->AddSection(section);
		m_tlTudi->SetDataSource(dataSource);
		this->AddChild(m_tlTudi);
	} while (0);
	
	m_infoTuDi = new TutorInfo;
	
	m_infoTuDi->Initialization(CGPointMake(0, 48));
	
	this->AddChild(m_infoTuDi);
	
	refreshTuDi();
	
	if (!s_seDaoshi && s_vTudi.size() > (unsigned int)0 && m_infoTuDi)
	{
		m_infoTuDi->ChangeTutor(s_vTudi[0]);
		ShowTudiInfo(true);
	}else if (s_seDaoshi && m_infoDaoShi)
	{
		m_infoDaoShi->ChangeTutor(s_seDaoshi);
	}
}

void TutorUILayer::refreshTuDi()
{
	// 徒弟列表
	if (!m_tlTudi 
		|| !m_tlTudi->GetDataSource()
		|| m_tlTudi->GetDataSource()->Count() != 1)
		return;
		
	NDSection* section = m_tlTudi->GetDataSource()->Section(0);
	
	size_t maxCount = section->Count() > s_vTudi.size() ? section->Count() : s_vTudi.size();
	
	unsigned int infoCount = 0;
	
	for (size_t i = 0; i < maxCount; i++) 
	{
		SocialElement *se = i < s_vTudi.size() ? s_vTudi[i] : NULL;
		
		if (se != NULL)
		{
			NDSocialCell *cell = NULL;
			if (infoCount < section->Count())
				cell = (NDSocialCell *)section->Cell(infoCount);
			else
			{
				cell = new NDSocialCell;
				cell->Initialization();
				section->AddCell(cell);
			}
			cell->ChangeSocialElement(se);
			
			infoCount++;
		}
		else
		{
			if (infoCount < section->Count() && section->Count() > 0)
			{
				section->RemoveCell(section->Count()-1);
			}
		}
	}
	
	m_tlTudi->ReflashData();
}

void TutorUILayer::refreshDaoShi()
{
	if (m_infoDaoShi)
	{
		m_infoDaoShi->ChangeTutor(s_seDaoshi);
		//m_infoDaoShi->SetVisible(s_seDaoshi != NULL);
	}
}

void TutorUILayer::SetVisible(bool visible)
{
	NDUILayer::SetVisible(visible);
	
	if (visible)
	{
		//m_infoTuDi->SetVisible(m_infoTuDiShow);
		
		refreshMainList();
	}
	
	ShowEquipInfo(false);
}

void TutorUILayer::ShowTudiInfo(bool show)
{
	if (m_infoTuDi) 
	{
		m_infoTuDi->SetVisible(show);
		m_infoTuDiShow = show;
	}
}

void TutorUILayer::refreshMainList()
{
	refreshDaoShi();
	
	refreshTuDi();
	
	// 1.显示导师 删除导师　-->选第0个徒弟显示
	// 2.显示导师 删除徒弟  -->不做处理
	// 3.显示徒弟 删除导师  -->不做处理
	// 4.显示徒弟 删除徒弟  -->删除的是显示的徒弟则选第0个徒弟显示
	// 5.更新信息
	
	if (m_infoDaoShi)
		m_infoDaoShi->ChangeTutor(s_seDaoshi);
		
	if (!m_infoTuDi) return;
	
	
	// 统一先更新
	SocialElement* se = m_infoTuDi->GetTutor();
	
	VEC_TUDI_ELEMENT_IT it = s_vTudi.begin();
	bool find = false;
	for (; it != s_vTudi.end(); it++) 
	{
		if (*it == se)
		{
			find = true;
			break;
		}
	}
	
	if (find)
	{
		m_infoTuDi->ChangeTutor(se);
		if (!s_seDaoshi && this->IsVisibled())
			ShowTudiInfo(true);
	}
	else
	{
		if (!se)
			ShowTudiInfo(false);

		if ((!s_seDaoshi || m_infoTuDi->IsVisibled()) && this->IsVisibled())
		{
			
			if (!s_vTudi.empty())
			{
				m_infoTuDi->ChangeTutor(s_vTudi[0]);
				ShowTudiInfo(true);
			}
			else
			{
				ShowTudiInfo(false);
			}
		}
	}
}

void TutorUILayer::refreshSocialData()
{
	if (m_infoDaoShi)
		m_infoDaoShi->refreshSocialData();
		
	if (m_infoTuDi)
		m_infoTuDi->refreshSocialData();
}

void TutorUILayer::ShowEquipInfo(bool show, int lookface/*=0*/, int targetId/*=0*/)
{
	if (!show) 
	{
		SAFE_DELETE_NODE(m_infoEquip);
	
		return;
	}
	
	if (!this->IsVisibled()) return;
	
	bool find = false;
	
	if (m_infoTuDi && m_infoTuDi->GetTutor() && m_infoTuDi->GetTutor()->m_id == targetId)
	{
		find = true;
	}
	
	if (m_infoDaoShi && m_infoDaoShi->GetTutor() && m_infoDaoShi->GetTutor()->m_id == targetId)
	{
		find = true;
	}
	
	if (!find) return;
	
	SAFE_DELETE_NODE(m_infoEquip);
	
	m_infoEquip = new SocialPlayerEquip;
	
	m_infoEquip->Initialization(lookface);
	
	m_infoEquip->SetFrameRect(CGRectMake(0, 0, 480, 320));
	
	this->AddChild(m_infoEquip);
	
	if (m_tlTudi)
		m_tlTudi->SetVisible(false);
}
