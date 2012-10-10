//
//  NDUIMemo.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __NDUIMemo_H
#define __NDUIMemo_H

#include "NDUINode.h"
#include <string>
#include "NDUIOptionButton.h"
#include "NDPicture.h"

#include "CCTexture2D.h"

namespace NDEngine
{
	typedef enum
	{
		MemoTextAlignmentLeft = 0,
		MemoTextAlignmentCenter,
		MemoTextAlignmentRight
	}MemoTextAlignment;
	
	class NDUIMemo : public NDUINode, public NDUIOptionButtonDelegate
	{
		DECLARE_CLASS(NDUIMemo)
		NDUIMemo();
		~NDUIMemo();
	public:
		void SetText(const char* text);
		std::string GetText();
		
		void SetFontColor(ccColor4B fontColor);
		ccColor4B GetFontColor(){ return m_fontColor; }
		
		void SetFontSize(unsigned int fontSize);
		unsigned int GetFontSize(){ return m_fontSize; }
		
		void SetBackgroundColor(ccColor4B color);
		
		void SetBackgroundPicture(NDPicture* pic, bool bClearOnFree=false);
		
		void SetFrameRect(CGRect rect); override
		
		void SetTextAlignment(MemoTextAlignment alignment){ m_textAlignment = alignment; }
		MemoTextAlignment GetTextAlignment(){ return m_textAlignment; }
		
		unsigned int GetCurrentPageNum();
		unsigned int GetLastPageNum();
		unsigned int GetTotalPageCount();
	public:	
		void draw(); override
		void Initialization(); override
		void OnOptionChange(NDUIOptionButton* option); override
		void OnFrameRectChange(CGRect srcRect, CGRect dstRect); override
		void SetVisible(bool visible); override
		void OnTextClick(CGPoint touchPos);
		
	private:
		void MakeTexture();
		void MakeCoordinates();
		void MakeVertices();
	private:
		std::string m_text;
		ccColor4B m_fontColor;
		ccColor4B m_backgroundColor;
		unsigned int m_fontSize;
		CGRect m_cutRect;
		bool m_needMakeTex, m_needMakeCoo, m_needMakeVer;
		GLbyte m_colors[16];
		GLfloat m_vertices[12];
		GLfloat m_coordinates[8];
		CCTexture2D *m_texture;
		unsigned int m_totalPage, m_currentPage, m_lastPage;
		NDUIOptionButton* m_pageArrow;
		int m_rowHeight, m_rowCount, m_pageCount;
		MemoTextAlignment m_textAlignment;
		
		NDPicture *m_picBG;
		bool m_bClearOnFree;
		
	};
}
#endif