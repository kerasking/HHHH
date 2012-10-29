/*
 *  UiPetAttr.cpp
 *  DragonDrive
 *
 *  Created by xwq on 12-1-14.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "UiPetAttr.h"

/*
 *  CUIPetAttr.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "UiPetAttr.h"
#include <sstream>
#include <string>
#include "NDPlayer.h"
#import "NDPicture.h"
#import "NDManualRole.h"
#import "NDUILabel.h"
#import "NDUIButton.h"
#import "NDDirector.h"
#import "CGPointExtension.h"
#import "NDUIBaseGraphics.h"
#import "NDUITableLayer.h"
#import "NDUIImage.h"
#import "define.h"
#import "NDConstant.h"
#import "ItemMgr.h"
#import "EnumDef.h"
#import "NDMsgDefine.h"
#import "NDDataTransThread.h"
#import "GameScene.h"
#import "NDUtility.h"
#include "NDPath.h"
#import "PlayerInfoScene.h"
#include "NDMapMgr.h"
#include "GameUIAttrib.h"
#include "CPet.h"
/////////////////////////////////////////////////////////

string strBasic[CUIPetAttr::ePAB_End][2] = 
{
	{NDCommonCString("Liliang"), NDCommonCString("LiLiangAttrTip")}, 
	{NDCommonCString("TiZhi"), NDCommonCString("TiZhiAttrTip")}, 
	{NDCommonCString("MingJie"), NDCommonCString("MingJieAttrTip")},
	{NDCommonCString("ZhiLi"), NDCommonCString("ZhiLiAttrTip")},
};


/////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(CUIPetAttr, NDUILayer)

CUIPetAttr::CUIPetAttr()
{
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		m_pointFrame[ePointState] = NULL;
		
		m_btnPointTxt[ePointState] = NULL;
		
		m_btnPointMinus[ePointState] = NULL;
		
		m_btnPointPlus[ePointState] = NULL;
		
		m_btnPointCur[ePointState] = NULL;	
		
		m_picPointMinus[ePointState][0] = NULL;
		m_picPointMinus[ePointState][1] = NULL;
		
		m_picPointPlus[ePointState][0] = NULL;
		m_picPointPlus[ePointState][1] = NULL;
	}
	
	m_layerPropAlloc = NULL;
	
	m_lbTotal = NULL;
	
	m_lbAlloc = NULL;
	
	m_btnCommit = NULL;
	
	m_iFocusPointType = _stru_point::ps_end;
	
	m_idPet = 0;
	
	m_bEnableOp = false;
	
	int_PET_ATTR_STR = 0; // 力量INT
	int_PET_ATTR_STA = 0; // 体质INT
	int_PET_ATTR_AGI = 0; // 敏捷INT
	int_PET_ATTR_INI = 0; // 智力INT
	int_ATTR_FREE_POINT = 0; //自由点数
} 

CUIPetAttr::~CUIPetAttr()
{
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		SAFE_DELETE(m_picPointMinus[ePointState][0]);
		SAFE_DELETE(m_picPointMinus[ePointState][1]);
		SAFE_DELETE(m_picPointPlus[ePointState][0]);
		SAFE_DELETE(m_picPointPlus[ePointState][1]);
	}
}

void CUIPetAttr::Update(OBJID idPet, bool bEnable)
{
	m_idPet = idPet;
	m_bEnableOp = bEnable;
	
	setBattlePetValueToPetAttr();
	
	UpdatePoint();
}

void CUIPetAttr::Initialization()
{
	NDUILayer::Initialization();
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	InitPropAlloc();
}

void CUIPetAttr::draw()
{	
}

void CUIPetAttr::OnButtonClick(NDUIButton* button)
{
	if (!m_bEnableOp)
	{
		return;
	}
	
	if ( button == m_btnCommit)
	{
		if (m_struPoint.iAlloc > 0 && m_struPoint.VerifyAllocPoint() ) 
		{
			NDUIDialog* dlg = new NDUIDialog;
			dlg->Initialization();
			dlg->SetDelegate(this);
			std::stringstream str;
			str << NDCommonCString("ModifyAttrTip") << m_struPoint.iTotal - m_struPoint.iAlloc;
			dlg->Show(NDCommonCString("tip"), str.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"),NULL);
		}
	}
	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		if (button->GetParent() && button->GetParent() == m_pointFrame[ePointState]) 
		{
			if (m_pointFrame[ePointState] && !m_pointFrame[ePointState]->IsFocus())
			{
				changePointFocus(ePointState);
				UpdateSlideBar(ePointState);
				return;
			}
			break;
		}
	}
	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		if (m_btnPointMinus[ePointState] == button) 
		{
			if (m_struPoint.iAlloc > 0 && m_struPoint.m_psProperty[ePointState].iPoint >0) 
			{
				m_struPoint.iAlloc -= 1; m_struPoint.m_psProperty[ePointState].iPoint -= 1;
				
				UpdatePorpText(ePointState);
				
				UpdateSlideBar(ePointState);
				
				UpdatePorpAlloc();
			}
		}
	}
	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		if (m_btnPointPlus[ePointState] == button) 
		{
			if (m_struPoint.iTotal >= 1 && m_struPoint.iTotal >= m_struPoint.iAlloc+1) 
			{
				m_struPoint.m_psProperty[ePointState].iPoint += 1;
				m_struPoint.iAlloc += 1;
				
				UpdatePorpText(ePointState);
				
				UpdateSlideBar(ePointState);
				
				UpdatePorpAlloc();
			}
		}
	}
	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		if (m_btnPointTxt[ePointState] == button
			|| m_btnPointCur[ePointState] == button) 
		{
			showDialog(strBasic[ePointState][0].c_str(), strBasic[ePointState][1].c_str());
			return;
		}
	}
}

void CUIPetAttr::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	dialog->Close();
	if (buttonIndex == 0) {
		this->sendAction();
	}
}

void CUIPetAttr::sendAction() {
	if ( !(m_struPoint.iAlloc > 0 
		   && m_struPoint.iAlloc <= m_struPoint.iTotal
		   && m_struPoint.VerifyAllocPoint()) 
		)
	{
		return;
	}
	
//	Item *itempet = ItemMgrObj.GetEquipItemByPos(Item::eEP_Pet);
//	NDBattlePet *pet = NDPlayer::defaultHero().battlepet;
//	if (!itempet || !pet) 
//	{
//		return;
//	}
	
	//int STR_POINT = 0x01;
	//	int STA_POINT = 0x02;
	//	int AGI_POINT = 0x04;
	//	int INI_POINT = 0x08;
	//int POINT_DEF[_stru_point::ps_end] = { 0x01, 0x04, 0x08, 0x02,};
	int POINT_DEF[_stru_point::ps_end] = { 0x01, 0x02, 0x04, 0x08,};
	NDTransData bao(_MSG_CHG_PET_POINT);
	bao << int(m_idPet);
	int btPointField = 0;
	for (int i = _stru_point::ps_begin; i < _stru_point::ps_end; i++) 
	{
		if (m_struPoint.m_psProperty[i].iPoint > 0) 
		{
			btPointField |= POINT_DEF[i];
		}
	}
	bao << (unsigned char)btPointField;
	for (int i = _stru_point::ps_begin; i < _stru_point::ps_end; i++) 
	{
		if (m_struPoint.m_psProperty[i].iPoint > 0) 
		{
			bao << (unsigned short)(m_struPoint.m_psProperty[i].iPoint);
		}
	}
	SEND_DATA(bao);
	
	NDBattlePet::tmpRestPoint = m_struPoint.iTotal - m_struPoint.iAlloc;
	NDBattlePet::tmpStrPoint = m_struPoint.GetPoint(_stru_point::ps_liliang);
	NDBattlePet::tmpStaPoint = m_struPoint.GetPoint(_stru_point::ps_tizhi);
	NDBattlePet::tmpAgiPoint = m_struPoint.GetPoint(_stru_point::ps_minjie);
	NDBattlePet::tmpIniPoint = m_struPoint.GetPoint(_stru_point::ps_zhili);
	int_ATTR_FREE_POINT = NDBattlePet::tmpRestPoint;
	int_PET_ATTR_STR = NDBattlePet::tmpStrPoint;
	int_PET_ATTR_STA = NDBattlePet::tmpStaPoint;
	int_PET_ATTR_AGI = NDBattlePet::tmpAgiPoint;
	int_PET_ATTR_INI = NDBattlePet::tmpIniPoint;

	UpdatePoint();
}

void CUIPetAttr::UpdatePoint()
{
	UpdateStrucPoint();
	
	for (int i =_stru_point::ps_begin; i<_stru_point::ps_end; i++) 
	{
		UpdatePorpText(i);
		SetPropTextFocus(i, i == m_iFocusPointType);
	}
	
	if (m_lbTotal)
	{
		std::stringstream ss; ss << m_struPoint.iTotal;
		m_lbTotal->SetText(ss.str().c_str());
	}
	
	if (m_lbAlloc)
	{
		std::stringstream ss; ss << m_struPoint.iAlloc;
		m_lbAlloc->SetText(ss.str().c_str());
	}
	
	UpdateSlideBar(m_iFocusPointType);
}

void CUIPetAttr::setBattlePetValueToPetAttr()
{	
	PetInfo* petInfo = PetMgrObj.GetPet(m_idPet);
	if (!petInfo){
		int_PET_ATTR_STR = 0; // 力量INT
		int_PET_ATTR_STA = 0; // 体质INT
		int_PET_ATTR_AGI = 0; // 敏捷INT
		int_PET_ATTR_INI = 0; // 智力INT
		int_ATTR_FREE_POINT = 0; // 自由点数
	}
	else
	{
		PetInfo::PetData& pet = petInfo->data;
		
		int_PET_ATTR_STR = pet.int_PET_ATTR_STR; // 力量INT
		int_PET_ATTR_STA = pet.int_PET_ATTR_STA; // 体质INT
		int_PET_ATTR_AGI = pet.int_PET_ATTR_AGI; // 敏捷INT
		int_PET_ATTR_INI = pet.int_PET_ATTR_INI; // 智力INT
		int_ATTR_FREE_POINT = pet.int_ATTR_FREE_POINT; // 自由点数
	}
	
	UpdateStrucPoint();
}

void CUIPetAttr::UpdateStrucPoint()
{
	m_struPoint.reset();
	m_struPoint.iTotal = int_ATTR_FREE_POINT;
	m_struPoint.m_psProperty[_stru_point::ps_liliang].iFix = int_PET_ATTR_STR;
	m_struPoint.m_psProperty[_stru_point::ps_tizhi].iFix = int_PET_ATTR_STA;
	m_struPoint.m_psProperty[_stru_point::ps_minjie].iFix = int_PET_ATTR_AGI;
	m_struPoint.m_psProperty[_stru_point::ps_zhili].iFix = int_PET_ATTR_INI;
	m_struPoint.iAlloc = 0;
}

#pragma mark 新加的
void CUIPetAttr::OnPropSlideBarChange(NDPropSlideBar* bar, int change)
{
	if (bar == m_slideBar)
	{
		m_struPoint.SetAllocPoint(_stru_point::enumPointState(m_iFocusPointType), change);
		
		UpdatePorpText(m_iFocusPointType);
		
		UpdatePorpAlloc();
	}
}

void CUIPetAttr::SetVisible(bool visible)
{
	NDUILayer::SetVisible(visible);
}


bool CUIPetAttr::changePointFocus(int iPointType)
{
	if (iPointType < _stru_point::ps_begin || iPointType >= _stru_point::ps_end )
	{
		return false;
	}
	
	if (m_iFocusPointType == iPointType)
	{
		return false;
	}
	
	if (m_pointFrame[iPointType])
		m_pointFrame[iPointType]->SetLayerFocus(true);
	if (m_pointFrame[m_iFocusPointType])
		m_pointFrame[m_iFocusPointType]->SetLayerFocus(false);
	
	SetPlusOrMinusPicture(iPointType, true, true);
	SetPlusOrMinusPicture(iPointType, false, true);
	
	SetPlusOrMinusPicture(m_iFocusPointType, true, false);
	SetPlusOrMinusPicture(m_iFocusPointType, false, false);
	
	SetPropTextFocus(iPointType, true);
	SetPropTextFocus(m_iFocusPointType, false);
	
	
	m_iFocusPointType = iPointType;
	
	return true;
}

void CUIPetAttr::AddPropAlloc(NDUINode* parent)
{
	if (!parent || !m_layerPropAlloc) return;
	
	CGSize size = parent->GetFrameRect().size;
	m_layerPropAlloc->SetFrameRect(CGRectMake(0, 0, size.width, size.height));
	
	parent->AddChild(m_layerPropAlloc);
}

void CUIPetAttr::InitPropAlloc()
{
	m_layerPropAlloc = this;
	
	int width = 252;
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDUILayer *layer = new NDUILayer;
	layer->Initialization();
	layer->SetFrameRect(CGRectMake(8, 17, width-10, 18));
	layer->SetBackgroundColor(ccc4(127, 98, 56, 255));
	layer->SetTouchEnabled(false);
	m_layerPropAlloc->AddChild(layer);
	
	NDUILabel *text = new NDUILabel;
	text->Initialization();
	text->SetFontSize(14);
	text->SetFontColor(ccc4(255, 237, 46, 255));
	text->SetTextAlignment(LabelTextAlignmentLeft);
	text->SetText(NDCommonCString("CanAllocAttr"));
	text->SetFrameRect(CGRectMake(7, 2,  width-10, 14));
	layer->AddChild(text);
	
	m_lbTotal = new NDUILabel;
	m_lbTotal->Initialization();
	m_lbTotal->SetFontSize(14);
	m_lbTotal->SetFontColor(ccc4(255, 237, 46, 255));
	m_lbTotal->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbTotal->SetFrameRect(CGRectMake(120, 2, width-10, 14));
	std::stringstream ss; ss << int_ATTR_FREE_POINT;
	m_lbTotal->SetText(ss.str().c_str());
	layer->AddChild(m_lbTotal);
	
	m_lbAlloc = new NDUILabel;
	m_lbAlloc->Initialization();
	m_lbAlloc->SetFontSize(14);
	m_lbAlloc->SetFontColor(ccc4(255, 237, 46, 255));
	m_lbAlloc->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbAlloc->SetFrameRect(CGRectMake(120+69, 2, width-10, 14));
	m_lbAlloc->SetText("0");
	layer->AddChild(m_lbAlloc);
	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		m_picPointMinus[ePointState][0] = pool.AddPicture(NDPath::GetImgPathNew("minu_normal.png"));
		m_picPointMinus[ePointState][1] = pool.AddPicture(NDPath::GetImgPathNew("minu_selected.png"));
		m_picPointPlus[ePointState][0] = pool.AddPicture(NDPath::GetImgPathNew("plus_normal.png"));
		m_picPointPlus[ePointState][1] = pool.AddPicture(NDPath::GetImgPathNew("plus_selected.png"));
		
		m_pointFrame[ePointState] = new NDPropAllocLayer;
		m_pointFrame[ePointState]->Initialization(CGRectMake(5,52+(5+27)*ePointState,238,27));
		
		m_layerPropAlloc->AddChild(m_pointFrame[ePointState]);
	}
	
	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		m_btnPointTxt[ePointState] = new NDUIButton();
		m_btnPointTxt[ePointState]->Initialization();
		m_btnPointTxt[ePointState]->SetFrameRect(CGRectMake(4, 4, 48, 19));
		m_btnPointTxt[ePointState]->SetFontColor(ccc4(255, 255, 255, 255));
		m_btnPointTxt[ePointState]->SetFontSize(13);
		m_btnPointTxt[ePointState]->SetTitle(strBasic[ePointState][0].c_str());
		m_btnPointTxt[ePointState]->CloseFrame();
		m_btnPointTxt[ePointState]->SetDelegate(this);
		m_pointFrame[ePointState]->AddChild(m_btnPointTxt[ePointState]);
	}
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		m_btnPointMinus[ePointState] = new NDUIButton();
		m_btnPointMinus[ePointState]->Initialization();
		CGSize size = m_picPointMinus[ePointState][1]->GetSize();
		m_btnPointMinus[ePointState]->SetFrameRect(CGRectMake(62, 3, size.width, size.height));
		SetPlusOrMinusPicture(ePointState, false, (ePointState==_stru_point::ps_begin));
		m_btnPointMinus[ePointState]->SetDelegate(this);
		m_pointFrame[ePointState]->AddChild(m_btnPointMinus[ePointState]);
	}
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		m_btnPointPlus[ePointState] = new NDUIButton();
		m_btnPointPlus[ePointState]->Initialization();
		CGSize size = m_picPointPlus[ePointState][1]->GetSize();
		m_btnPointPlus[ePointState]->SetFrameRect(CGRectMake(170, 3, size.width, size.height));
		SetPlusOrMinusPicture(ePointState, true, (ePointState==_stru_point::ps_begin));
		m_btnPointPlus[ePointState]->SetDelegate(this);
		m_pointFrame[ePointState]->AddChild(m_btnPointPlus[ePointState]);
	}
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		std::stringstream strDisplay; 
		strDisplay << m_struPoint.m_psProperty[ePointState].iPoint 
		<< "(+" << m_struPoint.m_psProperty[ePointState].iFix << ")";
		
		m_btnPointCur[ePointState] = new NDUIButton();
		m_btnPointCur[ePointState]->Initialization();
		m_btnPointCur[ePointState]->SetFontColor(ccc4(22, 87, 81, 255));
		m_btnPointCur[ePointState]->SetFontSize(13);
		m_btnPointCur[ePointState]->SetTitle(strDisplay.str().c_str());
		m_btnPointCur[ePointState]->CloseFrame();
		m_btnPointCur[ePointState]->SetFrameRect(CGRectMake(82, 0, 88, 27));
		m_btnPointCur[ePointState]->SetDelegate(this);
		m_pointFrame[ePointState]->AddChild(m_btnPointCur[ePointState]);
	}
	
	m_slideBar = new NDPropSlideBar();
	m_slideBar->Initialization(CGRectMake(6, 182, width-12, 45),205);
	m_slideBar->SetMax(int_ATTR_FREE_POINT);
	m_slideBar->SetDelegate(this);
	m_layerPropAlloc->AddChild(m_slideBar);
	
	NDUILayer *layerBtn = new NDUILayer;
	layerBtn->Initialization();
	layerBtn->SetFrameRect(CGRectMake(195, 234, 48,24));	
	m_layerPropAlloc->AddChild(layerBtn);
	
	m_btnCommit = new NDUIButton;
	m_btnCommit->Initialization();
	m_btnCommit->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_btn_normal.png")),
									  pool.AddPicture(NDPath::GetImgPathNew("bag_btn_click.png")),
									  false, CGRectZero, true);
	m_btnCommit->SetFrameRect(CGRectMake(0, 0, 48,24));							 
	m_btnCommit->SetFontSize(12);
	m_btnCommit->SetTitle(NDCommonCString("commit"));
	m_btnCommit->SetFontColor(ccc4(255, 255, 255, 255));
	m_btnCommit->CloseFrame();
	m_btnCommit->SetDelegate(this);
	layerBtn->AddChild(m_btnCommit);
	
	changePointFocus(_stru_point::ps_begin);
}

void CUIPetAttr::SetPlusOrMinusPicture(int eProp, bool plus, bool focus)
{
	if (eProp < _stru_point::ps_begin || eProp >= _stru_point::ps_end) return;
	
	int iFocus = focus ? 1 : 0;
	
	NDUIButton *btn = plus ? m_btnPointPlus[eProp] : m_btnPointMinus[eProp];
	
	NDPicture  *pic = plus ? m_picPointPlus[eProp][iFocus] : m_picPointMinus[eProp][iFocus];
	
	if (!btn || !pic) return;
	
	CGSize size = btn->GetFrameRect().size,
	sizePic = pic->GetSize();
	
	btn->SetImage(pic, true, CGRectMake((size.width-sizePic.width)/2, (size.height-sizePic.height)/2, sizePic.width, sizePic.height));
}

void CUIPetAttr::SetPropTextFocus(int eProp, bool focus)
{
	if (eProp < _stru_point::ps_begin || eProp >= _stru_point::ps_end) return;
	
	ccColor4B color = focus ? ccc4(255, 0, 0, 255) : 
	(m_struPoint.IsAlloc(_stru_point::enumPointState(eProp)) ? 
	 ccc4(255, 255, 255, 255) : ccc4(22, 87, 81, 255));
	
	if (m_btnPointCur[eProp])
		m_btnPointCur[eProp]->SetFontColor(color);
}

void CUIPetAttr::UpdatePorpText(int eProp)
{
	if (eProp < _stru_point::ps_begin || eProp >= _stru_point::ps_end) return;
	
	stringstream ss; ss << (m_struPoint.m_psProperty[eProp].iFix + m_struPoint.m_psProperty[eProp].iPoint);
	
	if (m_btnPointCur[eProp])
		m_btnPointCur[eProp]->SetTitle(ss.str().c_str());
}

void CUIPetAttr::UpdatePorpAlloc()
{
	stringstream ss;
	ss << m_struPoint.iAlloc;
	
	if (m_lbAlloc)
		m_lbAlloc->SetText(ss.str().c_str());
}

void CUIPetAttr::UpdateSlideBar(int eProp)
{
	if (eProp < _stru_point::ps_begin || eProp >= _stru_point::ps_end) return;
	
	if (m_slideBar)
	{
		m_slideBar->SetMax(m_struPoint.iTotal, false);
		m_slideBar->SetMin(m_struPoint.GetMinPoint(_stru_point::enumPointState(eProp)),false);
		m_slideBar->SetCur(m_struPoint.iAlloc, true);
	}
}