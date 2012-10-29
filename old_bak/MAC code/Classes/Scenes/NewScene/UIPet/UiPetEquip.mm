/*
 *  UiPetEquip.mm
 *  DragonDrive
 *
 *  Created by xwq on 12-1-14.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDDirector.h"
#include "ItemMgr.h"
#include "ImageNumber.h"
#include "GameRoleNode.h"
#include "CGPointExtension.h"
#include "ItemImage.h"
#include "NDUtility.h"
#include "NDUIDialog.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "NDBattlePet.h"
#include "NDPlayer.h"
#include "define.h"
#include "NDString.h"
#include "EnumDef.h"
#include "NDUISynLayer.h"
#include "NDMapMgr.h"
#include "GameItemInlay.h"
#include "PlayerInfoScene.h"
#include <sstream>
#include "NewChatScene.h"
#include "UiPetEquip.h"
#include "NDPath.h"
#include "CPet.h"


//////////////////////////////////////////////////////////////////////

#define DIALOG_TAG_CLOSE (100)

IMPLEMENT_CLASS(CUIPetEquip, NDUILayer)

CUIPetEquip::CUIPetEquip()
{
	m_pImageMouse	= NULL;
	m_pLabelName	= NULL;
	m_pLabelPost	= NULL;
	m_pLabelLevel	= NULL;
	m_pLabelTrait	= NULL;
	m_pLabelQuality	= NULL;
	
	m_stateBarExp	= NULL;	
	m_pLabelHp		= NULL;	
	m_pLabelMp		= NULL;
	m_pBtnRoleBg	= NULL;
	m_pBtnMainPlayed= NULL;
	m_pBtnRest		= NULL;			
	m_pBtnPlayed	= NULL;		
	m_pBtnIn		= NULL;			
	m_pBtnOut		= NULL;			
	m_pBtnDel		= NULL;			
	m_pBtnDisboard	= NULL;		
	m_pBtnShow		= NULL;
	m_pBtnLeft		= NULL;
	m_pBtnRight		= NULL;
	m_pPetNode		= NULL;
	m_idFocusPet	= 0;
	m_bEnable		= true;
}

CUIPetEquip::~CUIPetEquip()
{
}

bool CUIPetEquip::Init()
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	NDPicture* pPicBg = pool.AddPicture(NDPath::GetImgPathNew("bag_left_bg.png"));
	if (!pPicBg) {
		return false;
	}
	CGSize rSize = pPicBg->GetSize();
	this->SetFrameRect(CGRectMake(0,12, rSize.width, rSize.height));
	this->SetBackgroundImage(pPicBg, true);
	int nStartY = MARGIN_T;
	
	m_pLabelName = new NDUILabel();
	if (!m_pLabelName) {
		return false;
	}
	m_pLabelName->Initialization();
	m_pLabelName->SetFontSize(13);
	m_pLabelName->SetTextAlignment(LabelTextAlignmentCenter);
	m_pLabelName->SetFontColor(ccc4(187,19,19,255));
	m_pLabelName->SetFrameRect(CGRectMake(rSize.width/2-40, nStartY, 80, 20));
	this->AddChild(m_pLabelName);
	
	NDPicture* picBtnL	= pool.AddPicture(NDPath::GetImgPathNew("arrow_left.png"));
	CGSize sizeBtnL     = picBtnL->GetSize();
	CGRect rectCustom	= CGRectMake( (BUTTON_W - sizeBtnL.width) / 2, 
									  (BUTTON_H - sizeBtnL.height) / 2, 
									  sizeBtnL.width, sizeBtnL.height );
	m_pBtnLeft = new NDUIButton;
	m_pBtnLeft->Initialization();
	m_pBtnLeft->SetFrameRect(CGRectMake(MARGIN_L, nStartY, BUTTON_W, BUTTON_H));
	m_pBtnLeft->SetDelegate(this);
	m_pBtnLeft->SetImage(picBtnL, true, rectCustom, true);
	this->AddChild(m_pBtnLeft);
	
	NDPicture* picBtnR	= pool.AddPicture(NDPath::GetImgPathNew("arrow_right.png"));
	m_pBtnRight = new NDUIButton;
	m_pBtnRight->Initialization();
	m_pBtnRight->SetFrameRect(CGRectMake(rSize.width - MARGIN_R - BUTTON_W, nStartY, BUTTON_W, BUTTON_H));
	m_pBtnRight->SetDelegate(this);
	m_pBtnRight->SetImage(picBtnR, true, rectCustom, true);
	this->AddChild(m_pBtnRight);
	
	nStartY += 24;
	for (int i = ID_BUTTON_AMULDT1; i <= ID_BUTTON_SHOES; i++) {
		int nX = (i % 2) ? MARGIN_L : (rSize.width - (ITEM_CELL_W-2 + MARGIN_R));
		int nY = nStartY + (i-ID_BUTTON_AMULDT1)/2 * (ITEM_CELL_H + ITEM_CELL_INTERVAL_H);
		
		NDUIItemButton* pBtn = new NDUIItemButton();
		if (!pBtn) {
			return false;
		}
		pBtn->Initialization();
		pBtn->SetTag(i);
		pBtn->SetFrameRect(CGRectMake(nX, nY, ITEM_CELL_W-2, ITEM_CELL_H-2));
		pBtn->SetDelegate(this);
		this->AddChild(pBtn);
		m_mapButton[i] = pBtn;
	}
	
	int nRoleBgW = rSize.width - MARGIN_L - MARGIN_R - 2*ITEM_CELL_W -2*ITEM_CELL_INTERVAL_W;
	int nRoleBgH = 3*ITEM_CELL_H + 2*ITEM_CELL_INTERVAL_H;
	NDPicture* pPicRoleBg = pool.AddPicture(NDPath::GetImgPathNew("role_bg.png"), nRoleBgW, nRoleBgH);
	if (!pPicRoleBg) {
		return false;
	}
	CGSize rPicRoleSize = pPicRoleBg->GetSize();
	m_pBtnRoleBg = new NDUIButton;
	if (!m_pBtnRoleBg) {
		return false;
	}
	m_pBtnRoleBg->Initialization();
	m_pBtnRoleBg->SetFrameRect(CGRectMake(MARGIN_L+ITEM_CELL_W+ITEM_CELL_INTERVAL_W, 
										  nStartY, 
										  rPicRoleSize.width, 
										  rPicRoleSize.height));
	m_pBtnRoleBg->CloseFrame();
	m_pBtnRoleBg->SetBackgroundPicture(pPicRoleBg);
	m_pBtnRoleBg->SetDelegate(this);
	this->AddChild(m_pBtnRoleBg);
	
	//
	m_pLabelPost = new NDUILabel();
	if (!m_pLabelPost) {
		return false;
	}
	m_pLabelPost->Initialization();
	m_pLabelPost->SetFontSize(11);
	m_pLabelPost->SetTextAlignment(LabelTextAlignmentCenter);
	m_pLabelPost->SetFontColor(ccc4(187,19,19,255));
	m_pLabelPost->SetFrameRect(CGRectMake(rPicRoleSize.width/2-35, 5, 70, 15));
	m_pBtnRoleBg->AddChild(m_pLabelPost);
	
	m_pLabelLevel = new NDUILabel();
	if (!m_pLabelLevel) {
		return false;
	}
	m_pLabelLevel->Initialization();
	m_pLabelLevel->SetFontSize(11);
	m_pLabelLevel->SetTextAlignment(LabelTextAlignmentCenter);
	m_pLabelLevel->SetFontColor(ccc4(187,19,19,255));
	m_pLabelLevel->SetFrameRect(CGRectMake(rPicRoleSize.width/2-35, 20, 70, 15));
	m_pBtnRoleBg->AddChild(m_pLabelLevel);
	
	
	m_pLabelQuality = new NDUILabel();
	if (!m_pLabelQuality) {
		return false;
	}
	m_pLabelQuality->Initialization();
	m_pLabelQuality->SetFontSize(11);
	m_pLabelQuality->SetTextAlignment(LabelTextAlignmentLeft);
	m_pLabelQuality->SetFontColor(ccc4(187,19,19,255));
	m_pLabelQuality->SetFrameRect(CGRectMake(rPicRoleSize.width/2-35, 38, 35, 15));
	m_pBtnRoleBg->AddChild(m_pLabelQuality);
	
	m_pLabelTrait = new NDUILabel();
	if (!m_pLabelTrait) {
		return false;
	}
	m_pLabelTrait->Initialization();
	m_pLabelTrait->SetFontSize(11);
	m_pLabelTrait->SetTextAlignment(LabelTextAlignmentRight);
	m_pLabelTrait->SetFontColor(ccc4(187,19,19,255));
	m_pLabelTrait->SetFrameRect(CGRectMake(rPicRoleSize.width/2, 38, 35, 15));
	m_pBtnRoleBg->AddChild(m_pLabelTrait);
	
	
	// 宠物动画
	m_pPetNode = new CPetNode;
	m_pPetNode->Initialization();
	m_pPetNode->SetDisplayPos(ccp(100,185));
	m_pBtnRoleBg->AddChild(m_pPetNode);
	
	nStartY += nRoleBgH + 3;
	
	NDUILabel* pLabelExp = new NDUILabel();
	if (!pLabelExp) {
		return false;
	}
	pLabelExp->Initialization();
	pLabelExp->SetText("Exp");
	pLabelExp->SetFontSize(13);
	pLabelExp->SetTextAlignment(LabelTextAlignmentLeft);
	pLabelExp->SetFontColor(ccc4(187,19,19,255));
	pLabelExp->SetFrameRect(CGRectMake(MARGIN_L, nStartY, 40, 25));
	this->AddChild(pLabelExp);
	
	m_stateBarExp = new NDExpStateBar();
	if (!m_stateBarExp) {
		return false;
	}
	m_stateBarExp->Initialization(CGPointMake(MARGIN_L+25, nStartY+3));
	this->AddChild(m_stateBarExp);
	
	nStartY += 18;
	m_pLabelHp = new NDUILabel();
	if (!m_pLabelHp) {
		return false;
	}
	m_pLabelHp->Initialization();
	m_pLabelHp->SetFontSize(13);
	m_pLabelHp->SetTextAlignment(LabelTextAlignmentLeft);
	m_pLabelHp->SetFontColor(ccc4(187,19,19,255));
	m_pLabelHp->SetFrameRect(CGRectMake(MARGIN_L, nStartY, 100, 15));
	this->AddChild(m_pLabelHp);
	
	m_pLabelMp = new NDUILabel();
	if (!m_pLabelMp) {
		return false;
	}
	m_pLabelMp->Initialization();
	m_pLabelMp->SetFontSize(13);
	m_pLabelMp->SetTextAlignment(LabelTextAlignmentLeft);
	m_pLabelMp->SetFontColor(ccc4(187,19,19,255));
	m_pLabelMp->SetFrameRect(CGRectMake(rSize.width/2-5, nStartY, 100, 15));
	this->AddChild(m_pLabelMp);
	
	m_pBtnMainPlayed = this->CreateButton(NDCommonCString("MainPet"));
	if (!m_pBtnMainPlayed) {
		return false;
	}
	
	m_pBtnRest = this->CreateButton(NDCommonCString("PetRest"));
	if (!m_pBtnRest) {
		return false;
	}
	
	m_pBtnPlayed = this->CreateButton(NDCommonCString("PetFighter"));
	if (!m_pBtnPlayed) {
		return false;
	}
	
	m_pBtnIn = this->CreateButton(NDCommonCString("PetIn"));
	if (!m_pBtnIn) {
		return false;
	}
	
	m_pBtnOut = this->CreateButton(NDCommonCString("PetOut"));
	if (!m_pBtnOut) {
		return false;
	}
	
	m_pBtnDel = this->CreateButton(NDCommonCString("PetDrop"));
	if (!m_pBtnDel) {
		return false;
	}
	
	m_pBtnDisboard = this->CreateButton(NDCommonCString("PetDisboard"));
	if (!m_pBtnDisboard) {
		return false;
	}
	
	m_pBtnShow = this->CreateButton(NDCommonCString("PetShow"));
	if (!m_pBtnShow) {
		return false;
	}
	
	this->UpdateFocusPet();
	return true;
}

void CUIPetEquip::Update(OBJID idUser, OBJID idFocusPet, bool bEnable)
{
	m_idFocusPet = idFocusPet;
	m_bEnable = bEnable;
	
	if (m_idFocusPet && !PetMgrObj.GetPet(m_idFocusPet)) {
		m_idFocusPet = 0;
	}

	m_vecIdPet.clear();
	if (idUser) {
		PetMgrObj.GetPets(idUser, m_vecIdPet);
		for (ID_VEC::iterator iter = m_vecIdPet.begin(); iter != m_vecIdPet.end(); ) {
			PetInfo* petInfo = PetMgrObj.GetPet(*iter);
			if (!petInfo){
				return;
			}
			int nPos = petInfo->data.int_PET_ATTR_POSITION;
			if (bEnable && (PET_POSITION_BAG & nPos)) {
				m_vecIdPet.erase(iter);
			}
			else {
				iter++;
			}
		}
		if (!m_idFocusPet && !m_vecIdPet.empty()) {
			m_idFocusPet = m_vecIdPet[0];
		}
	}
	
	this->UpdateFocusPet();
}

void CUIPetEquip::OnButtonClick(NDUIButton* button)
{
	if (!button || !m_idFocusPet) {
		return;
	}
	NDTransData bao(_MSG_PET_ACTION);
	if (button == m_pBtnMainPlayed) {
		bao << (int)m_idFocusPet << int(MSG_PET_ACTION_GENERAL) << int(0);
	}
	else if (button == m_pBtnRest) {
		bao << (int)m_idFocusPet << int(MSG_PET_ACTION_REST) << int(0);
	}
	else if (button == m_pBtnPlayed) {
		bao << (int)m_idFocusPet << int(MSG_PET_ACTION_FIGHT) << int(0);
	}
	else if (button == m_pBtnIn) {
		bao << (int)m_idFocusPet << int(MSG_PET_ACTION_UNSHOW) << int(0);
	}
	else if (button == m_pBtnOut) {
		bao << (int)m_idFocusPet << int(MSG_PET_ACTION_SHOW) << int(0);
	}
	else if (button == m_pBtnDel) {
		NDUIDialog *dlg = new NDUIDialog;
		dlg->Initialization();
		dlg->Show(NDCommonCString("WenXinTip"), NDCommonCString("PetDropTip"), "", NDCommonCString("Ok"), NULL);
		dlg->SetTag(DIALOG_TAG_CLOSE);
		dlg->SetDelegate(this);
		return;
		//bao << (int)m_idFocusPet << int(MSG_PET_ACTION_DROP) << int(0);
	}
	else if (button == m_pBtnDisboard) {
		bao << (int)m_idFocusPet << int(MSG_PET_ACTION_TOBAG) << int(0);
	}
	else if (button == m_pBtnShow) {
		PetInfo* petInfo = PetMgrObj.GetPet(m_idFocusPet);
		
		if (!petInfo) return;
		
		PetInfo::PetData& petData = petInfo->data;
		
		NewChatScene* chat = NewChatScene::DefaultManager();
		if (chat)
		{
			
			chat->Show();
			chat->AppendItem(petData.int_PET_ID, 
							 CPetMgr::getPetQualityColor(petData.int_PET_ATTR_TYPE), 
							 petInfo->str_PET_ATTR_NAME);
		}
		return;
	}
	else if (button == m_pBtnLeft) {
		OBJID idPet = this->GetLastPetId();
		if (idPet != m_idFocusPet) {
			m_idFocusPet = idPet;
			this->UpdateFocusPet();
			CUIPetDelegate* pDelegate = dynamic_cast<CUIPetDelegate*> (this->GetDelegate());
			if (pDelegate) 
			{
				pDelegate->ChangePet();
			}
		}
		return;
	}
	else if (button == m_pBtnRight) {
		OBJID idPet = this->GetNextPetId();
		if (idPet != m_idFocusPet) {
			m_idFocusPet = idPet;
			this->UpdateFocusPet();
			CUIPetDelegate* pDelegate = dynamic_cast<CUIPetDelegate*> (this->GetDelegate());
			if (pDelegate) 
			{
				pDelegate->ChangePet();
			}
		}
		return;
	}
	else {
		return;
	}
	SEND_DATA(bao);
	ShowProgressBar;
}

bool CUIPetEquip::OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch)
{
	if (button->IsKindOfClass(RUNTIME_CLASS(NDUIItemButton))) 
	{
		int nTag = button->GetTag();
		if (nTag < ID_BUTTON_AMULDT1 || nTag > ID_BUTTON_SHOES) {
			return false;
		}
		Item* item = ((NDUIItemButton*)button)->GetItem();
		if (!item) {
			return false;
		}
		
		NDPicture* pPic = ItemImage::GetItemByIconIndex(item->getIconIndex(), ((NDUIItemButton*)button)->IsGray());
		if (!pPic) {
			return false;
		}
		if (m_pImageMouse) {
			pPic->SetGrayState(((NDUIItemButton*)button)->IsGray());
			
			m_pImageMouse->SetPicture(pPic);
			
			CGSize rSize = pPic->GetSize();
			CGRect rRect = this->GetScreenRect();
			m_pImageMouse->SetFrameRect(CGRectMake(moveTouch.x-rSize.width/2-rRect.origin.x, moveTouch.y-rSize.height/2-rRect.origin.y, pPic->GetSize().width, pPic->GetSize().height));
			return true;
		}
	}
	
	return false;
}

bool CUIPetEquip::OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange)
{
	if (m_pImageMouse) {
		m_pImageMouse->SetPicture(NULL, true);
	}
	return false;
}

bool CUIPetEquip::OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch)
{
	if (!(desButton && uiSrcNode && desButton != uiSrcNode)) {
		return true;
	}
	if (!uiSrcNode->IsKindOfClass(RUNTIME_CLASS(NDUIItemButton))) {
		return true;
	}
		
	if (desButton == m_pBtnRoleBg || desButton->IsKindOfClass(RUNTIME_CLASS(NDUIItemButton)))
	{
		if (uiSrcNode->GetParent() == this) {
			return true;
		}

		Item* pItem = ((NDUIItemButton*)uiSrcNode)->GetItem();
		if (!pItem) {
			return true;
		}
		if (pItem->isItemPet()) {
			ItemMgrObj.UseItem(pItem);
		}
		else {
			if (m_idFocusPet) {
				if (pItem->isEquip() && !this->CheckItemLimit(pItem, true)) {
					return true;
				}
				ShowProgressBar;
				NDTransData bao(_MSG_PET_ACTION);
				bao << int(m_idFocusPet) << (int)MSG_PET_ACTION_USEITEM << int(pItem->iID);
				SEND_DATA(bao);
			}
		}
	}
	return true;
}

void CUIPetEquip::SetVisible(bool bVisible)
{
	NDUILayer::SetVisible(bVisible);
	if (bVisible) {
		this->UpdateButton();
	}
}

void CUIPetEquip::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (dialog->GetTag() == DIALOG_TAG_CLOSE) 
	{
		NDTransData bao(_MSG_PET_ACTION);
		bao << (int)m_idFocusPet << int(MSG_PET_ACTION_DROP) << int(0);
		SEND_DATA(bao);
		ShowProgressBar;
	}
	dialog->Close();
}

void CUIPetEquip::UpdateFocusPet(OBJID idPet)
{
	if (idPet && idPet != m_idFocusPet) {
		if (!this->IsExistPetInVec(idPet)) {
			m_vecIdPet.push_back(idPet);
		}
		m_idFocusPet = idPet;
	}
	if (m_idFocusPet) {
		PetInfo* petInfo = PetMgrObj.GetPet(m_idFocusPet);
		if (!petInfo || ((petInfo->data.int_PET_ATTR_POSITION&PET_POSITION_BAG) && m_bEnable)){
			OBJID idPet = this->GetNextPetId();
			this->DelPetId(m_idFocusPet);
			if (idPet == m_idFocusPet) {
				m_idFocusPet = 0;
			}
			else {
				m_idFocusPet = idPet;
			}
		}
	}
	else if (!m_vecIdPet.empty()){
		m_idFocusPet = m_vecIdPet[0];
	}

	this->UpdateName();
	this->UpdateEquip();
	this->UpdateExpHpMp();
	this->UpdateButton();
	this->UpdatePetNode();
}

void CUIPetEquip::UpdatePosition()
{
	if (!m_idFocusPet) {
		return;
	}
	this->UpdateButton();
}

void CUIPetEquip::UpdateName()
{
	NDString strName;
	NDString strPost;
	NDString strLevel;
	NDString strQuality;
	NDString strTrait;
	if (m_idFocusPet) {
		PetInfo* petInfo = PetMgrObj.GetPet(m_idFocusPet);
		if (!petInfo){
			return;
		}
		strName = petInfo->str_PET_ATTR_NAME;
		if (petInfo->data.int_PET_ATTR_POSITION & PET_POSITION_MAIN) {
			strPost = NDCommonCString("MainPet");
		}

		strLevel.Format("%s:%d", NDCommonCString("level"), petInfo->data.int_PET_ATTR_LEVEL);
		strQuality	= NDItemType::PETPINZHI(petInfo->GetQuality());
		strTrait = getPetType(petInfo->data.int_PET_ATTR_TYPE);
		unsigned int unClr = CPetMgr::getPetQualityColor(petInfo->data.int_PET_ATTR_TYPE);
		m_pLabelQuality->SetFontColor(INTCOLORTOCCC4(unClr));
	}
	m_pLabelName->SetText(strName.getData());
	m_pLabelPost->SetText(strPost.getData());
	m_pLabelLevel->SetText(strLevel.getData());
	m_pLabelQuality->SetText(strQuality.getData());
	m_pLabelTrait->SetText(strTrait.getData());
}
void CUIPetEquip::UpdateEquip()
{
	ID_VEC vecItemId;
	if (m_idFocusPet) {
		PetInfo* petInfo = PetMgrObj.GetPet(m_idFocusPet);
		if (!petInfo){
			return;
		}
//		PetInfo::PetData& petData = petInfo->data;
	}
	
	for (MAP_BUTTON::iterator iter = m_mapButton.begin(); iter != m_mapButton.end(); iter++) {
		NDUIItemButton* pBtn = iter->second;
		if (!pBtn) {
			continue;
		}
		NDPicture* pPicBtn = NULL;
		pPicBtn = ItemImage::GetItem(this->GetIconIndex(iter->first), true);
		if (!pPicBtn)
		{
			continue;
		}
		pPicBtn->SetColor(ccc4(215, 171, 108, 150));
		pPicBtn->SetGrayState(true);
	
		pBtn->SetDefaultItemPicture(pPicBtn);
	}
}

void CUIPetEquip::UpdateExpHpMp()
{
	int nHp		= 0;
	int nHpMax	= 0;
	int nMp		= 0;
	int nMpMax	= 0;
	int nExp	= 0;
	int nExpMax	= 0;
	if (m_idFocusPet) {
		PetInfo* petInfo = PetMgrObj.GetPet(m_idFocusPet);
		if (!petInfo){
			return;
		}
		PetInfo::PetData& petData = petInfo->data;
		nHp		= petData.int_PET_ATTR_LIFE;
		nHpMax	= petData.int_PET_ATTR_MAX_LIFE;
		nMp		= petData.int_PET_ATTR_MANA;
		nMpMax	= petData.int_PET_ATTR_MAX_MANA;
		nExp	= petData.int_PET_ATTR_EXP;
		nExpMax	= petData.int_PET_ATTR_LEVEUP_EXP;
	}
	NDString strHp;
	strHp.Format("Hp:%d/%d", nHp, nHpMax);
	NDString strMp;
	strMp.Format("Mp:%d/%d", nMp, nMpMax);
	m_pLabelHp->SetText(strHp.getData());
	m_pLabelMp->SetText(strMp.getData());
	m_stateBarExp->SetNumber(nExp, nExpMax);
}

void CUIPetEquip::UpdatePetNode()
{
	if (!m_pPetNode) return;
	
	m_pPetNode->ChangePet(m_idFocusPet);
}

void CUIPetEquip::UpdateButton()
{
	if (!this->IsVisibled()) {
		return;
	}
	m_pBtnMainPlayed->SetVisible(false);
	m_pBtnRest->SetVisible(false);
	m_pBtnPlayed->SetVisible(false);
	m_pBtnIn->SetVisible(false);
	m_pBtnOut->SetVisible(false);
	m_pBtnDel->SetVisible(false);
	m_pBtnDisboard->SetVisible(false);
	m_pBtnShow->SetVisible(false);
	
	if (!m_bEnable || !m_idFocusPet) {
		return;
	}
	PetInfo* petInfo = PetMgrObj.GetPet(m_idFocusPet);
	if (!petInfo){
		return;
	}
	PetInfo::PetData& petData = petInfo->data;
	int nPos = petData.int_PET_ATTR_POSITION;
	
	
	CGSize rSize = this->GetFrameRect().size;
	int nStartX = MARGIN_L;
	int nStartY = rSize.height - (MARGIN_B + BUTTON_H*2 + BUTTON_INTERVAL_H);
	
	if (!(PET_POSITION_MAIN & nPos)) {	// 是否主将
		m_pBtnMainPlayed->SetVisible(m_bEnable);
		m_pBtnMainPlayed->SetFrameRect(CGRectMake(nStartX, nStartY, BUTTON_W, BUTTON_H));
		this->NextButtonXY(rSize.width, nStartX, nStartY);
	}

	if (PET_POSITION_FIGHT & nPos) {
		m_pBtnRest->SetVisible(m_bEnable);
		m_pBtnRest->SetFrameRect(CGRectMake(nStartX, nStartY, BUTTON_W, BUTTON_H));
	}
	else {
		m_pBtnPlayed->SetVisible(m_bEnable);
		m_pBtnPlayed->SetFrameRect(CGRectMake(nStartX, nStartY, BUTTON_W, BUTTON_H));
	}
	this->NextButtonXY(rSize.width, nStartX, nStartY);
	
	if (PET_POSITION_SHOW & nPos) {
		m_pBtnIn->SetVisible(m_bEnable);
		m_pBtnIn->SetFrameRect(CGRectMake(nStartX, nStartY, BUTTON_W, BUTTON_H));
	}
	else {
		m_pBtnOut->SetVisible(m_bEnable);
		m_pBtnOut->SetFrameRect(CGRectMake(nStartX, nStartY, BUTTON_W, BUTTON_H));
	}
	this->NextButtonXY(rSize.width, nStartX, nStartY);
	
	m_pBtnDel->SetVisible(m_bEnable);
	m_pBtnDel->SetFrameRect(CGRectMake(nStartX, nStartY, BUTTON_W, BUTTON_H));
	this->NextButtonXY(rSize.width, nStartX, nStartY);
	
	if (PET_POSITION_BAG & nPos) {

	}
	else {
		m_pBtnDisboard->SetVisible(m_bEnable);
		m_pBtnDisboard->SetFrameRect(CGRectMake(nStartX, nStartY, BUTTON_W, BUTTON_H));
		this->NextButtonXY(rSize.width, nStartX, nStartY);
	}
	
	m_pBtnShow->SetVisible(m_bEnable);
	m_pBtnShow->SetFrameRect(CGRectMake(nStartX, nStartY, BUTTON_W, BUTTON_H));
}

int CUIPetEquip::GetIconIndex(int nPos)
{
	int index = -1;
	switch (nPos) {
		case ID_BUTTON_AMULDT1:
			index = 1+6;
			break;
		case ID_BUTTON_ARMOR:
			index = 0;
			break;
		case ID_BUTTON_AMULDT2:
			index = 1+6;
			break;
		case ID_BUTTON_HEAD:
			index = 5*6;
			break;
		case ID_BUTTON_DLOTHES:
			index = 1+5*6;
			break;
		case ID_BUTTON_SHOES:
			index = 6*6;
			break;
		default:
			break;
	}
	
	return index;
}


bool CUIPetEquip::CheckItemLimit(Item* item, bool isShow)
{
	if (!item)
	{
		return false;
	}
	
	stringstream sb;
	NDPlayer &player = NDPlayer::defaultHero();
	int levelLimit = item->getReq_level(); // 等级限制
	int selfLimit = player.level;
	if (selfLimit < levelLimit) {
		sb << NDCommonCString("LevelRequire") << levelLimit << "(" << NDCommonCString("current") << selfLimit << ")\n";
	}
	
	int req_phy = item->getReq_phy(); // 力量限制
	int self_phy = player.phyPoint;
	if (self_phy < req_phy) {
		sb <<  NDCommonCString("LiLiangXuQiu") << req_phy << "(" << NDCommonCString("current") << self_phy << ")\n";
	}
	int req_dex = item->getReq_dex(); // 敏捷限制
	int self_dex = player.dexPoint;
	if (self_dex < req_dex) {
		sb << NDCommonCString("MingJieXuQiu") << req_dex << "(" << NDCommonCString("current") << self_dex << ")\n";
	}
	
	int req_mag = item->getReq_mag(); // 智力限制
	int self_mag = player.magPoint;
	if (self_mag < req_mag) {
		sb << NDCommonCString("ZhiLiXuQiu") << req_mag << "(" << NDCommonCString("current") << self_mag << ")\n";
	}
	
	int req_def = item->getReq_def(); // 体质限制
	int self_def = player.defPoint;
	if (self_def < req_def) {
		sb << NDCommonCString("TiZhiXuQiu") << req_def << "(" << NDCommonCString("current") << self_def << ")";
	}
	
	std::string str = sb.str();
	if (!str.empty()) {
		if (isShow) {
			NDUIDialog *dlg = new NDUIDialog;
			dlg->Initialization();
			dlg->Show(NDCommonCString("NoUpToEquip"), str.c_str(), NULL, NULL);
		}
		return false;
	}
	
	return true;
}

NDUIButton* CUIPetEquip::CreateButton(const char* pszTitle)
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
	pBtn->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_btn_normal.png")),
							   pool.AddPicture(NDPath::GetImgPathNew("bag_btn_click.png")),
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

void CUIPetEquip::NextButtonXY(int nWidth, int& nX, int& nY)
{
	nX += BUTTON_W + BUTTON_INTERVAL_W;
	if (nX > nWidth - BUTTON_W - MARGIN_R) {
		nX = MARGIN_L;
		nY += BUTTON_H + BUTTON_INTERVAL_H;
	}
}

OBJID CUIPetEquip::GetLastPetId()
{
	OBJID idPet = m_idFocusPet;
	if (m_vecIdPet.size() >= 2) {
		for (ID_VEC::reverse_iterator iter = m_vecIdPet.rbegin(); iter != m_vecIdPet.rend(); iter++) {
			ID_VEC::reverse_iterator itLast = iter + 1;
			if (m_idFocusPet == *iter) {
				if (itLast == m_vecIdPet.rend()) {
					idPet = *(m_vecIdPet.rbegin());
				}
				else {
					idPet = *itLast;
				}
				break;
			}
		}
	}
	return idPet;
}

OBJID CUIPetEquip::GetNextPetId()
{
	OBJID idPet = m_idFocusPet;
	if (m_vecIdPet.size() >= 2) {
		for (ID_VEC::iterator iter = m_vecIdPet.begin(); iter != m_vecIdPet.end(); iter++) {
			ID_VEC::iterator itNext = iter + 1;
			if (m_idFocusPet == *iter) {
				if (itNext == m_vecIdPet.end()) {
					idPet = *(m_vecIdPet.begin());
				}
				else {
					idPet = *itNext;
				}
				break;
			}
		}
	}
	return idPet;
}

bool CUIPetEquip::DelPetId(OBJID idPet)
{
	for (ID_VEC::iterator iter = m_vecIdPet.begin(); iter != m_vecIdPet.end(); iter++) {
		if (idPet == *iter) {
			m_vecIdPet.erase(iter);
			return true;
		}
	}
	return false;
}

bool CUIPetEquip::IsExistPetInVec(OBJID idPet)
{
	for (ID_VEC::iterator iter = m_vecIdPet.begin(); iter != m_vecIdPet.end(); iter++) {
		if (idPet == *iter) {
			return true;
		}
	}
	return false;
}