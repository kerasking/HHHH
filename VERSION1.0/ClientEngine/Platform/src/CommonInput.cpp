#include "CommonInput.h"

NS_NDENGINE_BGN

IMPLEMENT_CLASS(IPlatformInput,NDObject)

IPlatformInput::IPlatformInput()
{

}

IPlatformInput::~IPlatformInput()
{

}

void IPlatformInput::Init()
{

}

void IPlatformInput::Show()
{

}


CInputBase::CInputBase()
{

}

CInputBase::~CInputBase()
{

}

bool CInputBase::OnInputReturn( CInputBase* base )
{
	return true;
}

void CInputBase::OnInputFinish( CInputBase* base )
{

}

bool CInputBase::OnInputTextChange( CInputBase* base, const char* inputString )
{
	return true;
}

NS_NDENGINE_END