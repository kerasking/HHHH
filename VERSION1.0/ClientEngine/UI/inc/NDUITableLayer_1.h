//
//  NDUITableLayer.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __NDUITableLayer_H
#define __NDUITableLayer_H

#include "NDUILayer.h"
#include <vector>
#include <string>
#include "..\..\Utility\inc\NDDataSource.h"
#include "NDUILabel.h"
#include "NDUIBaseGraphics.h"
#include "NDPicture.h"

namespace NDEngine
{
	class NDUISectionTitle;
	class NDUITableLayer;
	class NDUIVerticalScrollBar;
	
	//---------------------------------------------
	class NDUISectionTitleDelegate
	{
	public:
		virtual void OnSectionTitleClick(NDUISectionTitle* sectionTitle);
	};
	
	class NDUISectionTitle : public NDUINode
	{
		DECLARE_CLASS(NDUISectionTitle)
		NDUISectionTitle();
		~NDUISectionTitle();
	public:
		void SetText(const char* title);
		std::string GetText();	
		void SetTextAlignment(LabelTextAlignment align);
		void SetFontColor(cocos2d::ccColor4B fontColor);		
		cocos2d::ccColor4B GetFontColor();
		
		void SetFrameRect(CGRect rect); override
		
		void Initialization(); override
	public:
		void OnTouchDown(bool touched){ m_touched = touched; }
		void draw();override
		
	private:
		NDUILabel* m_lblText;
		bool m_touched;
		NDPicture* m_picAdd, *m_picSub;
	};	
	//---------------------------------------------
	
	//---------------------------------------------
	class NDUIVerticalScrollBarDelegate
	{
	public:
		virtual void OnVerticalScrollBarUpClick(NDUIVerticalScrollBar* scrollBar);
		virtual void OnVerticalScrollBarDownClick(NDUIVerticalScrollBar* scrollBar);
	};
	
	class NDUIVerticalScrollBar : public NDUINode
	{
		DECLARE_CLASS(NDUIVerticalScrollBar)
		NDUIVerticalScrollBar();
		~NDUIVerticalScrollBar();
	public:
		void Initialization(); override
		
		void SetCurrentContentY(float y);                                                                                      
		float GetCurrentContentY();
				
		void SetContentHeight(float h);
		float GetContentHeight(); 
	public:
		void draw(); override			
		void OnClick(CGPoint touch);
		void OnTouchDown(bool touched, CGPoint pos){ m_touched = touched; m_touchPos = pos; }
	private:
		float m_currentContentY, m_contentHeight;
		bool m_touched;
		CGPoint m_touchPos;
		NDPicture* m_picUp, *m_picDown;
		
	};
	//---------------------------------------------
	
	//---------------------------------------------
	class NDUITableLayerDelegate
	{
	public:
		/***
		* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
		* begin
		*/
		//virtual void OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
		//virtual void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
		/***
		* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
		* end
		*/
	};
	
	class NDUITableLayer: 
		public NDUILayer, 
		public NDUISectionTitleDelegate,
		public NDUIVerticalScrollBarDelegate
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
		
		void SetBackgroundColor(cocos2d::ccColor4B color); hide
		
		void ReflashData();
	public:	
		void Initialization();
		NDUISectionTitle* GetActiveSectionTitle();
		void draw();override
		void OnSectionTitleClick(NDUISectionTitle* sectionTitle); override
		void OnVerticalScrollBarUpClick(NDUIVerticalScrollBar* scrollBar);override
		void OnVerticalScrollBarDownClick(NDUIVerticalScrollBar* scrollBar);override
		bool TouchMoved(NDTouch* touch); override
		bool DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch); override			
		void UITouchEnd(NDTouch* touch); override
		void SetVisible(bool visible); override
		bool DispatchLongTouchEvent(CGPoint beginTouch, CGPoint endTouch); override
		bool DispatchLayerMoveEvent(CGPoint beginPoint, NDTouch *moveTouch); override
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
		cocos2d::ccColor4B m_bgColor;
		
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
