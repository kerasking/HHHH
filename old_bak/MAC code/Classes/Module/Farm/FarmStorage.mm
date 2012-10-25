/*
 *  FarmStorage.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "FarmStorage.h"
#include "NDDirector.h"
#include "define.h"
#include "NDUtility.h"
#include "NDConstant.h"
#include "CGPointExtension.h"
#include "NDDataTransThread.h"
#include "NDTransData.h"
#include "define.h"
#include "NDMsgDefine.h"
#include "GameStorageScene.h"
#include "NDPath.h"
#include <sstream>

class BtnLayer : public NDUILayer
{
	DECLARE_CLASS(BtnLayer)
public:
	bool TouchBegin(NDTouch* touch) override
	{
		m_beginTouch = touch->GetLocation();
		
		if (!CGRectContainsPoint(this->GetScreenRect(), m_beginTouch))
		{
			return false;
		}
		
		std::vector<NDNode*> tmplist = GetChildren();
		
		if (tmplist.empty())
		{
			return false;
		}
		
		std::vector<NDNode*>::iterator it = tmplist.begin();
		for (; it != tmplist.end(); it++) 
		{
			NDNode *node = (*it);
			if (node->IsKindOfClass(RUNTIME_CLASS(NDUINode))) 
			{
				NDUINode *uinode = (NDUINode*)node;
				
				if (!CGRectContainsPoint(uinode->GetScreenRect(), m_beginTouch))
				{
					continue;
				}
				
				if (uinode->IsVisibled() && this->IsVisibled() && this->EventEnabled()) 
				{
					this->DispatchTouchBeginEvent(m_beginTouch);
					return true;
				}
			}
			
		}
		
		return false;
	}
	
	bool TouchEnd(NDTouch* touch) override
	{
		m_endTouch = touch->GetLocation();
		this->DispatchTouchEndEvent(m_beginTouch, m_beginTouch);
		return true;
	}
};

IMPLEMENT_CLASS(BtnLayer, NDUILayer)

IMPLEMENT_CLASS(FarmEntityNode, NDUILayer)

FarmEntityNode::FarmEntityNode()
{
	m_lbTitle = NULL;
	m_btnAdd = NULL;
	m_btnMinus = NULL;
	m_stateBar = NULL;
	m_picAdd = NULL;
	m_picMinus = NULL;
	m_bNeedCacl = false;
	m_bFocus = false;
}

FarmEntityNode::~FarmEntityNode()
{
	SAFE_DELETE(m_picAdd);
	SAFE_DELETE(m_picMinus);
}

void FarmEntityNode::draw()
{
	if (!IsVisibled()) 
	{
		return;
	}
	
	ccColor4B color;
	if (this->GetParent() 
		&& this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDUILayer))
		&& ((NDUILayer*)(this->GetParent()))->GetFocus() == this) 
	{
		color = ccc4(223, 239, 98, 255);
		m_bFocus = true;
	}
	else 
	{
		color = ccc4(223, 239, 98, 0);
		m_bFocus = false;
	}
	
	this->SetBackgroundColor(color);
	
	NDUILayer::draw();
	
	if (m_bNeedCacl) 
	{
		LayOut();
	}
}

void FarmEntityNode::Initialization(NDNode* parent)
{
	NDAsssert(parent != NULL);
	
	BtnLayer *layer = ((FarmStorageDialog*)parent)->GetBtnLayer();
	
	NDAsssert(layer);
	
	NDUILayer::Initialization();
	
	this->SetBackgroundColor(ccc4(255, 255, 255, 0));
	
	//this->SetTouchEnabled(false);
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFrameRect(CGRectZero);
	//m_lbTitle->SetText("test");
	m_lbTitle->SetFontColor(ccc4(11,34,18,255));
	this->AddChild(m_lbTitle);
	
	m_picMinus = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("plusMinus.png"));
	m_picMinus->Cut(CGRectMake(8, 0, 9, 8));
	
	m_picAdd = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("plusMinus.png"));
	m_picAdd->Cut(CGRectMake(0, 0, 8, 8));
	
	m_btnMinus = new NDUIButton;
	m_btnMinus->Initialization();
	m_btnMinus->SetFrameRect(CGRectZero);
	m_btnMinus->SetDelegate(parent);
	layer->AddChild(m_btnMinus);
	
	m_btnAdd = new NDUIButton;
	m_btnAdd->Initialization();
	m_btnAdd->SetFrameRect(CGRectZero);
	m_btnAdd->SetDelegate(parent);
	layer->AddChild(m_btnAdd);
	
	m_stateBar = new NDUIStateBar;
	m_stateBar->Initialization();
	m_stateBar->SetNumber(10, 20, false);
	m_stateBar->ShowNum(true);
	m_stateBar->SetFrameRect(CGRectZero);
	m_stateBar->SetTouchEnabled(false);
	m_stateBar->SetStateColor(INTCOLORTOCCC4(0x0320f6));
	m_stateBar->SetSlideColor(INTCOLORTOCCC4(0x4258fd));
	this->AddChild(m_stateBar);
	
	
	UpdateLayOut();
}

NDUIStateBar* FarmEntityNode::GetStateBar()
{
	return m_stateBar;
}

NDUIButton* FarmEntityNode::GetAddBtn()
{
	return m_btnAdd;
}

NDUIButton* FarmEntityNode::GetMinusBtn()
{
	return m_btnMinus;
}

NDUILabel* FarmEntityNode::GetTitleLabel()
{
	return m_lbTitle;
}

void FarmEntityNode::LayOut()
{
	CGRect rect = GetFrameRect();
	CGRect scrRect = this->GetScreenRect();
	
	int iWidth = rect.size.width, iHeight = rect.size.height;
	
	int iCoodX = 5;
	
	if (m_lbTitle) 
	{
		CGSize size = getStringSize(m_lbTitle->GetText().c_str(), m_lbTitle->GetFontSize());
		
		m_lbTitle->SetFrameRect(CGRectMake(iCoodX, GetY(iHeight, size.height), size.width, size.height));
		
		iCoodX += size.width + 5;
		
		iCoodX = GetX(iWidth, iCoodX);
	}
	
	if (m_btnMinus) 
	{
		CGSize size = m_picMinus->GetSize();
		
		m_btnMinus->SetFrameRect(CGRectMake(iCoodX-5+scrRect.origin.x, 0+scrRect.origin.y, 40, rect.size.height));
		
		m_btnMinus->SetImage(m_picMinus, true, CGRectMake((40-size.width)/2, (rect.size.height-size.height)/2, size.width, size.height), false);
		
		iCoodX += 40 + 2;
		
		iCoodX = GetX(iWidth, iCoodX);
	}
	
	if (m_stateBar) 
	{
		int iStateW = (iWidth-iCoodX-40-2-28);
		if (iStateW < 0) 
		{
			iStateW = 0; 
		}
		
		m_stateBar->SetFrameRect(CGRectMake(iCoodX, 0, iStateW, iHeight));
		
		iCoodX += iStateW + 2;
		
		iCoodX = GetX(iWidth, iCoodX);
	}
	
	if (m_btnAdd) 
	{
		CGSize size = m_picAdd->GetSize();
		
		m_btnAdd->SetFrameRect(CGRectMake(iCoodX+scrRect.origin.x, 0+scrRect.origin.y, 40, rect.size.height));
		
		m_btnAdd->SetImage(m_picAdd, true, CGRectMake((40-size.width)/2, (rect.size.height-size.height)/2, size.width, size.height), false);
	}
}

void FarmEntityNode::UpdateLayOut()
{
	m_bNeedCacl = true;
}

int FarmEntityNode::GetY(int iParentH, int iChildH)
{
	return iChildH >= iParentH ? 0 : (iParentH - iChildH)/2;
}

int FarmEntityNode::GetX(int iParentW, int iChildW)
{
	return iChildW > iParentW ? iParentW : iChildW;
}

bool FarmEntityNode::IsFocus()
{
	return m_bFocus;
}

///////////////////////////////////////////

enum eTLOperate {
	eTLOperateAccess = 88,
	eTLOperateSave,
	eTLOperateClose,
};

IMPLEMENT_CLASS(FarmStorageDialog, NDScene)

FarmStorageDialog* FarmStorageDialog::s_instace = NULL;

FarmStorageDialog* FarmStorageDialog::Show(int lvl, int space)
{
	//NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
//	if (!scene) 
//	{
//		return NULL;
//	}
	
	FarmStorageDialog *dlg = new FarmStorageDialog;
	
	dlg->Initialization(lvl, space);

	NDDirector::DefaultDirector()->PushScene(dlg);
	
	
	return dlg;
}

FarmStorageDialog::FarmStorageDialog()
{
	m_iLvl = 0; m_iSpace = 0; m_iSpaceOp = 0;
	
	m_lbRestSpace = NULL;
	
	m_menulayerBG = NULL;
	
	m_tlMain = NULL;
	
	s_instace = this;
	
	m_iBtnHeight = 0;
	
	m_tlOperate = NULL;
	
	m_timer = new NDTimer();
	
	m_btnOperate = NULL;
	
	m_btnLayer = NULL;
}

FarmStorageDialog::~FarmStorageDialog()
{
	s_instace = NULL;
	
	delete m_timer;
}

void FarmStorageDialog::Initialization(int lvl, int space)
{
	//NDDlgBackGround::Initialization();
	
	NDScene::Initialization();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	this->AddChild(m_menulayerBG);
	
	//if ( m_menulayerBG->GetOkBtn() ) 
//	{
//		m_menulayerBG->GetOkBtn()->SetDelegate(this);
//	}
//	
//	if ( m_menulayerBG->GetCancelBtn() ) 
//	{
//		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
//	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	//this->SetFrameRect(CGRectMake((winsize.width-250)/2, (winsize.height-300)/2, 250, 300));
		
	NDUILabel *lb = new NDUILabel;
	lb->Initialization();
	lb->SetText(NDCString("StorageManage"));
	lb->SetTextAlignment(LabelTextAlignmentCenter);
	lb->SetFontColor(ccc4(0, 0, 0, 255));
	lb->SetFontSize(15);
	lb->SetFrameRect(CGRectMake(0, 5, winsize.width, 21));
	m_menulayerBG->AddChild(lb);
	
	//NDUILine *line = new NDUILine;
//	line->Initialization();
//	line->SetWidth(3);
//	line->SetFromPoint(ccp(17, 23));
//	line->SetToPoint(ccp(233,23));
//	line->SetColor(ccc3(0, 0, 0));
//	line->SetFrameRect(CGRectMake(1, 1, 1, 1));
//	this->AddChild(line);
	
	m_lbRestSpace = new NDUILabel;
	m_lbRestSpace->Initialization();
	m_lbRestSpace->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbRestSpace->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbRestSpace->SetFontSize(15);
	m_lbRestSpace->SetFrameRect(CGRectMake(0, 30, winsize.width, 21));
	m_menulayerBG->AddChild(m_lbRestSpace);
	
	m_btnLayer = new BtnLayer;
	m_btnLayer->Initialization();
	m_btnLayer->SetBackgroundColor(ccc4(255, 255, 255, 0));
	m_btnLayer->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	m_menulayerBG->AddChild(m_btnLayer,100);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->SetDelegate(this);
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetVisible(true);
	m_tlOperate->SetFrameRect(CGRectZero);
	//m_tlMain->SetFrameRect(CGRectMake(MAIN_TB_X, title_height+2, winsize.width-2*MAIN_TB_X, iHeigh));
	m_menulayerBG->AddChild(m_tlOperate);
	
	m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetVisible(false);
	//m_tlMain->SetFrameRect(CGRectMake(MAIN_TB_X, title_height+2, winsize.width-2*MAIN_TB_X, iHeigh));
	m_menulayerBG->AddChild(m_tlMain);
	
	std::vector<std::string> vec_str;
	std::vector<int> vec_id;
	
	vec_str.push_back(NDCString("StorageWuZi")); vec_id.push_back(eTLOperateAccess);
	
	if (lvl > 2) 
	{
		vec_str.push_back(NDCString("StorageWuZiLimit")); vec_id.push_back(eTLOperateSave);
	}
	
	vec_str.push_back(NDCommonCString("close")); vec_id.push_back(eTLOperateClose);
	
	m_iBtnHeight = vec_str.size()*30;
	
	InitTLContentWithVec(m_tlMain, vec_str, vec_id);
	
	SetLeve(lvl);
	SetSpace(space);
}

void FarmStorageDialog::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlMain) 
	{
		int iTag = cell->GetTag();
		switch (iTag) {
			case eTLOperateAccess:
			{
				GameStorageScene *scene = new GameStorageScene;
				scene->Initialization(true);
				NDDirector::DefaultDirector()->PushScene(scene);
			}
				break;
			case eTLOperateSave:
			{
				sendChangeMaxSpace();
			}
				break;
			case eTLOperateClose:
			{
				NDDirector::DefaultDirector()->PopScene();
			};
			default:
				break;
		}
	}
	else if (table == m_tlOperate) 
	{
		//if (this->m_tlOperate->m_beginTouch.x > 266 &&
//			this->m_tlOperate->m_beginTouch.x < 316) 
//		{
//			
//		}
//		else if (this->m_tlOperate->m_beginTouch.x > 366 &&
//				 this->m_tlOperate->m_beginTouch.x < 416)
//		{
//			
//		}
//		
//		NDLog(@"x=[%f],y=[%f]", m_tlOperate->m_beginTouch.x, m_tlOperate->m_beginTouch.y);
	}

}

void FarmStorageDialog::DealButton()
{
	std::vector<FarmEntityData>::iterator it = m_vecFarmEntity.begin();
	for (; it != m_vecFarmEntity.end(); it++) {
		FarmEntityNode *node = (*it).node;
		if (!node || !node->IsFocus()) continue;
		bool bChange = false;
		bool bAdd = false;
		if (node->GetAddBtn() == m_btnOperate) {
			if (m_iSpaceOp >= m_iSpace) {
				return;
			}
			(*it).change++;
			m_iSpaceOp++;
			bChange =true;
			bAdd = true;
		}
		else if (node->GetMinusBtn() == m_btnOperate) {
			//if ((*it).change <= 0) {
//				return;
//			}
			NDUIStateBar *bar = node->GetStateBar();
			if (!bar || bar->GetCurNum() >= bar->GetMaxNum()+(*it).change) 
			{
				return;
			}
			(*it).change--;
			m_iSpaceOp--;
			bChange =true;
		}
		
		if (bChange) {
			ccColor4B color = ccc4(0, 0, 0, 255);
			unsigned int fontsize = 15;
			if ((*it).change != 0) {
				color = ccc4(255, 0, 0, 255);
				fontsize = 18;
			}
			
			NDUIStateBar *bar = node->GetStateBar();
			if (bar) {
				bar->SetLabelMaxNum(color, bar->GetMaxNum()+(bAdd ? 1 : -1), fontsize);
			}
			
			if (m_lbRestSpace) 
			{
				std::stringstream ss; ss << NDCommonCString("RestSpace") << ": " << (m_iSpace-m_iSpaceOp);
				m_lbRestSpace->SetText(ss.str().c_str()); 
			}
			
			return;
		}
	}	
}

void FarmStorageDialog::OnButtonDown(NDUIButton* button)
{
	FarmEntityNode *node = NULL;
	std::vector<FarmEntityData>::iterator it = m_vecFarmEntity.begin();
	for (; it != m_vecFarmEntity.end(); it++) {
		FarmEntityNode *fe = (*it).node;
		if (!fe || !fe->IsFocus()) continue;
		if (!(fe->GetAddBtn() == button || fe->GetMinusBtn())) continue;
		node = fe;
	}
	
	if (!node) {
		return;
	}
	
	m_btnOperate = button;
	
	DealButton();
	
	m_timer->SetTimer(this, 66, 1.0f / 60.0f);
}

void FarmStorageDialog::OnButtonUp(NDUIButton* button)
{
	m_timer->KillTimer(this, 66);
	
	m_btnOperate = NULL;
}

void FarmStorageDialog::OnTimer(OBJID tag)
{
	DealButton();
}

FarmEntityNode* FarmStorageDialog::AddFarmEntity(int iItemType)
{

	if (!m_tlOperate) 
	{
		return NULL;
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDDataSource *dataSource = NULL;
	if (!m_tlOperate->GetDataSource()) 
	{
		dataSource = new NDDataSource;
		m_tlOperate->SetDataSource(dataSource);
	}
	else 
	{
		dataSource = m_tlOperate->GetDataSource();
	}
	
	NDSection *section = NULL;
	if (dataSource->Count() == 0) 
	{
		section = new NDSection;
		//section->UseCellHeight(true);
		dataSource->AddSection(section);
	}
	else 
	{
		section = dataSource->Section(0);
	}
	
	
	FarmEntityNode *node = new FarmEntityNode;
	node->Initialization(this);
	node->SetFrameRect(CGRectMake(0, 0, 450, 30));
	section->AddCell(node);
	
	section->SetFocusOnCell(0);
	
	int iHeight = winsize.height-m_iBtnHeight-55;
	int iH = section->Count()*30;//+section->Count()+1;
	if (iHeight > iH) {
		iHeight = iH;
		m_tlOperate->VisibleScrollBar(true);
	}
	else 
	{
		m_tlOperate->VisibleScrollBar(false);
	}

	
	m_tlOperate->SetFrameRect(CGRectMake(15, 50, 450, iHeight));
	
	m_tlOperate->ReflashData();
	
	FarmEntityData data;
	data.node = node;
	data.itemType = iItemType;
	m_vecFarmEntity.push_back(data);
	
	return node;
}



void FarmStorageDialog::SetLeve(int lvl)
{
	m_iLvl = lvl;
}
	
void FarmStorageDialog::SetSpace(int freeSpace)
{
	m_iSpace = freeSpace;
	
	if (m_lbRestSpace) 
	{
		std::stringstream ss; ss << NDCommonCString("RestSpace") << ": " << freeSpace;
		m_lbRestSpace->SetText(ss.str().c_str()); 
	}
}

FarmEntityNode* FarmStorageDialog::GetFarmEntity(int iTag)
{
	if (m_vecFarmEntity.empty()) {
		return NULL;
	}
	std::vector<FarmEntityData>::iterator it = m_vecFarmEntity.begin();
	for (; it != m_vecFarmEntity.end(); it++) {
		FarmEntityData& data = *it;
		if (data.node && data.node->GetTag() == iTag) {
			return data.node;
		}
	}
	
	return NULL;
}

void FarmStorageDialog::ClearOperateData()
{
	if (m_vecFarmEntity.empty()) {
		return;
	}
	std::vector<FarmEntityData>::iterator it = m_vecFarmEntity.begin();
	for (; it != m_vecFarmEntity.end(); it++) {
		FarmEntityData& data = *it;
		data.change = 0;
	}
	
	m_iSpaceOp = 0;
}

void FarmStorageDialog::sendChangeMaxSpace() 
{
	int iChangeCount = 0, iChange = 0;
	std::vector<FarmEntityData>::iterator it = m_vecFarmEntity.begin();
	for (; it != m_vecFarmEntity.end(); it++) {
		FarmEntityData& data = *it;
		if (data.change > 0 && data.node && data.node->GetStateBar()) {
			iChangeCount++;
			iChange += data.change;
		}
	}
	
	if (m_iSpaceOp != iChange || m_iSpaceOp > m_iSpace) {
		return;
	}
	
	NDTransData bao(_MSG_FARM_STORAGE);
	bao << (unsigned char)1 << int(0) << int(0) << (unsigned char)iChangeCount;

	do {
		std::vector<FarmEntityData>::iterator it = m_vecFarmEntity.begin();
		for (; it != m_vecFarmEntity.end(); it++) {
			FarmEntityData& data = *it;
			if (data.change > 0 && data.node && data.node->GetStateBar()) {
				bao << (int)data.node->GetTag() 
				<< (int)(data.node->GetStateBar()->GetMaxNum());
			}
		}
	} while (0);
	
	SEND_DATA(bao);
}

void FarmStorageDialog::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
{
#define fastinit(text, iid) \
do \
{ \
NDUIButton *btn = new NDUIButton(); \
btn->Initialization(); \
btn->SetFontSize(15); \
btn->SetTitle(text); \
btn->SetTag(iid); \
btn->SetFontColor(ccc4(0, 0, 0, 255)); \
btn->SetFrameRect(CGRectMake(0, 0, 480, 30)); \
btn->SetFocusColor(ccc4(255, 207, 74, 255)); \
section->AddCell(btn); \
} while (0)
	
	if (!tl || vec_str.empty() || vec_id.empty() || vec_str.size() != vec_id.size() )
	{
		NDLog(@"FarmStorageDialog::InitTLContentWithVec初始化失败");
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
	
	tl->SetFrameRect(CGRectMake(0, 320-30*vec_str.size()-vec_str.size()-1, 480, 30*vec_str.size()+vec_str.size()+1));
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