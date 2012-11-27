/*
*
*/

#ifndef NDBASEGLOBALDIALOG_H
#define NDBASEGLOBALDIALOG_H

#include "define.h"
#include "NDObject.h"

NS_NDENGINE_BGN

typedef struct _tagGlobalDialogBtnContent
{
	std::string str;
	bool bArrow;
	_tagGlobalDialogBtnContent(std::string str, bool bArrow = false)
	{
		str = str;
		bArrow = bArrow;
	}
} GlobalDialogBtnContent;

class NDBaseGlobalDialog:public NDObject
{
	DECLARE_CLASS(NDBaseGlobalDialog)

public:

	NDBaseGlobalDialog();
	virtual ~NDBaseGlobalDialog();

	virtual unsigned int GetID();
	virtual void ReturnID(unsigned int uiID);
	virtual void reset();

	virtual unsigned int Show(NDEngine::NDObject* delegate, const char* title,
		const char* text, uint timeout, const char* ortherButtons,
		.../*must NULL end*/);
	virtual unsigned int Show(NDEngine::NDObject* delegate, const char* title,
		const char* text, uint timeout,
		const std::vector<std::string>& ortherButtons);
	virtual unsigned int Show(NDEngine::NDObject* delegate, const char* title,
		const char* text, uint timeout,
		const std::vector<GlobalDialogBtnContent>& ortherButtons);

protected:
private:
};

NS_NDENGINE_END

#endif