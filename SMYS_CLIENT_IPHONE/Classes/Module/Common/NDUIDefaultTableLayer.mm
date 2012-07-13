/*
 *  NDUIDefaultTableLayer.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-9.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDUIDefaultTableLayer.h"
#import "NDDirector.h"
#import "CGPointExtension.h"
#import "NDUIBaseGraphics.h"
#import "NDUtility.h"
#import "ccMacros.h"

namespace NDEngine
{
#define FONT_SIZE 15
#define TITLE_PICTURE [NSString stringWithFormat:@"%s", GetImgPath("plusMinus.png")] 
	
	void NDUIDefaultSectionTitleDelegate::OnDefaultSectionTitleClick(NDUIDefaultSectionTitle* sectionTitle)
	{
	}
	
	void NDUIDefaultTableLayerDelegate::OnDefaultTableLayerCellSelected(NDUIDefaultTableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
	{
	}
	
	void NDUIDefaultTableLayerDelegate::OnDefaultTableLayerCellFocused(NDUIDefaultTableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
	{
	}
	
	void NDUIDefaultVerticalScrollBarDelegate::OnDefaultVerticalScrollBarUpClick(NDUIDefaultVerticalScrollBar* scrollBar)
	{
	}
	
	void NDUIDefaultVerticalScrollBarDelegate::OnDefaultVerticalScrollBarDownClick(NDUIDefaultVerticalScrollBar* scrollBar)
	{
	}
	
	///////////////////////////////////
	IMPLEMENT_CLASS(NDUIDefaultSectionTitle, NDUINode)
	NDUIDefaultSectionTitle::NDUIDefaultSectionTitle()
	{
		m_lblText = NULL;
		m_touched = false;
		m_picOpen = m_picClose = m_picBG = m_picFocusBG = NULL;
		m_bStateClearOnFree = m_bBGClearOnFree = true;
	}
	
	NDUIDefaultSectionTitle::~NDUIDefaultSectionTitle()
	{
		if (m_bStateClearOnFree) 
		{
			delete m_picOpen;
			delete m_picClose;
		}
		
		if (m_bBGClearOnFree) 
		{
			delete m_picBG;
			delete m_picFocusBG;
		}
	}
	
	void NDUIDefaultSectionTitle::Initialization()
	{
		NDUINode::Initialization();
		
		m_lblText = new NDUILabel();
		m_lblText->Initialization();
		m_lblText->SetFontSize(FONT_SIZE);
		m_lblText->SetTextAlignment(LabelTextAlignmentLeft);
		m_lblText->SetFontColor(ccc4(249, 164, 131, 255));
		this->AddChild(m_lblText);
		
		NDPicturePool& picpool = *(NDPicturePool::DefaultPool());
		
		m_picOpen = picpool.AddPicture(GetImgPathNew("icon_open.png"));
		
		m_picClose = picpool.AddPicture(GetImgPathNew("icon_close.png"));
		
		m_bStateClearOnFree = true;
	}
	
	void NDUIDefaultSectionTitle::SetText(const char* title)
	{
		m_lblText->SetText(title);
	}
	
	std::string NDUIDefaultSectionTitle::GetText()
	{
		return m_lblText->GetText();
	}
	
	void NDUIDefaultSectionTitle::SetTextAlignment(LabelTextAlignment align)
	{
		m_lblText->SetTextAlignment(align);
	}
	
	void NDUIDefaultSectionTitle::SetFontColor(ccColor4B fontColor)
	{
		m_lblText->SetFontColor(fontColor);
	}
	
	ccColor4B NDUIDefaultSectionTitle::GetFontColor()
	{
		return m_lblText->GetFontColor();
	}
	
	void NDUIDefaultSectionTitle::SetFrameRect(CGRect rect)
	{
		NDUINode::SetFrameRect(rect);
		m_lblText->SetFrameRect(CGRectMake(30, (rect.size.height-FONT_SIZE)/2, rect.size.width, rect.size.height));
		
		if (m_picBG || m_picFocusBG || rect.size.width == 0 || rect.size.height == 0) 
		{
			return;
		}
		
		NDPicturePool& picpool = *(NDPicturePool::DefaultPool());
		
		//m_picBG = picpool.AddPicture(GetImgPathNew("btn_ok&cancel_normal.png"), rect.size.width, rect.size.height);
		
		//m_picFocusBG = picpool.AddPicture(GetImgPathNew("btn_ok&cancel_hightlight.png"), rect.size.width, rect.size.height);
		
		m_picBG = picpool.AddPicture(GetImgPathNew("btn_back2.png"), rect.size.width, rect.size.height);
		
		m_picFocusBG = picpool.AddPicture(GetImgPathNew("btn_back2_focused.png"), rect.size.width, rect.size.height);
		
		m_bBGClearOnFree = true;
	}
	
	void NDUIDefaultSectionTitle::SetStatePicture(NDPicture *picOpen, NDPicture *close, bool bClearOnFree/*=true*/)
	{
		if (m_bStateClearOnFree) 
		{
			delete m_picOpen;
			delete m_picClose;
		}
		
		m_picOpen = picOpen;
		
		m_picClose = close;
		
		m_bStateClearOnFree = bClearOnFree;
	}
	
	void NDUIDefaultSectionTitle::SetBGPicture(NDPicture *pic, NDPicture *picfocus, bool bClearOnFree/*=true*/)
	{
		if (m_bBGClearOnFree) 
		{
			delete m_picBG;
			delete m_picFocusBG;
		}
		
		m_picBG = pic;
		
		m_picFocusBG = picfocus;
		
		m_bBGClearOnFree = bClearOnFree;
	}
	
	void NDUIDefaultSectionTitle::draw()
	{
		NDUINode::draw();
		
		if (this->IsVisibled()) 
		{
			NDNode* parentNode = this->GetParent();
			if (parentNode) 
			{
				if (parentNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
				{
					NDUILayer* uiLayer = (NDUILayer*)parentNode;
					
					CGRect scrRect = this->GetScreenRect();
					
					/*
					ccColor4B color;
					if (m_touched) 
						color = ccc4(247, 223, 156, 255);
					else 
						color = ccc4(198, 211, 214, 255);
					
					//draw back ground image
					DrawRecttangle(CGRectMake(scrRect.origin.x + 10, scrRect.origin.y, scrRect.size.width - 20, scrRect.size.height), color);						
					DrawCircle(ccp(scrRect.origin.x + 10, scrRect.origin.y + 12), 13, 0, 10, color);
					DrawCircle(ccp(scrRect.origin.x + scrRect.size.width - 10, scrRect.origin.y + 12), 13, 0, 10, color);					
					
					DrawPolygon(scrRect, ccc4(125, 125, 125, 255), 1);
					*/
					
					if (parentNode->IsKindOfClass(RUNTIME_CLASS(NDUIDefaultTableLayer))) 
					{
						NDUIDefaultTableLayer* table = (NDUIDefaultTableLayer*)uiLayer;
						if (table->GetActiveSectionTitle() == this) 
						{
							if (m_picFocusBG)
								m_picFocusBG->DrawInRect(scrRect);
							else if (m_picBG)
								m_picBG->DrawInRect(scrRect);
								
							if (m_picClose)
								m_picClose->DrawInRect(CGRectMake(scrRect.origin.x + 20,
																  scrRect.origin.y + (scrRect.size.height-m_picClose->GetSize().height)/2,
																  m_picClose->GetSize().width, m_picClose->GetSize().height));
						}
						else 
						{
							if (m_picBG)
								m_picBG->DrawInRect(scrRect);
							if (m_picOpen)
								m_picOpen->DrawInRect(CGRectMake(scrRect.origin.x + 20,
																 scrRect.origin.y + (scrRect.size.height-m_picOpen->GetSize().height)/2,
																 m_picOpen->GetSize().width, m_picOpen->GetSize().height));
						}
					}
				}			
			}
			
		}
	}
	
	///////////////////////////////////////
	IMPLEMENT_CLASS(NDUIDefaultVerticalScrollBar, NDUINode)
	NDUIDefaultVerticalScrollBar::NDUIDefaultVerticalScrollBar()
	{
		m_currentContentY = 0;
		m_contentHeight = 0;
		m_picUp = NULL;
		m_picDown = NULL;
		m_touched = false;
		m_touchPos = CGPointZero;
	}
	
	NDUIDefaultVerticalScrollBar::~NDUIDefaultVerticalScrollBar()
	{
		delete m_picUp;
		delete m_picDown;
	}
	
	void NDUIDefaultVerticalScrollBar::Initialization()
	{
		NDUINode::Initialization();
		
		m_picUp = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("scroll_arrow.png"));
		m_picDown = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("scroll_arrow.png"));
		m_picDown->Rotation(PictureRotation180);		
	}
	
	void NDUIDefaultVerticalScrollBar::SetCurrentContentY(float y)
	{
		m_currentContentY = y;
	}
	
	float NDUIDefaultVerticalScrollBar::GetCurrentContentY()
	{
		return m_currentContentY;
	}
	
	void NDUIDefaultVerticalScrollBar::SetContentHeight(float h)
	{
		m_contentHeight = h;
	}
	
	float NDUIDefaultVerticalScrollBar::GetContentHeight()
	{
		return m_contentHeight;
	}
	
	void NDUIDefaultVerticalScrollBar::OnClick(CGPoint touch)
	{
		CGRect scrRect = this->GetScreenRect();
		
		if (m_contentHeight < scrRect.size.height) 
		{
			return;
		}
		
		if (scrRect.size.width < m_picUp->GetSize().width || scrRect.size.height < m_picUp->GetSize().height + m_picDown->GetSize().height) 
		{
			return;
		}
		
		CGRect picUpRect = CGRectMake(scrRect.origin.x, scrRect.origin.y, 
									  m_picUp->GetSize().width, m_picUp->GetSize().height);
		CGRect picDownRect = CGRectMake(scrRect.origin.x, scrRect.origin.y + scrRect.size.height - m_picDown->GetSize().height, 
										m_picDown->GetSize().width, m_picDown->GetSize().height);
		
		if (CGRectContainsPoint(picUpRect, touch)) 
		{
			NDUIDefaultVerticalScrollBarDelegate* delegate = dynamic_cast<NDUIDefaultVerticalScrollBarDelegate*> (this->GetDelegate());
			if (delegate) 
			{						
				delegate->OnDefaultVerticalScrollBarUpClick(this);
			}
		}
		else if (CGRectContainsPoint(picDownRect, touch)) 
		{
			NDUIDefaultVerticalScrollBarDelegate* delegate = dynamic_cast<NDUIDefaultVerticalScrollBarDelegate*> (this->GetDelegate());
			if (delegate) 
			{						
				delegate->OnDefaultVerticalScrollBarDownClick(this);
			}
		}
	}
	
	void NDUIDefaultVerticalScrollBar::draw()
	{
		if (this->IsVisibled()) 
		{
			CGRect scrRect = this->GetScreenRect();		
			
			if (scrRect.size.width < m_picUp->GetSize().width || scrRect.size.height < m_picUp->GetSize().height + m_picDown->GetSize().height) 
			{
				return;
			}
			
			if (m_contentHeight < scrRect.size.height) 
			{
				m_contentHeight = scrRect.size.height;
			}
			
			
			CGRect picUpRect = CGRectMake(scrRect.origin.x, scrRect.origin.y, 
										  m_picUp->GetSize().width, m_picUp->GetSize().height);
			CGRect picDownRect = CGRectMake(scrRect.origin.x, scrRect.origin.y + scrRect.size.height - m_picDown->GetSize().height, 
											m_picDown->GetSize().width, m_picDown->GetSize().height);
			
			if (m_touched) 
			{
				if (CGRectContainsPoint(picUpRect, m_touchPos)) 
				{
					m_picUp->SetColor(ccc4(125, 125, 125, 125));
				}
				else if (CGRectContainsPoint(picDownRect, m_touchPos)) 
				{
					m_picDown->SetColor(ccc4(125, 125, 125, 125));
				}
			}
			else 
			{
				m_picUp->SetColor(ccc4(255, 255, 255, 255));
				m_picDown->SetColor(ccc4(255, 255, 255, 255));
			}
			
			
			DrawRecttangle(scrRect, ccc4(49, 150, 189, 255));
			
			m_picUp->DrawInRect(picUpRect);
			m_picDown->DrawInRect(picDownRect);
			
			float scrollHeight = scrRect.size.height - m_picUp->GetSize().height - m_picDown->GetSize().height;
			float blockHeight = scrRect.size.height / m_contentHeight * scrollHeight;			
			float posY = m_currentContentY / m_contentHeight * scrollHeight;
			
			DrawRecttangle(CGRectMake(scrRect.origin.x, scrRect.origin.y + m_picUp->GetSize().height + posY, 14, blockHeight), ccc4(57, 109, 107, 255));
			DrawRecttangle(CGRectMake(scrRect.origin.x + 14, scrRect.origin.y + m_picUp->GetSize().height + posY, 14, blockHeight), ccc4(24, 60, 66, 255));
			
		}
	}
	
	
	///////////////////////////////////////
	IMPLEMENT_CLASS(NDUIDefaultTableLayer, NDUILayer)
	
	NDUIDefaultTableLayer::NDUIDefaultTableLayer()
	{
		m_dataSource = NULL;	
		m_needReflash = true;
		m_curSection = NULL;
		m_curSectionIndex = -1;
		m_sectionTitleVisibled = true;
		m_sectionTitlesHeight = 25;
		m_scrollBarVisibled = false;
		m_scrollBarWidth = 28;
		
		m_cellsInterval = 1;
		m_cellsLeftDistance = 2;
		m_cellsRightDistance = 2;
		
		m_bgColor = ccc4(255, 255, 255, 0);
		
		m_sectionTitlesAlign = LabelTextAlignmentCenter;
		
		m_style = DefaultTableLayerStyle_SingleSection;
	}
	
	NDUIDefaultTableLayer::~NDUIDefaultTableLayer()
	{
		delete m_dataSource;
		
		for_vec(m_picCellBGPicture, std::vector<CellBG>::iterator)
		{
			delete (*it).pic;
		}
	}
	
	void NDUIDefaultTableLayer::Initialization()
	{
		NDUILayer::Initialization();
		NDUILayer::SetBackgroundColor(ccc4(255, 255, 255, 0));
		//this->SetBackgroundColor(ccc4(132, 138, 115, 255));
		//this->SetBackgroundColor(ccc4(108, 158, 155, 255));
		this->SetBackgroundColor(m_bgColor);
	}
	
	void NDUIDefaultTableLayer::SetFocusOnCell(unsigned int cellIndex)
	{
		if (!m_curSection) return;
		
		m_curSection->SetFocusOnCell(cellIndex);
		
		if (m_curSection && m_curSection->Count() > cellIndex) 
		{
			NDUINode* cell = m_curSection->Cell(cellIndex);
			this->SetFocus(cell);
			NDUIDefaultTableLayerDelegate* delegate = dynamic_cast<NDUIDefaultTableLayerDelegate*> (this->GetDelegate());
			if (delegate) 
			{
				delegate->OnDefaultTableLayerCellFocused(this, cell, cellIndex, m_curSection);
			}
		}
	}
	
	void NDUIDefaultTableLayer::SetDataSource(NDDataSource* dataSource)
	{
		if (m_dataSource != dataSource) 
		{
			delete m_dataSource;
		}
		m_dataSource = dataSource;
	}
	
	void NDUIDefaultTableLayer::SetBackgroundColor(ccColor4B color)
	{
		m_bgColor = color;
	}
	
	void NDUIDefaultTableLayer::ReflashData()
	{
		if (!m_dataSource) 
			return;
		
		m_sectionTitles.clear();
		m_backgrounds.clear();
		m_scrollBars.clear();
		
		for_vec(m_picCellBGPicture, std::vector<CellBG>::iterator)
		{
			delete (*it).pic;
		}
		m_picCellBGPicture.clear();
		
		for (unsigned int i = 0; i < m_dataSource->Count(); i++) 
		{
			NDSection* section = m_dataSource->Section(i);
			for (unsigned int j = 0; j < section->Count(); j++) 
			{
				NDUINode* uiNode = section->Cell(j);
				if (uiNode->GetParent()) 
				{
					uiNode->RemoveFromParent(false);
				}
			}
		}
		
		this->RemoveAllChildren(true);
		
		CGRect thisRect = this->GetFrameRect();	
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		//draw sections
		for (unsigned int i = 0; i < m_dataSource->Count(); i++) 
		{
			NDSection* section = m_dataSource->Section(i);			
			
			//draw background
			this->DrawBackground(i);
			
			//draw scrollbar
			if (m_scrollBarVisibled) 
			{
				if (section->Count() > 0) 
				{
					NDUIDefaultVerticalScrollBar* scrollBar = this->DrawScrollbar(i);
					//scrollBar->SetContentHeight((row - 1) * (section->GetRowHeight() + m_cellsInterval));
					CGRect lastCellRect = this->GetCellRectWithIndex(i, section->Count()-1);
					if (m_sectionTitleVisibled) 
						scrollBar->SetContentHeight(lastCellRect.origin.y + lastCellRect.size.height - (i + 1) * m_sectionTitlesHeight);
					else						
						scrollBar->SetContentHeight(lastCellRect.origin.y + lastCellRect.size.height);
				}				
			}
			
			for (unsigned int j = 0; j < section->Count(); j++) 
			{
				NDUINode* uiNode = section->Cell(j);
				
				//防止uilayer拦截行选择事件
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)) && !uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIDefaultTableLayer))) 
				{
					NDUILayer* uiLayer = (NDUILayer*)uiNode;
					uiLayer->SetTouchEnabled(false);
				}
				
				CGRect cellRect = this->GetCellRectWithIndex(i, j);
				//bool bDraw = CGRectIntersectsRect(m_backgrounds.at(i)->GetFrameRect(), cellRect) && (i == m_dataSource->Count() - 1);
				
				//draw cell					
				uiNode->SetFrameRect(cellRect);
				uiNode->EnableDraw(false);
				this->AddChild(uiNode);			
			}
		}
		
		if (m_dataSource->Count() > 0) 
		{			
			//m_curSectionIndex = m_dataSource->Count()-1;
			//m_curSection = m_dataSource->Section(m_curSectionIndex);
			
			//draw section titles		
			for (unsigned int i = 0; i < m_dataSource->Count(); i++) 
			{
				this->DrawSectionTitle(i);
			}
			/*
			if (m_dataSource->Count() > 0) 
			{
				NDUIDefaultSectionTitle* sectionTitle = m_sectionTitles.at(m_curSectionIndex);
				sectionTitle->OnTouchDown(true);
			}	
			this->SetFocusOnCell(m_curSection->GetFocusCellIndex());
			*/
		}
		else 
		{
			m_curSection = NULL;
		}
		
	}
	
	bool NDUIDefaultTableLayer::TouchMoved(NDTouch* touch)
	{	
		NDUILayer::TouchMoved(touch);
		
		if (!m_curSection) return false;
		
		if (m_sectionTitleVisibled) 
		{
			for (unsigned int i = 0; i < m_sectionTitles.size(); i++) 
			{
				NDUIDefaultSectionTitle* sectionTitle = m_sectionTitles.at(i);
				CGRect rect = sectionTitle->GetScreenRect();
				if (CGRectContainsPoint(rect, m_beginTouch)) 
					return false;
			}
		}			
		
		this->SetFocusOnCell(m_curSection->GetFocusCellIndex());
		
		if (m_curSection) 
		{
			CGPoint prePos = touch->GetPreviousLocation();
			CGPoint curPos = touch->GetLocation();
			CGFloat subValue = curPos.y - prePos.y;
			
			if (m_sectionTitles.size() > m_curSectionIndex) 
			{
				NDUIDefaultSectionTitle* sectionTitle = m_sectionTitles.at(m_curSectionIndex);
				CGRect sectionTitleRect = sectionTitle->GetFrameRect();			
				
				if (m_curSection->Count() > 0) 
				{
					if (subValue > 0)  
					{
						NDUINode* firstCell = m_curSection->Cell(0);					
						if (m_sectionTitleVisibled) 
						{
							if (firstCell->GetFrameRect().origin.y + subValue  > sectionTitle->GetFrameRect().origin.y + sectionTitle->GetFrameRect().size.height) 
							{
								subValue = sectionTitle->GetFrameRect().origin.y + sectionTitle->GetFrameRect().size.height - firstCell->GetFrameRect().origin.y + m_cellsInterval;
							}
						}
						else 
						{
							if (firstCell->GetFrameRect().origin.y + subValue  > sectionTitle->GetFrameRect().origin.y) 
							{
								subValue = sectionTitle->GetFrameRect().origin.y  - firstCell->GetFrameRect().origin.y + m_cellsInterval;
							}
						}						
						
						if (subValue <= 0) 
							return false;
					}
					else 
					{
						NDUINode* lastCell = m_curSection->Cell(m_curSection->Count() - 1);
						CGFloat sectionBottom = this->GetFrameRect().size.height;
						if (m_curSectionIndex + 1 < m_dataSource->Count()) 
						{
							NDUIDefaultSectionTitle* nextSectionTitle = m_sectionTitles.at(m_curSectionIndex + 1);
							sectionBottom = nextSectionTitle->GetFrameRect().origin.y - m_cellsInterval;
						}
						if (lastCell->GetFrameRect().origin.y + lastCell->GetFrameRect().size.height + subValue < sectionBottom) 
						{
							subValue = sectionBottom - lastCell->GetFrameRect().origin.y - lastCell->GetFrameRect().size.height - m_cellsInterval;
						}
						
						if (subValue >= 0) 
							return false;
					}			
				}
			}			
			
			if (m_backgrounds.size() > m_curSectionIndex) 
			{
				NDUIRecttangle* cellBackground = m_backgrounds.at(m_curSectionIndex);			
				for (unsigned int i = 0; i < m_curSection->Count(); i++) 
				{				
					NDUINode* uiNode = m_curSection->Cell(i);							
					CGRect nodeRect = uiNode->GetFrameRect();
					uiNode->SetFrameRect(CGRectMake(nodeRect.origin.x, nodeRect.origin.y + subValue, nodeRect.size.width, nodeRect.size.height));
					bool bDraw = CGRectIntersectsRect(cellBackground->GetFrameRect(), uiNode->GetFrameRect());					
					uiNode->EnableDraw(bDraw);					
				}
			}
			
			
			if (m_scrollBars.size() > m_curSectionIndex) 
			{
				if (m_scrollBarVisibled) 
				{
					NDUIDefaultVerticalScrollBar* scrollBar = m_scrollBars.at(m_curSectionIndex);
					scrollBar->SetCurrentContentY(scrollBar->GetCurrentContentY() - subValue);
				}
			}
			
		}
		
		return true;
	}
	
	bool NDUIDefaultTableLayer::DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch)
	{		
		if (NDUILayer::DispatchTouchEndEvent(beginTouch, endTouch))
			return true;
		
		if (m_curSection) 
		{			
			for (unsigned int i = 0; i < m_curSection->Count(); i++)
			{
				NDUINode* cell = m_curSection->Cell(i);
				CGRect rect = cell->GetScreenRect();
				
				if (CGRectContainsPoint(rect, m_endTouch)) 
				{
					if (CGRectContainsPoint(rect, beginTouch)) 
					{			
						if (m_curSection->GetFocusCellIndex() != i) 
						{
							this->SetFocusOnCell(i);
						}
						else 
						{
							NDUIDefaultTableLayerDelegate* delegate = dynamic_cast<NDUIDefaultTableLayerDelegate*> (this->GetDelegate());
							if (delegate) 
							{
								delegate->OnDefaultTableLayerCellSelected(this, cell, i, m_curSection);								
							}
						}				
						
						return true;
					}					
				}
			}					
		}
		
		return false;
	}
	
	CGRect NDUIDefaultTableLayer::GetCellRectWithIndex(unsigned int sectionIndex, unsigned int cellIndex)
	{
		CGRect rect = CGRectZero;
		
		NDSection* section = m_dataSource->Section(sectionIndex);
		if (section) 
		{
			//get rect.origin.x
			int row = section->Count() / section->GetColumnCount() + 1;
			int columnIndex = cellIndex / row;
			CGFloat cellWitdh;
			if (m_scrollBarVisibled)
			{
				cellWitdh = (this->GetFrameRect().size.width - m_scrollBarWidth) / section->GetColumnCount();
			}
			else 
			{
				cellWitdh = this->GetFrameRect().size.width / section->GetColumnCount();
			}
			rect.origin.x = columnIndex * cellWitdh + m_cellsLeftDistance;
			
			//get rect.origin.y
			if (m_sectionTitleVisibled) 
			{
				rect.origin.y = (sectionIndex + 1) * m_sectionTitlesHeight;
			}
			
			if (section->IsUseCellHeight()) 
			{
				rect.origin.y += m_cellsInterval;
				
				for (unsigned int i = 0; i < cellIndex; i++) 
				{
					NDUINode* uiNode = section->Cell(i);
					if (uiNode)
					{
						rect.origin.y += uiNode->GetFrameRect().size.height + m_cellsInterval;
					}
				}				
			}
			else 
			{
				int rowIndex = cellIndex / section->GetColumnCount();
				rect.origin.y += rowIndex * (section->GetRowHeight() + m_cellsInterval) + m_cellsInterval;
			}
			
			//get rect.size.width
			rect.size.width = cellWitdh - m_cellsLeftDistance - m_cellsRightDistance;
			
			//get rect.size.height
			if (section->IsUseCellHeight()) 
			{
				NDUINode* uiNode = section->Cell(cellIndex);
				rect.size.height = uiNode->GetFrameRect().size.height;
			}
			else 
			{
				rect.size.height = section->GetRowHeight();
			}
		}
		
		
		return rect;
	}
	
	void NDUIDefaultTableLayer::UpdateSection()
	{
		unsigned int sectionSize =  m_sectionTitles.size();
		
		for (unsigned int i = 0; i < sectionSize; i++) 
		{
			NDUIDefaultSectionTitle* section = m_sectionTitles.at(i);
			if (i == m_curSectionIndex) 
			{
				section->OnTouchDown(true);
			}
			else 
			{
				section->OnTouchDown(false);
			}
		}
		
		if (m_curSectionIndex >= sectionSize)
		{
			for (unsigned int i = 0 ; i < sectionSize; i++)
			{
				CGRect sectionTitleRect = m_sectionTitles.at(i)->GetFrameRect();
				this->MoveSection(i, i * m_sectionTitlesHeight - sectionTitleRect.origin.y);			
			}
		}
		else
		{
			if (m_style == DefaultTableLayerStyle_SingleSection)
			{
				CGRect rect = this->GetFrameRect();
				CGRect sectionTitleRect = m_sectionTitles.at(m_curSectionIndex)->GetFrameRect(); 
				
				this->MoveSection(m_curSectionIndex, -sectionTitleRect.origin.y);
			}
			else // if (m_style == DefaultTableLayerStyle_MutiSection)
			{
				for (unsigned int i = 0 ; i <= m_curSectionIndex; i++)
				{
					CGRect sectionTitleRect = m_sectionTitles.at(i)->GetFrameRect();
					this->MoveSection(i, i * m_sectionTitlesHeight - sectionTitleRect.origin.y);			
				}
				
				CGRect rect = this->GetFrameRect();
				for (unsigned int i = m_dataSource->Count() -1 ; i > m_curSectionIndex; i--) 
				{			
					CGRect sectionTitleRect = m_sectionTitles.at(i)->GetFrameRect(); 
					
					this->MoveSection(i, rect.size.height - sectionTitleRect.origin.y - sectionTitleRect.size.height);
					
					rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - sectionTitleRect.size.height);			
				}
			}
		}
				
		
		//set enable draw
		for (unsigned int i = 0; i < sectionSize; i++) 
		{
			NDUIDefaultSectionTitle* section = m_sectionTitles.at(i);
			if (m_curSectionIndex >= sectionSize)
				section->EnableDraw(true && m_sectionTitleVisibled);
			if (i == m_curSectionIndex || m_curSectionIndex >= sectionSize || m_style != DefaultTableLayerStyle_SingleSection) 
				section->EnableDraw(true && m_sectionTitleVisibled);
			else 
				section->EnableDraw(false);
		}
		for (unsigned int i = 0 ; i < m_dataSource->Count(); i++) 
		{
			NDUIRecttangle* background = m_backgrounds.at(i);
			if (i == m_curSectionIndex)
				background->EnableDraw(true);
			else 
				background->EnableDraw(false);			
			
			NDSection* section = m_dataSource->Section(i);
			for (unsigned int j = 0; j < section->Count(); j++) 
			{
				NDUINode* uiNode = section->Cell(j);
				
				if (i == m_curSectionIndex && CGRectIntersectsRect(background->GetFrameRect(), uiNode->GetFrameRect())) 
					uiNode->EnableDraw(true);
				else 
					uiNode->EnableDraw(false);
			}
		}
		
		//set focus
		if (m_curSectionIndex < sectionSize && m_curSection && m_curSection->Count() > 0)
		{	
			m_curSection->SetFocusOnCell(0);
			this->SetFocusOnCell(m_curSection->GetFocusCellIndex());
		}
	}
	
	NDUIDefaultSectionTitle* NDUIDefaultTableLayer::GetActiveSectionTitle()
	{
		if (!m_sectionTitles.empty() && m_curSectionIndex < m_sectionTitles.size()) 
		{
			return m_sectionTitles.at(m_curSectionIndex);
		}
		return NULL;
	}
	
	void NDUIDefaultTableLayer::draw()
	{	
		NDDirector::DefaultDirector()->SetViewRect(this->GetScreenRect(), this);
		
		NDUILayer::draw();
		
		if (!this->IsVisibled()) 
		{			
			return;
		}
		
		if (m_needReflash) 
		{
			this->ReflashData();
			UpdateSection();
			m_needReflash = false;
		}
		
		if (!m_strCellBGFile.empty() && !m_picCellBGPicture.empty() && m_picCellBGPicture.size() == m_backgrounds.size()) 
		{
			int i = 0;
			for_vec(m_backgrounds, std::vector<NDUIRecttangle*>::iterator)
			{
				NDUIRecttangle* node = *it;
				
				if (node->DrawEnabled()) 
				{
					node->SetVisible(false);
					
					CellBG& bg = m_picCellBGPicture[i];
					CGRect rect;
					
					rect.origin = node->GetScreenRect().origin;
					rect.size = bg.drawRect.size;
					
					bg.pic->DrawInRect(rect);
				}
				
				i++;
			}
		}		
	}
	
	void NDUIDefaultTableLayer::MoveSection(unsigned int sectionIndex, int moveLen)
	{
		if (moveLen == 0) 
			return;
		
		NDUIDefaultSectionTitle* sectionTitle = m_sectionTitles.at(sectionIndex);
		CGRect sectionRect = sectionTitle->GetFrameRect();
		sectionTitle->SetFrameRect(CGRectMake(sectionRect.origin.x, sectionRect.origin.y + moveLen, sectionRect.size.width, sectionRect.size.height));		
		
		NDUIRecttangle* background = m_backgrounds.at(sectionIndex);
		CGRect bkgRect = background->GetFrameRect();
		background->SetFrameRect(CGRectMake(bkgRect.origin.x, bkgRect.origin.y + moveLen, bkgRect.size.width, bkgRect.size.height));
		
		if (m_scrollBarVisibled) 
		{
			NDUIDefaultVerticalScrollBar* scrollBar = m_scrollBars.at(sectionIndex);
			CGRect sbRect = scrollBar->GetFrameRect();
			scrollBar->SetFrameRect(CGRectMake(sbRect.origin.x, sbRect.origin.y + moveLen, sbRect.size.width, sbRect.size.height));
		}		
		
		NDSection* section = m_dataSource->Section(sectionIndex);
		for (unsigned int j = 0; j < section->Count(); j++) 
		{
			NDUINode* uiNode = section->Cell(j);
			
			CGRect nodeRect = uiNode->GetFrameRect();
			uiNode->SetFrameRect(CGRectMake(nodeRect.origin.x, nodeRect.origin.y + moveLen, nodeRect.size.width, nodeRect.size.height));			
		}
	}
	
	void NDUIDefaultTableLayer::DrawBackground(unsigned int sectionIndex)
	{
		CGRect thisRect = this->GetFrameRect();
		
		NDUIRecttangle* cellBackground = new NDUIRecttangle();
		cellBackground->Initialization();
		cellBackground->EnableEvent(false);
		if (m_sectionTitleVisibled) 
		{
			cellBackground->SetFrameRect(CGRectMake(m_cellsLeftDistance, m_sectionTitlesHeight * (sectionIndex + 1), 
													thisRect.size.width-m_cellsLeftDistance-m_cellsRightDistance, thisRect.size.height - m_sectionTitlesHeight * m_dataSource->Count()));
		}
		else 
		{
			cellBackground->SetFrameRect(CGRectMake(m_cellsLeftDistance, 0, thisRect.size.width-m_cellsLeftDistance-m_cellsRightDistance, thisRect.size.height));
		}
		
		cellBackground->SetColor(m_bgColor);
		this->AddChild(cellBackground);
		m_backgrounds.push_back(cellBackground);
		
		if (!m_strCellBGFile.empty() && m_dataSource && m_dataSource->Count() > sectionIndex) 
		{
			NDSection* section = m_dataSource->Section(sectionIndex);
			
			CGRect rect = cellBackground->GetScreenRect();
			
			rect.size.height = 0;
			
			for (unsigned int j = 0; j < section->Count(); j++) 
			{
				CGRect cellRect = this->GetCellRectWithIndex(sectionIndex, j);
				
				rect.size.height += cellRect.size.height + m_cellsInterval;
			}
			
			rect.size.height += 6;
			
			NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew(m_strCellBGFile.c_str()), rect.size.width, rect.size.height);
			m_picCellBGPicture.push_back(CellBG(pic, rect));
		}
	}
	
	NDUIDefaultVerticalScrollBar* NDUIDefaultTableLayer::DrawScrollbar(unsigned int sectionIndex)
	{
		CGRect thisRect = this->GetFrameRect();
		
		NDUIDefaultVerticalScrollBar* scrollBar = new NDUIDefaultVerticalScrollBar();
		scrollBar->Initialization();
		scrollBar->SetDelegate(this);
		
		NDUIRecttangle* cellBackground = m_backgrounds.at(sectionIndex);
		CGRect cellBackgroundRect = cellBackground->GetFrameRect();		
		scrollBar->SetFrameRect(CGRectMake(cellBackgroundRect.origin.x + cellBackgroundRect.size.width - m_scrollBarWidth, cellBackgroundRect.origin.y, 
										   m_scrollBarWidth, cellBackgroundRect.size.height));
		this->AddChild(scrollBar);
		m_scrollBars.push_back(scrollBar);
		
		return scrollBar;
	}
	
	void NDUIDefaultTableLayer::DrawSectionTitle(unsigned int sectionIndex)
	{
		CGRect thisRect = this->GetFrameRect();
		
		NDSection* section = m_dataSource->Section(sectionIndex);
		
		NDUIDefaultSectionTitle* uiSectionTitle = new NDUIDefaultSectionTitle();
		uiSectionTitle->Initialization();
		uiSectionTitle->SetText(section->GetTitle().c_str());
		uiSectionTitle->SetFrameRect(CGRectMake(0, m_sectionTitlesHeight * sectionIndex, thisRect.size.width, m_sectionTitlesHeight));
		uiSectionTitle->SetTextAlignment(m_sectionTitlesAlign);
		uiSectionTitle->SetDelegate(this);
		uiSectionTitle->EnableDraw(m_sectionTitleVisibled);
		this->AddChild(uiSectionTitle, 1);
		m_sectionTitles.push_back(uiSectionTitle);
	}
	
	void NDUIDefaultTableLayer::OpenSection(unsigned int sectionIndex)
	{
		if (m_needReflash) 
		{
			this->ReflashData();
			m_needReflash = false;
		}
		
		if (sectionIndex >= m_sectionTitles.size() 
			|| sectionIndex >= m_dataSource->Count()
			|| sectionIndex == m_curSectionIndex
			)
			return;
		
		m_curSection = m_dataSource->Section(sectionIndex);;
	
		m_curSectionIndex = sectionIndex;
		
		UpdateSection();
	}
	
	void NDUIDefaultTableLayer::CloseSection(unsigned int sectionIndex)
	{
		if (m_needReflash) 
		{
			this->ReflashData();
			m_needReflash = false;
		}
		
		if (sectionIndex >= m_sectionTitles.size() || sectionIndex != m_curSectionIndex) return;
	
		m_curSection = NULL;
		
		m_curSectionIndex = -1;
		
		UpdateSection();
	}
	
	void NDUIDefaultTableLayer::SetStyle(DefaultTableLayerStyle style)
	{
		m_style = style;
	}
	
	void NDUIDefaultTableLayer::SetCellBackgroundPicture(std::string filename)
	{
		m_strCellBGFile = filename;
	}
	
	void NDUIDefaultTableLayer::OnDefaultSectionTitleClick(NDUIDefaultSectionTitle* sectionTitle)
	{	
		if (m_dataSource) 
		{
			for (unsigned int i = 0; i < m_sectionTitles.size(); i++) 
			{
				NDUIDefaultSectionTitle* section = m_sectionTitles.at(i);
				
				if (sectionTitle == section) 
				{
					if (i == m_curSectionIndex)
					{ 
						CloseSection(i);
						
					}
					else if (i != m_curSectionIndex)
					{
						OpenSection(i);
					}
					
					break;
				}				
			}
			
			/*
			for (unsigned int i = 0; i < m_sectionTitles.size(); i++) 
			{
				NDUIDefaultSectionTitle* section = m_sectionTitles.at(i);
				if (i == m_curSectionIndex) 
				{
					section->OnTouchDown(true);
				}
				else 
				{
					section->OnTouchDown(false);
				}
			}
			
			for (unsigned int i = 0 ; i <= m_curSectionIndex; i++)
			{
				CGRect sectionTitleRect = m_sectionTitles.at(i)->GetFrameRect();
				this->MoveSection(i, i * m_sectionTitlesHeight - sectionTitleRect.origin.y);			
			}
			
			CGRect rect = this->GetFrameRect();
			for (unsigned int i = m_dataSource->Count() -1 ; i > m_curSectionIndex; i--) 
			{			
				CGRect sectionTitleRect = m_sectionTitles.at(i)->GetFrameRect(); 
				
				this->MoveSection(i, rect.size.height - sectionTitleRect.origin.y - sectionTitleRect.size.height);
				
				rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - sectionTitleRect.size.height);			
			}
			
			//set enable draw
			for (unsigned int i = 0 ; i < m_dataSource->Count(); i++) 
			{
				NDUIRecttangle* background = m_backgrounds.at(i);
				if (i == m_curSectionIndex)
					background->EnableDraw(true);
				else 
					background->EnableDraw(false);			
				
				NDSection* section = m_dataSource->Section(i);
				for (unsigned int j = 0; j < section->Count(); j++) 
				{
					NDUINode* uiNode = section->Cell(j);
					
					if (i == m_curSectionIndex && CGRectIntersectsRect(background->GetFrameRect(), uiNode->GetFrameRect())) 
						uiNode->EnableDraw(true);
					else 
						uiNode->EnableDraw(false);
				}
			}
			
			//set focus
			this->SetFocusOnCell(m_curSection->GetFocusCellIndex());
			*/
		}		
	}
	
	void NDUIDefaultTableLayer::OnDefaultVerticalScrollBarUpClick(NDUIDefaultVerticalScrollBar* scrollBar)
	{
		if (!m_curSection) return;
		
		NDUIRecttangle* bkg = m_backgrounds.at(m_curSectionIndex);
		CGRect bkgRect = bkg->GetScreenRect();
		
		NDTouch* touch = new NDTouch();
		touch->Initialization(1, ccp(bkgRect.origin.x + 10, bkgRect.origin.y + 10 + m_curSection->GetRowHeight() + m_cellsInterval), ccp(bkgRect.origin.x + 10, bkgRect.origin.y + 10));
		this->TouchMoved(touch);
		delete touch;
	}
	
	void NDUIDefaultTableLayer::OnDefaultVerticalScrollBarDownClick(NDUIDefaultVerticalScrollBar* scrollBar)
	{
		if (!m_curSection) return;
		
		NDUIRecttangle* bkg = m_backgrounds.at(m_curSectionIndex);
		CGRect bkgRect = bkg->GetScreenRect();
		
		NDTouch* touch = new NDTouch();
		touch->Initialization(1, ccp(bkgRect.origin.x + 10, bkgRect.origin.y + 10), ccp(bkgRect.origin.x + 10, bkgRect.origin.y + 10 + m_curSection->GetRowHeight() + m_cellsInterval));
		this->TouchMoved(touch);
		delete touch;
	}
}

