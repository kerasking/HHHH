/*
 *  UiPetSkill.mm
 *  DragonDrive
 *
 *  Created by shenqiliang on 12-1-14.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "UiPetSkill.h"

#include "NDUtility.h"
#include "NDMapMgr.h"
#include "BattleMgr.h"
#include "ItemImage.h"
#include "NDPath.h"
#include <sstream>
#include "ItemMgr.h"
#include "NDUISynLayer.h"
#include "CPet.h"

//////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(CUIPetSkillInfo, NDUILayer)

CUIPetSkillInfo::CUIPetSkillInfo()
{
	m_imgSkill		= NULL;
	m_lbSkillName	= NULL;
	m_lbReqLv		= NULL;
	m_skillInfo		= NULL;
	m_btnKaiQi		= NULL;
	m_pBtnLock		= NULL;
	m_pBtnUnLock	= NULL;
	m_pBtnLearn		= NULL;
	m_pBtnFocus		= NULL;
	
	m_bEnable		= true;
}

CUIPetSkillInfo::~CUIPetSkillInfo()
{
}

bool CUIPetSkillInfo::Init()
{
	NDUILayer::Initialization();
	
	NDPicture* pPicBg = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_left_bg.png"));
	if (!pPicBg) {
		return false;
	}
	CGSize rSize = pPicBg->GetSize();
	this->SetFrameRect(CGRectMake(0,12, rSize.width, rSize.height));
	this->SetBackgroundImage(pPicBg, true);
	
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
	
	imgSlash = new NDUIImage;
	imgSlash->Initialization();
	imgSlash->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_left_fengge.png")), true);
	imgSlash->SetFrameRect(CGRectMake(6, 200, 185, 2));
	this->AddChild(imgSlash);
	
	m_skillInfo = new NDUILabelScrollLayer;
	m_skillInfo->Initialization();
	m_skillInfo->SetFrameRect(CGRectMake(6, 74, 180, 118));
	this->AddChild(m_skillInfo);
	
	NDPicture *picClose = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_left_close.png"));
	CGSize sizeClose = picClose->GetSize();
	m_pBtnClose = new NDUIButton;
	m_pBtnClose->Initialization();
	m_pBtnClose->SetFrameRect(CGRectMake(0, 206, sizeClose.width, sizeClose.height));
	m_pBtnClose->SetImage(picClose, false, CGRectZero, true);
	m_pBtnClose->SetDelegate(this);
	this->AddChild(m_pBtnClose);
	
	m_btnKaiQi	= this->CreateButton(NDCommonCString("open"));
	m_pBtnLock	= this->CreateButton(NDCommonCString("PetSkillLock"));
	m_pBtnUnLock= this->CreateButton(NDCommonCString("PetSkillUnlock"));
	m_pBtnLearn	= this->CreateButton(NDCommonCString("PetSkillLearn"));
	
	this->UpdateButton();
	return false;
}

void CUIPetSkillInfo::EnableOperate(bool bEnable)
{
	m_bEnable = bEnable;
}

void CUIPetSkillInfo::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnKaiQi) {
		OBJID idPet=0;
		CUIPetDelegate* pDelegate = dynamic_cast<CUIPetDelegate*> (this->GetDelegate());
		if (pDelegate) 
		{
			idPet = pDelegate->GetFocusPetId();
		}
		if (idPet) 
		{
			ShowProgressBar;
			NDTransData bao(_MSG_PET_SKILL);
			bao << (unsigned char)4 << int(idPet) << int(0);
			SEND_DATA(bao);
		}
	}
	else if (button == m_pBtnLock) {
		CUIPetDelegate* pDelegate = dynamic_cast<CUIPetDelegate*> (this->GetDelegate());
		if (pDelegate) 
		{
			pDelegate->LockSkill(m_idSkill);
		}
	}
	else if (button == m_pBtnUnLock) {
		CUIPetDelegate* pDelegate = dynamic_cast<CUIPetDelegate*> (this->GetDelegate());
		if (pDelegate) 
		{
			pDelegate->UnLockSkill(m_idSkill);
		}
	}
	else if (button == m_pBtnLearn) {
		CUIPetDelegate* pDelegate = dynamic_cast<CUIPetDelegate*> (this->GetDelegate());
		if (pDelegate) 
		{
			pDelegate->LearnSkill();
		}
	}
	else if (button == m_pBtnClose) {
		CUIPetDelegate* pDelegate = dynamic_cast<CUIPetDelegate*> (this->GetDelegate());
		if (pDelegate) 
		{
			pDelegate->CloseSkillInfo();
		}
	}
}

void CUIPetSkillInfo::RefreshPetSkill(OBJID idSkill, bool bLock)
{
	m_idItem = 0;
	BattleSkill* pSkill = NULL;
	if (idSkill > 0) {
		pSkill = BattleMgrObj.GetBattleSkill(idSkill);
	}
	if (pSkill) {
		if (bLock) {
			m_pBtnFocus	= m_pBtnUnLock;
		}
		else {
			m_pBtnFocus	= m_pBtnLock;
		}
		m_idSkill = idSkill;

		m_imgSkill->SetPicture(GetSkillIconByIconIndex(pSkill->getIconIndex()), true);
		m_imgSkill->SetFrameRect(CGRectMake(20, 20, 34, 34));
		std::stringstream ss; 
		ss << pSkill->getName() << "(" << pSkill->getLevel() << NDCommonCString("Ji") << ")";
		m_lbSkillName->SetText(ss.str().c_str());
		ss.str("");
		ss << NDCommonCString("ReqLvl") << "：" << pSkill->getLvRequire() << NDCommonCString("Ji");
		m_lbReqLv->SetText(ss.str().c_str());
		m_skillInfo->SetText(pSkill->getSimpleDes(false).c_str());
		
		this->UpdateButton();
	} else {
		this->ClearInfo();
	}
}

void CUIPetSkillInfo::RefreshItemSkill(OBJID idItem, bool bShowBtn)
{
	Item* pItem = NULL;
	if (idItem) {
		pItem = ItemMgrObj.QueryItem(idItem);
	}
	
	if (pItem) {
		m_idItem	= idItem;
		m_idSkill	= 0;
		if (bShowBtn) {
			m_pBtnFocus	= m_pBtnLearn;
		}
		else {
			m_pBtnFocus	= NULL;
		}
		
		m_imgSkill->SetPicture(ItemImage::GetItemByIconIndex(pItem->getIconIndex()), true);
		
		m_lbSkillName->SetText(pItem->getItemNameWithAdd().c_str());
		
		m_lbReqLv->SetText("");
		
		m_skillInfo->SetText(this->QuerySkillItemDesc(idItem).c_str());
		
		this->UpdateButton();
	}
	else {
		this->ClearInfo();
	}
}

void CUIPetSkillInfo::RefreshLock(OBJID idPet)
{
	PetInfo* petInfo = NULL;
	if (m_bEnable && idPet) {
		petInfo = PetMgrObj.GetPet(idPet);
	}
	
	if (petInfo) {
		m_pBtnFocus = m_btnKaiQi;
		m_imgSkill->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("lockstate.png")), true);
		m_imgSkill->SetFrameRect(CGRectMake(17, 17, 40, 40));
		m_lbSkillName->SetText(NDCommonCString("notopen"));
		m_lbReqLv->SetText("");
		
		PetInfo::PetData& petData = petInfo->data;
		int needNum=petData.int_PET_MAX_SKILL_NUM+1;
		std::stringstream ss;
		ss << NDCommonCString("OpenPetSkillTip") << "<cff0000" << needNum*needNum << "/e" << NDCommonCString("ge") << "“" << NDCommonCString("TianGongFu") << "”。";
		m_skillInfo->SetText(ss.str().c_str());
		this->UpdateButton();
	}
	else {
		this->ClearInfo();
	}
}

void CUIPetSkillInfo::UpdateSkillItemDesc(OBJID idItem, std::string& strDesc)
{
	m_mapStrSkillItem[idItem] = strDesc;
	if (idItem == m_idItem && 0 == m_idSkill) {
		m_skillInfo->SetText(strDesc.c_str());
	}
}

void CUIPetSkillInfo::SetVisible(bool bVisible)
{
	NDUILayer::SetVisible(bVisible);
	if (bVisible) {
		this->UpdateButton();
	}
}

void CUIPetSkillInfo::ClearInfo()
{
	m_idSkill	= 0;
	m_idItem	= 0;
	m_pBtnFocus	= NULL;
	m_imgSkill->SetPicture(NULL, true);
	m_lbSkillName->SetText("");
	m_lbReqLv->SetText("");
	m_skillInfo->SetText("");
	
	this->UpdateButton();
}

void CUIPetSkillInfo::UpdateButton()
{
	if (!this->IsVisibled()) {
		return;
	}
	
	if (m_btnKaiQi && m_btnKaiQi != m_pBtnFocus) {
		m_btnKaiQi->SetVisible(false);
	}
	if (m_pBtnLock && m_pBtnLock != m_pBtnFocus) {
		m_pBtnLock->SetVisible(false);
	}
	if (m_pBtnUnLock && m_pBtnUnLock != m_pBtnFocus) {
		m_pBtnUnLock->SetVisible(false);
	}
	if (m_pBtnLearn && m_pBtnLearn != m_pBtnFocus) {
		m_pBtnLearn->SetVisible(false);
	}
	if (m_pBtnFocus) {
		m_pBtnFocus->SetVisible(m_bEnable);
	}
}

NDUIButton* CUIPetSkillInfo::CreateButton(const char* pszTitle)
{
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDUIButton* pBtn = new NDUIButton;
	if (!pBtn) {
		return false;
	}
	pBtn->Initialization();
	pBtn->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_btn_normal.png")),
							   pool.AddPicture(NDPath::GetImgPathNew("bag_btn_click.png")),
							   false, CGRectZero, true);
	pBtn->SetFontSize(12);
	pBtn->SetFontColor(ccc4(255, 255, 255, 255));
	pBtn->SetTitle(pszTitle);
	pBtn->SetFrameRect(CGRectMake(130, 210, 48, 24));
	pBtn->CloseFrame();
	pBtn->SetDelegate(this);
	this->AddChild(pBtn);
	return pBtn;
}

std::string CUIPetSkillInfo::QuerySkillItemDesc(OBJID idItem)
{
	if (!idItem) {
		return NULL;
	}
	
	std::map<OBJID, std::string>::iterator iter = m_mapStrSkillItem.find(idItem);
	if (iter != m_mapStrSkillItem.end()) {
		return iter->second;
	}
	
	NDTransData bao(_MSG_QUERY_PETCKILL);
	bao << int(idItem);
	SEND_DATA(bao);
	
	std::string str;
	str	= "...";
	m_mapStrSkillItem[idItem] = str;
	return m_mapStrSkillItem[idItem];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(CUIPetSkill, NDUILayer)

CUIPetSkill::CUIPetSkill()
{
	m_btnBack		= NULL;
	m_btnNext		= NULL;
	m_btnBackItem	= NULL;
	m_btnNextItem	= NULL;
	m_nPage			= 0;
	m_nPageItem		= 0;
	m_nSlotCount	= 0;
	m_bEnable		= true;
}

CUIPetSkill::~CUIPetSkill()
{

}

bool CUIPetSkill::Init()
{
	NDUILayer::Initialization();
	
	GLfloat fStartX = MARGIN_L;
	GLfloat fStartY = MARGIN_T;
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	NDPicture* picSkillButtonBg = pool.AddPicture(NDPath::GetImgPathNew("bag_bagitem.png"));
	NDPicture* picSkillButtonFocus = pool.AddPicture(NDPath::GetImgPathNew("bag_bagitem_sel.png"));

	for (int i = 0 ; i < SKILL_BTN_COUNT; i++) {
		NDUIButton* btn = new NDUIButton;
		btn->Initialization();
		btn->SetBackgroundPicture(picSkillButtonBg);
		btn->SetFocusImage(picSkillButtonFocus);
		btn->SetFrameRect(CGRectMake(fStartX, fStartY, BG_SIZE, BG_SIZE));
		btn->CloseFrame();
		btn->SetFontSize(12);
		btn->SetFontColor(ccc4(255, 255, 0, 255));
		btn->SetDelegate(this);
		btn->SetTag(i);
		
		this->AddChild(btn);
		m_btnSkills[i] = btn;
		fStartX += BG_SIZE + BUTTON_INTERVAL;
		
		if ((i+1) % COL_COUNT == 0) {
			fStartX = MARGIN_L;
			fStartY += BG_SIZE + 6;
		}
	}
	CGRect	rRect = this->GetFrameRect();
	
//	m_btnBack = this->CreateButton(NDCommonCString("PrevPage"));
//	if (!m_btnBack) {
//		return false;
//	}
//	m_btnBack->SetFrameRect(CGRectMake(MARGIN_L, fStartY, BUTTON_W, BUTTON_H));
//	
	m_pLabelPage = new NDUILabel;
	m_pLabelPage->Initialization();
	m_pLabelPage->SetFontSize(14);
	m_pLabelPage->SetFontColor(ccc4(187, 19, 19, 255));
	m_pLabelPage->SetText(NDCommonCString("PetSkillLearned"));
	m_pLabelPage->SetFrameRect(CGRectMake(MARGIN_L+BUTTON_W, fStartY+4, 240-BUTTON_W*2-MARGIN_L, 20));
	m_pLabelPage->SetTextAlignment(LabelTextAlignmentCenter);
	this->AddChild(m_pLabelPage);
//	
//	m_btnNext = this->CreateButton(NDCommonCString("NextPage"));
//	if (!m_btnNext) {
//		return false;
//	}
//	m_btnNext->SetFrameRect(CGRectMake(240-BUTTON_W, fStartY, BUTTON_W, BUTTON_H));
	
	fStartX = MARGIN_L;
	fStartY += 32;
	for (int i = 0 ; i < ITEM_BTN_COUNT; i++) {
		NDUIButton* btn = new NDUIButton;
		btn->Initialization();
		btn->SetBackgroundPicture(picSkillButtonBg);
		btn->SetFocusImage(picSkillButtonFocus);
		btn->SetFrameRect(CGRectMake(fStartX, fStartY, BG_SIZE, BG_SIZE));
		btn->CloseFrame();
		btn->SetDelegate(this);
		btn->SetTag(i+ITEM_BTN_BEGIN);
		
		this->AddChild(btn);
		m_btnItems[i]	= btn;
		fStartX += BG_SIZE + BUTTON_INTERVAL;
		
		if ((i+1) % COL_COUNT == 0) {
			fStartX = MARGIN_L;
			fStartY += BG_SIZE + 6;
		}
	}
	
	m_btnBackItem = this->CreateButton(NDCommonCString("PrevPage"));
	if (!m_btnBackItem) {
		return false;
	}
	m_btnBackItem->SetFrameRect(CGRectMake(MARGIN_L, fStartY, BUTTON_W, BUTTON_H));
	
	m_pLabelItemPage = new NDUILabel;
	m_pLabelItemPage->Initialization();
	m_pLabelItemPage->SetFontSize(14);
	m_pLabelItemPage->SetFontColor(ccc4(187, 19, 19, 255));
	m_pLabelItemPage->SetFrameRect(CGRectMake(MARGIN_L+BUTTON_W, fStartY+4, 240-BUTTON_W*2-MARGIN_L, 20));
	m_pLabelItemPage->SetTextAlignment(LabelTextAlignmentCenter);
	this->AddChild(m_pLabelItemPage);
	
	m_btnNextItem = this->CreateButton(NDCommonCString("NextPage"));
	if (!m_btnNextItem) {
		return false;
	}
	m_btnNextItem->SetFrameRect(CGRectMake(240-BUTTON_W, fStartY, BUTTON_W, BUTTON_H));
	

	this->UpdatePage();
	this->UpdatePageItem();
	return true;
}

void CUIPetSkill::Update(OBJID idPet, bool bEnable)
{
	m_idPet		= idPet;
	m_bEnable	= bEnable;
	
	PetInfo* petInfo = PetMgrObj.GetPet(m_idPet);
	if (!petInfo){
		m_nSlotCount = 0;
		m_mapSkillPos.clear();
	}
	else {
		m_nSlotCount = petInfo->data.int_PET_MAX_SKILL_NUM;
		
		m_mapSkillPos.clear();
		std::set<OBJID> setId;
		PetMgrObj.GetSkillList(m_idPet, setId);
		int i = 1;
		for (std::set<OBJID>::iterator iter = setId.begin(); iter != setId.end(); iter++) {
			m_mapSkillPos[i++]	= *iter;
		}
	}

	this->UpdateLockSkill();
	this->UpdatePage();
}

void CUIPetSkill::UpdateSkillItem(ID_VEC& vecItemId)
{
	m_mapItemPos.clear();
	int i = 1 + ITEM_BTN_BEGIN;
	for (ID_VEC::iterator iter = vecItemId.begin(); iter != vecItemId.end(); iter++) {
		m_mapItemPos[i++] = *iter;
	}
	this->UpdatePageItem();
}

PET_SKILL_BTN_TYPE CUIPetSkill::CUIPetSkill::GetBtnType()
{
	PET_SKILL_BTN_TYPE eType = PET_SKILL_BTN_TYPE_EMPTY;
	if (m_nPos < ITEM_BTN_BEGIN) {
		int nKey = this->GetKeyByPos(m_nPos);
		if (nKey > m_nSlotCount) {
			eType = PET_SKILL_BTN_TYPE_LOCK;
		}
		else {
			if (this->GetSkillIdByPos(m_nPos)) {
				eType = PET_SKILL_BTN_TYPE_SKILL;
			}
		}
	}
	else {
		if (this->GetItemIdByPos(m_nPos)) {
			eType = PET_SKILL_BTN_TYPE_ITEM;
		}
	}
	return eType;
}

OBJID CUIPetSkill::GetSkillId()
{
	return this->GetSkillIdByPos(m_nPos);
}

OBJID CUIPetSkill::GetItemId()
{
	return this->GetItemIdByPos(m_nPos);
}

bool CUIPetSkill::IsLockSkill(OBJID idSkill)
{
	return (m_setLockSkill.find(idSkill) == m_setLockSkill.end()) ? false : true;
}

void CUIPetSkill::OnButtonClick(NDUIButton* button)
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
		if (m_nPage < (((int)m_mapSkillPos.size()-1)/SKILL_BTN_COUNT)) {
			m_nPage++;
			this->UpdatePage();
		}
	}
	else if (button == m_btnBackItem) {
		if (m_nPageItem > 0) {
			m_nPageItem--;
			this->UpdatePageItem();
		}
	}
	else if (button == m_btnNextItem) {
		if (m_nPageItem < (((int)m_mapItemPos.size()-1)/SKILL_BTN_COUNT)) {
			m_nPageItem++;
			this->UpdatePageItem();
		}
	}
	else {
		CUIPetDelegate* pDelegate = dynamic_cast<CUIPetDelegate*> (this->GetDelegate());
		if (pDelegate) 
		{
			m_nPos	= button->GetTag();
			pDelegate->UpdateSkillInfo();
		}	
	}
}

void CUIPetSkill::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (!dialog) {
		return;
	}
	this->SendLearnSkillMsg();
	
	dialog->Close();
}

void CUIPetSkill::OpenGroove()
{
	m_nSlotCount++;
	this->UpdatePage();
}

void CUIPetSkill::LockSkill(OBJID idSkill)
{
	m_setLockSkill.insert(idSkill);
	this->UpdatePage();
	CUIPetDelegate* pDelegate = dynamic_cast<CUIPetDelegate*> (this->GetDelegate());
	if (pDelegate) 
	{
		pDelegate->UpdateSkillInfo();
	}
}

void CUIPetSkill::UnLockSkill(OBJID idSkill)
{
	m_setLockSkill.erase(idSkill);
	this->UpdatePage();
	CUIPetDelegate* pDelegate = dynamic_cast<CUIPetDelegate*> (this->GetDelegate());
	if (pDelegate) 
	{
		pDelegate->UpdateSkillInfo();
	}
}

void CUIPetSkill::LearnSkill()
{
	NDUIDialog* pDlg = new NDUIDialog;
	if (!pDlg) {
		return;
	}
	pDlg->Initialization();
	pDlg->SetDelegate(this);
	
	int nLockSize	= m_setLockSkill.size();
	int nSkillSize	= m_mapSkillPos.size();
	
	if (0 == nSkillSize) {
		this->SendLearnSkillMsg();
	}
	else {
		NDString strText;
		int nItemAmount	= ItemMgrObj.GetBagItemCount(ID_SUO_LING_FU);
		
		NDItemType* pItemtype = ItemMgrObj.QueryItemType(ID_SUO_LING_FU);
		if (!pItemtype) {
			return;
		}
		if (nLockSize > nItemAmount) {
			int nNeedEmoney = pItemtype->m_data.m_emoney * (nLockSize-nItemAmount);
			strText.Format(NDCommonCString("PetSkillTip1"), 
						   pItemtype->m_name.c_str(), nLockSize-nItemAmount, nNeedEmoney);
		}
		else {
			if (nLockSize >= nSkillSize) {
				strText.Format(NDCommonCString("PetSkillTip2"), pItemtype->m_name.c_str(), nLockSize);
			}
			else {
				strText.Format(NDCommonCString("PetSkillTip3"));
			}

		}

		pDlg->Show(NDCommonCString("WenXinTip"), strText.getData(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
	}
}

void CUIPetSkill::UpdatePage()
{	
	NDUIButton* pBtn	= NULL;
	for (int i = 0; i < SKILL_BTN_COUNT; i++) {
		pBtn = m_btnSkills[i];
		if (pBtn) {
			this->SetButtonImage(pBtn);
		}
	}
//	NDString strText;
//	strText.Format("%s(%d/%d)", "宠物技能", m_nPage + 1, (((int)m_mapSkillPos.size()-1)/SKILL_BTN_COUNT) + 1);
//	m_pLabelPage
}

void CUIPetSkill::UpdatePageItem()
{
	if (m_nPageItem == 0) {
		m_btnBackItem->EnalbelBackgroundGray(true);
	}
	else {
		m_btnBackItem->EnalbelBackgroundGray(false);
	}
	if (m_nPageItem == (((int)m_mapItemPos.size()-1)/SKILL_BTN_COUNT)) {
		m_btnNextItem->EnalbelBackgroundGray(true);
	}
	else {
		m_btnNextItem->EnalbelBackgroundGray(false);
	}
	
	NDUIButton* pBtn	= NULL;
	for (int i = 0; i < ITEM_BTN_COUNT; i++) {
		pBtn = m_btnItems[i];
		if (pBtn) {
			this->SetButtonImage(pBtn);
		}
	}
	NDString strText;
	strText.Format("%s(%d/%d)", NDCommonCString("PetSkillCanLearn"), m_nPageItem + 1, (((int)m_mapItemPos.size()-1)/SKILL_BTN_COUNT) + 1);
	m_pLabelItemPage->SetText(strText.getData());
}

int CUIPetSkill::GetSkillIdByPos(int nPos)
{
	if (nPos < ITEM_BTN_BEGIN) {
		int nKey = this->GetKeyByPos(nPos);
		std::map<int, int>::iterator iter = m_mapSkillPos.find(nKey);
		if (iter != m_mapSkillPos.end()) {
			return iter->second;
		}
	}
	
	return 0;
}

int CUIPetSkill::GetItemIdByPos(int nPos)
{
	if (nPos >= ITEM_BTN_BEGIN) {
		int nKey = this->GetKeyByPos(nPos);
		std::map<int, int>::iterator iter = m_mapItemPos.find(nKey);
		if (iter != m_mapItemPos.end()) {
			return iter->second;
		}
	}
	
	return 0;
}

int CUIPetSkill::GetKeyByPos(int nPos)
{
	int nKey = 0;
	if (nPos < ITEM_BTN_BEGIN) {
		nKey = nPos+SKILL_BTN_COUNT*m_nPage + 1;
	}
	else {
		nKey = nPos+ITEM_BTN_COUNT*m_nPageItem + 1;
	}
	return nKey;
}

void CUIPetSkill::SetButtonImage(NDUIButton* pBtn)
{
	if (!pBtn) {
		return;
	}
	int nPos = pBtn->GetTag();
	if (nPos < ITEM_BTN_BEGIN) {
		int idSkill = this->GetSkillIdByPos(nPos);
		BattleSkill* pSkill = NULL;
		if (idSkill > 0) {
			pSkill = BattleMgrObj.GetBattleSkill(idSkill);
		}
		if (pSkill) {
			pBtn->SetImage(GetSkillIconByIconIndex(pSkill->getIconIndex()), true, CGRectMake(4, 4, 34, 34), true);
			if (this->IsLockSkill(idSkill)) {
				pBtn->SetTitle(NDCommonCString("PetSkillLocked"));
			}
			else {
				pBtn->SetTitle("");
			}
		}
		else {
			pBtn->SetTitle("");
			if (this->GetKeyByPos(nPos) <= m_nSlotCount) {
				pBtn->SetImage(NULL, true, CGRectMake(4, 4, 34, 34), true);
			}
			else {
				pBtn->SetImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("lockstate.png")), true, CGRectMake(1, 1, 40, 40), true);
			}
		}
		
	}
	else {
		int idItem = this->GetItemIdByPos(nPos);
		Item* pItem = NULL;
		if (idItem) {
			pItem = ItemMgrObj.QueryItem(idItem);
		}
		if (pItem) {
			pBtn->SetImage(ItemImage::GetItemByIconIndex(pItem->getIconIndex()), true, CGRectMake(4, 4, 34, 34), true);
		}
		else {
			pBtn->SetImage(NULL, true, CGRectMake(4, 4, 34, 34), true);
		}
	}
}

NDUIButton* CUIPetSkill::CreateButton(const char* pszTitle)
{
	if (!pszTitle) {
		return NULL;
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
	pBtn->SetFrameRect(CGRectMake(0, 0, BUTTON_W, BUTTON_H));
	pBtn->CloseFrame();
	pBtn->SetDelegate(this);
	this->AddChild(pBtn);
	return pBtn;
}

void CUIPetSkill::UpdateLockSkill()
{
	std::set<OBJID> setTemp;
	std::map<int, int>::iterator iter = m_mapSkillPos.begin();
	for (; iter != m_mapSkillPos.end(); iter++) {
		if (this->IsLockSkill(iter->second)) {
			setTemp.insert(iter->second);
		}
	}
	m_setLockSkill = setTemp;
}

void CUIPetSkill::SendLearnSkillMsg()
{
	OBJID idItem = this->GetItemId();
	if (!idItem) {
		return;
	}
	ShowProgressBar;
	NDTransData bao(_MSG_PET_SKILL);
	bao << (unsigned char)5 << int(m_idPet) << int(idItem);
	bao << (unsigned char)m_setLockSkill.size();
	for (std::set<OBJID>::iterator iter = m_setLockSkill.begin(); iter != m_setLockSkill.end(); iter++) {
		bao << int(*iter);
	}
	SEND_DATA(bao);
}
