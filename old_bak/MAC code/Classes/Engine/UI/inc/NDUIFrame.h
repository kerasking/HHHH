//
//  NDUIFrame.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-4.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//	介绍
//	龙御特有的控件容器

#ifndef __NDUIFrame_H
#define __NDUIFrame_H

#include "NDUILayer.h"

#import "NDTile.h"

namespace NDEngine
{
	class NDUIFrame : public NDUILayer
	{
		DECLARE_CLASS(NDUIFrame)
		NDUIFrame();
		~NDUIFrame();
	public:		
		void draw(); override 
		void OnFrameRectChange(CGRect srcRect, CGRect dstRect); override
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
