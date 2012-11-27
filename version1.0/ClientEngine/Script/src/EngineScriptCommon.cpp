#include "EngineScriptCommon.h"
#include "globaldef.h"

NS_NDENGINE_BGN

int PicMemoryUsingLogOut(bool bNotPrintLog)
{
	int nSize = 0;
	if (!bNotPrintLog)
	{
		NDLog("\n============NDPicturePool Memory Report==============\n");
	}
	//nSize += NDPicturePool::DefaultPool()->Statistics(bNotPrintLog);
	if (!bNotPrintLog)
	{
		NDLog("\n============CCTextureCache Memory Report==============\n");
	}
	//nSize += [[CCTextureCache sharedTextureCache] Statistics:bNotPrintLog];
	return nSize;
}

NS_NDENGINE_END