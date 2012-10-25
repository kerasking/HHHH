/*
 *  LifeSkillRandomScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "LifeSkillRandomScene.h"
#include "LifeSkill.h"
#include "NDUIItemButton.h"
#include "NDUISynLayer.h"
#include "GameUIPlayerList.h"
#include "ItemMgr.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "define.h"
#include <sstream>

class FormulaRandomInfoLayer : public NDUILayer
{
	DECLARE_CLASS(FormulaRandomInfoLayer)
public:
	FormulaRandomInfoLayer();
	~FormulaRandomInfoLayer();
	
	void Initialization(int iType); hide
	void draw(); override
	
	bool TouchBegin(NDTouch* touch); override
	bool TouchEnd(NDTouch* touch); override
	
	void SetInfo(Item* item, int iCount);
	int GetItemCount();
	int GetItemID();
	bool IsEmpty();
	std::string GetText();
	Item* GetItem();
	
private:
	NDUIItemButton		*m_btnItem;
	NDUILabel			*m_lbText;
	int					m_iType;
	bool				m_bCacl, m_bFocus;
	int					m_iCount;
};

IMPLEMENT_CLASS(FormulaRandomInfoLayer, NDUILayer)

FormulaRandomInfoLayer::FormulaRandomInfoLayer()
{
	m_btnItem = NULL;
	m_lbText = NULL;
	m_iType = 0;
	m_bCacl = false;
	m_bFocus = false;
	m_iCount = 0;
}

FormulaRandomInfoLayer::~FormulaRandomInfoLayer()
{
}

void FormulaRandomInfoLayer::Initialization(int iType)
{
	if ( !(iType == eChaoYao || iType == eBaoShiYuanShi) ) 
	{
		return;
	}
	
	NDUILayer::Initialization();
	
	m_lbText = new NDUILabel;
	m_lbText->Initialization();
	m_lbText->SetText(iType == eChaoYao ? NDCommonCString("CaoYao") : NDCommonCString("BaoShiYuanShi"));
	m_lbText->SetFontSize(15);
	m_lbText->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbText->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbText->SetVisible(true);
	this->AddChild(m_lbText);
	
	m_btnItem = new NDUIItemButton;
	m_btnItem->Initialization();
	m_btnItem->ChangeItem(NULL);
	m_btnItem->SetVisible(false);
	this->AddChild(m_btnItem);
	
	m_iType = iType;
}

void FormulaRandomInfoLayer::draw()
{
	NDUILayer::draw();
	
	if (!m_bCacl) 
	{
		CGRect rect = GetFrameRect();
		
		if (m_btnItem) 
		{
			m_btnItem->SetFrameRect(CGRectMake(5, (rect.size.height-ITEM_CELL_H)/2, ITEM_CELL_W, ITEM_CELL_H));
			m_btnItem->ChangeItem(m_btnItem->GetItem());
			m_btnItem->SetVisible(true);
		}
		
		if (m_lbText) 
		{
			CGSize dim = CGSizeZero;
			std::string str = m_lbText->GetText();
			if (!str.empty()) 
			{
				dim = getStringSizeMutiLine(str.c_str(), m_lbText->GetFontSize(), CGSizeMake(480,320));
			}
			m_lbText->SetFrameRect(CGRectMake(0, (rect.size.height - dim.height)/2, rect.size.width, dim.height));
		}
	}
	
	m_bCacl = true;
	
	NDNode* parentNode = this->GetParent();
	if (parentNode && parentNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
	{
		NDUILayer	*uiLayer = (NDUILayer*)parentNode;
		CGRect scrRect = this->GetScreenRect();	
		
		//draw focus 
		if (uiLayer->GetFocus() == this) 
		{
			DrawRecttangle(scrRect, ccc4(255, 206, 70, 255));					
		}
	}
}

bool FormulaRandomInfoLayer::TouchBegin(NDTouch* touch)
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
		if (uiLayer->GetFocus() != this) 
		{
			return false;
		}
		
		FormulaRandomInfoLayerDelegate* delegate = dynamic_cast<FormulaRandomInfoLayerDelegate*> (this->GetDelegate());
		if (delegate && m_btnItem && m_btnItem->GetItem() != NULL && m_iCount > 0) 
		{
			delegate->OnFormulaRandomInfoLayerClick(this);
		}	
	}
	
	return true;
}

bool FormulaRandomInfoLayer::TouchEnd(NDTouch* touch)
{
	return true;
}

void FormulaRandomInfoLayer::SetInfo(Item* item, int iCount)
{
	if (m_btnItem) 
	{
		m_btnItem->ChangeItem(item);
	}
	
	m_iCount = item == NULL ? 0 : iCount;

	if (m_lbText) 
	{
		std::stringstream title;
		if (item) 
		{
			title << item->getItemName() << " X" << iCount;
		}
		else 
		{
			title << (m_iType == eChaoYao ? NDCommonCString("CaoYao") : NDCommonCString("BaoShiYuanShi"));
		}
		
		m_lbText->SetText(title.str().c_str());
	}
}

int FormulaRandomInfoLayer::GetItemCount()
{
	return m_iCount;
}

int FormulaRandomInfoLayer::GetItemID()
{
	if (m_btnItem->GetItem()) 
	{
		return m_btnItem->GetItem()->iID;
	}
	
	return 0;
}

bool FormulaRandomInfoLayer::IsEmpty()
{
	return GetItemID() == 0 && GetItemCount() == 0;
}

std::string FormulaRandomInfoLayer::GetText()
{
	if (!m_lbText) 
	{
		return "";
	}
	
	return m_lbText->GetText();
}

Item* FormulaRandomInfoLayer::GetItem()
{
	if (!m_btnItem) 
	{
		return NULL;
	}
	
	return m_btnItem->GetItem();
}

//////////////////////////////////////////
#define title_height (28)
#define control_start_x (10)
#define control_start_y (title_height+6)

#define info_w (190)
#define info_h (45)
#define info_interval (3)

enum  
{
	eOP_Select = 300,
	eOP_XieXia,
	eOP_Cancel,
};

IMPLEMENT_CLASS(LifeSkillRandomScene, NDScene)

LifeSkillRandomScene::LifeSkillRandomScene()
{
	m_menulayerBG= NULL;
	m_lbTitle = NULL;
	m_itemBag = NULL;
	m_tlOperate = NULL;
	memset(m_layerRandomInfo, 0, sizeof(m_layerRandomInfo));
	m_iType = 0;
	
	m_iOperateInfoIndex = -1;
}

LifeSkillRandomScene::~LifeSkillRandomScene()
{
}

void LifeSkillRandomScene::Initialization(int iType)
{
	if (!(iType == eChaoYao || iType == eBaoShiYuanShi))
	{
		return;
	}
	
	m_iType = iType;
	 
	NDScene::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	m_menulayerBG->ShowOkBtn();
	this->AddChild(m_menulayerBG);
	
	if (m_menulayerBG->GetOkBtn()) 
	{
		m_menulayerBG->GetOkBtn()->SetDelegate(this);
	}
	
	if (m_menulayerBG->GetCancelBtn()) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	std::string strTitle = eChaoYao == iType ? NDCommonCString("LianYao") : NDCommonCString("BaoShiHeCheng");
	CGSize dim = getStringSizeMutiLine(strTitle.c_str(), 15);
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 245, 0, 255));
	m_lbTitle->SetFrameRect(CGRectMake((winsize.width-dim.width)/2, (title_height-dim.height)/2, dim.width, dim.height));
	m_lbTitle->SetText(strTitle.c_str());
	m_menulayerBG->AddChild(m_lbTitle);
	
	for(int i = 0; i < eMaxRandomInfo; i++)
	{
		FormulaRandomInfoLayer *&info = m_layerRandomInfo[i];
		info = new FormulaRandomInfoLayer;
		info->Initialization(iType);
		info->SetInfo(NULL, 0);
		
		if (i%2 == 0)
		{
			info->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
		}
		else
		{
			info->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
		}
		
		info->SetFrameRect(CGRectMake(control_start_x, control_start_y+(info_h+info_interval)*i, info_w, info_h));
		info->SetDelegate(this);
		m_menulayerBG->AddChild(info);
	}
	
	std::vector<Item*> itemlist;
	m_itemBag = new GameItemBag;
	m_itemBag->Initialization(itemlist);
	m_itemBag->SetDelegate(this);
	m_itemBag->SetPageCount(ItemMgrObj.GetPlayerBagNum());
	m_itemBag->SetFrameRect(CGRectMake(203, control_start_y, ITEM_BAG_W, ITEM_BAG_H));
	m_menulayerBG->AddChild(m_itemBag);
	
	NDUITopLayerEx *topLayerEx = new NDUITopLayerEx;
	topLayerEx->Initialization();
	topLayerEx->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	this->AddChild(topLayerEx);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetDelegate(this);
	m_tlOperate->SetVisible(false);
	topLayerEx->AddChild(m_tlOperate);
	
	reset();
}

void LifeSkillRandomScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlOperate && cell) 
	{
		int iTag = cell->GetTag();
		switch (iTag) {
			case eOP_Select:
			{
				Item *item = m_itemBag == NULL ? NULL : m_itemBag->GetFocusItem();
				if (item) 
				{
					std::vector<int> t_itemType = Item::getItemType(item->iItemType);
					
					if (t_itemType[0] == 6
						&& ((m_iType == eChaoYao && t_itemType[1] == 1) || (m_iType == eBaoShiYuanShi && t_itemType[1] == 2))) 
					{
						
						for (int i = 0; i < eMaxRandomInfo; i++)
						{
							if (m_layerRandomInfo[i] && m_layerRandomInfo[i]->GetItemID() == item->iID)
							{
								m_tlOperate->SetVisible(false);
								showDialog("", NDCommonCString("CantRepeatUse"));
								return;
							}
						}
						
						for (int i = 0; i < eMaxRandomInfo; i++) 
						{
							if (m_layerRandomInfo[i] && m_layerRandomInfo[i]->IsEmpty()) 
							{
								
								NDUICustomView *view = new NDUICustomView;
								view->Initialization();
								view->SetDelegate(this);
								std::vector<int> vec_id; vec_id.push_back(1);
								std::vector<std::string> vec_str; vec_str.push_back(NDCommonCString("InputAmountMaxTen"));
								view->SetEdit(1, vec_id, vec_str);
								view->SetEditText("1", 0);
								view->Show();
								this->AddChild(view);
								break;
							}
							if (i == 2) 
							{
								showDialog(NDCommonCString("OperateFail"),  NDCommonCString("MaterialLanFull"));
							}
						}
					} 
					else 
					{
						std::stringstream ss; 
						ss	<< NDCommonCString("ItemNot") 
							<< (m_iType == eChaoYao ? NDCommonCString("LianYao") : NDCommonCString("HeCheng"))
							<< NDCommonCString("material");
							
						showDialog(NDCommonCString("OperateFail"), ss.str().c_str());
					}
					
				}
			}
				break;
			case eOP_XieXia:
			{
				if (m_iOperateInfoIndex >= 0 
					&& m_iOperateInfoIndex <= eMaxRandomInfo
					&& m_layerRandomInfo[m_iOperateInfoIndex]) 
				{
					m_layerRandomInfo[m_iOperateInfoIndex]->SetInfo(NULL, 0);
					FiltItem(false);
					m_iOperateInfoIndex = -1;
				}
			}
				break;
			case eOP_Cancel:
			{
				m_iOperateInfoIndex = -1;
			}
				break;
			default:
				break;
		}
		m_tlOperate->SetVisible(false);
	}
}

bool LifeSkillRandomScene::OnCustomViewConfirm(NDUICustomView* customView)
{
	Item *item = m_itemBag == NULL ? NULL : m_itemBag->GetFocusItem();
	
	if (!item) 
	{
		return true;
	}
	
	VerifyViewNum(*customView);
	
	std::string stramount =	customView->GetEditText(0);
	if (!stramount.empty())
	{
		int useCount = atoi(stramount.c_str());
		if(useCount <= 0){
			customView->ShowAlert(NDCommonCString("OperateFailCantZero"));
			return false;
		}
		
		if (useCount > 10) 
		{
			customView->ShowAlert(NDCommonCString("OperateFailSmallTen"));
			return false;
		}
		
		if (useCount > item->iAmount) 
		{
			customView->ShowAlert(NDCommonCString("OperateFailOverAmount"));
			return false;
		}
		
		for (int i = 0; i < eMaxRandomInfo; i++)
		{
			if (m_layerRandomInfo[i] && m_layerRandomInfo[i]->IsEmpty())
			{
				m_layerRandomInfo[i]->SetInfo(item, useCount);
				if (m_itemBag) 
				{
					m_itemBag->UpdateTitle();
				}
				break;
			}
			
			if (i == eMaxRandomInfo-1) 
			{
				customView->ShowAlert(NDCommonCString("OperateFailMaterialFull"));
				return false;
			}
		}
	}
	
	return true;
}

void LifeSkillRandomScene::OnFormulaRandomInfoLayerClick(FormulaRandomInfoLayer* layer)
{
	if (layer && layer->GetItemID() != 0 && layer->GetItemCount() > 0) 
	{
		for(int i = 0; i < eMaxRandomInfo; i++)
		{
			if (m_layerRandomInfo[i] && m_layerRandomInfo[i] == layer)
			{
				m_iOperateInfoIndex = i;
			}
		}
		std::vector<std::string> vec_str;
		std::vector<int> vec_id;
		vec_str.push_back(NDCommonCString("XieXia")); vec_id.push_back(eOP_XieXia);
		vec_str.push_back(NDCommonCString("return")); vec_id.push_back(eOP_Cancel);
		InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
	}
}

bool LifeSkillRandomScene::OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
{
	if (itembag == m_itemBag && item) 
	{
		int iUseCount = 0;
		
		for(int i = 0; i < eMaxRandomInfo; i++)
		{
			if (m_layerRandomInfo[i] && m_layerRandomInfo[i]->GetItemID() == item->iID) 
			{
				iUseCount = m_layerRandomInfo[i]->GetItemCount();
				break;
			}
		}
		
		std::stringstream sb; sb << item->getItemNameWithAdd();
		sb << ("  X") << item->iAmount - iUseCount;
		
		m_itemBag->SetTitle(sb.str().c_str());
		//EquipUIScreen.setItemColor(m_itemInfo, item);
		
		m_itemBag->SetTitleColor(INTCOLORTOCCC4(getItemColor(item)));
		
		if (bFocused) 
		{
			std::vector<std::string> vec_str;
			std::vector<int> vec_id;
			vec_str.push_back(NDCommonCString("select")); vec_id.push_back(eOP_Select);
			vec_str.push_back(NDCommonCString("return")); vec_id.push_back(eOP_Cancel);
			InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
		}
	}
	
	if (itembag == m_itemBag && !item) 
	{
		m_itemBag->SetTitle("");
	}
	
	return true;
}

void LifeSkillRandomScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetCancelBtn())
	{
		NDDirector::DefaultDirector()->PopScene();
	}
	else if (button == m_menulayerBG->GetOkBtn())
	{
		std::stringstream strBuf; strBuf << NDCommonCString("UseMaterial") << ": \n";
		for (int i = 0; i < eMaxRandomInfo; i++) 
		{
			if (!m_layerRandomInfo[i] || m_layerRandomInfo[i]->IsEmpty()) 
			{
				std::stringstream ss; 
				ss << (m_iType == eChaoYao ? NDCommonCString("LianYao") : NDCommonCString("HeCheng")) << NDCommonCString("MaterialNeedThree");
				showDialog(NDCommonCString("OperateFail"), ss.str().c_str());
				return;
			} 
			else 
			{
				strBuf << ("    ");
				strBuf << (m_layerRandomInfo[i]->GetText());
				strBuf << "\n";
			}
		}
		strBuf << (m_iType == eChaoYao ? NDCommonCString("LianYao") : NDCommonCString("HeCheng")) << "!";
		
		NDUIDialog *dlg = new NDUIDialog;
		dlg->Initialization();
		dlg->SetDelegate(this);
		dlg->Show(NDCommonCString("WenXinTip"), strBuf.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
	}

}

void LifeSkillRandomScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	ItemMgr& mgr = ItemMgrObj;
	int bagSum = mgr.GetPlayerBagNum() * 24;
	VEC_ITEM& itemList = mgr.GetPlayerBagItems();
	if (int(itemList.size()) >= bagSum) 
	{
		dialog->Close();
		showDialog(NDCommonCString("OperateFail"), NDCommonCString("BagFullTip"));
		return;
	}
	
	NDTransData bao(_MSG_SYNTHESIZE);
	bao << (unsigned char)0 <<  (m_iType == eChaoYao ? ALCHEMY_IDSKILL : GEM_IDSKILL);
	
	for (int i = 0; i < eMaxRandomInfo; i++) 
	{
		if (!m_layerRandomInfo[i] || m_layerRandomInfo[i]->IsEmpty()) 
		{
			std::stringstream ss; 
			ss << (m_iType == eChaoYao ? NDCommonCString("LianYao") : NDCommonCString("HeCheng")) << NDCommonCString("MaterialNeedThree");
			showDialog(NDCommonCString("OperateFail"), ss.str().c_str());
			return;
		}
		
		bao << int(m_layerRandomInfo[i]->GetItem()->iItemType) 
			<< (unsigned char)(m_layerRandomInfo[i]->GetItemCount());
	}
	
	ShowProgressBar;
	SEND_DATA(bao);
	
	dialog->Close();
}

void LifeSkillRandomScene::reset()
{
	for(int i = 0; i < eMaxRandomInfo; i++)
	{
		if (m_layerRandomInfo[i]) 
		{
			m_layerRandomInfo[i]->SetInfo(NULL, 0);
		}
	}
	
	FiltItem(true);
}

void LifeSkillRandomScene::FiltItem(bool isReset)
{
	if (!m_itemBag) 
	{
		return;
	}
	
	VEC_ITEM& itemList = ItemMgrObj.GetPlayerBagItems();
	std::vector<Item*> t_itemList;
	Item *t_item = NULL;
	int iSize = itemList.size();
	
	if (iSize == 0) 
	{
		m_itemBag->UpdateItemBag(t_itemList);
		for(int i = 0; i < eMaxRandomInfo; i++)
		{
			if (m_layerRandomInfo[i]) 
			{
				m_layerRandomInfo[i]->SetInfo(NULL, 0);
			}
		}
		
		return;
	}
	
	for (int i = iSize - 1; i >= 0; i--) 
	{
		t_item = itemList[i];
		std::vector<int> t_itemType = Item::getItemType(t_item->iItemType);
		if (t_itemType[0] == 6
			&& ((m_iType == eChaoYao && t_itemType[1] == 1) || (m_iType == eBaoShiYuanShi && t_itemType[1] == 2))
			) {// 炼药61，合成62
			if (isReset) {
				t_itemList.insert(t_itemList.begin(), t_item);
			} else {
				for (int j = 0; j < eMaxRandomInfo; j++) {// 判断有没被放在材料栏上了
					if (m_layerRandomInfo[j] && m_layerRandomInfo[j]->GetItemID() == t_item->iID
						&& m_layerRandomInfo[j]->GetItemCount() >= t_item->iAmount) 
					{
						break;
					}
					
					if (j == 2) 
					{
						t_itemList.insert(t_itemList.begin(), t_item);
					}
				}
			}
		}
	}
	
	m_itemBag->UpdateItemBag(t_itemList);
	m_itemBag->UpdateTitle();
}

void LifeSkillRandomScene::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
{
#define fastinit(text, iid) \
do \
{ \
NDUIButton *btn = new NDUIButton(); \
btn->Initialization(); \
btn->SetFontSize(15); \
btn->SetTitle(text); \
btn->SetTag(iid); \
btn->SetFontColor(ccc4(255, 255, 255, 255)); \
btn->SetFocusColor(ccc4(253, 253, 253, 255)); \
btn->SetFrameRect(CGRectMake(0, 0, 120, 30)); \
section->AddCell(btn); \
} while (0)
	
	if (!tl || vec_str.empty() || vec_id.empty() || vec_str.size() != vec_id.size() )
	{
		NDLog(@"LifeSkillRandomScene::InitTLContentWithVec初始化失败");
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


