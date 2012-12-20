#include "NDVideoEventListener.h"
#include "ObjectTracker.h"

NS_NDENGINE_BGN
IMPLEMENT_CLASS(NDVideoEventListener,NDObject)

NDVideoEventListener::NDVideoEventListener()
{
	INC_NDOBJ_RTCLS
}

NDVideoEventListener::~NDVideoEventListener()
{
	DEC_NDOBJ_RTCLS
}

NS_NDENGINE_END