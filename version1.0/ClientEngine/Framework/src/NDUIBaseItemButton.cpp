#include "NDUIBaseItemButton.h"

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDUIBaseItemButton, NDUINode)

NDUIBaseItemButton::NDUIBaseItemButton()
{

}

NDUIBaseItemButton::~NDUIBaseItemButton()
{

}

void NDUIBaseItemButton::SetLock(bool bSet)
{

}

bool NDUIBaseItemButton::IsLock()
{
	return false;
}

void NDUIBaseItemButton::ChangeItem(unsigned int unItemId)
{

}

unsigned int NDUIBaseItemButton::GetItemId()
{
	return 0;
}

void NDUIBaseItemButton::ChangeItemType(unsigned int unItemType)
{

}

unsigned int NDUIBaseItemButton::GetItemType()
{
	return 0;
}

void NDUIBaseItemButton::RefreshItemCount()
{

}

unsigned int NDUIBaseItemButton::GetItemCount()
{
	return 0;
}

void NDUIBaseItemButton::SetShowAdapt(bool bShowAdapt)
{

}

bool NDUIBaseItemButton::IsShowAdapt()
{
	return true;
}

void NDUIBaseItemButton::SetItemBackgroundPicture(NDPicture *pic,
												  NDPicture *touchPic /*= NULL*/, bool useCustomRect /*= false*/,
												  CCRect customRect /*= CCRectZero*/, bool clearPicOnFree /*= false*/)
{

}

void NDUIBaseItemButton::SetItemBackgroundPictureCustom(NDPicture *pic,
														NDPicture *touchPic /*= NULL*/, bool useCustomRect /*= false*/,
														CCRect customRect /*= CCRectZero*/)
{

}

void NDUIBaseItemButton::SetItemTouchDownImage(NDPicture *pic,
										   bool useCustomRect /*= false*/, CCRect customRect /*= CCRectZero*/,
										   bool clearPicOnFree /*= false*/)
{

}

void NDUIBaseItemButton::SetItemTouchDownImageCustom(NDPicture *pic,
												 bool useCustomRect /*= false*/, CCRect customRect /*= CCRectZero*/)
{

}

void NDUIBaseItemButton::SetItemFocusImage(NDPicture *pic,
										   bool useCustomRect /*= false*/, CCRect customRect /*= CCRectZero*/,
										   bool clearPicOnFree /*= false*/)
{

}

void NDUIBaseItemButton::SetItemFocusImageCustom(NDPicture *pic,
												 bool useCustomRect /*= false*/, CCRect customRect /*= CCRectZero*/)
{

}

void NDUIBaseItemButton::InitializationItem()
{

}

void NDUIBaseItemButton::SetItemFrameRect(CCRect rect)
{

}

void NDUIBaseItemButton::CloseItemFrame()
{

}

NS_NDENGINE_END