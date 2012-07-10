/*
 *  LifeSkillScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "LifeSkillScene.h"
#include "define.h"
#include "NDUtility.h"
#include "GameUITaskList.h"
#include "NDDirector.h"
#include "NDMapMgr.h"
#include "ItemMgr.h"
#include "NDUISynLayer.h"
#include "FormulaMaterialData.h"
#include <sstream>

struct FormulaLvlLessThan
{
	bool operator () (int first, int second)	
	{
		NDMapMgr& mgr = NDMapMgrObj;
		FormulaMaterialData * firstobj = mgr.getFormulaData(first);
		FormulaMaterialData * secondobj = mgr.getFormulaData(second);
		if (!firstobj || !secondobj)
		{
			return false;
		}
		return firstobj->grade < secondobj->grade;
	}
};

//////////////////////////////////////
#define title_height (28)
#define bottom_height (42)

#define info_x (10)
#define info_y (title_height+5)

#define BTN_W (85)
#define BTN_H (23)

enum  
{
	eOP_Begin = 0,
	eOP_Query = eOP_Begin,
	eOP_Product,
	eOP_End,
};


IMPLEMENT_CLASS(LifeSkillScene, NDScene)

LifeSkillScene::LifeSkillScene()
{
	m_menulayerBG			= NULL;
	m_lbTitle				= NULL;
	m_lbLvl					= NULL;
	m_imageExp				= NULL;
	m_picExp				= NULL;
	m_stateSkillVal			= NULL;
	m_imagenumSkillVal		= NULL;
	m_layerSubTitile		= NULL;
	m_crBG					= NULL;
	m_tlContent				= NULL;
	m_btnPrev				= NULL;
	m_picPrev				= NULL;
	m_btnNext				= NULL;
	m_picNext				= NULL;
	m_lbPage				= NULL;
	m_formulaDialog			= NULL;
	m_dlgProduct			= NULL;
	
	m_iType = 0;
	m_iOpenType = 0;
	m_iCurPage = 0;
	m_iMaxPage = 0;
	
	m_iProductFormulaID = 0;
}

LifeSkillScene::~LifeSkillScene()
{
	SAFE_DELETE(m_picExp);
	SAFE_DELETE(m_picPrev);
	SAFE_DELETE(m_picNext);
}

void LifeSkillScene::Initialization(int iType, int iOpen)
{
	NDScene::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	this->AddChild(m_menulayerBG);
	
	if (m_menulayerBG->GetCancelBtn()) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	std::string strTitle = ALCHEMY_IDSKILL == iType ? NDCommonCString("LianYao") : NDCommonCString("BaoShiHeCheng");
	CGSize dim = getStringSizeMutiLine(strTitle.c_str(), 15);
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 245, 0, 255));
	m_lbTitle->SetFrameRect(CGRectMake((winsize.width-dim.width)/2, (title_height-dim.height)/2, dim.width, dim.height));
	m_lbTitle->SetText(strTitle.c_str());
	m_menulayerBG->AddChild(m_lbTitle);
	
	m_lbLvl = new NDUILabel;
	m_lbLvl->Initialization();
	m_lbLvl->SetFontSize(15);
	m_lbLvl->SetFontColor(ccc4(244, 248, 255, 255));
	m_lbLvl->SetFrameRect(CGRectMake(info_x, info_y, 45, 15));
	m_lbLvl->SetText("LV1");
	m_menulayerBG->AddChild(m_lbLvl);
	
	m_picExp = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("exp.png"));
	CGSize sizeExp = m_picExp->GetSize();
	
	m_imageExp =  new NDUIImage;
	m_imageExp->Initialization();
	m_imageExp->SetPicture(m_picExp);
	m_imageExp->SetFrameRect(CGRectMake(info_x+40, info_y+5, sizeExp.width, sizeExp.height));
	m_menulayerBG->AddChild(m_imageExp);
	
	m_stateSkillVal = new NDUIStateBar();
	m_stateSkillVal->Initialization();
	m_stateSkillVal->ShowNum(false);
	m_stateSkillVal->SetFrameRect(CGRectMake(info_x+40+sizeExp.width+2, info_y+3, 102, 13));
	m_stateSkillVal->SetNumber(125, 7789);
	m_stateSkillVal->SetStateColor(ccc4(192,162,18,255));
	m_menulayerBG->AddChild(m_stateSkillVal);
	
	m_imagenumSkillVal = new ImageNumber;
	m_imagenumSkillVal->Initialization();
	m_imagenumSkillVal->SetTitleRedTwoNumber(125,7789);
	m_imagenumSkillVal->SetFrameRect(CGRectMake(info_x+40+sizeExp.width+2+102+3, info_y+5, 100, 11));
	m_menulayerBG->AddChild(m_imagenumSkillVal);
	
	m_layerSubTitile = new NDUILayer;
	m_layerSubTitile->Initialization();
	m_layerSubTitile->SetBackgroundColor(ccc4(222, 217, 135, 255));
	m_layerSubTitile->SetFrameRect(CGRectMake(info_x, info_y+20, winsize.width-2*info_x, 24));
	m_menulayerBG->AddChild(m_layerSubTitile);
	
	NDUILabel *lb = new NDUILabel;
	lb->Initialization();
	lb->SetFontSize(15);
	lb->SetFontColor(ccc4(0, 0, 0, 255));
	lb->SetTextAlignment(LabelTextAlignmentCenter);
	lb->SetFrameRect(CGRectMake(0, 0, winsize.width-2*info_x, 24));
	lb->SetText(NDCommonCString("PeiFangList"));
	m_layerSubTitile->AddChild(lb);
	
	m_crBG = new NDUICircleRect;
	m_crBG->Initialization();
	m_crBG->SetRadius(10);
	m_crBG->SetFillColor(ccc4(177, 185, 172, 255));
	m_crBG->SetFrameColor(ccc4(0, 0, 0, 255));
	m_crBG->SetFrameRect(CGRectMake(info_x, info_y+20+24+5, winsize.width-2*info_x, 175));
	m_menulayerBG->AddChild(m_crBG);
	
	CGRect rect = m_crBG->GetFrameRect();
	m_tlContent = new NDUITableLayer;
	m_tlContent->Initialization();
	m_tlContent->VisibleSectionTitles(false);
	m_tlContent->VisibleScrollBar(true);
	m_tlContent->SetFrameRect(CGRectMake(rect.origin.x+5, rect.origin.y+5, rect.size.width-10, rect.size.height-10));
	m_tlContent->SetVisible(false);
	m_tlContent->SetDelegate(this);
	m_menulayerBG->AddChild(m_tlContent);
	
	m_picPrev = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picPrev->Cut(CGRectMake(319, 144, 48, 19));
	CGSize prevSize = m_picPrev->GetSize();
	
	m_picNext = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picNext->Cut(CGRectMake(318, 164, 47, 17));
	CGSize nextSize = m_picNext->GetSize();
	
	m_btnPrev = new NDUIButton();
	m_btnPrev->Initialization();
	m_btnPrev->SetFrameRect(CGRectMake((winsize.width-BTN_W*2)/2, winsize.height-bottom_height-BTN_H, BTN_W, BTN_H));
	m_btnPrev->SetImage(m_picPrev, true,CGRectMake((BTN_W-prevSize.width)/2, (BTN_H-prevSize.height)/2, prevSize.width, prevSize.height));
	m_btnPrev->SetDelegate(this);
	m_menulayerBG->AddChild(m_btnPrev);
	
	m_btnNext = new NDUIButton();
	m_btnNext->Initialization();
	m_btnNext->SetFrameRect(CGRectMake((winsize.width-BTN_W*2)/2+BTN_W, winsize.height-bottom_height-BTN_H, BTN_W, BTN_H));
	m_btnNext->SetImage(m_picNext, true,CGRectMake((BTN_W-nextSize.width)/2, (BTN_H-nextSize.height)/2, nextSize.width, nextSize.height));
	m_btnNext->SetDelegate(this);
	m_menulayerBG->AddChild(m_btnNext);
	
	m_lbPage = new NDUILabel;
	m_lbPage->Initialization();
	m_lbPage->SetFontSize(15);
	m_lbPage->SetFontColor(ccc4(17, 9, 144, 255));
	m_lbPage->SetTextAlignment(LabelTextAlignmentCenter); 
	m_lbPage->SetFrameRect(CGRectMake(0, winsize.height-bottom_height-BTN_H, winsize.width, BTN_H));
	m_lbPage->SetText("1/1");
	m_menulayerBG->AddChild(m_lbPage);
	
	m_iType = iType;
	m_iOpenType = iOpen;
	
	if (iOpen == LifeSkillScene_Query) 
	{
		m_btnPrev->SetVisible(false);
		m_btnNext->SetVisible(false);
		m_lbPage->SetVisible(false);
	}
	
	LoadData();
	UpdateGUI();
	UpdateSkillData();
}

void LifeSkillScene::UpdateSkillData()
{
	NDMapMgr& mgr = NDMapMgrObj;
	LifeSkill *skill = mgr.getLifeSkill(m_iType);
	if (!skill) 
	{
		return;
	}
	
	std::stringstream sslvl; 
	sslvl << "LV" << int(skill->uSkillGrade);
	
	if (m_lbLvl) 
	{
		m_lbLvl->SetText(sslvl.str().c_str());
	}
	
	if (m_stateSkillVal) 
	{
		m_stateSkillVal->SetNumber(skill->uSkillExp, skill->uSkillExp_max);
	}
	
	if (m_imagenumSkillVal) 
	{
		m_imagenumSkillVal->SetTitleRedTwoNumber(skill->uSkillExp, skill->uSkillExp_max);
	}
}

void LifeSkillScene::LoadData()
{
	m_vecFormula.clear();
	NDMapMgr& mgr = NDMapMgrObj;
	
	mgr.getFormulaBySkill(m_iType, m_vecFormula);
	
	if (!m_vecFormula.empty()) 
	{
		std::sort(m_vecFormula.begin(), m_vecFormula.end(), FormulaLvlLessThan());
	}

	
	int totalSyndicates = m_vecFormula.size();
	if (totalSyndicates % 10 == 0 && totalSyndicates != 0) 
	{
		m_iMaxPage = totalSyndicates / 10;
	} 
	else 
	{
		m_iMaxPage = totalSyndicates / 10 + 1;
	}
}

void LifeSkillScene::UpdateGUI()
{
	int iSize = m_vecFormula.size();
	std::vector<std::string> vec_str; std::vector<int> vec_id;
	NDMapMgr& mgr = NDMapMgrObj;
	int i = m_iOpenType == LifeSkillScene_Query ? 0 : m_iCurPage * 10;
	
	for (int j = 0; i < iSize; i++, j++) 
	{
		if (j >= 10 && m_iOpenType != LifeSkillScene_Query)
			break;
		FormulaMaterialData *data = mgr.getFormulaData(m_vecFormula[i]);
		if (!data) 
		{
			continue;
		}
		vec_str.push_back(data->formulaName);
		vec_id.push_back(m_vecFormula[i]);
	}
	InitTLContentWithVec(m_tlContent,vec_str, vec_id);
	
	std::stringstream sspage; sspage << m_iCurPage+1 << "/" << m_iMaxPage;
	if (m_lbPage) 
	{
		m_lbPage->SetText(sspage.str().c_str());
	}
}

void LifeSkillScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetCancelBtn())
	{
		NDDirector::DefaultDirector()->PopScene();
	}
	else if (button == m_btnPrev)
	{
		if (m_iCurPage > 0) 
		{
			m_iCurPage--;
			UpdateGUI();
		} 
		else
		{
			showDialog(NDCommonCString("WenXinTip"), NDCommonCString("FirstPageTip"));
		}
	}
	else if (button == m_btnNext)
	{
		if (m_iCurPage+1 < m_iMaxPage)
		{
			m_iCurPage++;
			UpdateGUI();
		} 
		else
		{
			showDialog(NDCommonCString("WenXinTip"), NDCommonCString("LastPageTip"));
		}
	}
}

void LifeSkillScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlContent && cell->IsKindOfClass(RUNTIME_CLASS(NDUITBCellLayer))) 
	{
		int iFormulaID = cell->GetTag();
		
		m_vecOperate.clear();
		
		m_formulaDialog = new FormulaInfoDialog;
		m_formulaDialog->Initialization();
		std::vector<std::string> vec_str;
		vec_str.push_back(NDCommonCString("ChaKang")); m_vecOperate.push_back(eOP_Query);
		if( m_iOpenType == LifeSkillScene_Product)
		{
			vec_str.push_back(m_iType == ALCHEMY_IDSKILL ? NDCommonCString("LianYao") : NDCommonCString("HeCheng"));
			m_vecOperate.push_back(eOP_Product);
		}
		m_formulaDialog->SetDelegate(this);
		m_formulaDialog->Show(iFormulaID, NDCommonCString("Cancel"), vec_str);
	}
}

void LifeSkillScene::OnFormulaInfoDialogClose(FormulaInfoDialog* dialog)
{
	m_formulaDialog = NULL;
	m_vecOperate.clear();
}

void LifeSkillScene::OnFormulaInfoDialogClick(FormulaInfoDialog* dialog, unsigned int buttonIndex)
{
	if (dialog == m_formulaDialog && buttonIndex < m_vecOperate.size()) 
	{
		int op = m_vecOperate[buttonIndex];
		int iFomulaID = dialog->GetFormulaID();
		if (op == eOP_Query) 
		{
			FormulaMaterialData *formuladata = NDMapMgrObj.getFormulaData(iFomulaID);
			
			if ( formuladata )
			{
				formuladata->showDetailDialog();
			}
		}
		else if (op == eOP_Product)
		{
			//m_iType == ALCHEMY_IDSKILL ? "炼药" :　NDCommonCString("HeCheng")
//			
//			openInputForm((FormulaMaterialData) v.parama);

			NDUICustomView *view = new NDUICustomView;
			view->Initialization();
			view->SetDelegate(this);
			view->SetTag(iFomulaID);
			std::vector<int> vec_id; vec_id.push_back(1);
			std::vector<std::string> vec_str; vec_str.push_back(NDCommonCString("InputAmount"));
			view->SetEdit(1, vec_id, vec_str);
			view->Show();
			this->AddChild(view);
		}
		
		dialog->Close();
	}
}

bool LifeSkillScene::OnCustomViewConfirm(NDUICustomView* customView)
{
	VerifyViewNum(*customView);
	std::string stramount =	customView->GetEditText(0);
	if (!stramount.empty())
	{
		int useCount = atoi(stramount.c_str());
		if(useCount <= 0){
			customView->ShowAlert(NDCommonCString("OperateFailCantZero"));
			return false;
		}
		
		int iFomulaID = customView->GetTag();
		
		FormulaMaterialData *formuladata = NDMapMgrObj.getFormulaData(iFomulaID);
		
		if ( !formuladata )
		{
			return true;
		}
		
		std::stringstream strBuf;
		strBuf << NDCommonCString("UseMaterial") << ": \n";
		strBuf << ("    ");
		strBuf << (Item(formuladata->itemType1).getItemName());
		strBuf << (" X ");
		strBuf << (formuladata->itemCount1 * useCount);
		strBuf << ("\n");
		strBuf << ("    ");
		strBuf << (Item(formuladata->itemType2).getItemName());
		strBuf << (" X ");
		strBuf << (formuladata->itemCount2 * useCount);
		strBuf << ("\n");
		strBuf << ("    ");
		strBuf << (Item(formuladata->itemType3).getItemName());
		strBuf << (" X ");
		strBuf << formuladata->itemCount3 * useCount << "\n";
		if (formuladata->need_Money > 0) {
			strBuf << ("    ");
			strBuf << (NDCommonCString("money"));
			strBuf << formuladata->need_Money * useCount << "\n";
		}
		if (formuladata->need_EMoney > 0) {
			strBuf << ("    ");
			strBuf << (NDCommonCString("emoney"));
			strBuf << formuladata->need_EMoney * useCount << "\n";
		}
		strBuf << (m_iType == GEM_IDSKILL ? NDCommonCString("HeCheng") : NDCommonCString("ZhiZhuo") );
		strBuf << (formuladata->getProductItemsName());
		strBuf << (" X ");
		strBuf << (useCount);
		
		m_dlgProduct = new NDUIDialog;
		m_dlgProduct->Initialization();
		m_dlgProduct->SetDelegate(this);
		m_dlgProduct->Show(formuladata->formulaName.c_str(), strBuf.str().c_str(),NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
		m_dlgProduct->SetTag(useCount);
		m_iProductFormulaID = iFomulaID;
	}
	return true;
}

void LifeSkillScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (dialog == m_dlgProduct && m_iProductFormulaID != 0) 
	{
		int iCount = dialog->GetTag();
		FormulaMaterialData *formuladata = NDMapMgrObj.getFormulaData(m_iProductFormulaID);
		
		if ( formuladata )
		{
			ItemMgr& mgr = ItemMgrObj;
			int bagSum = mgr.GetPlayerBagNum() * 24;
			if (int( mgr.GetPlayerBagItems().size()) >= bagSum) 
			{
				showDialog(NDCommonCString("OperateFail"), NDCommonCString("BagFullTip"));
			}
			else 
			{
				ShowProgressBar;
				NDTransData bao(_MSG_SYNTHESIZE);
				bao << (unsigned char)1 << int(m_iProductFormulaID) << (unsigned char)iCount;
				SEND_DATA(bao);
			}
		}
		
		dialog->Close();
	}
}

void LifeSkillScene::OnDialogClose(NDUIDialog* dialog)
{
	m_dlgProduct = NULL;
	m_iProductFormulaID = 0;
}

void LifeSkillScene::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
{

	if (!tl || vec_str.empty() || vec_id.empty() || vec_str.size() != vec_id.size() )
	{
		NDLog(@"LifeSkillScene::InitTLContentWithVec初始化失败");
		return;
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	
	int iSize = vec_str.size();
	bool bChangeClr = false;
	for (int i = 0; i < iSize; i++)
	{
		std::string str = vec_str[i]; int iTag = vec_id[i];
		NDUITBCellLayer *layer = new NDUITBCellLayer;
		layer->Initialization();
		layer->SetBorder(false);
		layer->SetTag(iTag);
		layer->SetFrameRect(CGRectMake(0, 0, winsize.width-2*info_x-10, 25));
		
		NDUILabel *lbTxt = new NDUILabel();
		lbTxt->Initialization();
		lbTxt->SetTextAlignment(LabelTextAlignmentCenter);
		lbTxt->SetFontSize(15);
		lbTxt->SetText(str.c_str());
		lbTxt->SetFontColor(ccc4(26, 34, 21, 255));
		lbTxt->SetFrameRect(CGRectMake(0, (25-15)/2, winsize.width-2*info_x-10, 15));
		layer->AddChild(lbTxt);
		
		if (bChangeClr) {
			layer->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
		} else {
			layer->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
		}
		
		bChangeClr = !bChangeClr;
		
		section->AddCell(layer);
	}
	
	dataSource->AddSection(section);
	
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
}
