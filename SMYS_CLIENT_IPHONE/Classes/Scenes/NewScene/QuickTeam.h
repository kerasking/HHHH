/*
 *  QuickTeam.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _QUICK_TEAM_H_
#define _QUICK_TEAM_H_

#include "NDUIButton.h"
#include "NDUIAnimation.h"
#include "NDUISpecialLayer.h"
#include "PlayerHead.h"

class QuickTeam :
public NDUIChildrenEventLayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(QuickTeam)
	
	QuickTeam();
	
	~QuickTeam();
	
public:
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override 
	
	//bool OnButtonLongClick(NDUIButton* button); override
	
	void SetShrink(bool bShrink, bool animation=true);
	
	void Refresh(); // refresh data and ui
	
	bool IsShrink();
	
private:
	void ReverseShrink();
	
	void DealShrink(float time);
	
private:
	enum { eMaxShow = 4, };
	TeamRoleButton *m_btn[eMaxShow];
	
	NDPicture  *m_picShrink;
	NDUIButton *m_btnShrink;
	
	
	NDUIAnimation	m_curUiAnimation;
	unsigned int	m_keyAnimation;
	bool			m_stateShrink;
};

#endif // _QUICK_TEAM_H_