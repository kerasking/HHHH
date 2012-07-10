/*
 *  EmailSendScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "EmailSendScene.h"
#include "EmailData.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "NDConstant.h"
#include "CGPointExtension.h"
#include "GoodFriendUILayer.h"
#include "ItemMgr.h"
#include "NDPlayer.h"
#include "NDDataTransThread.h"
#include "NDTransData.h"
#include "define.h"
#include <sstream>

IMPLEMENT_CLASS(EmailEdit, NDUILayer)

EmailEdit::EmailEdit()
{
	m_lbText = NULL;
	m_memoText = NULL;
	m_crBG = NULL;
	m_bMemo = false;
}

EmailEdit::~EmailEdit()
{
}

void EmailEdit::Initialization(bool bMemo/*false*/)
{
	NDUILayer::Initialization();
	
	m_bMemo = bMemo;
	
	if (!bMemo) 
	{
		this->SetBackgroundColor(ccc4(254, 245, 212, 255));
		
		m_lbText = new NDUILabel;
		m_lbText->Initialization();
		m_lbText->SetFontSize(15);
		m_lbText->SetFontColor(ccc4(255, 255, 255, 255));
		m_lbText->SetTextAlignment(LabelTextAlignmentCenter);
		m_lbText->SetVisible(false);
		this->AddChild(m_lbText);
	}
	else 
	{
		this->SetBackgroundColor(ccc4(254, 245, 212, 0)); 
		
		m_crBG = new NDUICircleRect;
		m_crBG->Initialization();
		m_crBG->SetRadius(5);
		m_crBG->SetFillColor(ccc4(254, 245, 212, 255));
		m_crBG->SetVisible(false);
		this->AddChild(m_crBG);
		
		m_memoText = new NDUIMemo();
		m_memoText->Initialization();
		m_memoText->SetVisible(false);
		this->AddChild(m_memoText);
	}
}

void EmailEdit::draw()
{
	NDUILayer::draw();
	if (!this->IsVisibled()) 
	{
		return;
	}
	
	CGRect rect = GetFrameRect();
	
	NDNode* parentNode = this->GetParent();
	if (parentNode && parentNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
	{
		NDUILayer	*uiLayer = (NDUILayer*)parentNode;
		CGRect scrRect = this->GetScreenRect();	
		
		//draw focus 
		ccColor4B color;
		if (uiLayer->GetFocus() == this) 
		{
			color = ccc4(255, 206, 70, 255);
		}
		else 
		{
			color = ccc4(254, 245, 212, 255);
		}
		
		if (m_bMemo && m_crBG) 
		{
			m_crBG->SetFillColor(color);
			m_crBG->SetFrameRect(CGRectMake(0, 0, rect.size.width, rect.size.height));
			m_crBG->SetVisible(true);
		}
		else 
		{
			DrawRecttangle(scrRect, color);
			DrawLine(scrRect.origin, 
					 ccp(scrRect.origin.x, scrRect.origin.y+scrRect.size.height),
					 ccc4(20, 59, 64,255),
					 1);
			DrawLine(scrRect.origin, 
					 ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y),
					 ccc4(20, 59, 64,255),
					 1);
			DrawLine(ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y), 
					 ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y+scrRect.size.height),
					 ccc4(20, 59, 64,255),
					 1);
			DrawLine(ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y+scrRect.size.height),
					 ccp(scrRect.origin.x, scrRect.origin.y+scrRect.size.height),
					 ccc4(20, 59, 64,255),
					 1);
		}
		
		if (m_bMemo && m_memoText) 
		{
			m_memoText->SetFrameRect(CGRectMake(5, 5, rect.size.width-10, rect.size.height-10));
			m_memoText->SetBackgroundColor(ccc4(color.r, color.g, color.b, 255));
			m_memoText->SetVisible(true);
		}
		else 
		{
			if (m_lbText) 
			{
				CGSize dim = CGSizeZero;
				std::string str = m_lbText->GetText();
				if (!str.empty()) 
				{
					dim = getStringSizeMutiLine(str.c_str(), m_lbText->GetFontSize(), CGSizeMake(480,320));
				}
				m_lbText->SetFrameRect(CGRectMake(2, (rect.size.height - dim.height)/2, rect.size.width, dim.height));
				m_lbText->SetVisible(true);
			}
		}
	}
}

bool EmailEdit::TouchBegin(NDTouch* touch)
{
	if ( !(this->IsVisibled() && this->EventEnabled()) )
	{
		return false;
	}
	
	m_beginTouch = touch->GetLocation();
	
	if (!CGRectContainsPoint(this->GetScreenRect(), m_beginTouch)) 
	{
		return false;
	}
	
	NDNode* parentNode = this->GetParent();
	if (parentNode && parentNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
	{
		NDUILayer	*uiLayer = (NDUILayer*)parentNode;
		
		if (uiLayer->GetFocus() == this) 
		{
			EmailEditDelegate* delegate = dynamic_cast<EmailEditDelegate*> (this->GetDelegate());
			if (delegate) 
			{
				delegate->OnEmailEditClick(this);
			}				
			return true;
		}
	}
	
	return false;
}

void EmailEdit::SetText(std::string text)
{
	if (m_bMemo && m_memoText) 
	{
		m_memoText->SetText(text.c_str());
	}
	else 
	{
		if (m_lbText) 
		{
			m_lbText->SetText(text.c_str());
		}
	}
}

std::string EmailEdit::GetText()
{
	if (m_bMemo && m_memoText) 
	{
		return m_memoText->GetText();
	}
	else 
	{
		if (m_lbText) 
		{
			return m_lbText->GetText();
		}
	}
	
	return "";
}

void EmailEdit::SetFontColor(ccColor4B color)
{
	if (m_bMemo && m_memoText) 
	{
		m_memoText->SetFontColor(color);
	}
	else 
	{
		if (m_lbText) 
		{
			m_lbText->SetFontColor(color);
		}
	}
}

void EmailEdit::SetFontSize(unsigned int uisize)
{
	if (m_bMemo && m_memoText) 
	{
		m_memoText->SetFontSize(uisize);
	}
	else 
	{
		if (m_lbText) 
		{
			m_lbText->SetFontSize(uisize);
		}
	}	
}

void EmailEdit::SetTextAlignment(LabelTextAlignment alignment)
{
	if (m_bMemo && m_memoText) 
	{
		m_memoText->SetTextAlignment(MemoTextAlignment(alignment));
	}
	else 
	{
		if (m_lbText) 
		{
			m_lbText->SetTextAlignment(alignment);
		}
	}
}

////////////////////////////////////////////
#define title_height 28
#define bottom_height 42

EmailSendScene* EmailSendScene::s_instance = NULL;

IMPLEMENT_CLASS(EmailSendScene, NDScene)

EmailSendScene::EmailSendScene()
{
	NDAsssert(s_instance == NULL);
	m_menulayerBG = NULL;
	memset(m_imageMoney, 0, sizeof(m_imageMoney));
	memset(m_imageEMoney, 0, sizeof(m_imageEMoney));
	memset(m_picMoney, 0, sizeof(m_picMoney));
	memset(m_picEMoney, 0, sizeof(m_picEMoney));
	memset(m_edit, 0, sizeof(m_edit));
	m_btnFriend = NULL;
	m_tlOperate = NULL;
	s_instance = this;
	
	customViewTip[eRecvName] = "请输入收件人姓名";
	customViewTip[eContent] = "请输入正文内容";
	customViewTip[eAttachItem] = "";
	customViewTip[eAttachAmount] = "请输入附件物品的数量";
	customViewTip[eGiveEmoney] = "请输入要赠送的元宝";
	customViewTip[eGiveMoney] = "请输入要赠送的银两";
	customViewTip[ePayEmoney] = "请输入要收费的元宝";
	customViewTip[ePayMoney] = "请输入要收费的银两";
}

EmailSendScene::~EmailSendScene()
{
	SAFE_DELETE(m_picMoney[0]); SAFE_DELETE(m_picMoney[1]);
	SAFE_DELETE(m_picEMoney[0]); SAFE_DELETE(m_picEMoney[1]);
	s_instance = NULL;
}

EmailSendScene* EmailSendScene::Scene()
{
	EmailSendScene *scene = new EmailSendScene;
	scene->Initialization("");
	return scene;
}

EmailSendScene* EmailSendScene::Scene(std::string recvname)
{
	EmailSendScene *scene = new EmailSendScene;
	scene->Initialization(recvname);
	return scene;
}

void EmailSendScene::Initialization(std::string recvname)
{
	NDScene::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	m_menulayerBG->ShowOkBtn();
	m_menulayerBG->SetBackgroundColor(INTCOLORTOCCC4(0xc6cbb5));
	this->AddChild(m_menulayerBG);
	
	if (m_menulayerBG->GetOkBtn()) 
	{
		m_menulayerBG->GetOkBtn()->SetDelegate(this);
	}
	
	if (m_menulayerBG->GetCancelBtn()) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	CGSize dim = getStringSizeMutiLine("发邮件", 15);
	NDUILabel *lbTitle = new NDUILabel;
	lbTitle->Initialization();
	lbTitle->SetFontSize(15);
	lbTitle->SetFontColor(ccc4(255, 247, 0, 255));
	lbTitle->SetFrameRect(CGRectMake((winsize.width-dim.width)/2, (title_height-dim.height)/2, dim.width, dim.height));
	lbTitle->SetText("发邮件");
	m_menulayerBG->AddChild(lbTitle);
	
	InitText(ccp(12, title_height+3), "收件人");
	
	m_btnFriend = new NDUIButton;
	m_btnFriend->Initialization();
	m_btnFriend->SetFrameRect(CGRectMake(winsize.width-90, title_height+1, 73, 19));
	m_btnFriend->SetTitle("好友列表");
	m_btnFriend->CloseFrame();
	m_btnFriend->SetBackgroundColor(ccc4(55, 147, 184, 255));
	m_btnFriend->SetFontColor(ccc4(11, 34, 18, 255));
	m_btnFriend->SetFocusColor(ccc4(253, 253, 253, 255));
	m_btnFriend->SetDelegate(this);
	m_menulayerBG->AddChild(m_btnFriend);
	
	InitEdit(eRecvName, CGRectMake(0, title_height+20, winsize.width, 23), false);
	InitText(ccp(5, title_height+45), "内容");
	InitEdit(eContent, CGRectMake(5, title_height+60, winsize.width-10, 95), true);
	InitText(ccp(12, title_height+157), "附件");
	InitEdit(eAttachItem, CGRectMake(8, title_height+177, 240, 23), false);
	InitText(ccp(261, title_height+181), "X");
	InitEdit(eAttachAmount, CGRectMake(278, title_height+177, 40, 23), false);
	InitText(ccp(10, title_height+207), "赠送");
	InitText(ccp(247, title_height+207), "收费");
	
	for (int i = 0; i < 2; i++) 
	{
		int  iX = 45, iY = title_height+207;
		if (i == 1) 
		{
			iX += 237;
		}
		
		// emoney
		m_picEMoney[i] = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("emoney.png"));
		CGSize sizeEmoney = m_picEMoney[i]->GetSize();
		m_imageEMoney[i] =  new NDUIImage;
		m_imageEMoney[i]->Initialization();
		m_imageEMoney[i]->SetPicture(m_picEMoney[i]);
		m_imageEMoney[i]->SetFrameRect(CGRectMake(iX, iY, sizeEmoney.width, sizeEmoney.height));
		m_menulayerBG->AddChild(m_imageEMoney[i]);
		
		int index = eGiveEmoney;
		if (i == 1) 
		{
			index = ePayEmoney;
		}
		InitEdit(index, CGRectMake(iX+sizeEmoney.width+5, iY, 120, 17), false, LabelTextAlignmentCenter);
		m_edit[index]->SetFontSize(13);
		
		// money
		m_picMoney[i] = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("money.png"));
		CGSize sizemoney = m_picMoney[i]->GetSize();
		m_imageMoney[i] =  new NDUIImage;
		m_imageMoney[i]->Initialization();
		m_imageMoney[i]->SetPicture(m_picMoney[i]);
		m_imageMoney[i]->SetFrameRect(CGRectMake(iX, iY + 21, sizemoney.width, sizemoney.height));
		m_menulayerBG->AddChild(m_imageMoney[i]);
		
		index = eGiveMoney;
		if (i == 1) 
		{
			index = ePayMoney;
		}
		InitEdit(index, CGRectMake(iX+sizemoney.width+5, iY+21, 120, 17), false, LabelTextAlignmentCenter);
		m_edit[index]->SetFontSize(13);
	}
	
	m_menulayerBG->SetFocus(m_btnFriend);
	
	m_edit[eRecvName]->SetText(recvname);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->SetDelegate(this);
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetVisible(false);
	this->AddChild(m_tlOperate);
}

void EmailSendScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnFriend) 
	{
		GoodFriendUILayer *friendList = new GoodFriendUILayer;
		friendList->Initialization(GoodFriendEmail);
		this->AddChild(friendList, UILAYER_Z, UILAYER_GOOD_FRIEND_LIST_TAG);
	}
	else if (button == m_menulayerBG->GetOkBtn()) 
	{
		if (!checkEmail()) 
		{
			return;
		}
		std::string tip = "每封邮件需收取手续费100银两。是否确定要发送邮件给玩家 ";
		tip += m_edit[eRecvName]->GetText();
		NDUIDialog *dlg = new NDUIDialog;
		dlg->Initialization();
		dlg->SetDelegate(this);
		dlg->Show("温馨提示", tip.c_str(), "取消",  "确定", NULL);
	}
	else if (button == m_menulayerBG->GetCancelBtn()) 
	{
		NDDirector::DefaultDirector()->PopScene();
	}
}

void EmailSendScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlOperate && m_edit[eAttachItem] && m_edit[eAttachAmount])
	{
		int iTag = cell->GetTag();
		std::string content = "";
		std::string amount = "";
		Item* res = NULL;
		if (iTag != -1 && ItemMgrObj.HasItemByType(ITEM_BAG, iTag, res) && res) 
		{
			content = res->getItemName();
			amount = "1";
		}
		m_edit[eAttachItem]->SetTag(iTag);
		m_edit[eAttachItem]->SetText(content);
		m_edit[eAttachAmount]->SetText(amount);
		table->SetVisible(false);
	}
}

bool EmailSendScene::OnCustomViewConfirm(NDUICustomView* customView)
{
	std::string text =	customView->GetEditText(0);
	int iTag = customView->GetTag();
	if (text.empty() && iTag == eAttachAmount) 
	{
		return true;
	}
	
	if (iTag == eAttachAmount) 
	{
		VerifyViewNum(*customView);
		
		if (!m_edit[eAttachItem]) 
		{
			return true;
		}
		
		Item* res = NULL;
		int iItemID = m_edit[eAttachItem]->GetTag();
		if (iItemID == -1 || !ItemMgrObj.HasItemByType(ITEM_BAG, iItemID, res) || !res) 
		{
			return true;
		}
		
		int iAmount = atoi(text.c_str());
		
		if (iAmount <= 0) 
		{
			customView->ShowAlert("失败, 请填入正确的数量");
			return false;
		}
		
		if (res->isEquip()) 
		{ // 表示装备
			if (iAmount != 1) 
			{
				customView->ShowAlert("失败, 装备的附件数量只能是1");
				return false;
			} 
			else 
			{
				if (m_edit[eAttachAmount])
					m_edit[eAttachAmount]->SetText(text);
			}
		} 
		else 
		{
			if (iAmount > res->iAmount) 
			{
				std::stringstream ss; ss << "你背包中的该物品数量仅有" << res->iAmount << "个,请重新输入";
				customView->ShowAlert(ss.str().c_str());
				return false;
			} 
			else 
			{
				if (m_edit[eAttachAmount])
					m_edit[eAttachAmount]->SetText(text);
			}
		}
	}
	else if (iTag == eGiveMoney) 
	{
		VerifyViewNum(*customView);
		
		int iAmount = atoi(text.c_str());
		if (iAmount < 0) 
		{
			customView->ShowAlert("失败, 请填入正确的赠送金额");
			return false;
		}
		
		if (iAmount > NDPlayer::defaultHero().money) 
		{
			std::stringstream ss; ss << "你背包中的银两数仅有" << NDPlayer::defaultHero().money << ",请重新输入";
			customView->ShowAlert(ss.str().c_str());
			return false;
		}
			
		if (m_edit[eGiveMoney])
			m_edit[eGiveMoney]->SetText(iAmount == 0 ? "" : text);
	}
   else if (iTag == eGiveEmoney) 
   {
	   VerifyViewNum(*customView);
	   
	   int iAmount = atoi(text.c_str());
	   if (iAmount < 0) 
	   {
		   customView->ShowAlert("失败, 请填入正确的赠送元宝");
		   return false;
	   }
	   
	   if (iAmount > NDPlayer::defaultHero().eMoney) 
	   {
		   std::stringstream ss; ss << "你背包中的元宝数仅有" << NDPlayer::defaultHero().eMoney << ",请重新输入";
		   customView->ShowAlert(ss.str().c_str());
		   return false;
	   }

	   if (m_edit[eGiveEmoney])
		   m_edit[eGiveEmoney]->SetText(iAmount == 0 ? "" : text);
   }
   else if (iTag == ePayMoney || iTag == ePayEmoney)
   {
	   VerifyViewNum(*customView);
	   
	   int iAmount = atoi(text.c_str());
	   if (iAmount < 0) 
	   {
		   customView->ShowAlert("失败, 请填入正确的收费金额");
		   return false;
	   }
	   
	  m_edit[iTag]->SetText(iAmount == 0 ? "" : text);
   }
   else
   {
	   if (int(text.size()) > 220) 
	   {
		   customView->ShowAlert("内容长度不能超过110");
		   return false;
	   }
	   m_edit[iTag]->SetText(text);
   }

	return true;
}

void EmailSendScene::OnDialogClose(NDUIDialog* dialog)
{
}

void EmailSendScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	sendEmail();
	resetAllEdits();
	dialog->Close();
}

void EmailSendScene::OnEmailEditClick(EmailEdit* edit)
{
	for (int i = eBegin; i < eEnd; i++) 
	{
		if (edit == m_edit[i]) 
		{
			if (i == eAttachItem) 
			{
				std::vector<std::string> vec_str; std::vector<int> vec_id;
				vec_str.push_back("无"); vec_id.push_back(-1);
				VEC_ITEM& items = ItemMgrObj.GetPlayerBagItems();
				for_vec(items, VEC_ITEM_IT)
				{
					Item& item = *(*it);
					int type = Item::getIdRule(item.iItemType, Item::ITEM_TYPE);
					if(item.byBindState == BIND_STATE_BIND)
					{
						continue;
					}
					if (type < 3) 
					{ // 0装备,1宠物,2消耗品
						if (!item.isCanEmail()) {
							continue;
						}
						
						std::string name = item.getItemName();
						std::stringstream tempText;
						tempText << name;
						if (type == 2 && item.iAmount > 1) 
						{
							tempText << " x " << item.iAmount;
						}
						
						vec_str.push_back(tempText.str()); vec_id.push_back(item.iID);
					}
				}
				
				UpdateOperate(vec_str, vec_id);
			}
			else 
			{
				ShowCustomView(i, customViewTip[i]);
			}
			break;
		}
	}
}

void EmailSendScene::InitText(CGPoint pos, std::string str)
{
	CGSize dim = getStringSizeMutiLine(str.c_str(), 15);
	NDUILabel *lb = new NDUILabel;
	lb->Initialization();
	lb->SetFontSize(15);
	lb->SetFontColor(ccc4(0, 0, 0, 255));
	lb->SetFrameRect(CGRectMake(pos.x, pos.y, dim.width, dim.height));
	lb->SetText(str.c_str());
	m_menulayerBG->AddChild(lb);
}

void EmailSendScene::InitEdit(int index, CGRect rect, bool bMemo, int alignment/*=LabelTextAlignmentLeft*/)
{
	if (index < eBegin || index >= eEnd) return;
	
	if (m_edit[index]) 
	{
		return;
	}
	
	m_edit[index] = new EmailEdit;
	EmailEdit *&edit = m_edit[index];
	edit->Initialization(bMemo);
	edit->SetFrameRect(rect);
	edit->SetTextAlignment(LabelTextAlignment(alignment));
	edit->SetDelegate(this);
	edit->SetText("");
	edit->SetFontColor(ccc4(0, 0, 0, 255));
	m_menulayerBG->AddChild(edit);
}

void EmailSendScene::ShowCustomView(int iTag, std::string tip)
{
	if (iTag < eBegin || iTag >= eEnd || !m_edit[iTag]) 
	{
		return;
	}
	NDUICustomView *view = new NDUICustomView;
	view->Initialization();
	view->SetTag(iTag);
	view->SetDelegate(this);
	std::vector<int> vec_id; vec_id.push_back(1);
	std::vector<std::string> vec_str; vec_str.push_back(tip.c_str());
	view->SetEdit(1, vec_id, vec_str);
	view->SetEditText(m_edit[iTag]->GetText().c_str(), 0);
	view->Show();
	this->AddChild(view);
}

void EmailSendScene::UpdateOperate(std::vector<std::string> vec_str, std::vector<int> vec_id)
{
	if (!m_tlOperate || vec_str.empty() || vec_str.size() != vec_id.size()) 
	{
		return;
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDSection *section = new NDSection;
	NDDataSource * dataSource = new NDDataSource;
	section->Clear();
	//section->UseCellHeight(true);
	int iSize = vec_str.size();
	for (int i = 0; i < iSize; i++) 
	{
		NDUIButton* btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle(vec_str[i].c_str());
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		btn->SetTag(vec_id[i]);
		section->AddCell(btn);
	}
	
	dataSource->AddSection(section);
	
	int iHeight = iSize > 8 ? 240 : iSize*30;//+iSize+1;
	
	m_tlOperate->SetFrameRect(CGRectMake((winsize.width-120)/2, (winsize.height-iHeight)/2, 120, iHeight));
	m_tlOperate->SetVisible(true);
	m_tlOperate->VisibleScrollBar(iHeight > 240);
	
	if (m_tlOperate->GetDataSource())
	{
		m_tlOperate->SetDataSource(dataSource);
		m_tlOperate->ReflashData();
	}
	else
	{
		m_tlOperate->SetDataSource(dataSource);
	}
}

bool EmailSendScene::checkEmail()
{
	std::string recvname = "", content = "", itemname = "", itemcount = "", paymoney = "", payemoney = "";
	if (m_edit[eRecvName]) 
	{
		recvname = m_edit[eRecvName]->GetText();
	}
	
	if (m_edit[eContent]) 
	{
		content = m_edit[eContent]->GetText();
	}
	
	if (m_edit[eAttachItem] && m_edit[eAttachItem]->GetTag() > 0 && m_edit[eAttachItem]->GetText() != "") 
	{
		Item* res = NULL;
		int iItemID = m_edit[eAttachItem]->GetTag();
		if (iItemID == -1 || !ItemMgrObj.HasItemByType(ITEM_BAG, iItemID, res) || !res) 
		{
			return false;
		}
		itemname = m_edit[eAttachItem]->GetText();
	}
	
	if (m_edit[eAttachAmount]) 
	{
		itemcount = m_edit[eAttachAmount]->GetText();
	}
	
	if (m_edit[ePayMoney]) 
	{
		paymoney = m_edit[ePayMoney]->GetText();
	}
	
	if (m_edit[ePayEmoney]) 
	{
		payemoney = m_edit[ePayEmoney]->GetText();
	}
	
	if (recvname.empty()) {
		showDialog("失败", "收件人不能为空");
		return false;
	} 
	else if (content.empty()) {
		showDialog("失败", "邮件内容不能为空");
		return false;
	} 
	else if (!itemname.empty() && itemcount.empty()) 
	{
		showDialog("失败", "请填入附件物品数量");
		return false;
	} 
	else if (itemname.empty()) 
	{
		if ((!paymoney.empty() && atoi(paymoney.c_str()) > 0) || (!payemoney.empty() && atoi(payemoney.c_str()) > 0)) 
		{
			showDialog("失败", "不能发送没附件只收费的邮件");
			return false;
		}
	}
	return true;
}

void EmailSendScene::sendEmail()
{
	NDTransData bao(_MSG_SENDLETTER);
	
	int btAttachState = EmailData::ATTACH_NO;
	std::string text1 = m_edit[eAttachItem]->GetText();
	int iAmount = atoi(m_edit[eAttachAmount]->GetText().c_str());
	if (!text1.empty() && iAmount > 0) {
		btAttachState |= EmailData::ATTACH_ITEM_ID; // 附件含 item
	}
	
	text1 = m_edit[eGiveMoney]->GetText();
	int iGiveMoney = atoi(text1.c_str());
	if (!text1.empty() && iGiveMoney > 0) {
		btAttachState |= EmailData::ATTACH_MONEY; // 附件含 attach_money
	}
	
	text1 = m_edit[eGiveEmoney]->GetText();
	int iGiveEmoney = atoi(text1.c_str());
	if (!text1.empty() && iGiveEmoney > 0) {
		btAttachState |= EmailData::ATTACH_EMONEY; // 附件含 attach_emoney
	}
	
	text1 = m_edit[ePayMoney]->GetText();
	int iPayMoney = atoi(text1.c_str());
	if (!text1.empty() && iPayMoney > 0) {
		btAttachState |= EmailData::ATTACH_REQUIRE_MONEY; // 附件含
		// require_money
	}
	
	text1 = m_edit[ePayEmoney]->GetText();
	int iPayEmoney = atoi(text1.c_str());
	if (!text1.empty() && iPayEmoney > 0) {
		btAttachState |= EmailData::ATTACH_REQUIRE_EMONEY; // 附件含
		// require_emoney
	}
	
	bao << (unsigned char)btAttachState;
	
	text1 = m_edit[eAttachItem]->GetText();
	if (!text1.empty() && iAmount > 0) 
	{
		bao << int(m_edit[eAttachItem]->GetTag()) << (unsigned short)iAmount; // 附件含
	}
	
	if (iGiveMoney > 0) {
		bao << iGiveMoney; // 附件含 attach_money
	}
	
	if (iGiveEmoney > 0) {
		bao << iGiveEmoney; // 附件含 attach_emoney
	}
	
	if (iPayMoney > 0) {
		bao << iPayMoney; // 附件含 require_money
	}
	
	if (iPayEmoney > 0) {
		bao << iPayEmoney; // 附件含 require_emoney
	}
	
	//bao.write(0);// btCharSet
//	byte[] data = T.stringToBytes(receiveEdit.getText(), 1);
//	bao.writeShort(data.length);
//	bao.write(data);
//	
//	bao.write(0);// btCharSet
//	data = T.stringToBytes(contentBox.getText(), 1);
//	bao.writeShort(data.length);
//	bao.write(data);
	
	bao.WriteUnicodeString(m_edit[eRecvName]->GetText());
	bao.WriteUnicodeString(m_edit[eContent]->GetText());
	
	SEND_DATA(bao);
}

void EmailSendScene::resetAllEdits()
{
	for (int i = eBegin; i < eEnd; i++) 
	{
		if (m_edit[i]) 
		{
			m_edit[i]->SetText("");
		}
		
		if (i == eAttachItem) 
		{
			m_edit[i]->SetTag(-1);
		}
	}
}

void EmailSendScene::UpdateReciever(std::string recvname)
{
	if (!s_instance) 
	{
		return;
	}
	
	if (s_instance->m_edit[eRecvName])
		s_instance->m_edit[eRecvName]->SetText(recvname);
}
