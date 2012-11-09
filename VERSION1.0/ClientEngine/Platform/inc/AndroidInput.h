/*
*
*/

#ifndef ANDROIDINPUT_H
#define ANDROIDINPUT_H

#include "define.h"
#include "CommonInput.h"

NS_NDENGINE_BGN

class NDAndroidInput:public IPlatformInput
{
	DECLARE_CLASS(NDAndroidInput)

public:
	NDAndroidInput();
	virtual ~NDAndroidInput();
protected:
private:
};

NS_NDENGINE_END

#endif