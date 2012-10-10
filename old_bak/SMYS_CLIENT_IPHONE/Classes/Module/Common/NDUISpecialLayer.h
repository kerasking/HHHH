/*
 *  NDUISpecialLayer.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

// 一些特殊用处的层

#ifndef _ND_UI_SPECIAL_LAYER_H_
#define _ND_UI_SPECIAL_LAYER_H_

#include "NDUILayer.h"

using namespace NDEngine;

// 顾名思义,　NDUIChildrenLayer专门为子节点服务
// gui事件发生在子节点范围内时不往下传递事件,否则往下传递事件
class NDUIChildrenEventLayer :
public NDUILayer
{
	DECLARE_CLASS(NDUIChildrenEventLayer)
protected:
	bool TouchBegin(NDTouch* touch); override
};

//////////////////////////////////////
class NDUITopLayer : public NDUILayer
{
	DECLARE_CLASS(NDUITopLayer)
public:
	NDUITopLayer();
	~NDUITopLayer();
	
	void Initialization(); override
	bool TouchBegin(NDTouch* touch); override
};

////////////////////////////////////////////////
//该类实现:只挂接一个子节点,如果子节点不显示不处理消息,如果触点没落在显示的节点上则隐藏子节点
class NDUITopLayerEx : public NDUILayer
{
	DECLARE_CLASS(NDUITopLayerEx)
public:
	NDUITopLayerEx();
	~NDUITopLayerEx();
	
	void Initialization(); override
	bool TouchBegin(NDTouch* touch); override
};

////////////////////////////////////////////////
//蒙板层

/***
* 临时性注释 郭浩
* begin
*/
// class NDUIMaskLayer : public NDUILayer
// {
// 	DECLARE_CLASS(NDUIMaskLayer)
// 	
// public:
// 	NDUIMaskLayer();
// 	~NDUIMaskLayer();
// 
// 	void Initialization(); override
// 	
// 	DECLARE_AUTOLINK(NDUIMaskLayer)
// 	INTERFACE_AUTOLINK(NDUIMaskLayer)
// };
/***
* 临时性注释 郭浩
* end
*/


#endif // _ND_UI_SPECIAL_LAYER_H_