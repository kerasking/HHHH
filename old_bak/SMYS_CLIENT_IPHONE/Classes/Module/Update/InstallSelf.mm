//
//  InstallSelf.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "InstallSelf.h"

#define SELF_UPDATE_THREAD_FILE "/Applications/DragonDrive.app/updatePxl"

IMPLEMENT_CLASS(InstallSelf, NDObject)

static InstallSelf* InstallSelf_DefaultInstaller = NULL;

InstallSelf::InstallSelf()
{
	NDAsssert(InstallSelf_DefaultInstaller == NULL);
	m_inInstalling = false;
	m_cldPid = 0;
	
	m_timer = new NDTimer();
}

InstallSelf::~InstallSelf()
{
	delete m_timer;
	InstallSelf_DefaultInstaller = NULL;
}

InstallSelf* InstallSelf::DefaultInstaller()
{
	if (InstallSelf_DefaultInstaller == NULL) 
	{
		InstallSelf_DefaultInstaller = new InstallSelf();
	}
	return InstallSelf_DefaultInstaller;
}

void InstallSelf::SetPackagePath(const char* path)
{
	m_path = path;
}

void InstallSelf::Install()
{
	if (m_inInstalling) 
		return;

	m_cldPid = fork();
	if (m_cldPid == 0)
	{		
		execlp(SELF_UPDATE_THREAD_FILE, SELF_UPDATE_THREAD_FILE, m_path.c_str(), (char *)0 );
		_exit(0);
	}
	else if (m_cldPid > 0) 
	{
		m_inInstalling = true;
		m_timer->SetTimer(this, 1, 60 * 2);
	}
	else 
	{
		//fork error...
	}
}

void InstallSelf::OnTimer(OBJID tag)
{
	m_inInstalling = false;
	m_timer->KillTimer(this, 1);
}

InstallStatus InstallSelf::GetStatus()
{
	InstallStatus status;
	
	if (m_cldPid == 0) 
	{
		status = InstallStatusSuccess;
	}
	else 
	{
		int cldStatus = -1;
		waitpid(m_cldPid, &cldStatus, WNOHANG);
		if (cldStatus == 0) 
		{
			m_inInstalling = false;
			status = InstallStatusSuccess;
			m_timer->KillTimer(this, 1);
		}
		else 
		{
			if (m_inInstalling)
				status = InstallStatusInstalling;
			else 
				status = InstallStatusFailed;
		}
	}	
		
	return status;	
}


