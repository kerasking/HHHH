/*
*
*/

#ifndef NDUIBASEITEMBUTTON_H
#define NDUIBASEITEMBUTTON_H

#include "define.h"
#include "NDObject.h"
#include "NDPicture.h"
#include "NDUINode.h"

NS_NDENGINE_BGN

class NDUIBaseItemButton:public NDUINode
{
	DECLARE_CLASS(NDUIBaseItemButton)

public:

	NDUIBaseItemButton();
	virtual ~NDUIBaseItemButton();

	virtual void InitializationItem();
	virtual void SetItemFrameRect(CCRect rect);
	virtual void CloseItemFrame();
	virtual void SetItemBackgroundPicture(NDPicture *pic, NDPicture *touchPic = NULL,
		bool useCustomRect = false, CGRect customRect = CGRectZero, bool clearPicOnFree = false);
	virtual void SetItemBackgroundPictureCustom(NDPicture *pic, NDPicture *touchPic = NULL,
		bool useCustomRect = false, CGRect customRect = CGRectZero);

	virtual void SetItemFocusImage(NDPicture *pic, bool useCustomRect = false, CGRect customRect = CGRectZero, bool clearPicOnFree = false);
	virtual void SetItemFocusImageCustom(NDPicture *pic, bool useCustomRect = false, CGRect customRect = CGRectZero);

	virtual void SetLock(bool bSet);
	virtual bool IsLock();

	virtual void ChangeItem(unsigned int unItemId);
	virtual unsigned int GetItemId();

	virtual void ChangeItemType(unsigned int unItemType);
	virtual unsigned int GetItemType();

	virtual void RefreshItemCount();
	virtual unsigned int GetItemCount();

	virtual void SetShowAdapt(bool bShowAdapt);
	virtual bool IsShowAdapt();

protected:
private:
};

NS_NDENGINE_END

#endif