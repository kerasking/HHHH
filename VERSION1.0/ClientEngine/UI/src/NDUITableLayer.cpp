//
//  NDUITableLayer.m
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NDUITableLayer.h"
#import "NDDirector.h"
#import "CGPointExtension.h"
#import "NDUIBaseGraphics.h"
#import "NDUtility.h"
#import "ccMacros.h"

namespace NDEngine
{
	#define FONT_SIZE 15
	#define TITLE_PICTURE [NSString stringWithFormat:@"%s", GetImgPath("plusMinus.png")] 
	
	void NDUISectionTitleDelegate::OnSectionTitleClick(NDUISectionTitle* sectionTitle)
	{
	}

/***
* 临时性注释 郭浩
* begin
*/
// 	void NDUITableLayerDelegate::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
// 	{
// 	}
// 	
// 	void NDUITableLayerDelegate::OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
// 	{
// 	}
// 
/***
* 临时性注释 郭浩
* end
*/
	void NDUIVerticalScrollBarDelegate::OnVerticalScrollBarUpClick(NDUIVerticalScrollBar* scrollBar)
	{
	}
	
	void NDUIVerticalScrollBarDelegate::OnVerticalScrollBarDownClick(NDUIVerticalScrollBar* scrollBar)
	{
	}
	
	///////////////////////////////////
	IMPLEMENT_CLASS(NDUISectionTitle, NDUINode)
	NDUISectionTitle::NDUISectionTitle()
	{
		m_lblText = NULL;
		m_touched = false;
		m_picAdd = NULL;
		m_picSub = NULL;	
	}
	
	NDUISectionTitle::~NDUISectionTitle()
	{
		delete m_picAdd; 
		delete m_picSub;
	}
	
	void NDUISectionTitle::Initialization()
	{
		NDUINode::Initialization();
		
		m_lblText = new NDUILabel();
		m_lblText->Initialization();
		m_lblText->SetFontSize(FONT_SIZE);
		m_lblText->SetTextAlignment(LabelTextAlignmentCenter);
		this->AddChild(m_lblText);
		
		m_picAdd = NDPicturePool::DefaultPool()->AddPicture([TITLE_PICTURE UTF8String]);
		m_picAdd->Cut(CGRectMake(0, 0, 9, 9));
		m_picSub = NDPicturePool::DefaultPool()->AddPicture([TITLE_PICTURE UTF8String]);
		m_picSub->Cut(CGRectMake(9, 0, 9, 9));
	}
	
	void NDUISectionTitle::SetText(const char* title)
	{
		m_lblText->SetText(title);
	}
	
	std::string NDUISectionTitle::GetText()
	{
		return m_lblText->GetText();
	}
	
	void NDUISectionTitle::SetTextAlignment(LabelTextAlignment align)
	{
		m_lblText->SetTextAlignment(align);
	}
	
	void NDUISectionTitle::SetFontColor(cocos2d::ccColor4B fontColor)
	{
		m_lblText->SetFontColor(fontColor);
	}
	
	cocos2d::ccColor4B NDUISectionTitle::GetFontColor()
	{
		return m_lblText->GetFontColor();
	}
	
	void NDUISectionTitle::SetFrameRect(CGRect rect)
	{
		NDUINode::SetFrameRect(rect);
		m_lblText->SetFrameRect(CGRectMake(30, 0, rect.size.width - 60, rect.size.height));
	}
	
	void NDUISectionTitle::draw()
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
					
					cocos2d::ccColor4B color;
					if (m_touched) 
						color = ccc4(247, 223, 156, 255);
					else 
						color = ccc4(198, 211, 214, 255);
					
					//draw back ground image
					DrawRecttangle(CGRectMake(scrRect.origin.x + 10, scrRect.origin.y, scrRect.size.width - 20, scrRect.size.height), color);						
					DrawCircle(ccp(scrRect.origin.x + 10, scrRect.origin.y + 12), 13, 0, 10, color);
					DrawCircle(ccp(scrRect.origin.x + scrRect.size.width - 10, scrRect.origin.y + 12), 13, 0, 10, color);					
					
					DrawPolygon(scrRect, ccc4(125, 125, 125, 255), 1);
					
					if (parentNode->IsKindOfClass(RUNTIME_CLASS(NDUITableLayer))) 
					{
						NDUITableLayer* table = (NDUITableLayer*)uiLayer;
						if (table->GetActiveSectionTitle() == this) 
						{
							m_picSub->DrawInRect(CGRectMake(scrRect.origin.x + 20, scrRect.origin.y + 6, 10, 10));
						}
						else 
						{
							m_picAdd->DrawInRect(CGRectMake(scrRect.origin.x + 20, scrRect.origin.y + 6, 10, 10));
						}
					}
				}			
			}
			
		}
	}
	
	///////////////////////////////////////
	IMPLEMENT_CLASS(NDUIVerticalScrollBar, NDUINode)
	NDUIVerticalScrollBar::NDUIVerticalScrollBar()
	{
		m_currentContentY = 0;
		m_contentHeight = 0;
		m_picUp = NULL;
		m_picDown = NULL;
		m_touched = false;
		m_touchPos = CGPointZero;
	}
	
	NDUIVerticalScrollBar::~NDUIVerticalScrollBar()
	{
		delete m_picUp;
		delete m_picDown;
	}
	
	void NDUIVerticalScrollBar::Initialization()
	{
		NDUINode::Initialization();
		
		m_picUp = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("scroll_arrow.png"));
		m_picDown = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("scroll_arrow.png"));
		m_picDown->Rotation(PictureRotation180);		
	}
	
	void NDUIVerticalScrollBar::SetCurrentContentY(float y)
	{
		m_currentContentY = y;
	}
	
	float NDUIVerticalScrollBar::GetCurrentContentY()
	{
		return m_currentContentY;
	}
	
	void NDUIVerticalScrollBar::SetContentHeight(float h)
	{
		m_contentHeight = h;
	}
	
	float NDUIVerticalScrollBar::GetContentHeight()
	{
		return m_contentHeight;
	}
	
	void NDUIVerticalScrollBar::OnClick(CGPoint touch)
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
			NDUIVerticalScrollBarDelegate* delegate = dynamic_cast<NDUIVerticalScrollBarDelegate*> (this->GetDelegate());
			if (delegate) 
			{						
				delegate->OnVerticalScrollBarUpClick(this);
			}
		}
		else if (CGRectContainsPoint(picDownRect, touch)) 
		{
			NDUIVerticalScrollBarDelegate* delegate = dynamic_cast<NDUIVerticalScrollBarDelegate*> (this->GetDelegate());
			if (delegate) 
			{						
				delegate->OnVerticalScrollBarDownClick(this);
			}
		}
	}
	
	void NDUIVerticalScrollBar::draw()
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
	IMPLEMENT_CLASS(NDUITableLayer, NDUILayer)
	
	NDUITableLayer::NDUITableLayer()
	{
		m_dataSource = NULL;	
		m_needReflash = true;
		m_curSection = NULL;
		m_curSectionIndex = 0;
		m_sectionTitleVisibled = true;
		m_sectionTitlesHeight = 25;
		m_scrollBarVisibled = false;
		m_scrollBarWidth = 28;
		
		m_cellsInterval = 1;
		m_cellsLeftDistance = 2;
		m_cellsRightDistance = 2;
		
		m_bgColor = ccc4(132, 138, 115, 255);
		
		m_sectionTitlesAlign = LabelTextAlignmentCenter;
		
		m_selectEventFocustFirst = true;
	}
	
	NDUITableLayer::~NDUITableLayer()
	{
		delete m_dataSource;
	}
	
	void NDUITableLayer::Initialization()
	{
		NDUILayer::Initialization();
		
		//this->SetBackgroundColor(ccc4(132, 138, 115, 255));
		this->SetBackgroundColor(ccc4(108, 158, 155, 255));
	}
	
	void NDUITableLayer::SetFocusOnCell(unsigned int cellIndex)
	{
		m_curSection->SetFocusOnCell(cellIndex);
		if (m_curSection && m_curSection->Count() > cellIndex) 
		{
			NDUINode* cell = m_curSection->Cell(cellIndex);
			this->SetFocus(cell);
			NDUITableLayerDelegate* delegate = dynamic_cast<NDUITableLayerDelegate*> (this->GetDelegate());
			if (delegate) 
			{
				delegate->OnTableLayerCellFocused(this, cell, cellIndex, m_curSection);
			}
			else
			{
				NDUITargetDelegate* targetDelegate = this->GetTargetDelegate();
				if (targetDelegate)
				{
					targetDelegate->OnTargetTableEvent(this, cell, cellIndex, m_curSection);								
				}
			}
		}
	}
	
	void NDUITableLayer::SetDataSource(NDDataSource* dataSource)
	{
		if (m_dataSource != dataSource) 
		{
			delete m_dataSource;
		}
		m_dataSource = dataSource;
	}
	
	void NDUITableLayer::SetBackgroundColor(cocos2d::ccColor4B color)
	{
		NDUILayer::SetBackgroundColor(color);
		m_bgColor = color;
	}
	
	void NDUITableLayer::ReflashData()
	{
		if (!m_dataSource) 
			return;
		
		m_sectionTitles.clear();
		m_backgrounds.clear();
		m_scrollBars.clear();
		
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
					NDUIVerticalScrollBar* scrollBar = this->DrawScrollbar(i);
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
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)) && !uiNode->IsKindOfClass(RUNTIME_CLASS(NDUITableLayer))) 
				{
					NDUILayer* uiLayer = (NDUILayer*)uiNode;
					uiLayer->SetTouchEnabled(false);
				}
				
				CGRect cellRect = this->GetCellRectWithIndex(i, j);
				bool bDraw = CGRectIntersectsRect(m_backgrounds.at(i)->GetFrameRect(), cellRect) && (i == m_dataSource->Count() - 1);
									
				//draw cell					
				uiNode->SetFrameRect(cellRect);
				uiNode->EnableDraw(bDraw);
				this->AddChild(uiNode);			
			}
		}
		
		if (m_dataSource->Count() > 0) 
		{			
			m_curSectionIndex = m_dataSource->Count()-1;
			m_curSection = m_dataSource->Section(m_curSectionIndex);
			
			//draw section titles		
			for (unsigned int i = 0; i < m_dataSource->Count(); i++) 
			{
				this->DrawSectionTitle(i);
			}
			if (m_dataSource->Count() > 0) 
			{
				NDUISectionTitle* sectionTitle = m_sectionTitles.at(m_curSectionIndex);
				sectionTitle->OnTouchDown(true);
			}	
			this->SetFocusOnCell(m_curSection->GetFocusCellIndex());
		}
		else 
		{
			m_curSection = NULL;
		}
		
	}
	
	bool NDUITableLayer::TouchMoved(NDTouch* touch)
	{	
		NDUILayer::TouchMoved(touch);
		
		if (m_sectionTitleVisibled) 
		{
			for (unsigned int i = 0; i < m_sectionTitles.size(); i++) 
			{
				NDUISectionTitle* sectionTitle = m_sectionTitles.at(i);
				CGRect rect = sectionTitle->GetScreenRect();
				if (CGRectContainsPoint(rect, m_beginTouch)) 
					return false;
			}
		}			
		
		//this->SetFocusOnCell(m_curSection->GetFocusCellIndex());
		
		if (m_curSection) 
		{
			CGPoint prePos = touch->GetPreviousLocation();
			CGPoint curPos = touch->GetLocation();
			CGFloat subValue = curPos.y - prePos.y;
			
			if (m_sectionTitles.size() > m_curSectionIndex) 
			{
				NDUISectionTitle* sectionTitle = m_sectionTitles.at(m_curSectionIndex);
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
							NDUISectionTitle* nextSectionTitle = m_sectionTitles.at(m_curSectionIndex + 1);
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
					NDUIVerticalScrollBar* scrollBar = m_scrollBars.at(m_curSectionIndex);
					scrollBar->SetCurrentContentY(scrollBar->GetCurrentContentY() - subValue);
				}
			}
							
		}
		
		return true;
	}
	
	bool NDUITableLayer::DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch)
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
						
						if (!m_selectEventFocustFirst || m_curSection->GetFocusCellIndex() == i)
						{
							NDUITableLayerDelegate* delegate = dynamic_cast<NDUITableLayerDelegate*> (this->GetDelegate());
							if (delegate) 
							{
								delegate->OnTableLayerCellSelected(this, cell, i, m_curSection);								
							}
							else
							{
								NDUITargetDelegate* targetDelegate = this->GetTargetDelegate();
								if (targetDelegate)
								{
									targetDelegate->OnTargetTableEvent(this, cell, i, m_curSection);								
								}
							}
						}				
						
						return true;
					}					
				}
			}					
		}
		
		return false;
	}
	
	void NDUITableLayer::UITouchEnd(NDTouch* touch)
	{
		NDUILayer::UITouchEnd(touch);
		
		if (m_touchMoved && m_curSection && m_curSection->GetFocusCellIndex() < m_curSection->Count()) 
			this->SetFocus(m_curSection->Cell(m_curSection->GetFocusCellIndex()));
	}
	
	void NDUITableLayer::SetVisible(bool visible)
	{
		NDUILayer::SetVisible(visible);
		/*if (visible && m_curSection) {
			this->SetFocusOnCell(m_curSection->GetFocusCellIndex());
		}*/
	}
	
	CGRect NDUITableLayer::GetCellRectWithIndex(unsigned int sectionIndex, unsigned int cellIndex)
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
	
	NDUISectionTitle* NDUITableLayer::GetActiveSectionTitle()
	{
		if (!m_sectionTitles.empty()) 
		{
			return m_sectionTitles.at(m_curSectionIndex);
		}
		return NULL;
	}
	
	void NDUITableLayer::draw()
	{	
		NDDirector::DefaultDirector()->SetViewRect(this->GetScreenRect(), this);
		
		NDUILayer::draw();
		
		if (this->IsVisibled()) 
		{			
			if (m_needReflash) 
			{
				this->ReflashData();
				m_needReflash = false;
			}	
			
		}		
	}
	
	void NDUITableLayer::MoveSection(unsigned int sectionIndex, int moveLen)
	{
		if (moveLen == 0) 
			return;
		
		NDUISectionTitle* sectionTitle = m_sectionTitles.at(sectionIndex);
		CGRect sectionRect = sectionTitle->GetFrameRect();
		sectionTitle->SetFrameRect(CGRectMake(sectionRect.origin.x, sectionRect.origin.y + moveLen, sectionRect.size.width, sectionRect.size.height));		
		
		NDUIRecttangle* background = m_backgrounds.at(sectionIndex);
		CGRect bkgRect = background->GetFrameRect();
		background->SetFrameRect(CGRectMake(bkgRect.origin.x, bkgRect.origin.y + moveLen, bkgRect.size.width, bkgRect.size.height));
		
		if (m_scrollBarVisibled) 
		{
			NDUIVerticalScrollBar* scrollBar = m_scrollBars.at(sectionIndex);
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
	
	void NDUITableLayer::DrawBackground(unsigned int sectionIndex)
	{
		CGRect thisRect = this->GetFrameRect();
		
		NDUIRecttangle* cellBackground = new NDUIRecttangle();
		cellBackground->Initialization();
		cellBackground->EnableEvent(false);
		if (m_sectionTitleVisibled) 
		{
			cellBackground->SetFrameRect(CGRectMake(0, m_sectionTitlesHeight * (sectionIndex + 1), 
													thisRect.size.width, thisRect.size.height - m_sectionTitlesHeight * m_dataSource->Count()));
		}
		else 
		{
			cellBackground->SetFrameRect(CGRectMake(0, 0, thisRect.size.width, thisRect.size.height));
		}
		
		cellBackground->SetColor(m_bgColor);
		this->AddChild(cellBackground);
		m_backgrounds.push_back(cellBackground);
	}
	
	NDUIVerticalScrollBar* NDUITableLayer::DrawScrollbar(unsigned int sectionIndex)
	{
		CGRect thisRect = this->GetFrameRect();
		
		NDUIVerticalScrollBar* scrollBar = new NDUIVerticalScrollBar();
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
	
	void NDUITableLayer::DrawSectionTitle(unsigned int sectionIndex)
	{
		CGRect thisRect = this->GetFrameRect();
		
		NDSection* section = m_dataSource->Section(sectionIndex);
		
		NDUISectionTitle* uiSectionTitle = new NDUISectionTitle();
		uiSectionTitle->Initialization();
		uiSectionTitle->SetText(section->GetTitle().c_str());
		uiSectionTitle->SetFrameRect(CGRectMake(0, m_sectionTitlesHeight * sectionIndex, thisRect.size.width, m_sectionTitlesHeight));
		uiSectionTitle->SetTextAlignment(m_sectionTitlesAlign);
		uiSectionTitle->SetDelegate(this);
		uiSectionTitle->EnableDraw(m_sectionTitleVisibled);
		this->AddChild(uiSectionTitle, 1);
		m_sectionTitles.push_back(uiSectionTitle);
	}
	
	void NDUITableLayer::OnSectionTitleClick(NDUISectionTitle* sectionTitle)
	{	
		if (m_dataSource) 
		{
			for (unsigned int i = 0; i < m_sectionTitles.size(); i++) 
			{
				NDUISectionTitle* section = m_sectionTitles.at(i);
				if (sectionTitle == section) 
				{
					if (i == m_curSectionIndex && i+1 < m_sectionTitles.size()) 
						m_curSectionIndex = i+1;
					else 
						m_curSectionIndex = i;					
					m_curSection = m_dataSource->Section(m_curSectionIndex);
				}				
			}
			
			for (unsigned int i = 0; i < m_sectionTitles.size(); i++) 
			{
				NDUISectionTitle* section = m_sectionTitles.at(i);
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
						
		}		
	}
	
	void NDUITableLayer::OnVerticalScrollBarUpClick(NDUIVerticalScrollBar* scrollBar)
	{
		NDUIRecttangle* bkg = m_backgrounds.at(m_curSectionIndex);
		CGRect bkgRect = bkg->GetScreenRect();
		
		NDTouch* touch = new NDTouch();
		touch->Initialization(1, ccp(bkgRect.origin.x + 10, bkgRect.origin.y + 10 + m_curSection->GetRowHeight() + m_cellsInterval), ccp(bkgRect.origin.x + 10, bkgRect.origin.y + 10));
		this->TouchMoved(touch);
		delete touch;
	}
	
	void NDUITableLayer::OnVerticalScrollBarDownClick(NDUIVerticalScrollBar* scrollBar)
	{
		NDUIRecttangle* bkg = m_backgrounds.at(m_curSectionIndex);
		CGRect bkgRect = bkg->GetScreenRect();
		
		NDTouch* touch = new NDTouch();
		touch->Initialization(1, ccp(bkgRect.origin.x + 10, bkgRect.origin.y + 10), ccp(bkgRect.origin.x + 10, bkgRect.origin.y + 10 + m_curSection->GetRowHeight() + m_cellsInterval));
		this->TouchMoved(touch);
		delete touch;
	}
	
	bool NDUITableLayer::DispatchLongTouchEvent(CGPoint beginTouch, CGPoint endTouch)
	{
		return true;
	}
	
	bool NDUITableLayer::DispatchLayerMoveEvent(CGPoint beginPoint, NDTouch *moveTouch)
	{
		return true;
	}
}
