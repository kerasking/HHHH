/*
 *  PlayerSkillInfo.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "PlayerSkillInfo.h"
#include "NDUtility.h"
#include "ItemImage.h"
#include "BattleMgr.h"
#include "BattleSkill.h"
#include <sstream>
#include "NDMapMgr.h"
#include "UserStateUILayer.h"
#include "ItemMgr.h"
#include "NDString.h"
#include "NDPath.h"

using namespace NDEngine;

////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(CActSkillInfoLayer, NDUILayer)

CActSkillInfoLayer::CActSkillInfoLayer()
{
	m_imgSkill		= NULL;
	m_lbSkillName	= NULL;
	m_lbReqLv		= NULL;
	m_skillInfo		= NULL;
	m_btnKaiQi		= NULL;
}

CActSkillInfoLayer::~CActSkillInfoLayer()
{
	if (m_btnKaiQi && m_btnKaiQi->GetParent() == NULL) {
		SAFE_DELETE(m_btnKaiQi);
	}
}

void CActSkillInfoLayer::Initialization()
{
	NDUILayer::Initialization();
	
	NDUIImage* imgSkillBg = new NDUIImage;
	imgSkillBg->Initialization();
	imgSkillBg->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_bagitem_sel.png")), true);
	imgSkillBg->SetFrameRect(CGRectMake(16, 16, 42, 42));
	this->AddChild(imgSkillBg);
	
	m_imgSkill = new NDUIImage;
	m_imgSkill->Initialization();
	m_imgSkill->SetFrameRect(CGRectMake(20, 20, 34, 34));
	this->AddChild(m_imgSkill);
	
	m_lbSkillName = new NDUILabel;
	m_lbSkillName->Initialization();
	m_lbSkillName->SetFontSize(16);
	m_lbSkillName->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbSkillName->SetFrameRect(CGRectMake(66, 14, 160, 20));
	this->AddChild(m_lbSkillName);
	
	m_lbReqLv = new NDUILabel;
	m_lbReqLv->Initialization();
	m_lbReqLv->SetFontSize(14);
	m_lbReqLv->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbReqLv->SetFrameRect(CGRectMake(66, 41, 100, 20));
	this->AddChild(m_lbReqLv);
	
	NDUIImage* imgSlash = new NDUIImage;
	imgSlash->Initialization();
	imgSlash->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_left_fengge.png")), true);
	imgSlash->SetFrameRect(CGRectMake(6, 68, 185, 2));
	this->AddChild(imgSlash);
	
	m_skillInfo = new NDUILabelScrollLayer;
	m_skillInfo->Initialization();
	m_skillInfo->SetFrameRect(CGRectMake(6, 74, 180, 155));
	this->AddChild(m_skillInfo);
	
	m_btnKaiQi = new NDUIButton;
	m_btnKaiQi->Initialization();
	m_btnKaiQi->SetImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_btn_click.png")), false, CGRectZero, true);
	m_btnKaiQi->SetFontColor(ccc4(247, 247, 247, 255));
	m_btnKaiQi->SetTitle(NDCommonCString("open"));
	m_btnKaiQi->SetDelegate(this);
	m_btnKaiQi->SetFrameRect(CGRectMake(26, 226, 48, 24));
	this->RefreshBattleSkill(CActSkillLayer::BUTTON_EMPTY, 0);
}

void CActSkillInfoLayer::RefreshBattleSkill(int idBattleSkill, int nSlotCount)
{
	if (CActSkillLayer::BUTTON_LOCK == idBattleSkill) {
		if (m_btnKaiQi->GetParent() == NULL) {
			this->AddChild(m_btnKaiQi);
		}
		m_imgSkill->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("lockstate.png")), true);
		m_imgSkill->SetFrameRect(CGRectMake(17, 17, 40, 40));
		m_lbReqLv->SetText("");
		m_lbSkillName->SetText(NDCommonCString("notopen"));
		int nNeedCount = pow(2, ((nSlotCount+1)-5) / 3);
		std::stringstream ss; 
		NDItemType *pItemtype = ItemMgrObj.QueryItemType(ITEM_QI_QIAO);
		if (pItemtype == NULL) 
		{
			return;
		}
		NDString strText;
		strText.Format(NDCString("KaiQiShuoMin"), pItemtype->m_name.c_str(), nNeedCount);
		m_skillInfo->SetText(strText.getData());
	}
	else {
		if (m_btnKaiQi->GetParent()) {
			m_btnKaiQi->RemoveFromParent(false);
		}
		
		if (CActSkillLayer::BUTTON_INVALID == idBattleSkill) {
			m_imgSkill->SetPicture(NULL);
			m_lbSkillName->SetText("");
			m_lbReqLv->SetText("");
			m_skillInfo->SetText("");			
		}
		else if (CActSkillLayer::BUTTON_EMPTY == idBattleSkill) {
			m_imgSkill->SetPicture(NULL);
			m_lbSkillName->SetText("");
			m_lbReqLv->SetText("");
			NDItemType *pItemtype = ItemMgrObj.QueryItemType(ITEM_QI_QIAO);
			if (pItemtype == NULL) 
			{
				return;
			}
			NDString strText;
			strText.Format(NDCString("KongTiShi"), pItemtype->m_name.c_str());
			m_skillInfo->SetText(strText.getData());
		}
		else {
			BattleSkill* pSkill = BattleMgrObj.GetBattleSkill(idBattleSkill);
			if (!pSkill) {
				return;
			}
			m_imgSkill->SetPicture(GetSkillIconByIconIndex(pSkill->getIconIndex()), true);
			stringstream ss;
			ss << pSkill->getName() << "（" << pSkill->getLevel() << NDCommonCString("Ji") << "）";
			m_lbSkillName->SetText(ss.str().c_str());
			ss.str("");
			ss << NDCommonCString("LevelRequire") << "：" << pSkill->getLvRequire() << NDCommonCString("Ji");
			m_lbReqLv->SetText(ss.str().c_str());
			ss.str("");
			ss << pSkill->getSimpleDes(false) << NDCommonCString("ShouLianVal") << "：";
			
			if (pSkill->getSpRequire() == 0) 
			{
				ss << NDCommonCString("FullLvl");
			} 
			else 
			{
				ss << pSkill->getCurSp() << "/" << pSkill->getSpRequire();
			}
			
			m_skillInfo->SetText(ss.str().c_str());
		}
	}
	
	if (!this->IsVisibled()) {
		m_skillInfo->SetVisible(false);
	}
}

void CActSkillInfoLayer::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnKaiQi) {
		NDNode* pParent = this->GetParent();
		if (pParent && pParent->IsKindOfClass(RUNTIME_CLASS(PlayerSkillInfo))) {
			((PlayerSkillInfo*)pParent)->OpenGroove();
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(CActSkillLayer, NDUILayer)

CActSkillLayer::CActSkillLayer()
{
	m_skillInfoLayer= NULL;
	m_imageMouse	= NULL;
	m_btnBack		= NULL;
	m_btnNext		= NULL;
	m_btnBackSlot	= NULL;
	m_btnNextSlot	= NULL;
}

CActSkillLayer::~CActSkillLayer()
{
	if (m_imageMouse) {
		SAFE_DELETE(m_imageMouse);
	}
	for (std::map<int, NDPicture*>::iterator it = m_recylePictures.begin(); it != m_recylePictures.end(); it++) 
	{
		SAFE_DELETE(it->second);
	}
	m_recylePictures.clear();
	
	// 上发技能位置变更
	NDTransData bao(_MSG_CONFIG_SKILL_SLOT);
	std::vector<int>	vecInt;
	unsigned char ucCount	= 0;
	std::map<int, int>::iterator iter = m_mapSkillPos.begin();
	for (; iter != m_mapSkillPos.end(); iter++) {
		if (iter->second > 0) {
			BattleSkill* pSkill = BattleMgrObj.GetBattleSkill(iter->second);
			if (pSkill) {
				int nSlot		= pSkill->GetSlot();
				int nThisSlot	= this->GetSlotByKey(iter->first);
				if (nThisSlot != nSlot) {
					vecInt.push_back(iter->second);
					vecInt.push_back(nThisSlot);
					ucCount++;
				}
			}
		}
	}
	if (ucCount) {
		bao << ucCount;
		std::vector<int>::iterator iter = vecInt.begin();
		for (; iter != vecInt.end(); iter++) {
			bao << int(*iter);
			iter++;
			if (iter == vecInt.end()) {
				break;
			}
			bao << (unsigned char)(*iter);
		}
		SEND_DATA(bao);
	}
	m_mapSkillPos.clear();
}

enum  {
	BG_SIZE = 42,
};

void CActSkillLayer::Initialization(const SET_BATTLE_SKILL_LIST& battleSkills, CActSkillInfoLayer* skillInfoLayer, int nMaxSlot)
{
	NDUILayer::Initialization();
	
	m_skillInfoLayer = skillInfoLayer;
	
	GLfloat fStartX = 0;
	GLfloat fStartY = 0;
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	NDPicture* picSkillButtonBg = pool.AddPicture(NDPath::GetImgPathNew("bag_bagitem.png"));
	NDPicture* picSkillButtonFocus = pool.AddPicture(NDPath::GetImgPathNew("bag_bagitem_sel.png"));
	
	bool bClearPicOnFree = true;
	
	for (int i = 0 ; i < ACT_BTN_COUNT; i++) {
		NDUIButton* btn = new NDUIButton;
		btn->Initialization();
		if (bClearPicOnFree) {
			bClearPicOnFree = !bClearPicOnFree;
			btn->SetBackgroundPicture(picSkillButtonBg, NULL, false, CGRectZero, true);
			btn->SetFocusImage(picSkillButtonFocus, false, CGRectZero, true);
		} else {
			btn->SetBackgroundPicture(picSkillButtonBg);
			btn->SetFocusImage(picSkillButtonFocus);
		}
		btn->SetFrameRect(CGRectMake(fStartX, fStartY, BG_SIZE, BG_SIZE));
		btn->CloseFrame();
		btn->SetDelegate(this);
		btn->SetTag(i);
		
		this->AddChild(btn);
		m_btnActSkills[i] = btn;
		fStartX += BG_SIZE + 4;
		
		if ((i+1) % COL_COUNT == 0) {
			fStartX = 0;
			fStartY += BG_SIZE + 6;
		}
	}
	CGRect	rRect = this->GetFrameRect();
	
	m_pLabelLearned = new NDUILabel;
	m_pLabelLearned->Initialization();
	m_pLabelLearned->SetFontSize(14);
	m_pLabelLearned->SetFontColor(ccc4(187, 19, 19, 255));
	m_pLabelLearned->SetFrameRect(CGRectMake(0, fStartY+4, 60, 20));
	m_pLabelLearned->SetText(NDCString("LearnedSkill"));
	this->AddChild(m_pLabelLearned);

	m_btnBack	= this->CreatePageButton(NDCommonCString("PrevPage"));
	if (!m_btnBack) {
		return;
	}
	m_btnBack->SetFrameRect(CGRectMake(60, fStartY, 52, 24));
	
	m_pLabelLearnedPage = new NDUILabel;
	m_pLabelLearnedPage->Initialization();
	m_pLabelLearnedPage->SetFontSize(14);
	m_pLabelLearnedPage->SetFontColor(ccc4(187, 19, 19, 255));
	m_pLabelLearnedPage->SetFrameRect(CGRectMake(115, fStartY+4, 60, 20));
	m_pLabelLearnedPage->SetTextAlignment(LabelTextAlignmentCenter);
	this->AddChild(m_pLabelLearnedPage);

	m_btnNext	= this->CreatePageButton(NDCommonCString("NextPage"));
	if (!m_btnNext) {
		return;
	}
	m_btnNext->SetFrameRect(CGRectMake(230-56, fStartY, 52, 24));
	
	m_nSlotCount = nMaxSlot;
	fStartX = 0;
	fStartY += 32;
	for (int i = 0 ; i < SLOT_BTN_COUNT; i++) {
		NDUIButton* btn = new NDUIButton;
		btn->Initialization();
		btn->SetBackgroundPicture(picSkillButtonBg);
		btn->SetFocusImage(picSkillButtonFocus);
		btn->SetFrameRect(CGRectMake(fStartX, fStartY, BG_SIZE, BG_SIZE));
		btn->CloseFrame();
		btn->SetDelegate(this);
		btn->SetTag(i+SLOT_SKILL_BEGIN);
			
		this->AddChild(btn);
		m_btnSlotSkills[i]	= btn;
		fStartX += BG_SIZE + 4;

		if ((i+1) % COL_COUNT == 0) {
			fStartX = 0;
			fStartY += BG_SIZE + 6;
		}
	}
	
	m_imageMouse = new NDUIImage;
	m_imageMouse->Initialization();
	m_imageMouse->EnableEvent(false);
	this->AddChild(m_imageMouse, 1);
	
	m_pLabelEquip = new NDUILabel;
	m_pLabelEquip->Initialization();
	m_pLabelEquip->SetFontSize(14);
	m_pLabelEquip->SetFontColor(ccc4(187, 19, 19, 255));
	m_pLabelEquip->SetFrameRect(CGRectMake(0, fStartY+4, 60, 20));
	m_pLabelEquip->SetText(NDCString("EquipSkill"));
	this->AddChild(m_pLabelEquip);

	m_btnBackSlot	= this->CreatePageButton(NDCommonCString("PrevPage"));
	if (!m_btnBackSlot) {
		return;
	}
	m_btnBackSlot->SetFrameRect(CGRectMake(60, fStartY, 52, 24));
	
	m_pLabelEquipPage = new NDUILabel;
	m_pLabelEquipPage->Initialization();
	m_pLabelEquipPage->SetFontSize(14);
	m_pLabelEquipPage->SetFontColor(ccc4(187, 19, 19, 255));
	m_pLabelEquipPage->SetFrameRect(CGRectMake(115, fStartY+4, 60, 20));
	m_pLabelEquipPage->SetTextAlignment(LabelTextAlignmentCenter);
	this->AddChild(m_pLabelEquipPage);
		
	m_btnNextSlot	= this->CreatePageButton(NDCommonCString("NextPage"));
	if (!m_btnNextSlot) {
		return;
	}
	m_btnNextSlot->SetFrameRect(CGRectMake(230-56, fStartY, 52, 24));
	
	m_nPage	= 0;
	m_nPageSlot	= 0;
	BattleSkill* pSkill = NULL;
	int nPos = 1;
	SET_BATTLE_SKILL_LIST::const_iterator it = battleSkills.begin();
	for (; it != battleSkills.end(); it++) {
		pSkill = BattleMgrObj.GetBattleSkill(*it);
		if (pSkill) {
			int nSlot = pSkill->GetSlot();
			if (nSlot) {
				m_mapSkillPos[nSlot+1000] = pSkill->getId();
			}
			else {
				m_mapSkillPos[nPos++] = pSkill->getId();
			}
		}
	}
	
	this->UpdatePage();
	this->UpdatePageSlot();
}

void CActSkillLayer::OnButtonClick(NDUIButton* button)
{
	if (!button) {
		return;
	}
	if (button == m_btnBack) {
		if (m_nPage > 0) {
			m_nPage--;
			this->UpdatePage();
		}
	}
	else if (button == m_btnNext) {
		if (m_nPage < (((int)m_mapSkillPos.size()-1)/ACT_BTN_COUNT)) {
			m_nPage++;
			this->UpdatePage();
		}
	}
	else if (button == m_btnBackSlot) {
		if (m_nPageSlot > 0) {
			m_nPageSlot--;
			this->UpdatePageSlot();
		}
	}
	else if (button == m_btnNextSlot) {
		if (m_nPageSlot < ((MAX_SLOT_SKILL-1)/ACT_BTN_COUNT)) {
			m_nPageSlot++;
			this->UpdatePageSlot();
		}
	}
	else {
		if (m_skillInfoLayer) {
			int idSkill = this->GetSkillIdByPos(button->GetTag());
			m_skillInfoLayer->RefreshBattleSkill(idSkill, m_nSlotCount);
		}
	}
}

bool CActSkillLayer::OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch)
{
	if (!button) {
		return false;
	}
	
	CGPoint rPoint = this->GetScreenRect().origin;
	int idSkill = this->GetSkillIdByPos(button->GetTag());
	if (idSkill <= 0) {
		return false;
	}
	BattleSkill* pSkill = BattleMgrObj.GetBattleSkill(idSkill);
	if (!pSkill) {
		return false;
	}
	NDPicture* pic = NULL;
	std::map<int, NDPicture*>::iterator iter = m_recylePictures.find(pSkill->getIconIndex());
	if (iter != m_recylePictures.end()) {
		pic	= iter->second;
	}
	else {
		pic	= GetSkillIconByIconIndex(pSkill->getIconIndex());
		if (!pic) {
			return false;
		}
		m_recylePictures[pSkill->getIconIndex()]	= pic;
	}
	
	m_imageMouse->SetPicture(pic);
	CGSize size = pic->GetSize();
	m_imageMouse->SetFrameRect(CGRectMake(moveTouch.x-size.width/2-rPoint.x, moveTouch.y-size.height/2-rPoint.y, size.width, size.height));
	return true;
}

bool CActSkillLayer::OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange)
{
	m_imageMouse->SetPicture(NULL);
	return true;
}

bool CActSkillLayer::OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch)
{
	if (!desButton || !uiSrcNode) {
		return false;
	}
	if (desButton == uiSrcNode) {
		return true;
	}
	if (!uiSrcNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
	{
		return false;
	}
	if (desButton == m_btnBack 
		|| desButton == m_btnNext 
		|| desButton == m_btnBackSlot 
		|| desButton == m_btnNextSlot) {
		return true;
	}
	
	int idDesSkill = this->GetSkillIdByPos(desButton->GetTag());
	if (BUTTON_LOCK == idDesSkill || BUTTON_INVALID == idDesSkill) {
		return true;
	}
	int idSrcSkill = this->GetSkillIdByPos(uiSrcNode->GetTag());
	if (idSrcSkill <= 0) {
		return false;
	}
	
	m_mapSkillPos[this->GetKeyByPos(uiSrcNode->GetTag())] = idDesSkill;
	m_mapSkillPos[this->GetKeyByPos(desButton->GetTag())] = idSrcSkill;
	this->SetButtonImage(desButton);
	this->SetButtonImage((NDUIButton*)uiSrcNode);
	
	if (m_skillInfoLayer) {
		m_skillInfoLayer->RefreshBattleSkill(idSrcSkill, m_nSlotCount);
	}
	this->SetFocus(desButton);
	return true;
}

void CActSkillLayer::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (!dialog) {
		return;
	}
	this->SendOpenGrooveMsg();
	dialog->Close();
}

void CActSkillLayer::OpenGroove()
{
	if (m_nSlotCount >= MAX_SLOT_SKILL) {
		return;
	}
	int nItemCount = ItemMgrObj.GetBagItemCount(ITEM_QI_QIAO);
	int nNeedCount = pow(2, ((m_nSlotCount+1)-5) / 3);
	if (nItemCount < nNeedCount) {
		NDPlayer& player = NDPlayer::defaultHero();
		NDItemType *pItemtype = ItemMgrObj.QueryItemType(ITEM_QI_QIAO);
		if (pItemtype == NULL) 
		{
			return;
		}
		int nItemEMoney = pItemtype->m_data.m_emoney;
		int nNeedEmondy = (nNeedCount-nItemCount)*nItemEMoney;
		if (player.eMoney < nNeedEmondy) {
			showDialog(NDCommonCString("WenXinTip"), NDCString("BaoWuBuZhu"));
		}
		else {
			NDUIDialog* dlg = new NDUIDialog;
			dlg->Initialization();
			dlg->SetDelegate(this);
			NDString strText;
			strText.Format(NDCString("GouMaiShiYong"), pItemtype->m_name.c_str(), nNeedCount-nItemCount, nNeedEmondy);
			dlg->Show(NDCommonCString("WenXinTip"), strText.getData(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
		}
	}
	else {
		this->SendOpenGrooveMsg();
	}
}

void CActSkillLayer::SendOpenGrooveMsg()
{
	NDTransData bao(_MSG_BUY_GOODS_AUTO_USE);
	bao << int(1) << int(0) << int(0);
	SEND_DATA(bao);
	m_nSlotCount++;
	this->UpdatePageSlot();
	m_skillInfoLayer->RefreshBattleSkill(BUTTON_EMPTY, 0);
}

void CActSkillLayer::UpdatePage()
{
	if (m_nPage == 0) {
		m_btnBack->EnalbelBackgroundGray(true);
	}
	else {
		m_btnBack->EnalbelBackgroundGray(false);
	}
	if (m_nPage == (((int)m_mapSkillPos.size()-1)/ACT_BTN_COUNT)) {
		m_btnNext->EnalbelBackgroundGray(true);
	}
	else {
		m_btnNext->EnalbelBackgroundGray(false);
	}
	
	NDUIButton* pBtn	= NULL;
	for (int i = 0; i < ACT_BTN_COUNT; i++) {
		pBtn = m_btnActSkills[i];
		if (pBtn) {
			this->SetButtonImage(pBtn);
		}
	}
	NDString strText;
	strText.Format("%d/%d", m_nPage + 1, (((int)m_mapSkillPos.size()-1)/ACT_BTN_COUNT) + 1);
	m_pLabelLearnedPage->SetText(strText.getData());
}

void CActSkillLayer::UpdatePageSlot()
{
	if (m_nPageSlot == 0) {
		m_btnBackSlot->EnalbelBackgroundGray(true);
	}
	else {
		m_btnBackSlot->EnalbelBackgroundGray(false);
	}
	if (m_nPageSlot == ((MAX_SLOT_SKILL-1)/ACT_BTN_COUNT)) {
		m_btnNextSlot->EnalbelBackgroundGray(true);
	}
	else {
		m_btnNextSlot->EnalbelBackgroundGray(false);
	}
	
	NDUIButton* pBtn	= NULL;
	for (int i = 0; i < SLOT_BTN_COUNT; i++) {
		pBtn = m_btnSlotSkills[i];
		if (pBtn) {
			this->SetButtonImage(pBtn);
		}
	}
	NDString strText;
	strText.Format("%d/%d", m_nPageSlot + 1, ((MAX_SLOT_SKILL-1)/ACT_BTN_COUNT) + 1);
	m_pLabelEquipPage->SetText(strText.getData());
}

int CActSkillLayer::GetSkillIdByPos(int nPos)
{
	int idSkill = 0;
	int nKey = this->GetKeyByPos(nPos);
	std::map<int, int>::iterator iter = m_mapSkillPos.find(nKey);
	if (iter != m_mapSkillPos.end()) {
		idSkill = iter->second;
	}
	else if (nKey > SLOT_SKILL_BEGIN+m_nSlotCount && nKey <= SLOT_SKILL_BEGIN+MAX_SLOT_SKILL) {
		idSkill = BUTTON_LOCK;
	}
	else if (nKey > SLOT_SKILL_BEGIN + MAX_SLOT_SKILL){
		idSkill = BUTTON_INVALID;
	}
	else {
		idSkill = BUTTON_EMPTY;
	}
	return idSkill;
}

int CActSkillLayer::GetKeyByPos(int nPos)
{
	int nKey = 0;
	if (nPos < SLOT_SKILL_BEGIN) {
		nKey = nPos+ACT_BTN_COUNT*m_nPage + 1;
	}
	else {
		nKey = nPos+SLOT_BTN_COUNT*m_nPageSlot + 1;
	}
	return nKey;
}

int CActSkillLayer::GetSlotByKey(int nKey)
{
	if (nKey < SLOT_SKILL_BEGIN) {
		return 0;
	}
	
	return nKey - SLOT_SKILL_BEGIN;
}

void CActSkillLayer::SetButtonImage(NDUIButton* pBtn)
{
	if (!pBtn) {
		return;
	}
	int nPos = pBtn->GetTag();
	int idSkill = this->GetSkillIdByPos(nPos);
	BattleSkill* pSkill = NULL;
	if (idSkill > 0) {
		pSkill = BattleMgrObj.GetBattleSkill(idSkill);
		if (pSkill) {
			pBtn->SetImage(GetSkillIconByIconIndex(pSkill->getIconIndex()), true, CGRectMake(4, 4, 34, 34), true);
		}
		else {
			pBtn->SetImage(NULL, true, CGRectMake(4, 4, 34, 34), true);
		}
	}
	else if (BUTTON_INVALID == idSkill) {
		NDPicture* pPic = new NDPicture(true);
		pPic->Initialization(NDPath::GetImgPathNew("bag_bagitem.png"));
		pPic->SetGrayState(true);
		pBtn->SetImage(pPic, true, CGRectMake(4, 4, 34, 34), true);
		pBtn->EnalbeGray(true);
	}
	else if (BUTTON_LOCK == idSkill) {
		pBtn->SetImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("lockstate.png")), true, CGRectMake(1, 1, 40, 40), true);
	}
	else if (BUTTON_EMPTY == idSkill) {
		pBtn->SetImage(NULL, true, CGRectMake(4, 4, 34, 34), true);
	}
}

NDUIButton* CActSkillLayer::CreatePageButton(const char* pszTitle)
{
	if (!pszTitle) {
		return false;
	}
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDUIButton* pBtn = new NDUIButton;
	if (!pBtn) {
		return false;
	}
	pBtn->Initialization();
	pBtn->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_btn_normal.png"), true),
							   pool.AddPicture(NDPath::GetImgPathNew("bag_btn_click.png"), true),
							   false, CGRectZero, true);
	pBtn->SetFontSize(12);
	pBtn->SetFontColor(ccc4(255, 255, 255, 255));
	pBtn->SetTitle(pszTitle);
	pBtn->SetFrameRect(CGRectMake(0, 0, 52, 24));
	pBtn->CloseFrame();
	pBtn->SetDelegate(this);
	this->AddChild(pBtn);
	return pBtn;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(BattleSkillInfoLayer, NDUILayer)

BattleSkillInfoLayer::BattleSkillInfoLayer()
{
	m_imgSkill = NULL;
	m_lbSkillName = NULL;
	m_lbReqLv = NULL;
	m_skillInfo = NULL;
}

BattleSkillInfoLayer::~BattleSkillInfoLayer()
{
	
}

void BattleSkillInfoLayer::Initialization()
{
	NDUILayer::Initialization();
	
	NDUIImage* imgSkillBg = new NDUIImage;
	imgSkillBg->Initialization();
	imgSkillBg->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_bagitem_sel.png")), true);
	imgSkillBg->SetFrameRect(CGRectMake(16, 16, 42, 42));
	this->AddChild(imgSkillBg);
	
	m_imgSkill = new NDUIImage;
	m_imgSkill->Initialization();
	m_imgSkill->SetFrameRect(CGRectMake(20, 20, 34, 34));
	this->AddChild(m_imgSkill);
	
	m_lbSkillName = new NDUILabel;
	m_lbSkillName->Initialization();
	m_lbSkillName->SetFontSize(16);
	m_lbSkillName->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbSkillName->SetFrameRect(CGRectMake(66, 14, 160, 20));
	this->AddChild(m_lbSkillName);
	
	m_lbReqLv = new NDUILabel;
	m_lbReqLv->Initialization();
	m_lbReqLv->SetFontSize(14);
	m_lbReqLv->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbReqLv->SetFrameRect(CGRectMake(66, 41, 100, 20));
	this->AddChild(m_lbReqLv);
	
	NDUIImage* imgSlash = new NDUIImage;
	imgSlash->Initialization();
	imgSlash->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_left_fengge.png")), true);
	imgSlash->SetFrameRect(CGRectMake(6, 68, 185, 2));
	this->AddChild(imgSlash);
	
	m_skillInfo = new NDUILabelScrollLayer;
	m_skillInfo->Initialization();
	m_skillInfo->SetFrameRect(CGRectMake(6, 74, 180, 155));
	this->AddChild(m_skillInfo);
	this->RefreshBattleSkill(-1);
}

void BattleSkillInfoLayer::RefreshBattleSkill(int idBattleSkill)
{
	BattleSkill* pSkill = BattleMgrObj.GetBattleSkill(idBattleSkill);
	
	if (!pSkill) {
		m_imgSkill->SetPicture(NULL);
		m_lbSkillName->SetText("");
		m_lbReqLv->SetText("");
		m_skillInfo->SetText("");
	} else {
		m_imgSkill->SetPicture(GetSkillIconByIconIndex(pSkill->getIconIndex()), true);
		stringstream ss;
		ss << pSkill->getName() << "（" << pSkill->getLevel() << NDCommonCString("Ji") << "）";
		m_lbSkillName->SetText(ss.str().c_str());
		ss.str("");
		ss << NDCommonCString("LevelRequire") << "：" << pSkill->getLvRequire() << NDCommonCString("Ji");
		m_lbReqLv->SetText(ss.str().c_str());
		ss.str("");
		ss << pSkill->getSimpleDes(false) << NDCommonCString("ShouLianVal") << "：";
		
		if (pSkill->getSpRequire() == 0) 
		{
			ss << NDCommonCString("FullLvl");
		} 
		else 
		{
			ss << pSkill->getCurSp() << "/" << pSkill->getSpRequire();
		}
		
		m_skillInfo->SetText(ss.str().c_str());
	}
	
	if (!this->IsVisibled()) {
		m_skillInfo->SetVisible(false);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(BattleSkillLayer, NDUILayer)

BattleSkillLayer::BattleSkillLayer()
{
	m_skillInfoLayer = NULL;
}

BattleSkillLayer::~BattleSkillLayer()
{
	
}

void BattleSkillLayer::Initialization(const SET_BATTLE_SKILL_LIST& battleSkills, BattleSkillInfoLayer* skillInfoLayer)
{
	NDUILayer::Initialization();
	
	m_skillInfoLayer = skillInfoLayer;
	
	GLfloat fStartX = 0;
	GLfloat fStartY = 0;
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	NDPicture* picSkillButtonBg = pool.AddPicture(NDPath::GetImgPathNew("bag_bagitem.png"));
	NDPicture* picSkillButtonFocus = pool.AddPicture(NDPath::GetImgPathNew("bag_bagitem_sel.png"));
	
	bool bClearPicOnFree = true;
	
	BattleSkill* pSkill = NULL;
	SET_BATTLE_SKILL_LIST::const_iterator it = battleSkills.begin();
	
	for (int i = 0 ; i < ROW_COUNT; i++) {
		fStartX = 0;
		for (int j = 0; j < COL_COUNT; j++) {
			NDUIButton* btn = new NDUIButton;
			btn->Initialization();
			if (bClearPicOnFree) {
				bClearPicOnFree = !bClearPicOnFree;
				btn->SetBackgroundPicture(picSkillButtonBg, NULL, false, CGRectZero, true);
				btn->SetFocusImage(picSkillButtonFocus, false, CGRectZero, true);
			} else {
				btn->SetBackgroundPicture(picSkillButtonBg);
				btn->SetFocusImage(picSkillButtonFocus);
			}
			btn->SetFrameRect(CGRectMake(fStartX, fStartY, BG_SIZE, BG_SIZE));
			btn->CloseFrame();
			btn->SetDelegate(this);
			
			if (it != battleSkills.end()) {
				pSkill = BattleMgrObj.GetBattleSkill(*it);
				if (pSkill) {
					btn->SetTag(*it);
					btn->SetImage(GetSkillIconByIconIndex(pSkill->getIconIndex()), true, CGRectMake(4, 4, 34, 34), true);
				}
				it++;
			}
			
			this->AddChild(btn);
			m_btnBattleSkills[i][j] = btn;
			
			fStartX += BG_SIZE + 4;
		}
		fStartY += BG_SIZE + 6;
	}
}

void BattleSkillLayer::OnButtonClick(NDUIButton* button)
{
	if (m_skillInfoLayer) {
		m_skillInfoLayer->RefreshBattleSkill(button->GetTag());
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(LifeSkillInfoLayer, NDUILayer)

LifeSkillInfoLayer::LifeSkillInfoLayer()
{
	m_imgSkill = NULL;
	m_lbSkillName = NULL;
	m_lbLv = NULL;
	m_skillInfo = NULL;
}

LifeSkillInfoLayer::~LifeSkillInfoLayer()
{
	
}

void LifeSkillInfoLayer::Initialization()
{
	NDUILayer::Initialization();
	
	NDUIImage* imgSkillBg = new NDUIImage;
	imgSkillBg->Initialization();
	imgSkillBg->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_bagitem_sel.png")), true);
	imgSkillBg->SetFrameRect(CGRectMake(16, 16, 42, 42));
	this->AddChild(imgSkillBg);
	
	m_imgSkill = new NDUIImage;
	m_imgSkill->Initialization();
	m_imgSkill->SetFrameRect(CGRectMake(20, 20, 34, 34));
	this->AddChild(m_imgSkill);
	
	m_lbSkillName = new NDUILabel;
	m_lbSkillName->Initialization();
	m_lbSkillName->SetFontSize(14);
	m_lbSkillName->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbSkillName->SetFrameRect(CGRectMake(66, 14, 160, 20));
	this->AddChild(m_lbSkillName);
	
	m_lbLv = new NDUILabel;
	m_lbLv->Initialization();
	m_lbLv->SetFontSize(14);
	m_lbLv->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbLv->SetFrameRect(CGRectMake(66, 41, 100, 20));
	this->AddChild(m_lbLv);
	
	NDUIImage* imgSlash = new NDUIImage;
	imgSlash->Initialization();
	imgSlash->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_left_fengge.png")), true);
	imgSlash->SetFrameRect(CGRectMake(6, 68, 185, 2));
	this->AddChild(imgSlash);
	
	m_skillInfo = new NDUILabelScrollLayer;
	m_skillInfo->Initialization();
	m_skillInfo->SetFrameRect(CGRectMake(6, 74, 180, 155));
	this->AddChild(m_skillInfo);
}

void LifeSkillInfoLayer::RefreshLifeSkill(int idSkill)
{
	FormulaMaterialData* pFormualData = NDMapMgrObj.getFormulaData(idSkill);
	
	if (!pFormualData) {
		m_imgSkill->SetPicture(NULL);
		m_lbSkillName->SetText("");
		m_lbLv->SetText("");
		m_skillInfo->SetText("");
	} else {
		m_imgSkill->SetPicture(GetSkillIconByIconIndex(pFormualData->iconIndex), true);
		m_lbSkillName->SetText(pFormualData->formulaName.c_str());
		/*stringstream ss;
		ss << "等级：" << pFormualData-> << NDCommonCString("Ji");
		m_lbReqLv->SetText(ss.str().c_str());*/
		m_skillInfo->SetText(pFormualData->getDetailDescription().c_str());
	}
	
	if (!this->IsVisibled())
		m_skillInfo->SetVisible(false);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(LifeSkillLayer, NDUILayer)

LifeSkillLayer::LifeSkillLayer()
{
	m_layerLianYao = NULL;
	m_layerBaoShi = NULL;
	
	m_btnLianYao = NULL;
	m_btnBaoShi = NULL;
	
	m_imgFocus = NULL;
	
	m_lbLifeSkillLV = NULL;
	m_numLifeSkillExp = NULL;
	m_rectLifeSkillExp = NULL;
	
	m_skillInfoLayer = NULL;
	
	memset(m_btnLifeSkillsLianYao, 0L, sizeof(m_btnLifeSkillsLianYao));
	memset(m_btnLifeSkillsBaoShi, 0L, sizeof(m_btnLifeSkillsBaoShi));
}

LifeSkillLayer::~LifeSkillLayer()
{
	if (m_layerLianYao && NULL == m_layerLianYao->GetParent()) {
		SAFE_DELETE(m_layerLianYao);
	}
	
	if (m_layerBaoShi && NULL == m_layerBaoShi->GetParent()) {
		SAFE_DELETE(m_layerBaoShi);
	}
}

void LifeSkillLayer::UpdateLifeSkill()
{
	vector<int> vFormulaSkills;
	NDMapMgr& mgr = NDMapMgrObj;
	mgr.getFormulaBySkill(ALCHEMY_IDSKILL, vFormulaSkills);
	vector<int>::iterator it = vFormulaSkills.begin();
	
	FormulaMaterialData* pFormulaData = NULL;
	
	for (int i = 0 ; i < ROW_COUNT; i++) {
		for (int j = 0; j < COL_COUNT; j++) {
			NDUIButton* btn = m_btnLifeSkillsLianYao[ROW_COUNT][COL_COUNT];
			if (it != vFormulaSkills.end()) {
				pFormulaData = NDMapMgrObj.getFormulaData(*it);
				if (pFormulaData) {
					btn->SetTag(*it);
					btn->SetImage(GetSkillIconByIconIndex(pFormulaData->iconIndex), true, CGRectMake(4, 4, 34, 34), true);
				}
				it++;
			} else {
				btn->SetTag(0);
				btn->SetImage(NULL);
			}
		}
	}
	
	vFormulaSkills.clear();
	mgr.getFormulaBySkill(GEM_IDSKILL, vFormulaSkills);
	it = vFormulaSkills.begin();
	
	pFormulaData = NULL;
	
	for (int i = 0 ; i < ROW_COUNT; i++) {
		for (int j = 0; j < COL_COUNT; j++) {
			NDUIButton* btn = m_btnLifeSkillsBaoShi[i][j];
			
			if (it != vFormulaSkills.end()) {
				pFormulaData = NDMapMgrObj.getFormulaData(*it);
				if (pFormulaData) {
					btn->SetTag(*it);
					btn->SetImage(GetSkillIconByIconIndex(pFormulaData->iconIndex), true, CGRectMake(4, 4, 34, 34), true);
				}
				it++;
			} else {
				btn->SetTag(0);
				btn->SetImage(NULL);
			}
		}
	}
	
	m_layerLianYao->SetFocus(NULL);
	m_layerBaoShi->SetFocus(NULL);
	this->m_skillInfoLayer->RefreshLifeSkill(0);
}

void LifeSkillLayer::Initialization(LifeSkillInfoLayer* skillInfoLayer)
{
	NDUILayer::Initialization();
	m_skillInfoLayer = skillInfoLayer;
	
	m_layerLianYao = new NDUILayer;
	m_layerLianYao->Initialization();
	m_layerLianYao->SetFrameRect(CGRectMake(0, 0, 230, 186));
	
	GLfloat fStartX = 0;
	GLfloat fStartY = 0;
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	NDPicture* picSkillButtonBg = pool.AddPicture(NDPath::GetImgPathNew("bag_bagitem.png"));
	NDPicture* picSkillButtonFocus = pool.AddPicture(NDPath::GetImgPathNew("bag_bagitem_sel.png"));
	
	bool bClearPicOnFree = true;
	
	vector<int> vFormulaSkills;
	NDMapMgr& mgr = NDMapMgrObj;
	mgr.getFormulaBySkill(ALCHEMY_IDSKILL, vFormulaSkills);
	vector<int>::iterator it = vFormulaSkills.begin();
	
	FormulaMaterialData* pFormulaData = NULL;
	
	for (int i = 0 ; i < ROW_COUNT; i++) {
		fStartX = 0;
		for (int j = 0; j < COL_COUNT; j++) {
			NDUIButton* btn = new NDUIButton;
			btn->Initialization();
			if (bClearPicOnFree) {
				bClearPicOnFree = !bClearPicOnFree;
				btn->SetBackgroundPicture(picSkillButtonBg, NULL, false, CGRectZero, true);
				btn->SetFocusImage(picSkillButtonFocus, false, CGRectZero, true);
			} else {
				btn->SetBackgroundPicture(picSkillButtonBg);
				btn->SetFocusImage(picSkillButtonFocus);
			}
			btn->SetFrameRect(CGRectMake(fStartX, fStartY, BG_SIZE, BG_SIZE));
			btn->CloseFrame();
			btn->SetDelegate(this);
			
			if (it != vFormulaSkills.end()) {
				pFormulaData = NDMapMgrObj.getFormulaData(*it);
				if (pFormulaData) {
					btn->SetTag(*it);
					btn->SetImage(GetSkillIconByIconIndex(pFormulaData->iconIndex), true, CGRectMake(4, 4, 34, 34), true);
				}
				it++;
			}
			
			m_btnLifeSkillsLianYao[i][j] = btn;
			m_layerLianYao->AddChild(btn);
			fStartX += BG_SIZE + 4;
		}
		fStartY += BG_SIZE + 6;
	}
	
	m_layerBaoShi = new NDUILayer;
	m_layerBaoShi->Initialization();
	m_layerBaoShi->SetFrameRect(CGRectMake(0, 0, 230, 186));
	
	vFormulaSkills.clear();
	mgr.getFormulaBySkill(GEM_IDSKILL, vFormulaSkills);
	it = vFormulaSkills.begin();
	
	pFormulaData = NULL;
	
	//fStartX = 0;
	fStartY = 0;
	
	for (int i = 0 ; i < ROW_COUNT; i++) {
		fStartX = 0;
		for (int j = 0; j < COL_COUNT; j++) {
			NDUIButton* btn = new NDUIButton;
			btn->Initialization();
			
			btn->SetBackgroundPicture(picSkillButtonBg);
			btn->SetFocusImage(picSkillButtonFocus);
			btn->SetFrameRect(CGRectMake(fStartX, fStartY, BG_SIZE, BG_SIZE));
			btn->CloseFrame();
			btn->SetDelegate(this);
			
			if (it != vFormulaSkills.end()) {
				pFormulaData = NDMapMgrObj.getFormulaData(*it);
				if (pFormulaData) {
					btn->SetTag(*it);
					btn->SetImage(GetSkillIconByIconIndex(pFormulaData->iconIndex), true, CGRectMake(4, 4, 34, 34), true);
				}
				it++;
			}
			
			m_btnLifeSkillsBaoShi[i][j] = btn;
			m_layerBaoShi->AddChild(btn);
			fStartX += BG_SIZE + 4;
		}
		fStartY += BG_SIZE + 6;
	}
	
	m_btnLianYao = new NDUIButton;
	m_btnLianYao->Initialization();
	m_btnLianYao->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("lifeskill_btn_normal.png"), 112, 32), NULL, false, CGRectZero, true);
	m_btnLianYao->CloseFrame();
	m_btnLianYao->SetFocusImage(pool.AddPicture(NDPath::GetImgPathNew("lifeskill_btn_focus.png"), 112, 32), false, CGRectZero, true);
	m_btnLianYao->SetFrameRect(CGRectMake(0, 216, 112, 32));
	m_btnLianYao->SetDelegate(this);
	m_btnLianYao->SetFontSize(18);
	m_btnLianYao->SetTitle(NDCommonCString("LianYao"));
	this->AddChild(m_btnLianYao);
	
	m_btnBaoShi = new NDUIButton;
	m_btnBaoShi->Initialization();
	m_btnBaoShi->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("lifeskill_btn_normal.png"), 112, 32), NULL, false, CGRectZero, true);
	m_btnBaoShi->CloseFrame();
	m_btnBaoShi->SetFocusImage(pool.AddPicture(NDPath::GetImgPathNew("lifeskill_btn_focus.png"), 112, 32), false, CGRectZero, true);
	m_btnBaoShi->SetFrameRect(CGRectMake(116, 216, 112, 32));
	m_btnBaoShi->SetDelegate(this);
	m_btnBaoShi->SetFontSize(18);
	m_btnBaoShi->SetTitle(NDCommonCString("BaoShi"));
	this->AddChild(m_btnBaoShi);
	
	m_imgFocus = new NDUIImage;
	m_imgFocus->Initialization();
	m_imgFocus->EnableEvent(false);
	NDPicture* pic = pool.AddPicture(NDPath::GetImgPathNew("newui_tab_selarrow.png"));
	pic->Rotation(PictureRotation180);
	m_imgFocus->SetPicture(pic, true);
	m_imgFocus->SetFrameRect(CGRectMake(30, 210, 53, 6));
	this->AddChild(m_imgFocus);
	
	m_lbLifeSkillLV = new NDUILabel;
	m_lbLifeSkillLV->Initialization();
	m_lbLifeSkillLV->SetFrameRect(CGRectMake(0, 192, 32, 20));
	m_lbLifeSkillLV->SetFontColor(ccc4(198, 19, 19, 255));
	this->AddChild(m_lbLifeSkillLV);
	
	NDUIImage* imgExp = new NDUIImage;
	imgExp->Initialization();
	imgExp->EnableEvent(false);
	imgExp->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("redexp.png")), true);
	imgExp->SetFrameRect(CGRectMake(32, 198, 21, 7));
	this->AddChild(imgExp);
	
	NDUIRecttangle* rectExpFrame = new NDUIRecttangle;
	rectExpFrame->Initialization();
	rectExpFrame->EnableEvent(false);
	rectExpFrame->SetFrameRect(CGRectMake(54, 195, 140, 11));
	rectExpFrame->SetColor(ccc4(119, 68, 43, 255));
	this->AddChild(rectExpFrame);
	
	rectExpFrame = new NDUIRecttangle;
	rectExpFrame->Initialization();
	rectExpFrame->EnableEvent(false);
	rectExpFrame->SetFrameRect(CGRectMake(55, 196, 138, 9));
	rectExpFrame->SetColor(ccc4(255, 247, 198, 255));
	this->AddChild(rectExpFrame);
	
	m_rectLifeSkillExp = new NDUIRecttangle;
	m_rectLifeSkillExp->Initialization();
	m_rectLifeSkillExp->EnableEvent(false);
	m_rectLifeSkillExp->SetFrameRect(CGRectMake(55, 196, 0, 9));
	m_rectLifeSkillExp->SetColor(ccc4(16, 169, 208, 255));
	this->AddChild(m_rectLifeSkillExp);
	
	m_numLifeSkillExp = new ImageNumber;
	m_numLifeSkillExp->Initialization();
	m_numLifeSkillExp->EnableEvent(false);
	m_numLifeSkillExp->SetFrameRect(CGRectMake(196, 196, 30, 20));
	this->AddChild(m_numLifeSkillExp);
	
	this->SetFocus(m_btnLianYao);
	this->OnButtonClick(m_btnLianYao);
}

void LifeSkillLayer::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnLianYao) {
		m_imgFocus->SetFrameRect(CGRectMake(30, 210, 53, 6));
		m_btnLianYao->SetFontColor(ccc4(248, 237, 172, 255));
		m_btnBaoShi->SetFontColor(ccc4(173, 70, 25, 255));
		m_layerBaoShi->RemoveFromParent(false);
		if (m_layerLianYao->GetParent() == NULL) {
			this->AddChild(m_layerLianYao);
		}
		
		NDMapMgr& mgr = NDMapMgrObj;
		LifeSkill *skill = mgr.getLifeSkill(ALCHEMY_IDSKILL);
		if (!skill) 
		{
			m_lbLifeSkillLV->SetText("LV0");
			m_rectLifeSkillExp->SetFrameRect(CGRectMake(55, 196, 0, 9));
			m_numLifeSkillExp->SetSmallRedTwoNumber(0, 0);
			return;
		}
		stringstream sslvl; 
		sslvl << "LV" << int(skill->uSkillGrade);
		
		m_lbLifeSkillLV->SetText(sslvl.str().c_str());
		GLfloat width = 138.f * skill->uSkillExp / skill->uSkillExp_max;
		m_rectLifeSkillExp->SetFrameRect(CGRectMake(55, 196, width, 9));
		m_numLifeSkillExp->SetSmallRedTwoNumber(skill->uSkillExp, skill->uSkillExp_max);
		
		NDUINode* btnSkillFocus = m_layerLianYao->GetFocus();
		m_skillInfoLayer->RefreshLifeSkill(btnSkillFocus == NULL ? 0 : btnSkillFocus->GetTag());
	} else if (button == m_btnBaoShi) {
		m_imgFocus->SetFrameRect(CGRectMake(146, 210, 53, 6));
		m_btnBaoShi->SetFontColor(ccc4(248, 237, 172, 255));
		m_btnLianYao->SetFontColor(ccc4(173, 70, 25, 255));
		m_layerLianYao->RemoveFromParent(false);
		if (m_layerBaoShi->GetParent() == NULL) {
			this->AddChild(m_layerBaoShi);
		}
		
		NDMapMgr& mgr = NDMapMgrObj;
		LifeSkill *skill = mgr.getLifeSkill(GEM_IDSKILL);
		if (!skill) 
		{
			m_lbLifeSkillLV->SetText("LV0");
			m_rectLifeSkillExp->SetFrameRect(CGRectMake(55, 196, 0, 9));
			m_numLifeSkillExp->SetSmallRedTwoNumber(0, 0);
			return;
		}
		stringstream sslvl; 
		sslvl << "LV" << int(skill->uSkillGrade);
		
		m_lbLifeSkillLV->SetText(sslvl.str().c_str());
		GLfloat width = 138.f * skill->uSkillExp / skill->uSkillExp_max;
		m_rectLifeSkillExp->SetFrameRect(CGRectMake(55, 196, width, 9));
		m_numLifeSkillExp->SetSmallRedTwoNumber(skill->uSkillExp, skill->uSkillExp_max);
		
		NDUINode* btnSkillFocus = m_layerBaoShi->GetFocus();
		m_skillInfoLayer->RefreshLifeSkill(btnSkillFocus == NULL ? 0 : btnSkillFocus->GetTag());
	} else {
		m_skillInfoLayer->RefreshLifeSkill(button->GetTag());
	}

}

////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(PlayerSkillInfo, NDUILayer)

PlayerSkillInfo* PlayerSkillInfo::s_instance = NULL;

PlayerSkillInfo::PlayerSkillInfo()
{
	s_instance = this;
	m_actSkillLayer = NULL;
	m_pasSkillLayer = NULL;
	m_actSkillInfoLayer = NULL;
	m_pasSkillInfoLayer = NULL;
	m_lifeSkillLayer = NULL;
	m_lifeSkillInfoLayer = NULL;
	m_userStateLayer = NULL;
	m_userStateInfoLayer = NULL;
}

PlayerSkillInfo::~PlayerSkillInfo()
{
	s_instance = NULL;
	
	if (m_actSkillInfoLayer && m_actSkillInfoLayer->GetParent() == NULL) {
		SAFE_DELETE(m_actSkillInfoLayer);
	}
	
	if (m_pasSkillInfoLayer && m_pasSkillInfoLayer->GetParent() == NULL) {
		SAFE_DELETE(m_pasSkillInfoLayer);
	}
	
	if (m_lifeSkillInfoLayer && m_lifeSkillInfoLayer->GetParent() == NULL) {
		SAFE_DELETE(m_lifeSkillInfoLayer);
	}
	
	if (m_userStateInfoLayer && m_userStateInfoLayer->GetParent() == NULL) {
		SAFE_DELETE(m_userStateInfoLayer);
	}
}

void PlayerSkillInfo::Initialization()
{
	NDUILayer::Initialization();
	
	NDUIImage* imgBg = new NDUIImage;
	imgBg->Initialization();
	imgBg->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_left_bg.png")), true);
	imgBg->SetFrameRect(CGRectMake(0, 10, 203, 262));
	this->AddChild(imgBg);
	
	m_actSkillInfoLayer = new CActSkillInfoLayer;
	m_actSkillInfoLayer->Initialization();
	m_actSkillInfoLayer->SetFrameRect(CGRectMake(0, 10, 202, 260));
	this->AddChild(m_actSkillInfoLayer);
	
	m_pasSkillInfoLayer = new BattleSkillInfoLayer;
	m_pasSkillInfoLayer->Initialization();
	m_pasSkillInfoLayer->SetFrameRect(CGRectMake(0, 10, 202, 260));
	
	m_lifeSkillInfoLayer = new LifeSkillInfoLayer;
	m_lifeSkillInfoLayer->Initialization();
	m_lifeSkillInfoLayer->SetFrameRect(CGRectMake(0, 10, 202, 260));
	
	m_userStateInfoLayer = new UserStateInfoLayer;
	m_userStateInfoLayer->Initialization();
	m_userStateInfoLayer->SetFrameRect(CGRectMake(0, 10, 202, 260));
}

void PlayerSkillInfo::AddActSkill(NDUINode* parent)
{
	if (!parent) {
		return;
	}
	
	NDPlayer& player = NDPlayer::defaultHero();
	m_actSkillLayer = new CActSkillLayer;
	m_actSkillLayer->Initialization(player.GetSkillList(SKILL_TYPE_ATTACK), m_actSkillInfoLayer, player.m_nMaxSlot);
	m_actSkillLayer->SetFrameRect(CGRectMake(14, 16, 230, 240));
	parent->AddChild(m_actSkillLayer);
}

void PlayerSkillInfo::AddPasSkill(NDUINode* parent)
{
	if (!parent) {
		return;
	}
	
	NDPlayer& player = NDPlayer::defaultHero();
	m_pasSkillLayer = new BattleSkillLayer;
	m_pasSkillLayer->Initialization(player.GetSkillList(SKILL_TYPE_PASSIVE), m_pasSkillInfoLayer);
	m_pasSkillLayer->SetFrameRect(CGRectMake(14, 16, 230, 240));
	parent->AddChild(m_pasSkillLayer);
}

void PlayerSkillInfo::AddLifeSkill(NDUINode* parent)
{
	if (!parent) {
		return;
	}
	
	m_lifeSkillLayer = new LifeSkillLayer;
	m_lifeSkillLayer->Initialization(m_lifeSkillInfoLayer);
	m_lifeSkillLayer->SetFrameRect(CGRectMake(14, 16, 230, 240));
	parent->AddChild(m_lifeSkillLayer);
}

void PlayerSkillInfo::AddPlayerState(NDUINode* parent)
{
	m_userStateLayer = new UserStateIconLayer;
	m_userStateLayer->Initialization(m_userStateInfoLayer);
	m_userStateLayer->SetFrameRect(CGRectMake(14, 16, 230, 240));
	parent->AddChild(m_userStateLayer);
}

void PlayerSkillInfo::Update()
{
	if (m_lifeSkillLayer) {
		m_lifeSkillLayer->UpdateLifeSkill();
	}
	if (m_userStateLayer) {
		m_userStateLayer->UpdateUserState();
	}
}

void PlayerSkillInfo::OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex)
{
	if (curIndex == 0) {
		m_pasSkillInfoLayer->RemoveFromParent(false);
		m_lifeSkillInfoLayer->RemoveFromParent(false);
		m_userStateInfoLayer->RemoveFromParent(false);
		if (m_actSkillInfoLayer->GetParent() == NULL) {
			this->AddChild(m_actSkillInfoLayer);
		}
	} else if (curIndex == 1) {
		m_actSkillInfoLayer->RemoveFromParent(false);
		m_lifeSkillInfoLayer->RemoveFromParent(false);
		m_userStateInfoLayer->RemoveFromParent(false);
		if (m_pasSkillInfoLayer->GetParent() == NULL) {
			this->AddChild(m_pasSkillInfoLayer);
		}
	} else if (curIndex == 2) {
		m_pasSkillInfoLayer->RemoveFromParent(false);
		m_actSkillInfoLayer->RemoveFromParent(false);
		m_userStateInfoLayer->RemoveFromParent(false);
		
		if (m_lifeSkillInfoLayer->GetParent() == NULL) {
			this->AddChild(m_lifeSkillInfoLayer);
		}
		
	} else if (curIndex == 3) {
		m_pasSkillInfoLayer->RemoveFromParent(false);
		m_actSkillInfoLayer->RemoveFromParent(false);
		m_lifeSkillInfoLayer->RemoveFromParent(false);
		
		if (m_userStateInfoLayer->GetParent() == NULL) {
			this->AddChild(m_userStateInfoLayer);
		}
		
	}
}

void PlayerSkillInfo::OpenGroove()
{
	if (m_actSkillLayer) {
		m_actSkillLayer->OpenGroove();
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(UserStateInfoLayer, NDUILayer)

UserStateInfoLayer::UserStateInfoLayer()
{
	m_imgSkill= NULL;
	m_lbSkillName = NULL;
	m_skillInfo = NULL;
	m_btnYiChu = NULL;
}

UserStateInfoLayer::~UserStateInfoLayer()
{
	if (m_btnYiChu && m_btnYiChu->GetParent() == NULL) {
		SAFE_DELETE(m_btnYiChu);
	}
}

void UserStateInfoLayer::Initialization()
{
	NDUILayer::Initialization();
	
	NDUIImage* imgSkillBg = new NDUIImage;
	imgSkillBg->Initialization();
	imgSkillBg->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_bagitem_sel.png")), true);
	imgSkillBg->SetFrameRect(CGRectMake(16, 16, 42, 42));
	this->AddChild(imgSkillBg);
	
	m_imgSkill = new NDUIImage;
	m_imgSkill->Initialization();
	m_imgSkill->SetFrameRect(CGRectMake(20, 20, 34, 34));
	this->AddChild(m_imgSkill);
	
	m_lbSkillName = new NDUILabel;
	m_lbSkillName->Initialization();
	m_lbSkillName->SetFontSize(16);
	m_lbSkillName->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbSkillName->SetFrameRect(CGRectMake(66, 14, 160, 20));
	this->AddChild(m_lbSkillName);
	
	NDUIImage* imgSlash = new NDUIImage;
	imgSlash->Initialization();
	imgSlash->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_left_fengge.png")), true);
	imgSlash->SetFrameRect(CGRectMake(6, 68, 185, 2));
	this->AddChild(imgSlash);
	
	imgSlash = new NDUIImage;
	imgSlash->Initialization();
	imgSlash->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_left_fengge.png")), true);
	imgSlash->SetFrameRect(CGRectMake(6, 222, 185, 2));
	this->AddChild(imgSlash);
	
	m_skillInfo = new NDUILabelScrollLayer;
	m_skillInfo->Initialization();
	m_skillInfo->SetFrameRect(CGRectMake(6, 74, 180, 140));
	this->AddChild(m_skillInfo);
	
	m_btnYiChu = new NDUIButton;
	m_btnYiChu->Initialization();
	m_btnYiChu->SetImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_btn_click.png")), false, CGRectZero, true);
	m_btnYiChu->SetFontColor(ccc4(247, 247, 247, 255));
	m_btnYiChu->SetTitle(NDCommonCString("YiChu"));
	m_btnYiChu->SetDelegate(this);
	m_btnYiChu->SetFrameRect(CGRectMake(26, 226, 48, 24));
}

void UserStateInfoLayer::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnYiChu) {
		NDTransData bao(_MSG_USER_STATE_CHG);
		bao << m_btnYiChu->GetTag();
		SEND_DATA(bao);
	}
}

void UserStateInfoLayer::RefreshUserState(int idState)
{
	UserState* pState = UserStateUILayer::getUserStateByID(idState);
	if (pState) {
		if (m_btnYiChu->GetParent() == NULL) {
			this->AddChild(m_btnYiChu);
		}
		m_imgSkill->SetPicture(GetSkillIconByIconIndex(pState->iconIndex), true);
		m_lbSkillName->SetText(pState->stateName.c_str());
		
		stringstream ss, sb;
		uint recycle = pState->endTime; //% 10000000000; // YYMMDDHHMM
		sb << "20" <<(recycle / 100000000) << NDCommonCString("year")
		<< (recycle % 100000000 / 1000000) << NDCommonCString("month")
		<< (recycle % 1000000 / 10000) << NDCommonCString("day")
		<< (recycle % 10000 / 100) << NDCommonCString("hour") 
		<< (recycle%100) << NDCommonCString("minute");
		
		ss << NDCommonCString("deadline") << "：\n" << sb.str()
		<< "\n" << NDCommonCString("effect") << "：\n" << pState->descript;
		
		m_skillInfo->SetText(ss.str().c_str());
		m_btnYiChu->SetTag(idState);
		
	} else {
		if (m_btnYiChu->GetParent()) {
			m_btnYiChu->RemoveFromParent(false);
		}
		m_btnYiChu->SetTag(0);
		m_imgSkill->SetPicture(NULL);
		m_lbSkillName->SetText("");
		m_skillInfo->SetText("");
	}
	
	if (!this->IsVisibled())
		m_skillInfo->SetVisible(false);
}

//////////////////////////////////////////////////////////////////////////////////////////
UserStateIconLayer* UserStateIconLayer::s_instance = NULL;

IMPLEMENT_CLASS(UserStateIconLayer, NDUILayer)

UserStateIconLayer::UserStateIconLayer()
{
	s_instance = this;
	memset(m_btnState, 0L, sizeof(m_btnState));
	m_stateInfoLayer = NULL;
}

UserStateIconLayer::~UserStateIconLayer()
{
	s_instance = NULL;
}

void UserStateIconLayer::Initialization(UserStateInfoLayer* stateInfoLayer)
{
	NDUILayer::Initialization();
	
	m_stateInfoLayer = stateInfoLayer;
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	
	GLfloat fStartX = 0;
	GLfloat fStartY = 0;
	
	NDPicture* picSkillButtonBg = pool.AddPicture(NDPath::GetImgPathNew("bag_bagitem.png"));
	NDPicture* picSkillButtonFocus = pool.AddPicture(NDPath::GetImgPathNew("bag_bagitem_sel.png"));
	
	bool bClearPicOnFree = true;
	
	MAP_USER_STATE& mapUserState = UserStateUILayer::getAllUserState();
	MAP_USER_STATE_IT it = mapUserState.begin();
	
	UserState* pState = NULL;
	
	for (int i = 0 ; i < ROW_COUNT; i++) {
		fStartX = 0;
		for (int j = 0; j < COL_COUNT; j++) {
			NDUIButton* btn = new NDUIButton;
			btn->Initialization();
			if (bClearPicOnFree) {
				bClearPicOnFree = !bClearPicOnFree;
				btn->SetBackgroundPicture(picSkillButtonBg, NULL, false, CGRectZero, true);
				btn->SetFocusImage(picSkillButtonFocus, false, CGRectZero, true);
			} else {
				btn->SetBackgroundPicture(picSkillButtonBg);
				btn->SetFocusImage(picSkillButtonFocus);
			}
			btn->SetFrameRect(CGRectMake(fStartX, fStartY, BG_SIZE, BG_SIZE));
			btn->CloseFrame();
			btn->SetDelegate(this);
			
			if (it != mapUserState.end()) {
				pState = it->second;
				if (pState) {
					btn->SetTag(pState->idState);
					btn->SetImage(GetSkillIconByIconIndex(pState->iconIndex), true, CGRectMake(4, 4, 34, 34), true);
				}
				it++;
			} else {
				btn->SetTag(0);
			}
			
			m_btnState[i][j] = btn;
			this->AddChild(btn);
			fStartX += BG_SIZE + 4;
		}
		fStartY += BG_SIZE + 6;
	}
	
	this->SetFocus(m_btnState[0][0]);
	this->OnButtonClick(m_btnState[0][0]);
}

void UserStateIconLayer::OnDelUserState()
{
	if (s_instance) {
		s_instance->UpdateUserState();
	}
}

void UserStateIconLayer::UpdateUserState()
{
	MAP_USER_STATE& mapUserState = UserStateUILayer::getAllUserState();
	MAP_USER_STATE_IT it = mapUserState.begin();
	
	UserState* pState = NULL;
	
	for (int i = 0 ; i < ROW_COUNT; i++) {
		for (int j = 0; j < COL_COUNT; j++) {
			NDUIButton* btn = m_btnState[i][j];
			
			if (it != mapUserState.end()) {
				pState = it->second;
				if (pState) {
					btn->SetTag(pState->idState);
					btn->SetImage(GetSkillIconByIconIndex(pState->iconIndex), true, CGRectMake(4, 4, 34, 34), true);
				}
				it++;
			} else {
				btn->SetTag(0);
				btn->SetImage(NULL);
			}
		}
	}
	this->SetFocus(m_btnState[0][0]);
	this->OnButtonClick(m_btnState[0][0]);
}

void UserStateIconLayer::OnButtonClick(NDUIButton* button)
{
	if (m_stateInfoLayer) {
		m_stateInfoLayer->RefreshUserState(button->GetTag());
	}
}
