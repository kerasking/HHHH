/*
 *  NDTip.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-13.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_TIP_H_
#define _ND_TIP_H_

#include "NDUILayer.h"
#include "NDUILabel.h"
#include "NDUIBaseGraphics.h"
#include <deque>
#include <string>

using namespace NDEngine;

typedef enum
{
	TipTriangleAlignBegin = 0,
	TipTriangleAlignLeft = TipTriangleAlignBegin,
	TipTriangleAlignCenter,
	TipTriangleAlignRight,
	TipTriangleAlignEnd,
}TipTriangleAlign;

class LayerTip : public NDUILayer
{
	DECLARE_CLASS(LayerTip)
public:
	LayerTip();
	~LayerTip();
	
	void Initialization(); override
	void draw(); override
	void SetFrameRect(CGRect rect); override
	
	void Hide();
	void Show();
	
	void SetText(std::string str);
	void SetTextFontSize(unsigned int uisize);
	void SetTextColor(ccColor4B color);
	CGSize GetTipSize();
	
	void SetWidth(int iWidth);
	
	void SetTalkStyle(bool bSet);
	
	void SetTalkDisplayPos(CGPoint pos);
	
	void SetTriangleAlign(TipTriangleAlign align);
	
private:
	void recacl();
private:
	NDUILabel *m_lbTip;
	NDUICircleRect *m_crRect;
	bool	m_bTalkStyle;
	
	int m_iWidth;
	
	NDUILine *m_line[2];
	NDUITriangle *m_triangleNode;
	CGPoint	m_posTalk;
	bool m_bNeedCacl;
	TipTriangleAlign m_alignTriangle;
};

/////////////////////////////////////////////////////
/***
* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
* begin
*/
// class TalkBox : public NDUILayer
// {
// 	DECLARE_CLASS(TalkBox)
// public:
// 	TalkBox();
// 	
// 	void addTalkMsg(std::string msg,int sec);
// 	
// 	void SetDisPlayPos(CGPoint pos);
// 	
// 	void SetFix();
// 	
// 	void Initialization(); override
// 	
// 	void draw(); override
// 	
// 	void SetTriangleAlign(TipTriangleAlign align);
// 	
// 	CGSize GetSize();
// 	
// private:
// 	void reset();
// 	
// 	LayerTip* newLayerTip();
// 	
// private:
// 	int nextShowY;
// 	bool isFirstNext;
// 	enum { spilitWidth=80 };
// 	long timeForTalkMsg;
// 	int moveSpeed;
// 	std::deque<std::string> talkMsgs;
// 	CGPoint m_pos;
// 	LayerTip *m_tip[2];
// 	bool m_bConstant;
// };
/***
* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
* end
*/

#endif // _ND_TIP_H_