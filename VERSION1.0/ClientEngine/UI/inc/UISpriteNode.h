/*
 *  UISpriteNode.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-22.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _UI_SPRITE_NODE_H_ZJH_
#define _UI_SPRITE_NODE_H_ZJH_

#include "NDUINode.h"
#include "NDSprite.h"
#include "NDObject.h"

class NDEngine::NDSprite;
using namespace NDEngine;


class CUISpriteNode : public NDEngine::NDUINode
{
	DECLARE_CLASS(CUISpriteNode)
	
	CUISpriteNode();
	~CUISpriteNode();
	
public:
	void Initialization();
	void ChangeSprite(const char* sprfile);
	bool isAnimationComplete();
	void SetAnimation(int nIndex, bool bFaceRight);
	void SetPlayFrameRange(int nStartFrame, int nEndFrame);
	void SetPosition(int nPosX, int nPosY);
private:
	NDEngine::NDUINode*				m_pkSpriteParentNode;
	NDEngine::NDSprite*				m_pkSprite;
	
protected:
	void draw(); override
};

#endif // _UI_SPRITE_NODE_H_ZJH_