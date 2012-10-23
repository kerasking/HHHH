/*
 *  NDOptLayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDOptLayer.h"

IMPLEMENT_CLASS(NDOptLayer, NDUILayer)

NDOptLayer::NDOptLayer()
{
	
}

NDOptLayer::~NDOptLayer()
{
	
}

void NDOptLayer::Initialization(NDUITableLayer* opt)
{
	NDUILayer::Initialization();
	this->SetFrameRect(CGRectMake(0.0f, 0.0f, 480.0f, 280.0f));
	this->m_opt = opt;
	this->AddChild(this->m_opt);
}