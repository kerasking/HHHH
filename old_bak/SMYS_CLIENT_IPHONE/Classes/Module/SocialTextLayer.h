/*
 *  SocialTextLayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SOCIAL_TEXT_LAYER_H__
#define __SOCIAL_TEXT_LAYER_H__

#include "NDUINode.h"
#include "SocialElement.h"
#include "NDUIBaseGraphics.h"

using namespace NDEngine;

// 需要支持的功能
// 1. 可以设置焦点色
// 2. 可以设置背景色
// 3. 可以设置文本颜色

class SocialTextLayer : public NDUINode
{
	DECLARE_CLASS(SocialTextLayer)
public:
	SocialTextLayer();
	~SocialTextLayer();
	
	// 根据元素在线标志设置文本颜色
	void Initialization(CGRect rectRoundRect, CGRect rectCol, SocialElement* socialEle);
	
	void draw();
	
	void SetBackgroundColor(ccColor4B clrBg) {
		this->m_clrBackground = clrBg;
	}
	
	void SetFocusColor(ccColor4B clrFocus) {
		this->m_clrFocus = clrFocus;
	}
	
	SocialElement* GetSocialElement() const {
		return this->m_socialElement;
	}
	
	void SetFrameRect(CGRect rect); override
	
private:
	SocialElement* m_socialElement;
	ccColor4B m_clrBackground;		// 背景颜色
	ccColor4B m_clrFocus;			// 焦点色
	
	NDUICircleRect* m_roundRectFrame;	// 圆角矩形背景
};

#endif