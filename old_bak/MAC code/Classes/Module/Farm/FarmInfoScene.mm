/*
 *  FarmInfoScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "FarmInfoScene.h"
#include "GameUIAttrib.h"
#include "GameUIPlayerList.h"
#include "NDUITimeStateBar.h"
#include "NDDirector.h"
#include "NDTransData.h"
#include "ItemMgr.h"
#include "NDItemType.h"
#include "NDMsgDefine.h"
#include "NDDataTransThread.h"
#include "CGPointExtension.h"
#include "NDUtility.h"
#include "NDMapMgr.h"
#include "FarmMgr.h"
#include "NDPath.h"
#include <sstream>

#pragma mark 属性cell

IMPLEMENT_CLASS(NDFarmPropCell, NDUINode)

NDFarmPropCell::NDFarmPropCell()
{
	m_lbKey = m_lbValue = NULL;
	
	m_picBg = m_picFocus = NULL;
	
	m_clrNormalText = ccc4(79, 79, 79, 255);
	m_clrFocusText = ccc4(146, 0, 0, 255);
	
	m_imageStateBar = NULL;
	
	m_restime = 0;
	m_totaltime = 0;
	
	m_timer = NULL;
	
	m_begintime = 0.0f;
	
	m_bFinish = false;
	
	m_strFinish = "";
	
	iType = 0;
	iParam = 0;
	
	m_fPercent = 0.0f;
	
	m_rectProcess = NULL;
}

NDFarmPropCell::~NDFarmPropCell()
{
	if (m_timer)
	{
		m_timer->KillTimer(this, 1010);
		delete m_timer;
		m_timer = NULL;
	}
}

void NDFarmPropCell::Initialization(std::string str, int t, int r)
{
	NDUINode::Initialization();
	
	m_totaltime = t; m_restime = r;
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	//int width = 238, height = 23;
	
	m_picBg = pool.AddPicture(NDPath::GetImgPathNew("attr_listitem_bg.png"), 0, 23);
	
	CGSize sizeBg = m_picBg->GetSize();
	
	this->SetFrameRect(CGRectMake(0, 0, 238, 23));
	
	m_picFocus = pool.AddPicture(NDPath::GetImgPathNew("selected_item_bg.png"), 238, 0);
	
	m_lbKey = new NDUILabel;
	m_lbKey->Initialization();
	m_lbKey->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbKey->SetFontSize(14);
	m_lbKey->SetFontColor(m_clrNormalText);
	m_lbKey->SetText(str.c_str());
	this->AddChild(m_lbKey);
	
	m_imageStateBar = new NDUIImage;
	m_imageStateBar->Initialization();
	m_imageStateBar->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("new_statebar.png"), 90, 0), true);
	m_imageStateBar->SetFrameRect(CGRectMake(238-90-4, 0, 90, 18));
	this->AddChild(m_imageStateBar);
	
	m_rectProcess = new NDUIRecttangle;
	m_rectProcess->Initialization();
	m_rectProcess->SetColor(ccc4(126, 0, 0, 255));
	m_imageStateBar->AddChild(m_rectProcess);
	
	m_lbValue = new NDUILabel;
	m_lbValue->Initialization();
	m_lbValue->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbValue->SetFontSize(14);
	m_lbValue->SetFontColor(ccc4(255, 255, 255, 255));
	m_lbValue->SetFrameRect(CGRectMake(0, 0, 90, 18));
	m_imageStateBar->AddChild(m_lbValue);
	
	SetTime(m_restime, m_totaltime);
}

void NDFarmPropCell::draw()
{
	if (!this->IsVisibled()) return;
	
	CGRect scrRect = this->GetScreenRect();
	
	NDNode *parent = this->GetParent();
	
	NDPicture * pic = NULL;
	
	if (parent && parent->IsKindOfClass(RUNTIME_CLASS(NDUILayer)) && ((NDUILayer*)parent)->GetFocus() == this)
	{
		pic = m_picFocus;
		if (m_lbKey) {
			m_lbKey->SetFontColor(m_clrFocusText);
		}
	}
	else
	{
		pic = m_picBg;
		if (m_lbKey) {
			m_lbKey->SetFontColor(m_clrNormalText);
		}
	}
	
	if (pic)
	{
		CGSize size = pic->GetSize();
		pic->DrawInRect(CGRectMake(scrRect.origin.x+(scrRect.size.width-size.width)/2, 
								   scrRect.origin.y+(scrRect.size.height-size.height)/2, 
								   size.width, size.height));
		
		size.height += (scrRect.size.height-size.height)/2;
		
		if (m_lbKey)
		{
			CGRect rect;
			rect.origin = ccp(2, (size.height-m_lbKey->GetFontSize())/2);
			rect.size = size;
			m_lbKey->SetFrameRect(rect);
		}
		
		if (m_imageStateBar)
		{
			CGRect rect = m_imageStateBar->GetFrameRect();
			rect.origin.y = (size.height-rect.size.height)/2;
			m_imageStateBar->SetFrameRect(rect);
			
			rect.size.width *= m_fPercent < 0.0f ? 0.0f : (m_fPercent > 1.0f ? 1.0f : m_fPercent);
			rect.origin = ccp(0.0f, 0.0f);
			if (m_rectProcess)
				m_rectProcess->SetFrameRect(rect);

		}
	}
	
}

void NDFarmPropCell::SetTime(unsigned long rest, unsigned long total)
{
	if (!m_timer) 
	{
		m_timer = new NDTimer;
		m_timer->SetTimer(this, 1010, 1.0f);
	}
	
	m_restime = rest;
	m_totaltime = total;
	m_bFinish = false;
	m_begintime = [NSDate timeIntervalSinceReferenceDate];
	
	OnTimer(0);
}

void NDFarmPropCell::OnTimer(OBJID tag)
{
	if (!(tag == 1010 || tag == 0)) return;
	
	int rest = (int) (m_restime - ([NSDate timeIntervalSinceReferenceDate] - m_begintime));
	if (rest < 0) {
		rest = 0;
	}
	
	m_fPercent = m_totaltime == 0 ? 0 : (((float)(m_totaltime-rest))/m_totaltime);
	
	//this->SetPercent(percent);
	
	std::stringstream sb;
	if (m_restime >= 3600) {
		int h = rest / 3600;
		if (h > 9) {
			sb << h << ":";
		} else {
			sb << "0" << h << ":";
		}
	} else {
		sb << ("00:");
	}
	
	if (rest >= 60) {
		int m = (rest % 3600) / 60;
		if (m > 9) {
			sb << m << ":";
		} else {
			sb << "0" << m << ":";
		}
	} else {
		sb << "00:";
	}
	
	int s = rest % 60;
	if (s > 9) {
		sb << (s);
	} else {
		sb << "0" << s;
	}
	
	if(rest<=0){
		m_bFinish=true;
		m_timer->KillTimer(this, 1010);
		delete m_timer;
		m_timer = NULL;
		
		//NDUITimeStateBarDelegate* delegate = dynamic_cast<NDUITimeStateBarDelegate*> (this->GetDelegate());
		//if (delegate) 
		//{
		//	delegate->OnTimeStateBarFinish(this);
		//}
	}
	
	if (m_lbValue)
	{
		m_lbValue->SetText(!m_bFinish || m_strFinish.empty() ? sb.str().c_str() : m_strFinish.c_str());
		
		if (m_bFinish)
			m_lbValue->SetFontColor(ccc4(255, 248, 198, 255));
	}
}

void NDFarmPropCell::SetFinishText(std::string text)
{
	m_strFinish = text;
	if (m_bFinish && m_lbValue) 
	{
		m_lbValue->SetText(m_strFinish.c_str());
		
		m_lbValue->SetFontColor(ccc4(255, 248, 198, 255));
	}
}

void NDFarmPropCell::ReduceRestTime(unsigned long add)
{
	if (m_restime < add) {
		m_restime = 0;
	}
	else 
	{
		m_restime -= add;
	}
}
/////////////////////////////////////////
#pragma mark 新的农场动态

IMPLEMENT_CLASS(FarmInfoLayer, NDUILayer)

std::vector<FarmResource> FarmInfoLayer::vec_farm_rsc;
std::vector<NDFarmPropCell*> FarmInfoLayer::vec_farm_status;
FarmInfoLayer* FarmInfoLayer::s_intance = NULL;

FarmInfoLayer::FarmInfoLayer()
{
	m_tbTrends = NULL;
	
	m_layerFarmState = NULL;
	
	m_scrollCurRes = NULL;
	m_scrollMainRes = NULL;
	
	s_intance = this;
}

FarmInfoLayer::~FarmInfoLayer()
{
	s_intance = NULL;
	
	for_vec(vec_farm_status, std::vector<NDFarmPropCell*>::iterator)
	{
		if ((*it)->GetParent() == NULL)
		{
			delete *it;
		}
	}
	
	vec_farm_status.clear();
	
	vec_farm_rsc.clear();
}

FarmInfoLayer* FarmInfoLayer::GetInstance()
{
	return s_intance;
}

void FarmInfoLayer::addState(int iType, std::string des, int totalTime, int restTime,int param)
{
	NDFarmPropCell *status = new NDFarmPropCell();
	status->Initialization(des, totalTime, restTime);
	status->iType = iType;
	status->iParam = param;
	
	if(iType==3)
	{
		status->SetFinishText(NDCommonCString("finish"));
	}
	else if(iType==4)
	{
		status->SetFinishText(NDCommonCString("ChengShou"));
	}
	
	vec_farm_status.push_back(status);
}

void FarmInfoLayer::addFarmTotalResource(int itemtypes, int total, int need)
{
	FarmResource fs;
	fs.num = total;
	fs.need_num = need;
	NDItemType *obj = ItemMgrObj.QueryItemType(itemtypes);
	if (obj) 
	{
		fs.name = obj->m_name;
	}
	
	vec_farm_rsc.push_back(fs);
}

void FarmInfoLayer::Initialization()
{	
	NDUILayer::Initialization();
	
	InitResurce();
	
	m_layerFarmState = new NDUILayer;
	
	m_layerFarmState->Initialization();
	
	m_tbTrends = new NDUITableLayer;
	
	m_tbTrends->Initialization();
	
	int width = 252;//, height = 274;
	do 
	{
		m_tbTrends = new NDUITableLayer;
		m_tbTrends->Initialization();
		m_tbTrends->SetBackgroundColor(ccc4(0, 0, 0, 0));
		m_tbTrends->VisibleSectionTitles(false);
		m_tbTrends->SetFrameRect(CGRectMake(6, 17, width-10, 226));
		m_tbTrends->VisibleScrollBar(false);
		m_tbTrends->SetCellsInterval(2);
		m_tbTrends->SetCellsRightDistance(0);
		m_tbTrends->SetCellsLeftDistance(0);
		m_tbTrends->SetDelegate(this);
		
		NDDataSource *dataSource = new NDDataSource;
		NDSection *section = new NDSection;
		section->UseCellHeight(true);
		
		for_vec(vec_farm_status, std::vector<NDFarmPropCell*>::iterator)
		{
			section->AddCell(*it);
		}
		
		vec_farm_status.clear();
		
		dataSource->AddSection(section);
		m_tbTrends->SetDataSource(dataSource);
		m_layerFarmState->AddChild(m_tbTrends);
	} while (0);
}

void FarmInfoLayer::InitTrends(NDUINode* parent)
{
	if (!parent || !m_layerFarmState) return;
	
	CGSize size = parent->GetFrameRect().size;
	m_layerFarmState->SetFrameRect(CGRectMake(0, 0, size.width, size.height));
	
	parent->AddChild(m_layerFarmState);
}

void FarmInfoLayer::addBuildSpeed(int iID, int time)
{
	std::vector<NDFarmPropCell*>::iterator it = vec_farm_status.begin();
	for (; it != vec_farm_status.end(); it++) 
	{
		NDFarmPropCell* node = *it;
		if (node->iParam == iID) 
		{
			node->ReduceRestTime(time);
			break;
		}
	}
}

void FarmInfoLayer::cancelBuilding(int iID)
{
	NDFarmPropCell *node = NULL;
	std::vector<NDFarmPropCell*>::iterator it = vec_farm_status.begin();
	for (; it != vec_farm_status.end(); it++) 
	{
		if ((*it)->iParam == iID) 
		{
			node = *it;
			break;
		}
	}
	
	if (m_tbTrends 
		&& m_tbTrends->GetDataSource() 
		&& m_tbTrends->GetDataSource()->Section(0)) 
	{
		NDSection* section = m_tbTrends->GetDataSource()->Section(0);
		
		section->RemoveCell(node);
		
		m_tbTrends->ReflashData();
	}
}

void FarmInfoLayer::InitResurce()
{
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture* picBagLeftBg = pool.AddPicture(NDPath::GetImgPathNew("bag_left_bg.png"));
	
	CGSize sizeBagLeftBg = picBagLeftBg->GetSize();
	
	NDUILayer *layerBg = new NDUILayer;
	layerBg->Initialization();
	layerBg->SetFrameRect(CGRectMake(0,12, sizeBagLeftBg.width, sizeBagLeftBg.height));
	layerBg->SetBackgroundImage(picBagLeftBg, true);
	this->AddChild(layerBg);
	
	NDUIImage *imageRes = new NDUIImage;
	imageRes->Initialization();
	imageRes->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("farmrheadtitle.png")), true);
	imageRes->SetFrameRect(CGRectMake(5, 10, 8, 8));
	layerBg->AddChild(imageRes);
	
	NDUILabel *lbCurRes = new NDUILabel;
	lbCurRes->Initialization();
	lbCurRes->SetFontSize(14);
	lbCurRes->SetFontColor(ccc4(148, 6, 5, 255));
	lbCurRes->SetTextAlignment(LabelTextAlignmentLeft);
	lbCurRes->SetText(NDCString("CurRes"));
	lbCurRes->SetFrameRect(CGRectMake(16, 7, sizeBagLeftBg.width, sizeBagLeftBg.height));
	layerBg->AddChild(lbCurRes);
	
	NDPicture* picRoleBg = pool.AddPicture(NDPath::GetImgPathNew("attr_role_bg.png"), 0, 104);
	
	CGSize sizeRoleBg = picRoleBg->GetSize();
	
	NDUILayer *layerCurRes = new NDUILayer;
	layerCurRes->Initialization();
	layerCurRes->SetFrameRect(CGRectMake(0,24, sizeRoleBg.width, sizeRoleBg.height));
	layerCurRes->SetBackgroundImage(picRoleBg, true);
	layerBg->AddChild(layerCurRes);
	
	m_scrollCurRes = new NDUIContainerScrollLayer;
	m_scrollCurRes->Initialization();
	m_scrollCurRes->SetFrameRect(CGRectMake(6, 10, sizeRoleBg.width-12, sizeRoleBg.height-20));
	//scrollCurRes->SetText();
	layerCurRes->AddChild(m_scrollCurRes);
	
	imageRes = new NDUIImage;
	imageRes->Initialization();
	imageRes->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("farmrheadtitle.png")), true);
	imageRes->SetFrameRect(CGRectMake(5, 5+24+104+3, 8, 8));
	layerBg->AddChild(imageRes);
	
	NDUILabel *lbMatainRes = new NDUILabel;
	lbMatainRes->Initialization();
	lbMatainRes->SetFontSize(14);
	lbMatainRes->SetFontColor(ccc4(148, 6, 5, 255));
	lbMatainRes->SetTextAlignment(LabelTextAlignmentLeft);
	lbMatainRes->SetText(NDCString("MaintainRes"));
	lbMatainRes->SetFrameRect(CGRectMake(16, 5+24+104, sizeBagLeftBg.width, sizeBagLeftBg.height));
	layerBg->AddChild(lbMatainRes);
	
	picRoleBg = pool.AddPicture(NDPath::GetImgPathNew("attr_role_bg.png"), 0, 104);
	NDUILayer *layerMatainRes = new NDUILayer;
	layerMatainRes->Initialization();
	layerMatainRes->SetFrameRect(CGRectMake(0,48+sizeRoleBg.height, sizeRoleBg.width, sizeRoleBg.height));
	layerMatainRes->SetBackgroundImage(picRoleBg, true);
	layerBg->AddChild(layerMatainRes);
	
	m_scrollMainRes = new NDUIContainerScrollLayer;
	m_scrollMainRes->Initialization();
	m_scrollMainRes->SetFrameRect(CGRectMake(6, 10, sizeRoleBg.width-12, sizeRoleBg.height-20));
	//scrollCurRes->SetText();
	layerMatainRes->AddChild(m_scrollMainRes);
	
	RefreshResurce();
}

void FarmInfoLayer::RefreshRes(int type)
{
	NDUIContainerScrollLayer *layerRes = 
		(type == 0 ? m_scrollCurRes : (type == 1 ? m_scrollMainRes : NULL));
		
	if (!layerRes) return;
	
	layerRes->RemoveAllChildren(true);
	
	CGRect rect = layerRes->GetFrameRect();
	float width = rect.size.width/2;
	
	size_t size = vec_farm_rsc.size();
	for (size_t i = 0; i < size; i++)
	{
		FarmResource& fr = vec_farm_rsc[i];
		
		std::stringstream ss;
		if (type == 0) {
			ss << fr.name << " :  " << fr.num;
		} else if (type == 1) {
			ss << fr.name << " : " << fr.need_num;
		}
		
		float startX = i % 2 == 0 ? 0.0f : width, 
			  startY = i / 2 * 18;
		
		NDUILabel *lb = new NDUILabel;
		lb->Initialization();
		lb->SetFontSize(12);
		lb->SetFontColor(ccc4(80, 79, 77, 255));
		lb->SetTextAlignment(LabelTextAlignmentLeft);
		lb->SetFrameRect(CGRectMake(startX, startY, rect.size.width, 18));
		lb->SetText(ss.str().c_str());
		layerRes->AddChild(lb);
	}
	
	layerRes->refreshContainer();
	
	if (!this->IsVisibled())
	{
		layerRes->SetVisible(false);
	}
}

void FarmInfoLayer::RefreshState()
{
	if (m_tbTrends 
		&& m_tbTrends->GetDataSource() 
		&& m_tbTrends->GetDataSource()->Count() > 0) 
	{
		NDSection* section = m_tbTrends->GetDataSource()->Section(0);
		
		section->Clear();
		
		for_vec(vec_farm_status, std::vector<NDFarmPropCell*>::iterator)
		{
			section->AddCell(*it);
		}
		
		m_tbTrends->ReflashData();
		
		vec_farm_status.clear();
		
		if (!this->IsVisibled())
		{
			m_tbTrends->SetVisible(false);
		}
	}
}

void FarmInfoLayer::RefreshResurce()
{
	RefreshRes(0);
	
	RefreshRes(1);
}

/////////////////////////////////////////
IMPLEMENT_CLASS(FarmStatus, NDUILayer)

FarmStatus::FarmStatus()
{
	totalTime = 0;
	restTime = 0;
	
	m_bar = NULL;
	m_lbTitle = NULL;
	
	m_bRecal = true;
	
	m_bFocus = false;
	
	iType = 0;
	iParam = 0;
}

FarmStatus::~FarmStatus()
{
	
}

void FarmStatus::Initialization(std::string str, int t, int r)
{
	totalTime = t; restTime = r; des = str;
	
	NDUILayer::Initialization();
	
	this->SetBackgroundColor(ccc4(0, 0, 0, 0));
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetText(des.c_str());
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbTitle->SetVisible(false);
	this->AddChild(m_lbTitle);
	
	m_bar = new NDUITimeStateBar;
	m_bar->Initialization();
	//m_bar->SetStateColor(ccc3(0, 0, 255));
	//m_bar->SetStateColor(ccc4(63, 188, 239,255));
	m_bar->SetVisible(false);
	m_bar->SetTime(restTime, totalTime);
	this->AddChild(m_bar);
}

bool FarmStatus::TouchBegin(NDTouch* touch)
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
	
	FarmStatusDelegate* delegate = dynamic_cast<FarmStatusDelegate*> (this->GetDelegate());
	if (delegate) 
	{
		delegate->OnFarmStatusClick(this, m_bFocus);
	}
	
	if (!m_bFocus) 
	{
		m_bFocus = true;
	}
	
	return true;
}

bool FarmStatus::TouchEnd(NDTouch* touch)
{
	return true;
}

void FarmStatus::SetFarmStatusFocus(bool bFocus)
{
	m_bFocus = bFocus;
}

void FarmStatus::draw()
{
	if (!this->IsVisibled()) 
	{
		return;
	}
	
	NDUILayer::draw();
	
	if (m_bRecal) 
	{
		CGRect rect = GetFrameRect();
		
		if (m_lbTitle) 
		{
			CGSize dim = CGSizeZero;
			std::string str = m_lbTitle->GetText();
			if (!str.empty()) 
			{
				dim = getStringSize(str.c_str(), m_lbTitle->GetFontSize());
			}
			m_lbTitle->SetFrameRect(CGRectMake(0, (rect.size.height-dim.height)/2, rect.size.width, rect.size.height+3));
			m_lbTitle->SetVisible(true);
		}
		
		if (m_bar) 
		{
			m_bar->SetFrameRect(CGRectMake(rect.size.width/2+5, 0, rect.size.width/2-5, rect.size.height));
			m_bar->SetVisible(true);
		}
		
		m_bRecal = false;
	}
	
	//draw focus 
	ccColor4B bgcolor;
	if (m_bFocus) 
	{
		bgcolor = ccc4(254, 246, 106, 255);				
	}
	else 
	{
		bgcolor = ccc4(0, 0, 0, 0);	
	}
	
	this->SetBackgroundColor(bgcolor);
}

void FarmStatus::SetFinishText(std::string text)
{
	if (m_bar) 
	{
		m_bar->SetFinishText(text);
	}
}

void FarmStatus::ReduceRestTime(unsigned long add)
{
	if (m_bar)
	{
		m_bar->ReduceRestTime(add);
	}
}

void FarmStatus::OnTimeStateBarFinish(NDUITimeStateBar* statebar)
{
	FarmStatusDelegate* delegate = dynamic_cast<FarmStatusDelegate*> (this->GetDelegate());
	if (delegate) 
	{
		delegate->OnFarmStatusFinish(this);
	}	
}

void FarmStatus::SetTitleColor(ccColor4B color)
{
	if (m_lbTitle) {
		m_lbTitle->SetFontColor(color);
	}
}

/////////////////////////////////////////

#define title_height 28
#define bottom_height 42

#define BTN_W (85)
#define BTN_H (23)

#define DRAW_X (8)

#define fontHeight (20)

#define STATE_HEIGHT (28)

#define STATE_INTERVAL (2)

#define COUNT_PER_PAGE (7) 

enum  
{
	eOP_Cancel = 66,
	eOP_Speed,
	eOP_Return,
};

IMPLEMENT_CLASS(FarmInfoScene, NDScene)

std::vector<FarmResource> FarmInfoScene::vec_farm_rsc;
std::vector<FarmStatus*> FarmInfoScene::vec_farm_status;

FarmInfoScene::FarmInfoScene()
{
	m_lbTitle = NULL;
	memset(m_lbFarmTrend, 0, sizeof(m_lbFarmTrend));
	m_btnNext = NULL;
	m_btnPrev = NULL;
	
	m_picNext = NULL;
	m_picPrev = NULL;
	
	m_tlOperate = NULL;
	
	m_iCurPage = 0;
	
	m_farmstatus = NULL;
}

FarmInfoScene::~FarmInfoScene()
{
	SAFE_DELETE(m_picNext);
	SAFE_DELETE(m_picPrev);
	
	ClearFarmStatus(NULL, true);
	vec_farm_rsc.clear();
}

FarmInfoScene* FarmInfoScene::Scene()
{
	FarmInfoScene* scene = new FarmInfoScene;
	scene->Initialization();
	return scene;
}

void FarmInfoScene::Initialization()
{
	NDScene::Initialization();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	this->AddChild(m_menulayerBG);
	
	
	if ( m_menulayerBG->GetCancelBtn() ) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 245, 0, 255));
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetFrameRect(CGRectMake(0, 0, winsize.width, title_height));
	m_menulayerBG->AddChild(m_lbTitle);
	
	m_picPrev = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	m_picPrev->Cut(CGRectMake(319, 144, 48, 19));
	CGSize prevSize = m_picPrev->GetSize();
	
	m_picNext = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	m_picNext->Cut(CGRectMake(318, 164, 47, 17));
	CGSize nextSize = m_picNext->GetSize();
	
	m_btnPrev = new NDUIButton();
	m_btnPrev->Initialization();
	m_btnPrev->SetFrameRect(CGRectMake(30, (title_height-BTN_H)/2, BTN_W, BTN_H));
	m_btnPrev->SetImage(m_picPrev, true,CGRectMake((BTN_W-prevSize.width)/2, (BTN_H-prevSize.height)/2, prevSize.width, prevSize.height));
	m_btnPrev->SetDelegate(this);
	m_menulayerBG->AddChild(m_btnPrev);
	
	m_btnNext = new NDUIButton();
	m_btnNext->Initialization();
	m_btnNext->SetFrameRect(CGRectMake(450-BTN_W, (title_height-BTN_H)/2, BTN_W, BTN_H));
	m_btnNext->SetImage(m_picNext, true,CGRectMake((BTN_W-nextSize.width)/2, (BTN_H-nextSize.height)/2, nextSize.width, nextSize.height));
	m_btnNext->SetDelegate(this);
	m_menulayerBG->AddChild(m_btnNext);
	
	DrawResourceString(NDCString("CurRes"), DRAW_X, title_height+3, INTCOLORTOCCC4(0xffffff), INTCOLORTOCCC4(0x3C5D4A));
	
	DrawResourceArray(DRAW_X, title_height+3+fontHeight, 0);
	
	//DrawResourceString(NDCString("MaintainRes"), DRAW_X, title_height+3+fontHeight*4+2, INTCOLORTOCCC4(0xffffff), INTCOLORTOCCC4(0x3C5D4A));
	DrawResourceString(NDCString("MaintainRes"), DRAW_X, (winsize.height-title_height-bottom_height)/2+title_height, INTCOLORTOCCC4(0xffffff), INTCOLORTOCCC4(0x3C5D4A));
	
	//DrawResourceArray(DRAW_X, title_height+2+fontHeight*5+2, 0);
	DrawResourceArray(DRAW_X,  (winsize.height-title_height-bottom_height)/2+fontHeight+title_height, 1);
	
	DrawResourceString(NDCString("FarmDongTai"), DRAW_X+winsize.width/2, title_height+3, INTCOLORTOCCC4(0xffffff), INTCOLORTOCCC4(0x3C5D4A), true);
	
	NDUITopLayerEx *topLayerEx = new NDUITopLayerEx;
	topLayerEx->Initialization();
	topLayerEx->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	m_menulayerBG->AddChild(topLayerEx, 1);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetDelegate(this);
	topLayerEx->AddChild(m_tlOperate);
	
	m_tlOperate->SetVisible(false);
	
	DrawState();
}

void FarmInfoScene::OnFarmStatusFinish(FarmStatus* farmstatus)
{
}

void FarmInfoScene::OnFarmStatusClick(FarmStatus* farmstatus, bool bFocused)
{
	if (bFocused) 
	{
		std::vector<std::string> vec_str;
		std::vector<int> vec_id;
		
		if(farmstatus->iType==3)
		{
			vec_str.push_back(NDCommonCString("JiaSuUp")); vec_id.push_back(eOP_Speed);
		}
		
		vec_str.push_back(NDCommonCString("Cancel")); vec_id.push_back(eOP_Cancel);
		vec_str.push_back(NDCommonCString("return")); vec_id.push_back(eOP_Return);
		
		m_farmstatus = farmstatus;
		InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
		m_tlOperate->SetVisible(true);
	}
	else 
	{
		DefocusFarmStatusExcepet(farmstatus);
	}
}

void FarmInfoScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (!m_farmstatus) {
		m_tlOperate->SetVisible(false);
		return;
	}
	
	if (cell->GetTag() == eOP_Cancel) 
	{
		std::string s;
		if(m_farmstatus->iType==3){
			s=NDCString("FarmTip");
		}else{
			s=NDCString("FarmTip2");
		}
		
		s = NDMapMgrObj.changeNpcString(s);
		
		NDUIDialog *dlg = new NDUIDialog;
		dlg->Initialization();
		dlg->SetDelegate(this);
		dlg->Show("", s.c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
		
		m_tlOperate->SetVisible(false);
		
		return;
	}
	else if (cell->GetTag() == eOP_Speed) 
	{
		showUseItemUI(m_farmstatus->iParam,5);
	}

	m_farmstatus = NULL;
	m_tlOperate->SetVisible(false);
}

void FarmInfoScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnNext) 
	{
		if (m_iCurPage+1 < GetPageCount()) 
		{
			m_iCurPage++;
			
			DrawState();
		}
	}
	else if (button == m_btnPrev) 
	{
		if (m_iCurPage > 0) 
		{
			m_iCurPage--;
			DrawState();
		}
	}
	else if (button == m_menulayerBG->GetCancelBtn())
	{
		NDDirector::DefaultDirector()->PopScene();
	}
}

void FarmInfoScene::addState(int iType, std::string des, int totalTime, int restTime,int param)
{
	FarmStatus *status = new FarmStatus();
	status->Initialization(des, totalTime, restTime);
	status->iType = iType;
	status->iParam = param;
	
	if(iType==3)
	{
		status->SetFinishText(NDCommonCString("finish"));
	}
	else if(iType==4)
	{
		status->SetFinishText(NDCommonCString("ChengShou"));
	}
	
	vec_farm_status.push_back(status);
}

void FarmInfoScene::addFarmTotalResource(int itemtypes, int total, int need)
{
	FarmResource fs;
	fs.num = total;
	fs.need_num = need;
	NDItemType *obj = ItemMgrObj.QueryItemType(itemtypes);
	if (obj) 
	{
		fs.name = obj->m_name;
	}
	
	vec_farm_rsc.push_back(fs);
}

void FarmInfoScene::DrawResourceString(std::string text, int x, int y, ccColor4B color1, ccColor4B color2, bool bAssign/*=false*/)
{
	if (text.empty() || !m_menulayerBG) return;
	
	NDUILabel *lable[2];
	lable[0] = new NDUILabel; lable[0]->Initialization(); lable[0]->SetText(text.c_str()); lable[0]->SetFontSize(15);
	lable[1] = new NDUILabel; lable[1]->Initialization(); lable[1]->SetText(text.c_str()); lable[1]->SetFontSize(15);
	
	lable[0]->SetFontColor(color1);
	lable[1]->SetFontColor(color2);
	
	CGSize size = getStringSize(text.c_str(), 15);
	
	lable[0]->SetFrameRect(CGRectMake(x, y, size.width, size.height));
	lable[1]->SetFrameRect(CGRectMake(x+1, y+1, size.width, size.height));
	
	m_menulayerBG->AddChild(lable[1]);
	m_menulayerBG->AddChild(lable[0]);
	
	if (bAssign) 
	{
		m_lbFarmTrend[0] = lable[0];
		m_lbFarmTrend[1] = lable[1];
	}
}

void FarmInfoScene::DrawResourceArray(int x, int y, int type)
{
	if (!m_menulayerBG) return;
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	int dx = (winsize.width/2 - x) / 2;
	int count = vec_farm_rsc.size();
	for (int i = 0; i < count; i++) {
		FarmResource& fr = vec_farm_rsc[i];
		int cx = x + i % 2 * dx;
		int cy = y + (i / 2) * fontHeight;
		std::stringstream ss;
		if (type == 0) {
			ss << fr.name << ":" << fr.num;
		} else if (type == 1) {
			ss << fr.name << ":" << fr.need_num;
		}
		
		CGSize size = getStringSize(ss.str().c_str(), 15);
		
		NDUILabel *lb = new NDUILabel;
		lb->Initialization();
		lb->SetText(ss.str().c_str());
		lb->SetFontSize(15);
		lb->SetFontColor(ccc4(0, 0, 0, 255));
		lb->SetFrameRect(CGRectMake(cx, cy, size.width, size.height+2));
		m_menulayerBG->AddChild(lb);
	}
}

void FarmInfoScene::DrawState()
{
	int count = vec_farm_status.size();
	
	if (m_lbFarmTrend[0] && m_lbFarmTrend[1]) {
		m_lbFarmTrend[0]->SetVisible(count != 0);
		m_lbFarmTrend[1]->SetVisible(count != 0);
	}
	
	if (m_lbTitle) 
	{
		std::stringstream ss; ss << NDCString("FarmDongTai") << m_iCurPage+1 << "/" << GetPageCount();
		m_lbTitle->SetText(count == 0 ? NDCString("FarmDongTai") : ss.str().c_str());
	}
	
	if (m_btnNext) m_btnNext->SetVisible(count != 0);
	if (m_btnPrev) m_btnPrev->SetVisible(count != 0);
	
	if (count == 0) return;
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	int iStart = m_iCurPage*COUNT_PER_PAGE;
	int iEnd = (m_iCurPage+1)*COUNT_PER_PAGE;
	
	int iX = DRAW_X+winsize.width/2;
	int iY = title_height+3+fontHeight;
	
	int iW = winsize.width/2-DRAW_X-5;
	
	for (int i = 0; i < count; i++) 
	{
		bool bShow = i >= iStart && i < iEnd;
		
		FarmStatus*& fs = vec_farm_status[i];
		
		if (!bShow && fs->GetParent()) 
		{
			fs->SetVisible(bShow);
		}
		
		if (bShow) 
		{
			if (!fs->GetParent()) 
			{
				m_menulayerBG->AddChild(fs);
				fs->SetDelegate(this);
			}
			
			fs->SetFrameRect(CGRectMake(iX, iY, iW, STATE_HEIGHT));
			iY += STATE_HEIGHT+STATE_INTERVAL;
			
			fs->SetFarmStatusFocus(i == iStart);
		}
	}
}

void FarmInfoScene::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
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
btn->SetFrameRect(CGRectMake(0, 0, 120, 30)); \
btn->SetFocusColor(ccc4(255, 207, 74, 255)); \
section->AddCell(btn); \
} while (0)
	
	if (!tl || vec_str.empty() || vec_id.empty() || vec_str.size() != vec_id.size() )
	{
		NDLog(@"FarmInfoScene::InitTLContentWithVec初始化失败");
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

void FarmInfoScene::ClearFarmStatus(FarmStatus* status, bool bAll/*=false*/)
{
	if (bAll) 
	{
		std::vector<FarmStatus*>::iterator it = vec_farm_status.begin();
		for (; it != vec_farm_status.end(); it++) 
		{
			FarmStatus *node = *it;
			
			BeforoeFarmStatusClear(node);
			
			SAFE_DELETE_NODE(node);
		}
		vec_farm_status.clear();

		return;
	}
	
	std::vector<FarmStatus*>::iterator it = vec_farm_status.begin();
	for (; it != vec_farm_status.end(); it++) 
	{
		FarmStatus *node = *it;
		if (node == status) 
		{
			BeforoeFarmStatusClear(node);
			
			SAFE_DELETE_NODE(node);
			
			vec_farm_status.erase(it);
			
			break;
		}
	}
}

void FarmInfoScene::BeforoeFarmStatusClear(FarmStatus* status)
{
	if (status == m_farmstatus) 
	{
		m_farmstatus = NULL;
	}
}

int FarmInfoScene::GetPageCount()
{
	int count = vec_farm_status.size();
	
	return count/COUNT_PER_PAGE+(count%COUNT_PER_PAGE==0 ? 0 : 1);
}

void FarmInfoScene::DefocusFarmStatusExcepet(FarmStatus* status)
{
	std::vector<FarmStatus*>::iterator it = vec_farm_status.begin();
	for (; it != vec_farm_status.end(); it++) 
	{
		FarmStatus *node = *it;
		if (node == status) 
		{
			continue;
		}
		
		node->SetFarmStatusFocus(false);
	}
}

void FarmInfoScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	
	if (m_farmstatus) 
	{
		NDTransData bao(_MSG_ENTER_HAMLET);
		bao << (unsigned char)(m_farmstatus->iType)
		<< int(m_farmstatus->iParam);
		SEND_DATA(bao);
	}
	dialog->Close();
}

void FarmInfoScene::cancelBuilding(int iID) 
{
	FarmStatus *node = NULL;
	std::vector<FarmStatus*>::iterator it = vec_farm_status.begin();
	for (; it != vec_farm_status.end(); it++) 
	{
		if ((*it)->iParam == iID) 
		{
			node = *it;
			break;
		}
	}
	
	if (node)
		ClearFarmStatus(node, false);
		
	DrawState();
}

void FarmInfoScene::addBuildSpeed(int iID, int time) 
{
	std::vector<FarmStatus*>::iterator it = vec_farm_status.begin();
	for (; it != vec_farm_status.end(); it++) 
	{
		FarmStatus* node = *it;
		if (node->iParam == iID) 
		{
			node->ReduceRestTime(time);
			break;
		}
	}
}


