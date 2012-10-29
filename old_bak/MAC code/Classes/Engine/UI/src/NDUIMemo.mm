//
//  NDUIMemo.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "NDUIMemo.h"
#import "ccMacros.h"
#import "NDDirector.h"
#import "NDUILayer.h"
#import "define.h"
#import "NDUtility.h"
#include "I_Analyst.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDUIMemo, NDUINode)
	

#define PAGE_ARROW_SIZE CGSizeMake(60, 15)
	
	NDUIMemo::NDUIMemo()
	{
		m_backgroundColor = ccc4(255, 255, 255, 255);
		m_fontSize = 13;
		m_needMakeTex = false;
		m_texture = NULL;
		m_totalPage = 1;
		m_currentPage = 1;
		m_lastPage = 1;
		m_pageArrow = NULL;
		m_rowCount = 0;
		m_rowHeight = 0;
		m_pageCount = 0;
		m_cutRect = CGRectZero;
		m_textAlignment = MemoTextAlignmentLeft;
		m_bClearOnFree = false;
		m_picBG = NULL;
	}
	
	NDUIMemo::~NDUIMemo()
	{
		[m_texture release];
		
		if (m_bClearOnFree) delete m_picBG;
	}
	
	void NDUIMemo::Initialization()
	{
		NDUINode::Initialization();
		
		this->SetFontColor(ccc4(24, 85, 82, 255));
		
		m_pageArrow = new NDUIOptionButton();
		m_pageArrow->Initialization();
		m_pageArrow->SetDelegate(this);
		m_pageArrow->SetFontColor(ccc4(24, 85, 82, 255));
		m_pageArrow->SetBgClr(ccc4(0, 0, 0, 0));
		m_pageArrow->ShowFrame(false);
		m_pageArrow->SetFontSize(10);
		m_pageArrow->EnableDraw(false);
		this->AddChild(m_pageArrow);
	}
	
	void NDUIMemo::SetText(const char* text)
	{
		//if (0 == strncmp(text, m_text.c_str(), strlen(text))) 
//			return;
		
		if (!text || m_text == std::string(text)) 
		{
			return;
		}
		
		m_needMakeTex = true;
		m_needMakeCoo = true;
		m_needMakeVer = true;
		
		m_text = text;
	}
	
	std::string NDUIMemo::GetText()
	{
		return m_text;
	}
	
	void NDUIMemo::SetFontColor(ccColor4B fontColor)
	{
		m_fontColor = fontColor;
		
		m_colors[0] = fontColor.r; 
		m_colors[1] = fontColor.g;
		m_colors[2] = fontColor.b;
		m_colors[3] = fontColor.a;
		
		m_colors[4] = fontColor.r; 
		m_colors[5] = fontColor.g;
		m_colors[6] = fontColor.b;
		m_colors[7] = fontColor.a;
		
		m_colors[8] = fontColor.r; 
		m_colors[9] = fontColor.g;
		m_colors[10] = fontColor.b;
		m_colors[11] = fontColor.a;
		
		m_colors[12] = fontColor.r; 
		m_colors[13] = fontColor.g;
		m_colors[14] = fontColor.b;
		m_colors[15] = fontColor.a;
	}
	
	void NDUIMemo::SetFontSize(unsigned int fontSize)
	{
		if (m_fontSize != fontSize)
		{
			m_needMakeTex = true;
			m_needMakeCoo = true;
			m_needMakeVer = true;
		}
		
		m_fontSize = fontSize;
	}
	
	void NDUIMemo::SetBackgroundColor(ccColor4B color)
	{
		m_backgroundColor = color;
	}
	
	void NDUIMemo::SetBackgroundPicture(NDPicture* pic, bool bClearOnFree/*=false*/)
	{
		if (m_bClearOnFree) 
		{
			delete m_picBG;
		}
		
		m_picBG = pic;
		
		m_bClearOnFree = bClearOnFree;
	}
	
	unsigned int NDUIMemo::GetCurrentPageNum()
	{
		return m_currentPage;
	}
	
	unsigned int NDUIMemo::GetLastPageNum()
	{
		return m_lastPage;
	}
	
	unsigned int  NDUIMemo::GetTotalPageCount()
	{
		return m_totalPage;
	}
	
	void NDUIMemo::SetFrameRect(CGRect rect)
	{		
		NDUINode::SetFrameRect(rect);
		m_pageArrow->SetFrameRect(CGRectMake((rect.size.width - PAGE_ARROW_SIZE.width) / 2, 
						     rect.size.height - PAGE_ARROW_SIZE.height, 
						     PAGE_ARROW_SIZE.width, 
						     PAGE_ARROW_SIZE.height));
	}
	
	void NDUIMemo::SetVisible(bool visible)
	{
		NDUINode::SetVisible(visible);
		m_pageArrow->SetVisible(visible);
	}
	
	void NDUIMemo::OnFrameRectChange(CGRect srcRect, CGRect dstRect)
	{
		if (srcRect.size.width != dstRect.size.height || srcRect.size.height != dstRect.size.height)
		{
			m_needMakeTex = true;
			m_needMakeCoo = true;
			m_needMakeVer = true;
		}
		else if (srcRect.origin.x != dstRect.origin.x || srcRect.origin.y != dstRect.origin.y)
		{
			m_needMakeVer = true;
		}
	}
	
	void NDUIMemo::MakeTexture()
	{
		NSString *text = [NSString stringWithUTF8String:m_text.c_str()];
		
		CGRect thisRect = this->GetFrameRect();
		
		if (m_picBG) 
		{
			thisRect.size.width -= 16;
			thisRect.size.height -= 16;
		}
		
		CGSize dim = [text sizeWithFont:[UIFont fontWithName:FONT_NAME size:m_fontSize] 
					  constrainedToSize:CGSizeMake(thisRect.size.width , thisRect.size.height * 100)];		
		
		[m_texture release];
		m_texture = [[CCTexture2D alloc] initWithString:text 
											 dimensions:dim 
											  alignment:UITextAlignmentLeft
											   fontName:FONT_NAME 
											   fontSize:m_fontSize];		
		
		m_rowHeight = [@"a" sizeWithFont:[UIFont fontWithName:FONT_NAME size:m_fontSize]].height;
		m_rowCount  = m_texture.contentSize.height / m_rowHeight;
		
		if (thisRect.size.height / (m_rowHeight * m_rowCount) >= 1) 
		{
			m_pageCount = thisRect.size.height / m_rowHeight;
		}
		else 
		{
			m_pageCount = (thisRect.size.height - PAGE_ARROW_SIZE.height) / m_rowHeight;
		}
		
		if (m_pageCount > 0) 
		{
			if (m_rowCount % m_pageCount == 0) 
				m_totalPage = m_rowCount / m_pageCount;
			else 
				m_totalPage = m_rowCount / m_pageCount + 1;
			
			if (m_totalPage > 1) 
			{
				m_pageArrow->EnableDraw(true);
				
				VEC_OPTIONS options;
				for (unsigned int i = 1; i <= m_totalPage; i++) 
				{
					NSString *str = [NSString stringWithFormat:@"%d / %d", i, m_totalPage];
					options.push_back(std::string([str UTF8String]));
				}
				
				m_pageArrow->SetOptions(options);
			}
			else 
				m_pageArrow->EnableDraw(false);
		}
		else 
			m_pageArrow->EnableDraw(false);
		m_currentPage = 1;
	}
	
	void NDUIMemo::MakeCoordinates()
	{
		if (m_texture) 
		{
			CGRect thisRect = this->GetFrameRect();	
			
			if (m_picBG) 
			{
				thisRect.size.width -= 16;
				thisRect.size.height -= 16;
			}	
			
			int pageHeight = m_pageCount * m_rowHeight;
					
			m_cutRect.size.width = m_texture.contentSize.width;
			m_cutRect.origin.y = (m_currentPage - 1) * pageHeight;			
			if (m_texture.contentSize.height - m_cutRect.origin.y > pageHeight) 
				m_cutRect.size.height = pageHeight;
			else 
				m_cutRect.size.height = m_texture.contentSize.height - m_cutRect.origin.y;			
			
			m_coordinates[0] = m_cutRect.origin.x / m_texture.pixelsWide;
			m_coordinates[1] = (m_cutRect.origin.y + m_cutRect.size.height) / m_texture.pixelsHigh;
			m_coordinates[2] = (m_cutRect.origin.x + m_cutRect.size.width) / m_texture.pixelsWide;
			m_coordinates[3] = m_coordinates[1];
			m_coordinates[4] = m_coordinates[0];
			m_coordinates[5] = m_cutRect.origin.y / m_texture.pixelsHigh;
			m_coordinates[6] = m_coordinates[2];
			m_coordinates[7] = m_coordinates[5];	
			
		}	
	}
	
	void NDUIMemo::MakeVertices()
	{
		if (m_texture) 
		{
			CGRect scrRect = this->GetScreenRect();	
			CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
			
			if (m_picBG) 
			{
				scrRect.origin.x += 8;
				scrRect.origin.y += 8;
				scrRect.size.width -= 16;
				scrRect.size.height -= 16;
			}
			
			CGRect drawRect;			
			if (m_textAlignment == MemoTextAlignmentLeft) 
			{
				drawRect = CGRectMake(scrRect.origin.x, scrRect.origin.y, m_cutRect.size.width, m_cutRect.size.height); 
			}
			else if (m_textAlignment == MemoTextAlignmentCenter)
			{
				drawRect = CGRectMake(scrRect.origin.x + (scrRect.size.width - m_cutRect.size.width) / 2, 
									  scrRect.origin.y + (scrRect.size.height - m_cutRect.size.height) / 2, 
									  m_cutRect.size.width, m_cutRect.size.height); 
			}
			else 
			{
				drawRect = CGRectMake(scrRect.origin.x + scrRect.size.width - m_cutRect.size.width, 
									  scrRect.origin.y, 
									  m_cutRect.size.width, m_cutRect.size.height); 
			}
			
			
			
			m_vertices[0] = drawRect.origin.x;
			m_vertices[1] = winSize.height - drawRect.origin.y - drawRect.size.height;
			m_vertices[2] = 0;
			m_vertices[3] = drawRect.origin.x + drawRect.size.width;
			m_vertices[4] = m_vertices[1];
			m_vertices[5] = 0;
			m_vertices[6] = m_vertices[0];
			m_vertices[7] = winSize.height - drawRect.origin.y;
			m_vertices[8] = 0;
			m_vertices[9] = m_vertices[3];
			m_vertices[10] = m_vertices[7];
			m_vertices[11] = 0;
		}
	}
	
	void NDUIMemo::OnOptionChange(NDUIOptionButton* option)
	{
		m_lastPage = m_currentPage;
		m_currentPage = option->GetOptionIndex() + 1;
		this->MakeCoordinates();
		this->MakeVertices();
	}
	
	void NDUIMemo::OnTextClick(CGPoint touchPos)
	{
		if (m_totalPage > 1) 
		{
			CGRect scrRect = this->GetScreenRect();
			if (touchPos.x < scrRect.origin.x + scrRect.size.width / 2) 
			{
				m_pageArrow->PreOpt();				
			}
			else 
			{
				m_pageArrow->NextOpt();
			}
			
			this->OnOptionChange(m_pageArrow);
		}		
	}	
	
	void NDUIMemo::draw()
	{
        TICK_ANALYST(ANALYST_NDUIMemo);	
		NDUINode::draw();
		
		if (this->IsVisibled()) 
		{
			NDNode* pNode = this->GetParent();
			if (pNode && pNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
			{
				NDUILayer* uiLayer = (NDUILayer*)pNode;
				if (!m_pageArrow->GetParent()) 
				{
					uiLayer->AddChild(m_pageArrow);
				}
			}
			
			if (m_picBG) 
				m_picBG->DrawInRect(this->GetScreenRect());
			else
				DrawRecttangle(this->GetScreenRect(), m_backgroundColor);	
			
			if (m_needMakeTex) 
			{
				this->MakeTexture();
				m_needMakeTex = false;
			}
			
			if (m_needMakeCoo) 
			{
				this->MakeCoordinates();
				m_needMakeCoo = false;
			}
			
			if (m_needMakeVer) 
			{
				this->MakeVertices();
				m_needMakeVer = false;
			}			
			
			if (m_texture) 
			{
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				
				glBindTexture(GL_TEXTURE_2D, m_texture.name);
				
				glVertexPointer(3, GL_FLOAT, 0, m_vertices);
				glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_colors);
				glTexCoordPointer(2, GL_FLOAT, 0, m_coordinates);
				
				glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
				
				glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST);
			}
		}
	}
}
