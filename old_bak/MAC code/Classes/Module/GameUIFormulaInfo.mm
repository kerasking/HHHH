/*
 *  GameUIFormulaInfo.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-26.m_iCol
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GameUIFormulaInfo.h"
#include "NDDirector.h"
#include "NDMapMgr.h"
#include "ItemMgr.h"
#include "NDConstant.h"
#include "CGPointExtension.h"
#include "FormulaMaterialData.h"
#include "NDUtility.h"
#include "NDPath.h"
#include <sstream>

#define item_cell_h (42)
#define item_cell_w (42)

IMPLEMENT_CLASS(FormulaInfoLayer, NDUILayer)

FormulaInfoLayer::FormulaInfoLayer()
{
	m_iCol = eCol;
	m_bCacl = false;
}

FormulaInfoLayer::~FormulaInfoLayer()
{
}

void FormulaInfoLayer::Initialization(int iFormulaID, int iItemCol/*=eCol*/)
{
	FormulaMaterialData *formuladata = NDMapMgrObj.getFormulaData(iFormulaID);
	
	if ( !formuladata )
	{
		return;
	}
	
	NDUILayer::Initialization();
	
	this->SetBackgroundColor(ccc4(255, 255, 255, 0));
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetText(formuladata->formulaName.c_str());
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 255, 255, 255));
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetVisible(true);
	this->AddChild(m_lbTitle);
	
	InitItemInfo(formuladata->itemType1, formuladata->itemCount1);
	InitItemInfo(formuladata->itemType2, formuladata->itemCount2);
	InitItemInfo(formuladata->itemType3, formuladata->itemCount3);
	
	m_iCol = iItemCol;
	m_iFormulaID = iFormulaID;
}

void FormulaInfoLayer::draw()
{
	NDUILayer::draw();
	
	if (!m_bCacl) 
	{
		CGRect rect = GetFrameRect();
		CGSize infosize = GetInfoSize();
		
		int iStartX = 0, iStartY = 0;
		if (rect.size.width > infosize.width) 
		{
			iStartX = (rect.size.width - infosize.width)/2;
		}
		if (rect.size.height > infosize.height) 
		{
			iStartY = (rect.size.height - infosize.height)/2;
		}
		
		if (m_lbTitle) 
		{
			CGSize sizetitle = getStringSizeMutiLine(m_lbTitle->GetText().c_str(), m_lbTitle->GetFontSize(), CGSizeMake(480,320));
			m_lbTitle->SetFrameRect(CGRectMake(iStartX, iStartY+eTitleInterval, sizetitle.width, sizetitle.height));
			iStartY += eTitleInterval*2+sizetitle.height;
		}
		
		int iIndex = 0;
		for_vec(m_vecFormulaInfo, formula_info_it)
		{
			s_formula_info& info = *it;
			NDUIItemButton	*&btn		= info.btn;
			NDUILayer		*&layer		= info.layer;
			NDUILabel		*&lbInfo	= info.lbInfo;
			
			if (btn && layer) 
			{
				int iX = iStartX, iY = iStartY; 
				iX += (iIndex%m_iCol)*(item_cell_w+eInfoW+eInfoInterval)+ ( (iIndex%m_iCol) == 0 ? 0 : (iIndex%m_iCol-1)*eInfoInterval );
				iY += (iIndex/m_iCol)*(item_cell_h+eInfoInterval);
				
				btn->SetFrameRect(CGRectMake(iX, iY, item_cell_w, item_cell_h));
				layer->SetFrameRect(CGRectMake(iX+item_cell_w+eInfoInterval, iY, eInfoW, eInfoH));
				lbInfo->SetFrameRect(CGRectMake(0, (eInfoH-lbInfo->GetFontSize())/2, eInfoW, eInfoH));
				btn->SetVisible(true);
				layer->SetVisible(true);
				lbInfo->SetVisible(true);
			}
			
			iIndex++;
		}
	}
	
	m_bCacl = true;
}

bool FormulaInfoLayer::TouchBegin(NDTouch* touch)
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
	
	FormulaInfoDelegate* delegate = dynamic_cast<FormulaInfoDelegate*> (this->GetDelegate());
	if ( !delegate || !delegate->OnFormulaInfoClick(this) ) 
	{
		FormulaMaterialData *formuladata = NDMapMgrObj.getFormulaData(GetFormulaID());
		
		if ( !formuladata )
		{
			return true;
		}
		
		formuladata->showDetailDialog();
	}
	
	return true;
}

bool FormulaInfoLayer::TouchEnd(NDTouch* touch)
{
	return true;
}

int FormulaInfoLayer::GetFormulaID()
{
	return m_iFormulaID;
}

void FormulaInfoLayer::InitItemInfo(int itemType, int iRequireCount)
{
	int count = ItemMgrObj.GetBagItemCount(itemType);
	
	std::stringstream ss;
	ss << count << "/" << iRequireCount;
	
	Item *item = new Item(itemType);
	
	s_formula_info info;
	
	info.item = item;
	
	info.btn = new NDUIItemButton;
	info.btn->Initialization();
	info.btn->ChangeItem(item);
	info.btn->SetVisible(false);
	this->AddChild(info.btn);
	
	info.layer = new NDUILayer;
	info.layer->Initialization();
	info.layer->SetBackgroundColor(ccc4(160, 177, 155, 255));
	info.layer->SetVisible(false);
	this->AddChild(info.layer);
	
	info.lbInfo = new NDUILabel;
	info.lbInfo->Initialization();
	info.lbInfo->SetFontSize(13);
	info.lbInfo->SetFontColor(ccc4(11, 34, 18, 255));
	info.lbInfo->SetTextAlignment(LabelTextAlignmentLeft);
	info.lbInfo->SetVisible(false);
	info.lbInfo->SetText(ss.str().c_str());
	info.layer->AddChild(info.lbInfo);
	
	m_vecFormulaInfo.push_back(info);	
}

CGSize FormulaInfoLayer::GetInfoSize()
{
	CGSize res = CGSizeZero;
	
	if (m_lbTitle) 
	{
		CGSize sizetitle = getStringSizeMutiLine(m_lbTitle->GetText().c_str(), m_lbTitle->GetFontSize(), CGSizeMake(480,320));
		res.height = sizetitle.height+eTitleInterval*2;
		res.width  = sizetitle.width;
	}
	int iSize = m_vecFormulaInfo.size();
	if (iSize == 0) 
	{
		return res;
	}
	int iInfoW = (item_cell_w+eInfoW+eInfoInterval)*m_iCol + (m_iCol-1)*eInfoInterval;
	int iRowCount = iSize/m_iCol+ (iSize%m_iCol == 0 ? 0 : 1);
	int iInfoH = iRowCount * item_cell_h + (iRowCount-1)*eInfoInterval;
	
	res.width = ( res.width > iInfoW ? res.width : iInfoW );
	res.height += iInfoH;
	
	return res;
}

////////////////////////////////////////////////

IMPLEMENT_CLASS(FormulaInfoDialog, NDUILayer)

#define bottom_image [NSString stringWithFormat:@"%s", GetImgPath("bottom.png")]

FormulaInfoDialog::FormulaInfoDialog()
{		
	m_layerContext = NULL;
	m_table = NULL;
	
	m_leaveButtonExists = false;
	
	m_width = 200;
	m_contextHeight = 180;
	m_buttonHeight = 28;
	
	std::string bottomImage = NDPath::GetImgPath("bottom.png");
	m_picLeftTop = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
	m_picLeftTop->SetReverse(true);
	m_picLeftTop->Rotation(PictureRotation180);
	
	m_picRightTop = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
	m_picRightTop->Rotation(PictureRotation180);
	
	m_picLeftBottom = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
	
	m_picRightBottom = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
	m_picRightBottom->SetReverse(true);
	
	m_bTouchBegin = false;
}

FormulaInfoDialog::~FormulaInfoDialog()
{
	delete m_picLeftTop;
	delete m_picRightTop;
	delete m_picLeftBottom;
	delete m_picRightBottom;
}

void FormulaInfoDialog::Initialization()
{	
	NDUILayer::Initialization();	
	
	m_table = new NDUITableLayer();
	m_table->Initialization();
	m_table->VisibleSectionTitles(false);
	m_table->SetDelegate(this);
	
	this->SetFrameRect(CGRectMake(0, 0, NDDirector::DefaultDirector()->GetWinSize().width, NDDirector::DefaultDirector()->GetWinSize().height));
}

void FormulaInfoDialog::draw()
{
	NDUILayer::draw();
	
	if (this->IsVisibled()) 
	{
		CGRect scrRect = this->GetScreenRect();
		
		// top frame
		//			this->DrawLine(ccp(scrRect.origin.x + 40, scrRect.origin.y + 3), 
		//						   ccp(scrRect.origin.x + scrRect.size.width - 40, scrRect.origin.y + 3), 
		//						   ccc4(49, 93, 90, 255), 1);
		//			this->DrawLine(ccp(scrRect.origin.x + 40, scrRect.origin.y + 4), 
		//						   ccp(scrRect.origin.x + scrRect.size.width - 40, scrRect.origin.y + 4), 
		//						   ccc4(107, 146, 140, 255), 1);
		//			this->DrawLine(ccp(scrRect.origin.x + 40, scrRect.origin.y + 5), 
		//						   ccp(scrRect.origin.x + scrRect.size.width - 40, scrRect.origin.y + 5), 
		//						   ccc4(74, 109, 107, 255), 1);		
		
		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 2), 
				 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 2), 
				 ccc4(41, 65, 33, 255), 1);
		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 3), 
				 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 3), 
				 ccc4(57, 105, 90, 255), 1);
		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 4), 
				 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 4), 
				 ccc4(82, 125, 115, 255), 1);
		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 5), 
				 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 5), 
				 ccc4(82, 117, 82, 255), 1);
		
		//bottom frame
		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 2), 
				 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 2), 
				 ccc4(41, 65, 33, 255), 1);
		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 3), 
				 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 3), 
				 ccc4(57, 105, 90, 255), 1);
		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 4), 
				 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 4), 
				 ccc4(82, 125, 115, 255), 1);
		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 5), 
				 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 5), 
				 ccc4(82, 117, 82, 255), 1);
		
		//left frame
		DrawLine(ccp(scrRect.origin.x + 13, scrRect.origin.y + 16), 
				 ccp(scrRect.origin.x + 13, scrRect.origin.y + scrRect.size.height - 16), 
				 ccc4(115, 121, 90, 255), 8);
		//			this->DrawLine(ccp(scrRect.origin.x + 17, scrRect.origin.y + 16), 
		//						   ccp(scrRect.origin.x + 17, scrRect.origin.y + scrRect.size.height - 16), 
		//						   ccc4(107, 89, 74, 255), 1);
		
		//right frame
		DrawLine(ccp(scrRect.origin.x + scrRect.size.width - 13, scrRect.origin.y + 16), 
				 ccp(scrRect.origin.x + scrRect.size.width - 13, scrRect.origin.y + scrRect.size.height - 16), 
				 ccc4(115, 121, 90, 255), 8);
		//			this->DrawLine(ccp(scrRect.origin.x + scrRect.size.width - 17, scrRect.origin.y + 16), 
		//						   ccp(scrRect.origin.x + scrRect.size.width - 17, scrRect.origin.y + scrRect.size.height - 16), 
		//						   ccc4(107, 89, 74, 255), 1);
		
		//background
		DrawRecttangle(CGRectMake(scrRect.origin.x + 17, scrRect.origin.y + 5, scrRect.size.width - 34, scrRect.size.height - 10), ccc4(196, 201, 181, 255));
		
		
		m_picLeftTop->DrawInRect(CGRectMake(scrRect.origin.x+7, 
											scrRect.origin.y, 
											m_picLeftTop->GetSize().width, 
											m_picLeftTop->GetSize().height));
		m_picRightTop->DrawInRect(CGRectMake(scrRect.origin.x + scrRect.size.width - m_picRightTop->GetSize().width - 7, 
											 scrRect.origin.y, 
											 m_picRightTop->GetSize().width, 
											 m_picRightTop->GetSize().height));
		m_picLeftBottom->DrawInRect(CGRectMake(scrRect.origin.x+7, 
											   scrRect.origin.y + scrRect.size.height - m_picLeftBottom->GetSize().height,
											   m_picLeftBottom->GetSize().width, 
											   m_picLeftBottom->GetSize().height));
		m_picRightBottom->DrawInRect(CGRectMake(scrRect.origin.x + scrRect.size.width - m_picRightBottom->GetSize().width - 7,
												scrRect.origin.y + scrRect.size.height - m_picRightBottom->GetSize().height,
												m_picRightBottom->GetSize().width,
												m_picRightBottom->GetSize().height));
	}
}

void FormulaInfoDialog::Show(int foumulaID, const char* cancleButton, const std::vector<std::string>& ortherButtons)
{		
	if (this->GetParent()) 
	{
		return;
	}
	
	m_leaveButtonExists = false;
	
	m_layerContext = new FormulaInfoLayer;
	m_layerContext->Initialization(foumulaID);
	CGSize sizeContext = m_layerContext->GetInfoSize();
	m_width = sizeContext.width + 74 > m_width ? sizeContext.width+74 : m_width;// interval = 20
	int iHeight = (sizeContext.height+40 > 180) ? (sizeContext.height+40) : 180;
	m_layerContext->SetFrameRect(CGRectMake(17, 5,m_width-34, iHeight));
	this->AddChild(m_layerContext);
	
	NDDataSource* dataSource = new NDDataSource();				
	NDSection* section = new NDSection();
	section->SetRowHeight(m_buttonHeight);
	dataSource->AddSection(section);
	m_table->SetDataSource(dataSource);
	m_table->SetFrameRect(CGRectMake(17, iHeight,
									 m_width - 34, 0));
	this->AddChild(m_table);
	
	if (ortherButtons.size() > 0) 
	{
		m_table->SetFrameRect(CGRectMake(17, iHeight, 
										 m_width - 34, (m_buttonHeight) * ortherButtons.size() + 1));
		iHeight += (m_buttonHeight) * ortherButtons.size() + 1;
	}		
	
	if (ortherButtons.size() > 0) 
	{			
		for (unsigned int i = 0; i < ortherButtons.size(); i++) 
		{
			std::string btnTitle = ortherButtons.at(i);
			
			NDUIButton* btn = new NDUIButton();
			btn->Initialization();
			btn->SetFocusColor(ccc4(253, 253, 253, 255));
			btn->SetTitle(btnTitle.c_str());
			
			section->AddCell(btn);				
		}								
	}
	
	if (cancleButton && strlen(cancleButton) != 0) 
	{
		m_leaveButtonExists = true;
		
		NDUIButton* btn = new NDUIButton();
		btn->Initialization();
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		btn->SetTitle(cancleButton);
		
		section->AddCell(btn);
		CGRect rect = m_table->GetFrameRect();
		m_table->SetFrameRect(CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, m_buttonHeight + 2 + rect.size.height));
		iHeight += m_buttonHeight + 2;
	}
	
	if (section->Count() > 0) 
	{
		section->SetFocusOnCell(0);
	}
	
	CGSize frameSize = CGSizeMake(m_width, iHeight+10);
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	this->SetFrameRect(CGRectMake((winSize.width - frameSize.width) / 2, 
								  (winSize.height - frameSize.height) / 2, 
								  frameSize.width, frameSize.height));
	
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene) 
	{
		scene->AddChild(this, UIDIALOG_Z-1);
		
		FormulaInfoDialogDelegate* delegate = dynamic_cast<FormulaInfoDialogDelegate*> (this->GetDelegate());
		if (delegate) 
		{
			delegate->OnFormulaInfoDialogShow(this);
		}
	}					
}

void FormulaInfoDialog::Show(int foumulaID, const char* cancleButton, const char* ortherButtons,...)
{
	va_list argumentList;
	char *eachObject;
	std::vector<std::string> btns; 
	
	if (ortherButtons) 
	{	
		btns.push_back(std::string(ortherButtons));
		va_start(argumentList, ortherButtons);
		while ((eachObject = va_arg(argumentList, char*))) 
		{
			btns.push_back(std::string(eachObject));
		}
		va_end(argumentList);
	}
	
	this->Show(foumulaID, cancleButton, btns);
	
}

bool FormulaInfoDialog::DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch)
{
	return NDUILayer::DispatchTouchEndEvent(beginTouch, endTouch);;
}

bool FormulaInfoDialog::TouchBegin(NDTouch* touch)
{
	if ( !(this->IsVisibled() && this->EventEnabled()) )
	{
		return false;
	}
	
	m_beginTouch = touch->GetLocation();
	
	int iCellCount = 0;
	if (m_table && m_table->GetDataSource() && m_table->GetDataSource()->Section(0))
	{
		iCellCount = m_table->GetDataSource()->Section(0)->Count();
	}
	
	if (iCellCount < 1)
	{
		this->Close();
		return true;
	}		
	
	m_bTouchBegin = CGRectContainsPoint(this->GetScreenRect(), m_beginTouch);
	
	return true;
}

bool FormulaInfoDialog::TouchEnd(NDTouch* touch)
{
	m_endTouch = touch->GetLocation();		
	
	if (CGRectContainsPoint(this->GetScreenRect(), m_endTouch) && this->IsVisibled() && this->EventEnabled() && m_bTouchBegin) 
	{
		this->DispatchTouchEndEvent(m_beginTouch, m_endTouch);
	}
	
	m_bTouchBegin = false;
	
	return true;
}

void FormulaInfoDialog::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (cellIndex == section->Count()-1) 
	{
		if (m_leaveButtonExists) 
		{
			this->Close();
			return;
		}
	}
	
	FormulaInfoDialogDelegate* delegate = dynamic_cast<FormulaInfoDialogDelegate*> (this->GetDelegate());
	if (delegate) 
	{
		delegate->OnFormulaInfoDialogClick(this, cellIndex);
	}
	
}

bool FormulaInfoDialog::OnFormulaInfoClick(FormulaInfoLayer* layer)
{
	FormulaInfoDialogDelegate* delegate = dynamic_cast<FormulaInfoDialogDelegate*> (this->GetDelegate());
	if (!delegate) 
	{
		return false;
	}
	
	return delegate->OnFormulaInfoClick(this, layer->GetFormulaID());
}

void FormulaInfoDialog::SetWidth(unsigned int width)
{
	m_width = width;
}

void FormulaInfoDialog::SetTitleHeight(unsigned int height)
{
	m_titleHeight = height;
}

void FormulaInfoDialog::SetContextHeight(unsigned int height)
{
	m_contextHeight = height;
}

void FormulaInfoDialog::SetButtonHeight(unsigned int height)
{
	m_buttonHeight = height;
}

void FormulaInfoDialog::Close()
{
	FormulaInfoDialogDelegate* delegate = dynamic_cast<FormulaInfoDialogDelegate*> (this->GetDelegate());
	if (delegate) 
	{
		delegate->OnFormulaInfoDialogClose(this);					
	}
	
	if (this->GetParent()) 
	{
		this->RemoveFromParent(true);
	}		
}

int FormulaInfoDialog::GetFormulaID()
{
	if (m_layerContext) 
	{
		return m_layerContext->GetFormulaID();
	}
	
	return 0;
}