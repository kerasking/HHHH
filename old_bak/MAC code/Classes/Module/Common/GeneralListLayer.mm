/*
 *  GeneralListLayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-22.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GeneralListLayer.h"
#include "NDDirector.h"
#include "GameScene.h"
#include "NDUISynLayer.h"
#include "SocialTextLayer.h"
#include "GameUIPlayerList.h"
#include <sstream>

enum {
	PER_PAGE_SIZE = 10,
};

enum 
{
	eOpeate_Move = 888, //迁移
	eOpeate_Return,
};

IMPLEMENT_CLASS(GeneralListLayer, NDUIMenuLayer)

GeneralListLayer* GeneralListLayer::s_instance = NULL;

void GeneralListLayer::processMsgCommonList(NDTransData& data)
{
	if (!s_instance) {
		int id = data.ReadInt();
		int field_count = data.ReadInt();
		int button_count = data.ReadInt();
		string title = data.ReadUnicodeString();
		
		if (field_count > 3) { // 最多支持3列
			return;
		}
		
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			GameScene* gameScene = (GameScene*)scene;
			GeneralListLayer *list = new GeneralListLayer;
			
			list->m_id = id;
			
			for (int i = 0; i < field_count; i++) {
				list->m_vFields.push_back(ListField());
				ListField& field = list->m_vFields.at(list->m_vFields.size() - 1);
				field.m_type = ListField::FIELD_TYPE(data.ReadByte());
				field.m_name = data.ReadUnicodeString();
			}
			
			for (int i = 0; i < button_count; i++) {
				list->m_vOpts.push_back(data.ReadUnicodeString());
			}
			
			list->Init(title);
			gameScene->AddChild(list, UILAYER_Z);
			gameScene->SetUIShow(true);
		} else {
			return;
		}
	}
}

void GeneralListLayer::processMsgCommonListRecord(NDTransData& data)
{
	if (!s_instance) {
		return;
	}
	
	int packageFlag = data.ReadByte();
	int curCount = data.ReadByte();
	data.ReadShort();
	
	string value;
	for (int i = 0; i < curCount; i++) {
		SocialElement* se = new SocialElement;
		s_instance->m_vElement.push_back(se);
		se->m_id = data.ReadInt();
		
		for (VEC_LIST_FIELD_IT it = s_instance->m_vFields.begin(); it != s_instance->m_vFields.end(); it++) {
			if ((*it).m_type == ListField::FT_INT) {
				stringstream ss;
				ss << data.ReadInt();
				value = ss.str();
			} else if ((*it).m_type == ListField::FT_STRING) {
				value = data.ReadUnicodeString();
			}
			
			if (it == s_instance->m_vFields.begin()) {
				se->m_text1 = value;
			} else if (it == s_instance->m_vFields.begin() + 1) {
				se->m_text2 = value;
			} else {
				se->m_text3 = value;
			}
		}
	}
	
	if ((packageFlag & 2) > 0) {
		CloseProgressBar;
		int nTotalPage = s_instance->m_vElement.size() / PER_PAGE_SIZE;
		if (s_instance->m_vElement.size() % PER_PAGE_SIZE > 0) {
			nTotalPage++;
		}
		s_instance->m_btnPage->SetPages(1, nTotalPage);
		s_instance->refreshMainList();
	}
}

//farm相关
void GeneralListLayer::processFarmList(std::string title, VEC_ITEM& itemlist, std::vector<std::string>& vec_str, int iNPCID, int iType)
{
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene)
	{
		return;
	}
		
	GeneralListLayer *list = new GeneralListLayer;
	
	list->m_id = iNPCID;
	list->m_iFarmType = iType;
	list->m_glType = GeneralListLayer_Farm;
	
	for_vec(vec_str, std::vector<std::string>::iterator)
	{
		list->m_vFields.push_back(ListField());
		ListField& field = list->m_vFields.at(list->m_vFields.size() - 1);
		field.m_type = ListField::FT_STRING;
		field.m_name = *it;
	}
	
	for_vec(itemlist, VEC_ITEM_IT)
	{
		SocialElement* se = new SocialElement;
		list->m_vElement.push_back(se);
		
		Item* item = *it;
		std::string s="";
		if(iType==0){
			s=NDCommonCString("farm");
		}else if(iType==1){
			s=NDCommonCString("muchang");
		}
		std::stringstream ss2, ss3;
		ss2 << s << item->getItemLevel() << NDCommonCString("Ji");
		ss3 << item->getSuitData() << NDCommonCString("FengZhong");
		
		se->m_id = item->iID;
		se->m_text1 = item->getItemName();
		se->m_text2 = ss2.str();
		se->m_text3 = ss3.str();
	}
	
	list->Init(title);
	scene->AddChild(list, UILAYER_Z);
	list->refreshMainList();
	
	if (scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
	{
		GameScene* gameScene = (GameScene*)scene;
		gameScene->SetUIShow(true);
	}
}

void GeneralListLayer::processEmpytHamlet(std::string title, std::vector<HamletInfo>& vec_info)
{
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene)
	{
		return;
	}
	
	GeneralListLayer *list = new GeneralListLayer;
	list->m_glType = GeneralListLayer_EmptyHamlet;
	do {
		list->m_vFields.push_back(ListField());
		ListField& field = list->m_vFields.back();
		field.m_type = ListField::FT_STRING;
		field.m_name = NDCommonCString("MengPaiHao");
	} while (0);
	do {
		list->m_vFields.push_back(ListField());
		ListField& field = list->m_vFields.back();
		field.m_type = ListField::FT_STRING;
		field.m_name = "";
	} while (0);
	
	for_vec(vec_info, std::vector<HamletInfo>::iterator)
	{
		HamletInfo& info = *it;
		SocialElement* se = new SocialElement;
		list->m_vElement.push_back(se);
		se->m_text1 = info.name;
		se->m_id = info.idHamlet;
		se->m_param = info.idNPc;
		se->m_text2 = "  ";
	}
	
	list->Init(title);
	scene->AddChild(list, UILAYER_Z);
	list->refreshMainList();
	
	if (scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
	{
		GameScene* gameScene = (GameScene*)scene;
		gameScene->SetUIShow(true);
	}
}

GeneralListLayer::GeneralListLayer()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->m_tlMain = NULL;
	this->m_curSelEle = NULL;
	this->m_optLayer = NULL;
	this->m_btnPage = NULL;
	m_id = ID_NONE;
	
	m_iFarmType = 0;
	
	m_tlOperate = NULL;
	
	m_glType = GeneralListLayer_None;
}

GeneralListLayer::~GeneralListLayer()
{
	s_instance = NULL;
	this->releaseElement();
}

void GeneralListLayer::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (this->m_optLayer) {
			this->m_optLayer->RemoveFromParent(true);
			this->m_optLayer = NULL;
		} else {
			if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
			{
				((GameScene*)(this->GetParent()))->SetUIShow(false);
				//this->RemoveFromParent(true);
			}
			GeneralListLayer* layer = this;
			SAFE_DELETE_NODE(layer);
		}
	}
}

void GeneralListLayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (m_glType == GeneralListLayer_Farm && table == m_tlMain) 
	{
		//BytesArrayOutput bao = new BytesArrayOutput();
//		bao.write(type);			
//		Integer in=(Integer)T.listRecords.elementAt(0);
//		bao.writeInt(in.intValue());
//		bao.writeInt(item.itemID);
//		ServerConnection.SEND_DATA(ServiceCode._MSG_FARM_PRODUCE,
//								  bao.toByteArray());
		NDTransData bao(_MSG_FARM_PRODUCE);
		bao << (unsigned char)m_iFarmType
			<< int(m_id)
			<< ((SocialTextLayer*)cell)->GetSocialElement()->m_id;
		SEND_DATA(bao);	
		GeneralListLayer* node = this;
		SAFE_DELETE_NODE(node);
		return;
	}
	
	if (m_glType == GeneralListLayer_EmptyHamlet && table == m_tlMain) 
	{
		this->m_curSelEle = ((SocialTextLayer*)cell)->GetSocialElement();
		showEmpytHamletOperate();
		return;
	}else if (m_glType == GeneralListLayer_EmptyHamlet && table == m_tlOperate) 
	{
		m_tlOperate->SetVisible(false);
		if (cell->GetTag() == eOpeate_Move && m_curSelEle) 
		{ // 迁移到空地
			NDTransData bao(_MSG_MOVE_FARMLAND);
			bao << (unsigned char)1 << int(m_curSelEle->m_param) << int(m_curSelEle->m_id);
			SEND_DATA(bao);
		}
		return;
	}

	if (this->m_tlMain == table && m_vOpts.size() > 0) {
		this->m_curSelEle = ((SocialTextLayer*)cell)->GetSocialElement();
		// 显示操作选项
		NDUITableLayer* opt = new NDUITableLayer;
		opt->Initialization();
		opt->VisibleSectionTitles(false);
		opt->SetDelegate(this);
		
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		int nHeight = 0;
		
		NDDataSource* ds = new NDDataSource;
		NDSection* sec = new NDSection;
		ds->AddSection(sec);
		opt->SetDataSource(ds);
		
		NDUIButton* btn = NULL;
		for (VEC_BUTTON_IT it = m_vOpts.begin(); it != m_vOpts.end(); it++) {
			btn = new NDUIButton;
			btn->Initialization();
			btn->SetTitle((*it).c_str());
			btn->SetFocusColor(ccc4(253, 253, 253, 255));
			sec->AddCell(btn);
			nHeight += 30;
		}
		opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - nHeight) / 2, 94, nHeight));
		sec->SetFocusOnCell(0);
		
		this->m_optLayer = new NDOptLayer;
		this->m_optLayer->Initialization(opt);
		this->AddChild(m_optLayer);
	} else if (this->m_optLayer && this->m_optLayer->GetOpt() == table) {
		this->sendMessage(cellIndex);
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
}

void GeneralListLayer::sendMessage(int action) {
	if (!m_curSelEle) {
		return;
	}
	
	NDTransData bao(_MSG_COMMON_LIST);
	
	bao << m_id << action << m_curSelEle->m_id;
	
	string value;
	for (VEC_LIST_FIELD_IT it = m_vFields.begin(); it != m_vFields.end(); it++) {
		if (it == m_vFields.begin()) {
			value = m_curSelEle->m_text1;
		} else if (it == m_vFields.begin() + 1) {
			value = m_curSelEle->m_text2;
		} else {
			value = m_curSelEle->m_text3;
		}
		
		if ((*it).m_type == ListField::FT_INT) {
			int s = atoi(value.c_str());
			bao << (s);
		} else if ((*it).m_type == ListField::FT_STRING) {
			bao.WriteUnicodeString(value);
		}
	}
	SEND_DATA(bao);
}

void GeneralListLayer::OnPageChange(int nCurPage, int nTotalPage)
{
	this->refreshMainList();
}

void GeneralListLayer::Init(const string& strTitle)
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUILabel* title = new NDUILabel;
	title->Initialization();
	title->SetText(strTitle.c_str());
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentCenter);
	title->SetFrameRect(CGRectMake(0, 5, winsize.width, 15));
	title->SetFontColor(ccc4(255, 240, 0,255));
	this->AddChild(title);
	
	NDUILayer* columnTitle = new NDUILayer;
	columnTitle->Initialization();
	columnTitle->SetBackgroundColor(ccc4(115, 117, 115, 255));
	columnTitle->SetFrameRect(CGRectMake(7, 32, 466, 17));
	this->AddChild(columnTitle);
	
	for (VEC_LIST_FIELD_IT it = m_vFields.begin(); it != m_vFields.end(); it++) {
		title = new NDUILabel;
		title->Initialization();
		title->SetText((*it).m_name.c_str());
		title->SetFontSize(15);
		title->SetFrameRect(CGRectMake(12, 32, 456, 17));
		title->SetFontColor(ccc4(0, 0, 0,255));
		LabelTextAlignment lta = LabelTextAlignmentLeft;
		if (it == m_vFields.end() - 1) {
			lta = LabelTextAlignmentRight;
		} else if (it == m_vFields.begin() + 1) {
			lta = LabelTextAlignmentCenter;
		}
		title->SetTextAlignment(lta);
		this->AddChild(title);
	}
	
	this->m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetFrameRect(CGRectMake(2, 50, 476, 200));
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->AddChild(m_tlMain);
	m_tlMain->SetDataSource(new NDDataSource);
	
	m_btnPage = new NDPageButton;
	m_btnPage->Initialization(CGRectMake(160.0f, 250.0f, 160.0f, 24.0f));
	m_btnPage->SetDelegate(this);
	this->AddChild(m_btnPage);
}

void GeneralListLayer::refreshMainList()
{
	// 清除相关数据
	this->m_curSelEle = NULL;
	
	if (this->m_optLayer) {
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
	
	NDDataSource *ds = m_tlMain->GetDataSource();
	ds->Clear();
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	size_t nCount = m_vElement.size();
	
	if (nCount > 0) {
		int nCurPage = m_btnPage->GetCurPage() - 1;
		
		size_t nStart = nCurPage * PER_PAGE_SIZE;
		nStart = min(nStart, nCount - 1);
		size_t nEnd = nStart + PER_PAGE_SIZE - 1;
		nEnd = min(nEnd, nCount - 1);
		
		bool bChangeClr = false;
		for (size_t i = nStart; i <= nEnd; i++) {
			SocialElement* se = m_vElement.at(i);
			SocialTextLayer* st = new SocialTextLayer;
			st->Initialization(CGRectMake(5.0f, 0.0f, 460.0f, 27.0f),
					   CGRectMake(10.0f, 0.0f, 450.0f, 27.0f), se);
			
			if (bChangeClr) {
				st->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
			} else {
				st->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
			}
			
			bChangeClr = !bChangeClr;
			sec->AddCell(st);
		}
	}
	
	this->m_tlMain->ReflashData();
}

void GeneralListLayer::releaseElement()
{
	for (VEC_SOCIAL_ELEMENT_IT it = this->m_vElement.begin(); it != this->m_vElement.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vElement.clear();
}

void GeneralListLayer::LoadUIOperate()
{
	if (m_tlOperate) return;
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	NDUITopLayerEx* topLayerEx = new NDUITopLayerEx;
	topLayerEx->Initialization();
	topLayerEx->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	this->AddChild(topLayerEx);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetDelegate(this);
	m_tlOperate->SetVisible(false);
	topLayerEx->AddChild(m_tlOperate);
}

void GeneralListLayer::showEmpytHamletOperate()
{
	if (!m_tlOperate)  LoadUIOperate();
	
	std::vector<std::string> vec_str;
	std::vector<int> vec_id;
	vec_str.push_back(NDCommonCString("QiangYi")); vec_id.push_back(eOpeate_Move);
	vec_str.push_back(NDCommonCString("return")); vec_id.push_back(eOpeate_Return);
	InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
}

void GeneralListLayer::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
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
btn->SetFocusColor(ccc4(253, 253, 253, 255)); \
section->AddCell(btn); \
} while (0)
	
	if (!tl || vec_str.empty() || vec_id.empty() || vec_str.size() != vec_id.size() )
	{
		NDLog(@"GeneralListLayer::InitTLContentWithVec初始化失败");
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
