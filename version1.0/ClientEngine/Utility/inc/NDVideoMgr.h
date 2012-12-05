/*
*
*/

#ifndef NDVIDEOMGR_H
#define NDVIDEOMGR_H

#include "define.h"
#include "NDObject.h"
#include "NDSharedPtr.h"
#include "NDVideoEventListener.h"

NS_NDENGINE_BGN

class NDVideoMgr:public NDObject
{
	DECLARE_CLASS(NDVideoMgr)

	typedef vector<NDSharedPtr<NDVideoEventListener> > VECVIDEOLISTENER;

public:

	virtual ~NDVideoMgr();

	static NDVideoMgr* GetVideoMgrSingleton();

	virtual bool PlayVideo(const char* pszFilename);
	
	bool RegisterVideoListener(NDVideoEventListener* pkVideoListener);

protected:

	NDVideoMgr();
	NDVideoMgr(const NDVideoMgr&);

	static NDVideoMgr* ms_pkVideoManager;

	virtual bool PlayVideoForAndroid(const char* pszFilename);
	virtual bool PlayVideoForWin32(const char* pszFilename);
	virtual bool PlayVideoForIOS(const char* pszFilename);

	VECVIDEOLISTENER m_vecVideoListener;

private:
};

#define VideoMgrPtr NDVideoMgr::GetVideoMgrSingleton()

NS_NDENGINE_END

#endif