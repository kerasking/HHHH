/*
 *  NewPetScene.cpp
 *  DragonDrive
 *
 *  Created by xwq on 12-1-12.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "NewPetScene.h"
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
#include "NDPath.h"
#import "PlayerInfoScene.h"
#include <sstream>


using namespace NDEngine;
//////////////////////////////////////////////////////////////////////

IMPLEMENT_CLASS(CUIPetTip, NDUILayer)

CUIPetTip::CUIPetTip()
{
	m_pLabelTitle	= NULL;
	m_pLabelTip		= NULL;
}

CUIPetTip::~CUIPetTip()
{
}

bool CUIPetTip::Init(int nWidth)
{
	NDUILayer::Initialization();
	
	NDPicture* pPicBg = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_bag_bg.png"), nWidth, 279);
	if (!pPicBg) {
		return false;
	}
	CGSize rSize = pPicBg->GetSize();
	this->SetFrameRect(CGRectMake(200, 4, nWidth, rSize.height));
	this->SetBackgroundImage(pPicBg, true);
	
	m_pLabelTitle = new NDUILabel;
	m_pLabelTitle->Initialization();
	m_pLabelTitle->SetFontSize(14);
	m_pLabelTitle->SetFontColor(ccc4(0, 0, 0, 255));
	m_pLabelTitle->SetFrameRect(CGRectMake(rSize.width/2-30, 10, 60, 20));
	m_pLabelTitle->SetText(NDCommonCString("tip"));
	this->AddChild(m_pLabelTitle);
	
	m_pLabelTip = new NDUILabelScrollLayer;
	m_pLabelTip->Initialization();
	m_pLabelTip->SetFrameRect(CGRectMake(10, 30, rSize.width - 20, rSize.height - 40));
	
	NDString strText1, strText2, strText3, strText4, strText5, strText6, strText7, strText;
	strText1.Format(NDCommonCString("PetTip1"), "\n    ");
	strText2.Format(NDCommonCString("PetTip2"), "\n    ");
	strText3.Format(NDCommonCString("PetTip3"), "\n    ");
	strText4.Format(NDCommonCString("PetTip4"), "\n    ");
	strText5.Format(NDCommonCString("PetTip5"), "\n    ");
	strText6.Format(NDCommonCString("PetTip6"), "\n    ");
	strText7.Format(NDCommonCString("PetTip7"), "\n    ");
	strText.Format("%s\n%s\n%s\n%s\n%s\n%s\n%s\n"
				   , strText1.getData()
				   , strText2.getData()
				   , strText3.getData()
				   , strText4.getData()
				   , strText5.getData()
				   , strText6.getData()
				   , strText7.getData());
	m_pLabelTip->SetText(strText.getData());
	this->AddChild(m_pLabelTip);
	
	return true;
}

//////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(CUIPet, NDUILayer)
CUIPet::CUIPet()
{
	m_pTip			= NULL;
	m_pPetEquip		= NULL;
	m_pPetAttr		= NULL;
	m_pPetPart		= NULL;
	m_pPetSkillInfo	= NULL;
	m_pPetSkill		= NULL;
	m_pPetBag		= NULL;
	m_pItemInfo		= NULL;
	
	m_pFocusLayer	= NULL;
	m_nSkillInfoIndex = 9999999;
}

CUIPet::~CUIPet()
{
}

bool CUIPet::Init(OBJID idUser, OBJID idFocusPet, bool bEnable)
{
	NDUILayer::Initialization();
	
	// 宠物装备
	m_pPetEquip = new CUIPetEquip();
	if (!m_pPetEquip) {
		return false;
	}
	m_pPetEquip->Init();
	m_pPetEquip->Update(idUser, idFocusPet, bEnable);
	m_pPetEquip->SetDelegate(this);
	this->AddChild(m_pPetEquip);
	
	// 
	m_idUser	= idUser;
	m_bEnable	= bEnable;
	
	NDFuncTab *pTab = new NDFuncTab;
	if (!pTab) {
		return false;
	}
	int nTabCount = bEnable ? 4 : 3;
	pTab->Initialization(nTabCount, CGPointMake(200, 5));
	pTab->SetDelegate(this);
	int i = 0;
	this->AddAttrInTab(pTab, i++);
	this->AddPartInTab(pTab, i++);
	this->AddSkillInTab(pTab, i++);
	int nBagIndex = 0;
	if (bEnable) {
		nBagIndex	= i;
		this->AddBagInTab(pTab, i++);
	}
	this->AddChild(pTab);
	
	// 技能信息
	m_pPetSkillInfo = new CUIPetSkillInfo();
	if (!m_pPetSkillInfo) {
		return false;
	}
	m_pPetSkillInfo->Init();
	m_pPetSkillInfo->EnableOperate(bEnable);
	this->AddChild(m_pPetSkillInfo);
	m_pPetSkillInfo->SetDelegate(this);
	
	m_pItemInfo		= new CUIItemInfo();
	if (!m_pItemInfo) {
		return false;
	}
	m_pItemInfo->Init();
	m_pItemInfo->EnableOperate(bEnable);
	this->AddChild(m_pItemInfo);
	m_pItemInfo->SetDelegate(this);
	
	if (m_pPetBag && m_pPetEquip->GetFocusPetId() == 0) {
		pTab->SetTabFocusOnIndex(nBagIndex);
	}
	
	m_pTip	= new CUIPetTip;
	m_pTip->Init(257);
	this->AddChild(m_pTip);
	
	pTab->SetTabFocusOnIndex(i, false);
	m_pFocusLayer	= m_pPetEquip;
	this->UpdateFocusLayer();
	return true;
}

void CUIPet::UpdateUI(OBJID idPet)
{
	if (!m_pPetEquip) {
		return;
	}
	m_pPetEquip->UpdateFocusPet(idPet);
	
	this->RefreshAttrData();
	this->RefreshPartData();
	this->RefreshSkillData();
	this->RefreshSkillInfoData();
	
	this->UpdateFocusLayer();
	CloseProgressBar;
}

void CUIPet::PetBagAddItem(OBJID idItem)
{
	if (m_pPetBag) {
		Item* pItem = ItemMgrObj.QueryItem(idItem);
		if (pItem) {
			if ((pItem->IsPetUseItem() || pItem->isItemPet())
				&& !pItem->IsPetSkillItem()) {
				m_pPetBag->AddItem(pItem);
				CloseProgressBar;
			}
		}
	}
}

void CUIPet::PetBagDelItem(OBJID idItem)
{
	if (m_pPetBag) {
		m_pPetBag->DelItem(idItem);
		CloseProgressBar;
	}
}

void CUIPet::PetBagItemCount(OBJID idItem)
{
	if (m_pPetBag) {
		Item* pItem = ItemMgrObj.QueryItem(idItem);
		if (pItem) {
			m_pPetBag->SetItemAmount(pItem, pItem->iAmount);
		}
		CloseProgressBar;
	}
}

void CUIPet::UpdateSkillItemDesc(OBJID idItem, std::string& strDesc)
{
	if (m_pPetSkillInfo) {
		m_pPetSkillInfo->UpdateSkillItemDesc(idItem, strDesc);
		CloseProgressBar;
	}
}

void CUIPet::SetVisible(bool bVisible)
{
	NDUILayer::SetVisible(bVisible);
	if (bVisible) {
		this->UpdateFocusLayer();
	}
}

void CUIPet::OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex)
{
	if (m_pTip) {
		this->RemoveChild(m_pTip, false);
		SAFE_DELETE(m_pTip);
		m_pFocusLayer	= m_pPetEquip;
		this->UpdateFocusLayer();
	}
	else {
		if (curIndex != m_nSkillInfoIndex && m_pFocusLayer != m_pPetEquip) {
			m_pFocusLayer	= m_pPetEquip;
			this->UpdateFocusLayer();
		}
	}
}

bool CUIPet::AddAttrInTab(NDFuncTab *pTab, int nIndex)
{
	if (!pTab) {
		return false;
	}
	TabNode* pTabNode = pTab->GetTabNode(nIndex);
	if (!pTabNode) {
		return false;
	}
	
	this->SetTabNodePic(pTabNode, 18*4);
	
	m_pPetAttr = new CUIPetAttr;
	if (!m_pPetAttr){
		return false;
	}
	
	m_pPetAttr->Initialization();
	m_pPetAttr->SetDelegate(this);
	pTab->GetClientLayer(nIndex)->AddChild(m_pPetAttr);
	this->RefreshAttrData();
	
	return true;
}

bool CUIPet::AddPartInTab(NDFuncTab *pTab, int nIndex)
{
	if (!pTab) {
		return false;
	}
	TabNode* pTabNode = pTab->GetTabNode(nIndex);
	if (!pTabNode) {
		return false;
	}
	
	this->SetTabNodePic(pTabNode, 18*5);
	
	m_pPetPart	= new CUIPetPart;
	if (!m_pPetPart) {
		return false;
	}
	
	m_pPetPart->Initialization();
	m_pPetPart->SetDelegate(this);
	pTab->GetClientLayer(nIndex)->AddChild(m_pPetPart);
	this->RefreshPartData();
	
	return true;
}

bool CUIPet::AddSkillInTab(NDFuncTab *pTab, int nIndex)
{
	if (!pTab) {
		return false;
	}
	TabNode* pTabNode = pTab->GetTabNode(nIndex);
	if (!pTabNode) {
		return false;
	}
	
	this->SetTabNodePic(pTabNode, 18*24);
	
	NDUIClientLayer* pClient = pTab->GetClientLayer(nIndex);
	if (!pClient) {
		return false;
	}
	
	CGSize sizeClient = pClient->GetFrameRect().size;
	m_pPetSkill = new CUIPetSkill;
	m_pPetSkill->Init();
	m_pPetSkill->SetDelegate(this);
	m_pPetSkill->SetFrameRect(CGRectMake(0, 0, sizeClient.width, sizeClient.height));
	pClient->AddChild(m_pPetSkill);
	m_nSkillInfoIndex = nIndex;
	this->RefreshSkillData();
	return true;
}

bool CUIPet::AddBagInTab(NDFuncTab *pTab, int nIndex)
{
	if (!pTab) {
		return false;
	}
	TabNode* pTabNode = pTab->GetTabNode(nIndex);
	if (!pTabNode) {
		return false;
	}
	
	this->SetTabNodePic(pTabNode, 18*23);
	
	m_pPetBag	= new NewGamePetBag;
	if (!m_pPetBag) {
		return false;
	}
	VEC_ITEM vecItem;
	this->GetPetItems(vecItem);
	m_pPetBag->Initialization(vecItem);
	m_pPetBag->SetDelegate(this);
	m_pPetBag->SetFrameRect(CGRectMake(5, 0, 275, 240));
	m_pPetBag->SetPageCount(ItemMgrObj.GetPlayerBagNum());
	pTab->GetClientLayer(nIndex)->AddChild(m_pPetBag);
	
	return true;
}

bool CUIPet::SetTabNodePic(TabNode* pTabNode, int nStartX)
{
	if (!pTabNode) {
		return false;
	}
	
	NDPicture *pPic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("newui_text.png"));
	NDPicture *pPicFocus = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("newui_text.png"));
	if (!pPic || !pPicFocus) {
		return false;
	}
	pPic->Cut(CGRectMake(nStartX, 36, 18, 36));
	pPicFocus->Cut(CGRectMake(nStartX, 0, 18, 36));
	pTabNode->SetTextPicture(pPic, pPicFocus);
	return true;
}

void CUIPet::UpdateFocusLayer()
{
	if (!this->IsVisibled()) {
		return;
	}
	
	if (m_pPetSkillInfo && m_pPetSkillInfo != m_pFocusLayer) {
		m_pPetSkillInfo->SetVisible(false);
	}
	if (m_pPetEquip && m_pPetEquip != m_pFocusLayer) {
		m_pPetEquip->SetVisible(false);
	}
	if (m_pItemInfo && m_pItemInfo != m_pFocusLayer) {
		m_pItemInfo->SetVisible(false);
	}
	
	if (m_pFocusLayer) {
		m_pFocusLayer->SetVisible(true);
	}
}

void CUIPet::GetPetItems(VEC_ITEM& vecItem)
{
	VEC_ITEM& vecBagItem = ItemMgrObj.GetPlayerBagItems();
	for (VEC_ITEM::iterator iter = vecBagItem.begin(); iter != vecBagItem.end(); iter++) {
		if (((*iter)->IsPetUseItem() || (*iter)->isItemPet()) 
			&& !(*iter)->IsPetSkillItem()) {
			vecItem.push_back(*iter);
		}
	}
}

void CUIPet::GetPetSkillItems(ID_VEC& vecItem)
{
	VEC_ITEM& vecBagItem = ItemMgrObj.GetPlayerBagItems();
	for (VEC_ITEM::iterator iter = vecBagItem.begin(); iter != vecBagItem.end(); iter++) {
		if ((*iter)->IsPetSkillItem()) {
			vecItem.push_back((*iter)->iID);
		}
	}
}

void CUIPet::RefreshAttrData()
{
	if (m_pPetAttr && m_pPetEquip) {
		m_pPetAttr->Update(m_pPetEquip->GetFocusPetId(), m_bEnable);
	}
}

void CUIPet::RefreshPartData()
{
	if (m_pPetPart && m_pPetEquip) {
		m_pPetPart->Update(m_pPetEquip->GetFocusPetId(), m_bEnable);
	}
}

void CUIPet::RefreshSkillData()
{
	if (m_pPetSkill && m_pPetEquip) {
		m_pPetSkill->Update(m_pPetEquip->GetFocusPetId(), m_bEnable);
		ID_VEC vecItemId;
		if (m_bEnable) {
			this->GetPetSkillItems(vecItemId);
		}
		m_pPetSkill->UpdateSkillItem(vecItemId);
	}
}

void CUIPet::RefreshSkillInfoData()
{
	if (m_pPetSkillInfo && m_pPetSkill && m_pPetEquip) {
		PET_SKILL_BTN_TYPE eType = m_pPetSkill->GetBtnType();
		if (PET_SKILL_BTN_TYPE_EMPTY == eType) {
			m_pPetSkillInfo->RefreshItemSkill(0, false);
		}
		else if (PET_SKILL_BTN_TYPE_LOCK == eType) {
			OBJID idPet = 0;
			if (m_pPetEquip) {
				idPet = m_pPetEquip->GetFocusPetId();
			}
			m_pPetSkillInfo->RefreshLock(idPet);
		}
		else if (PET_SKILL_BTN_TYPE_SKILL == eType) {
			OBJID idSkill = m_pPetSkill->GetSkillId();
			m_pPetSkillInfo->RefreshPetSkill(idSkill, m_pPetSkill->IsLockSkill(idSkill));
		}
		else if (PET_SKILL_BTN_TYPE_ITEM == eType) {
			m_pPetSkillInfo->RefreshItemSkill(m_pPetSkill->GetItemId(), m_pPetEquip->GetFocusPetId() ? true : false);
		}
	}
}

void CUIPet::UpdateSkillInfo()
{
	if (m_pPetSkillInfo) {
		this->RefreshSkillInfoData();
		
		m_pFocusLayer = m_pPetSkillInfo;
		this->UpdateFocusLayer();
	}
}

void CUIPet::CloseSkillInfo()
{
	m_pFocusLayer = m_pPetEquip;
	this->UpdateFocusLayer();
}

void CUIPet::LockSkill(OBJID idSkill)
{
	if (m_pPetSkill) {
		m_pPetSkill->LockSkill(idSkill);
	}
}

void CUIPet::UnLockSkill(OBJID idSkill)
{
	if (m_pPetSkill) {
		m_pPetSkill->UnLockSkill(idSkill);
	}
}

void CUIPet::LearnSkill()
{
	if (m_pPetSkill) {
		m_pPetSkill->LearnSkill();
	}
}

void CUIPet::UpdateBagItemInfo()
{
	if (m_pItemInfo && m_pPetBag) {
		if (m_pPetBag->GetFocusItem()) {
			m_pItemInfo->RefreshItemInfo(m_pPetBag->GetFocusItem());
			m_pFocusLayer = m_pItemInfo;
		}
		else {
			m_pFocusLayer = m_pPetEquip;
		}
		this->UpdateFocusLayer();
	}
}

void CUIPet::UseItem()
{
	if (m_pPetBag && m_pPetEquip) {
		Item* pItem = m_pPetBag->GetFocusItem();
		if (!pItem) {
			return;
		}
		m_pPetBag->SendUseItemMsg(m_pPetEquip->GetFocusPetId(), pItem->iID);
	}
}

void CUIPet::DropItem()
{
	if (m_pPetBag) {
		Item* pItem = m_pPetBag->GetFocusItem();
		if (!pItem) {
			return;
		}
		m_pPetBag->SendDropItemMsg(pItem->iID);
	}
}

void CUIPet::CloseBagItemInfo()
{
	m_pFocusLayer = m_pPetEquip;
	this->UpdateFocusLayer();
}

OBJID CUIPet::GetFocusPetId()
{
	if (m_pPetEquip) {
		return m_pPetEquip->GetFocusPetId();
	}
	return 0;
}

void CUIPet::ChangePet()
{
	if (!m_pPetEquip) {
		return;
	}
	
	this->RefreshAttrData();
	this->RefreshPartData();
	this->RefreshSkillData();
	this->RefreshSkillInfoData();
	
	this->UpdateFocusLayer();
}