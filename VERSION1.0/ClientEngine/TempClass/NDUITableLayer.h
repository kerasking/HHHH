//
//  NDUITableLayer.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef NDUITABLELAYER_H
#define NDUITABLELAYER_H

#include "NDUILayer.h"
#include <vector>
#include <string>
#include "NDDataSource.h"
#include "NDUILabel.h"
#include "NDUIBaseGraphics.h"
#include "NDPicture.h"

namespace NDEngine
{
	class NDUISectionTitle;
	class NDUITableLayer;
	class NDUIVerticalScrollBar;
	
	//---------------------------------------------
// 	class NDUISectionTitleDelegate
// 	{
// 	public:
// 		virtual void OnSectionTitleClick(NDUISectionTitle* sectionTitle);
// 	};
// 	
// 	class NDUISectionTitle : public NDUINode
// 	{
// 		DECLARE_CLASS(NDUISectionTitle)
// 		NDUISectionTitle();
// 		~NDUISectionTitle();
// 	public:
// 		void SetText(const char* title);
// 		std::string GetText();	
// 		void SetTextAlignment(LabelTextAlignment align);
// 		void SetFontColor(ccColor4B fontColor);		
// 		ccColor4B GetFontColor();
// 		
// 		void SetFrameRect(CGRect rect);  
// 		
// 		void Initialization();  
// 	public:
// 		void OnTouchDown(bool touched){ m_touched = touched; }
// 		void draw(); 
// 		
// 	private:
// 		NDUILabel* m_lblText;
// 		bool m_touched;
// 		NDPicture* m_picAdd, *m_picSub;
// 	};	
// 	//---------------------------------------------
// 	
// 	//---------------------------------------------
// 	class NDUIVerticalScrollBarDelegate
// 	{
// 	public:
// 		virtual void OnVerticalScrollBarUpClick(NDUIVerticalScrollBar* scrollBar);
// 		virtual void OnVerticalScrollBarDownClick(NDUIVerticalScrollBar* scrollBar);
// 	};
// 	
// 	class NDUIVerticalScrollBar : public NDUINode
// 	{
// 		DECLARE_CLASS(NDUIVerticalScrollBar)
// 		NDUIVerticalScrollBar();
// 		~NDUIVerticalScrollBar();
// 	public:
// 		void Initialization();  
// 		
// 		void SetCurrentContentY(float y);                                                                                      
// 		float GetCurrentContentY();
// 				
// 		void SetContentHeight(float h);
// 		float GetContentHeight(); 
// 	public:
// 		void draw();  			
// 		void OnClick(CGPoint touch);
// 		void OnTouchDown(bool touched, CGPoint pos){ m_touched = touched; m_touchPos = pos; }
// 	private:
// 		float m_currentContentY, m_contentHeight;
// 		bool m_touched;
// 		CGPoint m_touchPos;
// 		NDPicture* m_picUp, *m_picDown;
// 		
// 	};
	//---------------------------------------------
	
	//---------------------------------------------
// 	class NDUITableLayerDelegate
// 	{
// 	public:
// 		virtual void OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
// 		virtual void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
// 	};
	
	class NDUITableLayer :
		public NDUILayer
// 		public NDUISectionTitleDelegate,
// 		public NDUIVerticalScrollBarDelegate
	{
		DECLARE_CLASS(NDUITableLayer)
		NDUITableLayer();
		~NDUITableLayer();

	public:

		void SetDataSource(NDDataSource* dataSource);
		NDDataSource* GetDataSource(){ return m_dataSource; }
		
		void VisibleSectionTitles(bool bVisibled){ m_sectionTitleVisibled = bVisibled; }
		void SetSectionTitlesHeight(unsigned int height){ m_sectionTitlesHeight = height; }
		void SetSectionTitlesAlignment(LabelTextAlignment align){ m_sectionTitlesAlign = align; }
		
		void VisibleScrollBar(bool bVisibled){ m_scrollBarVisibled = bVisibled; }
		void SetScrollBarWidth(unsigned int width){ m_scrollBarWidth = width; }
		
		void SetCellsInterval(unsigned int interval){ m_cellsInterval = interval; }
		void SetCellsLeftDistance(unsigned int distace){ m_cellsLeftDistance = distace; }
		void SetCellsRightDistance(unsigned int distance){ m_cellsRightDistance = distance; }
		void SetSelectEvent(bool focusFirst) { m_selectEventFocustFirst = focusFirst; };
		
		void SetBackgroundColor(ccColor4B color);
		
		void ReflashData();

	public:

		void Initialization();
		NDUISectionTitle* GetActiveSectionTitle();
		void draw();
		void OnSectionTitleClick(NDUISectionTitle* sectionTitle);
		void OnVerticalScrollBarUpClick(NDUIVerticalScrollBar* scrollBar);
		void OnVerticalScrollBarDownClick(NDUIVerticalScrollBar* scrollBar);
		bool TouchMoved(NDTouch* touch);  
		bool DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch);
		void UITouchEnd(NDTouch* touch);  
		void SetVisible(bool visible);  
		bool DispatchLongTouchEvent(CGPoint beginTouch, CGPoint endTouch);
		bool DispatchLayerMoveEvent(CGPoint beginPoint, NDTouch *moveTouch);

	private:

		NDDataSource* m_dataSource;
		bool m_needReflash;
		NDSection* m_curSection;
		bool m_sectionTitleVisibled;
		bool m_scrollBarVisibled;
		bool m_selectEventFocustFirst;
		unsigned int m_curSectionIndex;
		unsigned int m_sectionTitlesHeight;
		unsigned int m_scrollBarWidth;
		std::vector<NDUISectionTitle*> m_sectionTitles;
		std::vector<NDUIRecttangle*> m_backgrounds;
		std::vector<NDUIVerticalScrollBar*> m_scrollBars;
		unsigned int m_cellsInterval, m_cellsLeftDistance, m_cellsRightDistance;
		ccColor4B m_bgColor;
		
		LabelTextAlignment m_sectionTitlesAlign;
			
		void MoveSection(unsigned int sectionIndex, int moveLen);
		void DrawBackground(unsigned int sectionIndex);
		void DrawSectionTitle(unsigned int sectionIndex);
		NDUIVerticalScrollBar* DrawScrollbar(unsigned int sectionIndex);
		void SetFocusOnCell(unsigned int cellIndex);
		
		CGRect GetCellRectWithIndex(unsigned int sectionIndex, unsigned int cellIndex);
		
	};
	//---------------------------------------------
}

#endif
