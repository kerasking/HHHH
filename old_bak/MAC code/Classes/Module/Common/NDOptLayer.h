/*
 *  NDOptLayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __ND_OPT_LAYER_H__
#define __ND_OPT_LAYER_H__

#include "NDUILayer.h"
#include "NDUITableLayer.h"

using namespace NDEngine;

class NDOptLayer : public NDUILayer {
	DECLARE_CLASS(NDOptLayer)
public:
	NDOptLayer();
	~NDOptLayer();
	
	void Initialization(NDUITableLayer* opt);
	
	NDUITableLayer* GetOpt() const {
		return this->m_opt;
	}
	
private:
	NDUITableLayer* m_opt;
};

#endif