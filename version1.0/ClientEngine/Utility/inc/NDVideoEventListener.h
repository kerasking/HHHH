/*
*
*/

#ifndef NDVIDEOEVENTLISTENER_H
#define NDVIDEOEVENTLISTENER_H

#include "NDObject.h"
#include "define.h"

NS_NDENGINE_BGN

class NDVideoEventListener:public NDObject
{
	DECLARE_CLASS(NDVideoEventListener)

public:
	NDVideoEventListener();
	virtual ~NDVideoEventListener();
protected:
private:
};

NS_NDENGINE_END

#endif