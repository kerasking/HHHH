/*
 *  SocialElement.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SocialElement.h"
#include "NDUtility.h"
#include "NDTextNode.h"
#include "ItemMgr.h"
#include "CGPointExtension.h"
#include "ItemImage.h"
#include "GameItemBag.h"
#include "NDMapMgr.h"
#include "NDUIItemButton.h"
#include "TutorUILayer.h"
#include "SocialScene.h"
#include "NDUISynLayer.h"
#include <sstream>
#include <set>


void SendSocialRequest(std::set<int> idlist)
{
	if (idlist.empty()) return;
	
	NDTransData bao(_MSG_QUERY_SOCIAL_INFO);
	
	bao << (unsigned short)(idlist.size());
	
	for_vec(idlist, std::set<int>::iterator)
	{
		bao << int(*it);
	}
	
	SEND_DATA(bao);
	
	ShowProgressBar;
}

void SendSocialRequest(int iUserID, ...)
{
	std::set<int> vec_id;
	
	vec_id.insert(iUserID);
	
	va_list argumentList;
	int eachID;
	
	va_start(argumentList, iUserID);
	
	while (eachID == va_arg(argumentList, int)) 
	{
		vec_id.insert(eachID);
	}
	
	SendSocialRequest(vec_id);
}

void GetOnlineFriendID(std::set<int>& vec_id)
{
	MAP_FRIEND_ELEMENT& friendList = NDMapMgrObj.GetFriendMap();
	
	MAP_FRIEND_ELEMENT_IT it = friendList.begin();
	
	for(; it != friendList.end(); it++)
	{
		FriendElement& ele = it->second;
		
		if (ele.m_state == ES_ONLINE)
		{
			vec_id.insert(ele.m_id);
		}
	}
}

void GetOnlineTutorID(std::set<int>& vec_id)
{
	if (TutorUILayer::s_seDaoshi && TutorUILayer::s_seDaoshi->m_state == ES_ONLINE)
	{
		vec_id.insert(TutorUILayer::s_seDaoshi->m_id);
	}
	
	VEC_TUDI_ELEMENT& tudilist = TutorUILayer::s_vTudi;
	
	for_vec(tudilist, VEC_TUDI_ELEMENT_IT)
	{
		SocialElement& ele = *(*it);
		
		if (ele.m_state == ES_ONLINE)
		{
			vec_id.insert(ele.m_id);
		}
	}
}


void RequsetFriendInfo()
{
	std::set<int> vec_id;
	
	GetOnlineFriendID(vec_id);
	
	if (vec_id.empty()) return;
	
	SendSocialRequest(vec_id);
}

void RequestTutorInfo()
{
	std::set<int> vec_id;
	
	GetOnlineTutorID(vec_id);

	SendSocialRequest(vec_id);
}

void RequestTutorAndFriendInfo()
{
	std::set<int> vec_id;
	
	GetOnlineFriendID(vec_id);
	
	GetOnlineTutorID(vec_id);
	
	SendSocialRequest(vec_id);
}

IMPLEMENT_CLASS(SocialFigure, NDUILayer)

SocialFigure::SocialFigure()
{
	m_curSe = NULL;
	
	m_btnEquip = m_btnLvl = NULL;
	
	m_role = NULL;
	
	m_imageRole = NULL;
	
	m_lbName = m_lbOnline = m_lbTutor = NULL;
	
	m_showLvl = false;
	
	m_npc = NULL;
}

SocialFigure::~SocialFigure()
{

	SAFE_DELETE_NODE(m_roleCotainer);
}

void SocialFigure::Initialization(bool showTutor, bool showOnline/*=true*/, CGSize size/*=CGSizeMake(178, 112)*/)
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	this->SetBackgroundImage(pool.AddPicture(GetImgPathNew("role_bg.png"), size.width, size.height));
	
	m_lbName = new NDUILabel;
	m_lbName->Initialization();
	m_lbName->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbName->SetFontSize(16);
	m_lbName->SetFontColor(ccc4(133, 40, 42, 255));
	m_lbName->SetFrameRect(CGRectMake(0, 0, size.width, 40));
	this->AddChild(m_lbName);
	
	m_btnEquip = new NDUIButton;
	m_btnEquip->Initialization();
	m_btnEquip->SetDelegate(this);
	m_btnEquip->SetFrameRect(CGRectMake(68, 36, 38, 60));
	m_btnEquip->CloseFrame();
	m_btnEquip->SetTouchDownColor(ccc4(0, 0, 0, 0));
	this->AddChild(m_btnEquip);
	
	m_imageRole = new NDUIImage;
	m_imageRole->Initialization();
	m_imageRole->EnableEvent(false);
	m_imageRole->SetFrameRect(CGRectMake(68, 36, 38, 60));
	this->AddChild(m_imageRole);
	
	NDPicture *picLvl = pool.AddPicture(GetImgPathNew("level_bg.png"));
	m_btnLvl = new NDUIButton;
	m_btnLvl->Initialization();
	m_btnLvl->EnableEvent(false);
	m_btnLvl->SetFrameRect(CGRectMake(45, 35, picLvl->GetSize().width, picLvl->GetSize().height));
	m_btnLvl->SetVisible(false);
	m_btnLvl->SetFontSize(10);
	m_btnLvl->SetFontColor(ccc4(254, 225, 107, 255));
	m_btnLvl->SetImage(picLvl, false, CGRectZero, true); 
	this->AddChild(m_btnLvl);
	
	int startX = 105, startY = 36;
	
	if (showOnline)
	{
		m_lbOnline = new NDUILabel;
		m_lbOnline->Initialization();
		m_lbOnline->SetTextAlignment(LabelTextAlignmentLeft);
		m_lbOnline->SetFontSize(12);
		m_lbOnline->SetFrameRect(CGRectMake(startX, startY, size.width, 20));
		this->AddChild(m_lbOnline);
		
		startY += 20;
	}
	
	if (showTutor)
	{
		m_lbTutor = new NDUILabel;
		m_lbTutor->Initialization();
		m_lbTutor->SetTextAlignment(LabelTextAlignmentLeft);
		m_lbTutor->SetFontSize(12);
		m_lbTutor->SetFrameRect(CGRectMake(startX, startY, size.width, 20));
		m_lbTutor->SetFontColor(ccc4(133, 40, 42, 255));
		this->AddChild(m_lbTutor);
	}
	
	m_roleCotainer = new NDUINode;
	m_roleCotainer->Initialization();
	m_roleCotainer->EnableEvent(false);
	m_roleCotainer->SetFrameRect(CGRectMake(0, 0, 480, 320));
	
	SetDefaultLookFace(100009001);
}

void SocialFigure::ChangeFigure(SocialElement* se)
{
	m_curSe = se;
	
	UpdateFigure();
}

void SocialFigure::UpdateFigure()
{
	if (!m_curSe)
	{
		m_showLvl = false;

		if (m_lbName)
			m_lbName->SetText("");

		if (m_lbOnline)
			m_lbOnline->SetText("");

		if (m_lbTutor)
			m_lbTutor->SetText("");
		
		if (m_btnLvl)
			m_btnLvl->SetVisible(false);
			
		SAFE_DELETE_NODE(m_role);
		
		SAFE_DELETE_NODE(m_npc);
			
		return;
	}
	
	if (m_lbName)
		m_lbName->SetText(m_curSe->m_text1.c_str());
	
	if (m_lbOnline)
	{
		m_lbOnline->SetText(m_curSe->m_state == ES_ONLINE ? NDCommonCString("online") : NDCommonCString("offline"));
		m_lbOnline->SetFontColor(m_curSe->m_state == ES_ONLINE ? ccc4(255, 255, 255, 255) : ccc4(96, 96, 96, 255));
	}
	
	if (m_lbTutor)
		m_lbTutor->SetText(m_curSe->m_param == 1 ? NDCommonCString("ChuShi") : NDCommonCString("normal"));
	
	if (m_btnLvl)
		m_lbOnline->SetText(m_curSe->m_state == ES_ONLINE ? NDCommonCString("online") : NDCommonCString("offline"));
		
	if (m_btnLvl && m_curSe->m_state == ES_OFFLINE)
		m_btnLvl->SetVisible(false);
		
	SocialData data;
	
	bool hasInfo = SocialScene::GetSocialData(m_curSe->m_id, data);
	
	if (m_curSe->m_state == ES_OFFLINE)
	{
		SetDefaultLookFace(100009001);
	}
	
	if (!hasInfo) return;
	
	if (data.lookface > 0)
	{
		SetLookFace(data.lookface);
		
		if (!m_role) return;
		
		for_vec(data.equips, std::vector<int>::iterator)
		{
			int equipTypeId = *it; //根据装备id,判断属于哪个部位
			NDItemType* item = ItemMgrObj.QueryItemType(equipTypeId);
			
			if (!item) continue;
			int nID = item->m_data.m_lookface;
			int quality = equipTypeId % 10;
			
			if (nID == 0) continue;
			int aniId = 0;
			if (nID > 100000) 
			{
				aniId = (nID % 100000) / 10;
			}
			if (aniId >= 1900 && aniId < 2000 || nID >= 19000 && nID < 20000) 
			{// 战宠
			} 
			else if (nID >= 20000 && nID < 30000 || nID > 100000)
			{
			}
			else 
			{
				m_role->SetEquipment(nID, quality);
			}
		}
		
		ShowLevel(true, data.lvl);
	}
	else
	{
		ShowLevel(false, 0);
	}
}

void SocialFigure::ShowLevel(bool show, int lvl)
{
	if (!m_btnLvl) return;
	
	m_showLvl = show;
	
	if (!show)
	{
		m_btnLvl->SetVisible(show);
		
		return;
	}
	
	std::stringstream ss; ss << lvl;
	
	m_btnLvl->SetTitle(ss.str().c_str());
	
	m_btnLvl->SetVisible(true);
}

void SocialFigure::SetDefaultFigure(NDPicture* pic)
{
	if (m_imageRole)
		m_imageRole->SetPicture(pic, true);
	else
		SAFE_DELETE(pic);
}

void SocialFigure::SetDefaultLookFace(int lookface)
{
	if (!m_roleCotainer) return;
	
	SAFE_DELETE_NODE(m_role);
	
	SAFE_DELETE_NODE(m_npc);
	
	m_npc = new NDNpc;
	m_npc->Initialization(lookface);
	m_roleCotainer->AddChild(m_npc);
}

void SocialFigure::SetLookFace(int lookface)
{
	if (!m_roleCotainer) return;
	
	SAFE_DELETE_NODE(m_role);
	
	SAFE_DELETE_NODE(m_npc);
	
	m_role = new NDManualRole;
	m_role->Initialization(lookface);
	m_roleCotainer->AddChild(m_role);
}

void SocialFigure::SetVisible(bool visible)
{
	bool showlvl = m_btnLvl == NULL ? false : m_showLvl;
	
	NDUILayer::SetVisible(visible);
	
	if (m_btnLvl)
		m_btnLvl->SetVisible(showlvl && visible);
}

void SocialFigure::draw()
{
	if (!this->IsVisibled()) return;
	
	NDUILayer::draw();
	
	NDBaseRole *role;
	if (m_role == NULL) 
		role = m_npc;
	else
		role = m_role;
	
	if (role && m_btnEquip)
	{
		CGRect rect = m_btnEquip->GetScreenRect();
		rect.origin = ccpAdd(rect.origin, ccp(rect.size.width/2-2, rect.size.height));
		role->SetPositionEx(rect.origin);
		role->RunAnimation(true);
	}
}

void SocialFigure::OnButtonClick(NDUIButton* button)
{
	if (button != m_btnEquip) return;
	
	if (!m_curSe || m_curSe->m_state != ES_ONLINE) return;
	
	sendQueryPlayer(m_curSe->m_id, SEE_EQUIP_INFO);
}

IMPLEMENT_CLASS(SocialEleInfo, NDUILayer)

SocialEleInfo::SocialEleInfo()
{
	m_layerScroll = NULL;
}

SocialEleInfo::~SocialEleInfo()
{
}

void SocialEleInfo::Initialization(CGRect rect)
{
	NDUILayer::Initialization();
	
	this->SetBackgroundImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("attr_role_bg.png"), rect.size.width, rect.size.height), true);
	
	this->SetFrameRect(rect);
	
	m_layerScroll = new NDUIContainerScrollLayer;
	m_layerScroll->Initialization();
	m_layerScroll->SetFrameRect(CGRectMake(4, 8, rect.size.width-8, rect.size.height-16));
	this->AddChild(m_layerScroll);
}

void SocialEleInfo::SetText(const char *text, ccColor4B color/*=ccc4(255, 0, 0, 255)*/, unsigned int fontsize/*=12*/)
{
	if (!m_layerScroll) return;
	
	m_layerScroll->RemoveAllChildren(true);
	
	if (!text) return;
	
	CGSize size = getStringSizeMutiLine(text, 12, CGSizeMake(m_layerScroll->GetFrameRect().size.width, 320));
	
	NDUILabel *lb = new NDUILabel;
	lb->Initialization();
	lb->SetTextAlignment(LabelTextAlignmentLeft);
	lb->SetFontSize(fontsize);
	lb->SetFrameRect(CGRectMake(0, 0, size.width, size.height));
	lb->SetFontColor(color);
	lb->SetText(text);
	m_layerScroll->AddChild(lb);
	
	m_layerScroll->refreshContainer();
}

void SocialEleInfo::ChaneSocialEle(SocialElement* se)
{
	if (!se)
	{
		this->SetText("");
		return;
	}
	
	SocialData tutor;
	
	bool hasInfo = SocialScene::GetSocialData(se->m_id, tutor);
	
	if (!hasInfo) 
	{
		this->SetText("");
		return;
	}
	
	std::stringstream sb;
	
	sb << NDCommonCString("sex") << "       " << NDCommonCString("bie") << ": " << tutor.sex << "\n";
	sb << NDCommonCString("JunTuanName") << ": ";
	if (tutor.SynName == "")
		sb << NDCommonCString("wu");
	else
	{
		sb << tutor.SynName << "\n";
		sb << NDCommonCString("JunTuanPost") << ": " << tutor.rank;
	}
	
	if (!tutor.junxian.empty())
	{
		sb << "\n" << NDCommonCString("JunXian") << " : " << tutor.junxian;
	}
	
	this->SetText(sb.str().c_str());
}


IMPLEMENT_CLASS(NDSocialCell, NDPropCell)

NDSocialCell::NDSocialCell()
{
	m_picOnline = m_picOffline = NULL;
	
	m_curSe = NULL;
}

NDSocialCell::~NDSocialCell()
{
}

void NDSocialCell::Initialization()
{
	NDPropCell::Initialization(false);
	
	this->SetFocusTextColor(ccc4(133, 40, 42, 255));
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	m_picOnline = pool.AddPicture(GetImgPathNew("online.png"));
	
	m_picOffline = pool.AddPicture(GetImgPathNew("offline.png"));
}

void NDSocialCell::draw()
{
	if (!this->IsVisibled()) return;
	
	if (!m_curSe) return;
	
	NDPropCell::draw();
	
	NDNode *parent = this->GetParent();
	
	NDPicture * pic = NULL;
	
	if (parent && parent->IsKindOfClass(RUNTIME_CLASS(NDUILayer)) && ((NDUILayer*)parent)->GetFocus() == this)
	{
		pic = m_picFocus;
	}
	else
	{
		pic = m_picBg;
	}
	
	if (!pic) return;
	
	CGSize size = pic->GetSize();
	
	if (m_curSe->m_state == ES_ONLINE)
		pic = m_picOnline;
	else
		pic = m_picOffline;
		
	if (!pic) return;
	
	CGSize sizeState = pic->GetSize();
	
	CGRect scrRect = this->GetScreenRect();
	
	pic->DrawInRect(CGRectMake(scrRect.origin.x+scrRect.size.width-10-sizeState.width, 
									 scrRect.origin.y+(size.height-sizeState.height)/2, 
									 sizeState.width, sizeState.height));
}

void NDSocialCell::ChangeSocialElement(SocialElement* se)
{
	m_curSe = se;
	
	if (m_curSe && m_lbKey)
		m_lbKey->SetText(m_curSe->m_text1.c_str());
}

SocialElement* NDSocialCell::GetSocialElement()
{
	return m_curSe;
}

#pragma mark 查看玩家装备

IMPLEMENT_CLASS(SocialPlayerEquip, NDUILayer)

SocialPlayerEquip::SocialPlayerEquip()
{
	m_layerEquipInfo = m_layerEquip = NULL;
	
	m_layerScroll = NULL;
	
	memset(m_cellinfoEquip, 0, sizeof(m_cellinfoEquip));
	
	m_picRoleBackground = NULL;
}

SocialPlayerEquip::~SocialPlayerEquip()
{
	SAFE_DELETE_NODE(m_roleCotainer);
	
	SAFE_DELETE(m_picRoleBackground);
}

void SocialPlayerEquip::Initialization(int lookface)
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture* picBagLeftBg = pool.AddPicture(GetImgPathNew("bag_left_bg.png"));
	
	CGSize sizeBagLeftBg = picBagLeftBg->GetSize();
	
	m_layerEquipInfo = new NDUILayer;
	m_layerEquipInfo->Initialization();
	m_layerEquipInfo->SetFrameRect(CGRectMake(0,12+37, sizeBagLeftBg.width, sizeBagLeftBg.height));
	m_layerEquipInfo->SetBackgroundImage(picBagLeftBg, true);
	this->AddChild(m_layerEquipInfo);
	
	NDUIImage *imageRes = new NDUIImage;
	imageRes->Initialization();
	imageRes->SetPicture(pool.AddPicture(GetImgPathNew("farmrheadtitle.png")), true);
	imageRes->SetFrameRect(CGRectMake(5, 10, 8, 8));
	m_layerEquipInfo->AddChild(imageRes);
	
	NDUILabel *lbEquipInfo= new NDUILabel;
	lbEquipInfo->Initialization();
	lbEquipInfo->SetFontSize(14);
	lbEquipInfo->SetFontColor(ccc4(148, 6, 5, 255));
	lbEquipInfo->SetTextAlignment(LabelTextAlignmentLeft);
	lbEquipInfo->SetText(NDCommonCString("EquipInfo"));
	lbEquipInfo->SetFrameRect(CGRectMake(16, 7, sizeBagLeftBg.width, sizeBagLeftBg.height));
	m_layerEquipInfo->AddChild(lbEquipInfo);
	
	NDPicture* picRoleBg = pool.AddPicture(GetImgPathNew("attr_role_bg.png"), 0, 222);
	
	CGSize sizeRoleBg = picRoleBg->GetSize();
	
	NDUILayer *layerEquipInfo = new NDUILayer;
	layerEquipInfo->Initialization();
	layerEquipInfo->SetFrameRect(CGRectMake(0,24, sizeRoleBg.width, sizeRoleBg.height));
	layerEquipInfo->SetBackgroundImage(picRoleBg, true);
	m_layerEquipInfo->AddChild(layerEquipInfo);
	
	m_layerScroll = new NDUIContainerScrollLayer;
	m_layerScroll->Initialization();
	m_layerScroll->SetFrameRect(CGRectMake(6, 10, sizeRoleBg.width-12, sizeRoleBg.height-20));
	layerEquipInfo->AddChild(m_layerScroll);
	
	m_layerEquip = new NDUILayer;
	m_layerEquip->Initialization();
	m_layerEquip->SetFrameRect(CGRectMake(200+6, 5+37, 250, 276));
	this->AddChild(m_layerEquip);
	
	m_picRoleBackground = pool.AddPicture(GetImgPathNew("role_bg.png"));
	
	m_roleCotainer = new NDUINode;
	m_roleCotainer->Initialization();
	m_roleCotainer->EnableEvent(false);
	m_roleCotainer->SetFrameRect(CGRectMake(0, 0, 480, 320));
	
	m_role = new NDManualRole;
	m_role->Initialization(lookface);
	m_roleCotainer->AddChild(m_role);
	m_role->SetPositionEx(ccp(334, 178));
	
	UpdateEquipList();
}

void SocialPlayerEquip::ShowEquip(Item* equip)
{
	if (!m_layerScroll) return;
	
	m_layerScroll->RemoveAllChildren(true);
	
	if (!equip) return;
	
	int width = m_layerScroll->GetFrameRect().size.width;
	
	std::string str = equip->makeItemDes(true, true);
	
	CGSize textSize;
	textSize.width = width;
	textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(str.c_str(), textSize.width, 13);
	
	NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(str.c_str(), 
													  13, 
													  textSize, 
													  ccc4(148, 6, 5, 255),
													  true);
	memo->SetFrameRect(CGRectMake(0, 0, textSize.width, textSize.height));		
	m_layerScroll->AddChild(memo);
	
	if (equip->isItemPet())
	{
		NDUIButton* btn= new NDUIButton;
		
		NDPicturePool& pool = *(NDPicturePool::DefaultPool());
		btn = new NDUIButton;
		
		btn->Initialization();
		
		btn->SetFrameRect(CGRectMake(0,
									 textSize.height, 
									 48, 
									 24));
		btn->SetFontColor(ccc4(255, 255, 255, 255));
		
		btn->SetFontSize(12);
		
		btn->CloseFrame();
		
		btn->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("bag_btn_normal.png")),
								  pool.AddPicture(GetImgPathNew("bag_btn_click.png")),
								  false, CGRectZero, true);
		btn->SetDelegate(this);
		
		btn->SetTitle(NDCommonCString("ChaKang"));
		
		btn->SetTag(equip->iID);
		
		m_layerScroll->AddChild(btn);
	}
	
	m_layerScroll->refreshContainer();
}

void SocialPlayerEquip::UpdateEquipList()
{
	if (!m_layerEquip) return;
	
	VEC_ITEM& vOtherItem = ItemMgrObj.GetOtherItem();
	
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		Item *item = NULL;
		
		for (VEC_ITEM::iterator it = vOtherItem.begin(); it != vOtherItem.end(); it++) 
		{
			if (::GetItemPos(*(*it)) == i)
			{
				item = *it;
				break;
			}
		}
		
		InitEquipItemList(i, item);
	}
	
	
}

void SocialPlayerEquip::InitEquipItemList(int iEquipPos, Item* item)
{
	if (iEquipPos < Item::eEP_Begin || iEquipPos >= Item::eEP_End)
	{
		return;
	}
	
	if (!m_cellinfoEquip[iEquipPos])
	{
		int iCellX = 35, iCellY = 20 , iXInterval = 4, iYInterval = 4;
		
		if(iEquipPos >= 0 && iEquipPos <= 3)
		{
			iCellX += (ITEM_CELL_W+iXInterval)*iEquipPos;
		}
		
		if(iEquipPos == 4 )
		{
			iCellY += (ITEM_CELL_H+iYInterval)*1;
		}
		
		if(iEquipPos == 5 )
		{
			iCellX += (ITEM_CELL_W+iXInterval)*3;
			iCellY += (ITEM_CELL_H+iYInterval)*1;
		}
		
		if(iEquipPos == 6 )
		{
			iCellY += (ITEM_CELL_H+iYInterval)*2;
		}
		
		if(iEquipPos == 7 )
		{
			iCellX += (ITEM_CELL_W+iXInterval)*3;
			iCellY += (ITEM_CELL_H+iYInterval)*2;
		}
		
		if (iEquipPos >= 8 && iEquipPos <= 15) 
		{
			iCellY += (ITEM_CELL_H+iYInterval)*3;
			
			iCellX += (ITEM_CELL_W+iXInterval)*((iEquipPos-8)%4);
			iCellY += (ITEM_CELL_H+iYInterval)*((iEquipPos-8)/4);
		}
		
		NDPicture *picDefaultItem = ItemImage::GetItem(GetIconIndexByEquipPos(iEquipPos), true);
		if (picDefaultItem)
		{
			picDefaultItem->SetColor(ccc4(215, 171, 108, 150));
			picDefaultItem->SetGrayState(true);
		}
		
		m_cellinfoEquip[iEquipPos] = new NDUIItemButton;
		m_cellinfoEquip[iEquipPos]->Initialization();
		m_cellinfoEquip[iEquipPos]->SetFrameRect(CGRectMake( iCellX+1, iCellY+1,ITEM_CELL_W-2, ITEM_CELL_H-2));
		m_cellinfoEquip[iEquipPos]->SetDelegate(this);
		m_cellinfoEquip[iEquipPos]->SetDefaultItemPicture(picDefaultItem);
		m_layerEquip->AddChild(m_cellinfoEquip[iEquipPos]);
	}
	
	m_cellinfoEquip[iEquipPos]->ChangeItem(item);
	
	m_cellinfoEquip[iEquipPos]->setBackDack(false);
	
	if (item) 
	{
		//roleequipok
		if (item->iAmount == 0) 
		{
			ItemMgrObj.SetRoleEuiptItemsOK(true, iEquipPos);
			m_cellinfoEquip[iEquipPos]->setBackDack(true);
			//T.roleEuiptItemsOK[i] = 1;
		}
		if (iEquipPos == Item::eEP_Ride) 
		{
			if (item->sAge == 0) 
			{
				//T.roleEuiptItemsOK[i] = 1;
				ItemMgrObj.SetRoleEuiptItemsOK(true, iEquipPos);
				m_cellinfoEquip[iEquipPos]->setBackDack(true);
			}
		}
	}	
}

int SocialPlayerEquip::GetIconIndexByEquipPos(int pos)
{
	int index = -1;
	switch (pos) {
		case Item::eEP_Shoulder:
			index = 2+5*6;
			break;
		case Item::eEP_Head:
			index = 5*6;
			break;
		case Item::eEP_XianLian:
			index = 3+6;
			break;
		case Item::eEP_ErHuan:
			index = 6;
			break;
		case Item::eEP_Armor:
			index = 1+5*6;
			break;
		case Item::eEP_YaoDai:
			index = 5+5*6;
			break;
		case Item::eEP_MainArmor:
			index = 0;
			break;
		case Item::eEP_FuArmor:
			index = 5;
			break;
		case Item::eEP_Shou:
			index = 3+5*6;
			break;
		case Item::eEP_HuTui:
			index = 4+5*6;
			break;
		case Item::eEP_LeftRing:
			index = 2+6;
			break;
		case Item::eEP_RightRing:
			index = 2+6;
			break;
		case Item::eEP_HuiJi:
			index = 1+6;
			break;
		case Item::eEP_Shoes:
			index = 6*6;
			break;
		case Item::eEP_Decoration:
			index = 1+1*6;
			break;
		case Item::eEP_Ride:
			index = 1+3*6;
			break;
		default:
			break;
	}
	
	return index;
}

void SocialPlayerEquip::OnButtonClick(NDUIButton* button)
{
	if (!button) return;
	
	if (!button->IsKindOfClass(RUNTIME_CLASS(NDUIItemButton)))
	{
		sendQueryDesc(button->GetTag());
		
		return;
	}
		
	ShowEquip(((NDUIItemButton*)button)->GetItem());
}

void SocialPlayerEquip::draw()
{
	if (!this->IsVisibled()) return;
	
	NDUILayer::draw();
	
	if (m_picRoleBackground && m_layerEquip)
	{
		CGRect rect;
		
		rect.size = m_picRoleBackground->GetSize();
		
		rect.origin = ccpAdd(ccp(82, 68), m_layerEquip->GetScreenRect().origin);
		
		m_picRoleBackground->DrawInRect(rect);
	}
	
	if (m_role)
		m_role->RunAnimation(true);
}
