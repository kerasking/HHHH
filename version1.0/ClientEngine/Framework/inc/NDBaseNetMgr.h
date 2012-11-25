/*
*
*/

#ifndef NDBASENETMGR_H
#define NDBASENETMGR_H

#include "define.h"
#include "NDObject.h"
#include "Singleton.h"
#include "NDTransData.h"

NS_NDENGINE_BGN

class NDMsgObject
{
public:
	NDMsgObject()
	{
	}
	virtual ~NDMsgObject()
	{
	}
	virtual bool process(unsigned short msgID, NDEngine::NDTransData*, int len) = 0;
};

class NDBaseNetMgr:
	public NDObject,
	public TSingleton<NDBaseNetMgr>
{
	DECLARE_CLASS(NDBaseNetMgr)

public:

	NDBaseNetMgr();
	virtual ~NDBaseNetMgr();

	virtual bool Process(NDEngine::NDTransData* data);
	virtual bool Process(unsigned short msgID, NDEngine::NDTransData* data, int len);
	virtual bool RegMsg(unsigned short msgID, NDMsgObject* msgObj);
	virtual void UnRegMsg(unsigned short msgID);
	virtual bool GetServerMsgPacket(NDTransData& data);

protected:
private:
};

#define NDBaseNetMsgPoolObj NDBaseNetMgr::GetBackSingleton("NDNetMsgPool")

NS_NDENGINE_END

#endif