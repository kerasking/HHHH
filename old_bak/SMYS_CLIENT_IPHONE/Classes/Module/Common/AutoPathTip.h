/*
 *  AutoPathTip.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _AUTO_PATH_TIP_H_
#define _AUTO_PATH_TIP_H_

#include "Singleton.h"
#include <string>

#define AutoPathTipObj	AutoPathTip::GetSingleton()

class AutoPathTip : public TSingleton<AutoPathTip>
{
public:
	AutoPathTip();
	~AutoPathTip();
	
	void work(std::string des);
	
	bool IsWorking();
	
	void Arrive();
	
	void Stop();
	
private:
	std::string m_des;
	
	bool m_bWork;
};

#endif // _AUTO_PATH_TIP_H_
