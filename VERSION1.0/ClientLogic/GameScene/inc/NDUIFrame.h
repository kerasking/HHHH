//
//  NDUIFrame.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-4.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
//
//	介绍
//	龙御特有的控件容器

#ifndef __NDUIFrame_H
#define __NDUIFrame_H

#include "NDUILayer.h"

#include "NDTile.h"

namespace NDEngine
{
	class NDUIFrame : public NDUILayer
	{
		DECLARE_CLASS(NDUIFrame)
		NDUIFrame();
		~NDUIFrame();
	public:		
		void draw(); override 
		void OnFrameRectChange(CCRect srcRect, CCRect dstRect); override
	private: 
		NDTile* m_tileLeftTop;		
		NDTile* m_tileRightTop;
		NDTile* m_tileLeftBottom;
		NDTile* m_tileRightBottom;
		void drawBackground();
		void Make();
	};
}
#endif
