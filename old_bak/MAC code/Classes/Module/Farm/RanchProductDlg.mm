/*
 *  RanchProductDlg.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "RanchProductDlg.h"
#include "NDDirector.h"
#include "NDTextNode.h"
#include "NDScene.h"
#include "NDDataTransThread.h"
#include "NDTransData.h"
#include "NDMsgDefine.h"
#include "NDPlayer.h"
#include "NDConstant.h"
#include "NDMapMgr.h"
#include "NDUISynLayer.h"

enum  
{
	eOP_ShouHuo = 345,		// 收获
	eOP_WeiShiLiao,			// 喂饲料
	eOP_CancelYanZhi,		// 取消养殖
	eOP_Return,				// 返回
};

IMPLEMENT_CLASS(RanchProductDlg, NDDlgBackGround)

RanchProductDlg::RanchProductDlg()
{
	m_iFarmID = m_iEntityID = m_iProductID = 0;
	m_status = NULL;
	m_bIsMatured = false;
}

RanchProductDlg::~RanchProductDlg()
{
}

void RanchProductDlg::Initialization(int iFarmID, int iEntityID, int iProductID, bool bHarvest)
{
	NDDlgBackGround::Initialization();
	
	m_iFarmID = iFarmID;
	m_iEntityID = iEntityID;
	m_iProductID = iProductID;
	m_bIsMatured = bHarvest;
	
	std::vector<string> vec_str; 
	std::vector<int> vec_id;
	
	if (iFarmID == NDPlayer::defaultHero().m_id) 
	{
		if (m_bIsMatured) {
			//ops = new TextView[2];
//			ops[0] = new TextView(NDCommonCString("ShouHuo"));
//			ops[0].id = 6;
//			ops[0].setOnClickListener(this);
//			
//			ops[1] = new TextView("返回");
//			ops[1].id = 0;
//			ops[1].setOnClickListener(this);
			vec_str.push_back(NDCommonCString("ShouHuo")); vec_id.push_back(eOP_ShouHuo);
			vec_str.push_back(NDCommonCString("return")); vec_id.push_back(eOP_Return);

		} else {
			//ops = new TextView[4];
//			ops[0] = new TextView("喂饲料");
//			ops[0].id = 4;
//			ops[0].setOnClickListener(this);
//			
//			ops[1] = new TextView("取消养殖");
//			ops[1].id = 50;
//			ops[1].setOnClickListener(this);
//			
//			ops[2] = new TextView(NDCommonCString("ShouHuo"));
//			ops[2].id = 6;
//			ops[2].setOnClickListener(this);
//			
//			ops[3] = new TextView(NDCommonCString("return"));
//			ops[3].id = 0;
//			ops[3].setOnClickListener(this);
			vec_str.push_back(NDCString("WeiSiLiao")); vec_id.push_back(eOP_WeiShiLiao);
			vec_str.push_back(NDCString("CancelYangZhi")); vec_id.push_back(eOP_CancelYanZhi);
			vec_str.push_back(NDCommonCString("ShouHuo")); vec_id.push_back(eOP_ShouHuo);
			vec_str.push_back(NDCommonCString("return")); vec_id.push_back(eOP_Return);
		}
	} else {
		//ops = new TextView[2];
//		ops[0] = new TextView(NDCommonCString("ShouHuo"));
//		ops[0].id = 6;
//		ops[0].setOnClickListener(this);
//		
//		ops[1] = new TextView(NDCommonCString("return"));
//		ops[1].id = 0;
//		ops[1].setOnClickListener(this);
		vec_str.push_back(NDCommonCString("ShouHuo")); vec_id.push_back(eOP_ShouHuo);
		vec_str.push_back(NDCommonCString("return")); vec_id.push_back(eOP_Return);
	}
	
	InitBtns(vec_str, vec_id);
}

void RanchProductDlg::AddStatus(std::string text, int iTotalTime, int iRestTime)
{
	if (!m_status) 
	{
		m_status = new FarmStatus();
		m_status->Initialization(text, iTotalTime, iRestTime);
		m_status->SetTitleColor(ccc4(255, 255, 255, 255));
		this->AddChild(m_status);
	}
}

void RanchProductDlg::Show(std::string title, std::string content)
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene) 
	{
		delete this;
		return;
	}
	
	this->SetText(title, content);
	scene->AddChild(this, UIDIALOG_Z);
}

void RanchProductDlg::SetText(std::string title, std::string content)
{
	int iWidth = 300;
	int iHeight = 6;
	NDUILabel *lbTitle = new NDUILabel;
	lbTitle->Initialization();
	lbTitle->SetText(title.c_str());
	lbTitle->SetFontSize(15);
	lbTitle->SetFontColor(ccc4(255, 255, 0, 255));
	lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	lbTitle->SetFrameRect(CGRectMake(17, iHeight, iWidth-34, 20));
	this->AddChild(lbTitle);
	
	iHeight += 30;
	
	if (m_status) 
	{
		m_status->SetFrameRect(CGRectMake(17, iHeight, iWidth - 50, 28));
		
		iHeight += 33;
	}
	
	if (content.size() > 0) {
		CGSize textSize;
		textSize.width = iWidth - 34;
		textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(content.c_str(), textSize.width, 13);

		NDUIText *memo = NDUITextBuilder::DefaultBuilder()->Build(content.c_str(), 
																  13, 
																  textSize, 
																  ccc4(255, 255, 255, 255),
																  false);
		memo->SetFrameRect(CGRectMake(17, iHeight, textSize.width, textSize.height + 10));		
		this->AddChild(memo);
		
		iHeight += textSize.height + 10;
		
		iHeight += 10;
	}
	
	iHeight += m_vecTLStr.size()*30+6;
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	this->SetFrameRect(CGRectMake((winsize.width-iWidth)/2, (winsize.height-iHeight)/2, iWidth, iHeight));
}

void RanchProductDlg::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	switch (cell->GetTag()) 
	{
		case eOP_CancelYanZhi:
		{
			NDUIDialog *dlg = new NDUIDialog;
			dlg->Initialization();
			dlg->SetDelegate(this);
			dlg->Show(NDCommonCString("confirm"), NDCString("ConfirmCancelYangZhi"), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
			return;
		}
			break;
		case eOP_Return:
		{
		}
			break;
		case eOP_ShouHuo:
		{
			Send(6);
		}
			break;
		case eOP_WeiShiLiao:
		{
			Send(4);
		}
			break;

		default:
			break;
	}
	
	this->Close();
}

void RanchProductDlg::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	Send(5);
	dialog->Close();
	
	RanchProductDlg* node = this;
	SAFE_DELETE_NODE(node);
}

void RanchProductDlg::Send(int iAction)
{
	NDTransData bao(_MSG_FARM_MU_CHANG);
	bao << int(m_iFarmID) << int(m_iEntityID) << (unsigned char)iAction << int(m_iProductID);
	SEND_DATA(bao);
}

////////////////////////////////////////////
IMPLEMENT_CLASS(FarmProductDlg, RanchProductDlg)

void FarmProductDlg::Initialization()
{
	NDDlgBackGround::Initialization();
}

void FarmProductDlg::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	NDMapMgr& mapmgr = NDMapMgrObj;
	
	if (cellIndex == m_vecTLStr.size()-1) 
	{
		mapmgr.ClearNPCChat();
		this->Close();
		// close;
		return;
	}
	
	
	if(cellIndex < mapmgr.vecNPCOPText.size())
	{
		ShowProgressBar;
		NDMapMgr::st_npc_op op = mapmgr.vecNPCOPText[cellIndex];
		
		NDTransData data(_MSG_DIALOG);
		data << mapmgr.GetDlgNpcID() << (unsigned short)(mapmgr.usData) << (unsigned char)(op.idx);
		data << (unsigned char)_TXTATR_ENTRANCE;
		data.WriteUnicodeString(op.str);
		NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
		mapmgr.ClearNPCChat();
	}
	
	this->Close();
}