#include "NDBaseGlobalDialog.h"

NS_NDENGINE_BGN
IMPLEMENT_CLASS(NDBaseGlobalDialog,NDObject)

NDBaseGlobalDialog::NDBaseGlobalDialog()
{

}

NDBaseGlobalDialog::~NDBaseGlobalDialog()
{

}

unsigned int NDBaseGlobalDialog::Show( NDEngine::NDObject* delegate, const char* title, const char* text, uint timeout, const char* ortherButtons, .../*must NULL end*/ )
{
	return 0;
}

unsigned int NDBaseGlobalDialog::Show( NDEngine::NDObject* delegate, const char* title, const char* text, uint timeout, const std::vector<std::string>& ortherButtons )
{
	return 0;
}

unsigned int NDBaseGlobalDialog::Show( NDEngine::NDObject* delegate, const char* title, const char* text, uint timeout, const std::vector<GlobalDialogBtnContent>& ortherButtons )
{
	return 0;
}

unsigned int NDBaseGlobalDialog::GetID()
{
	return 0;
}

void NDBaseGlobalDialog::ReturnID( unsigned int uiID )
{

}

void NDBaseGlobalDialog::reset()
{

}

NS_NDENGINE_END