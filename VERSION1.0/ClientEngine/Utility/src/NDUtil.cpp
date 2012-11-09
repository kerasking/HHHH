#include "NDUtil.h"

NS_NDENGINE_BGN

bool IsPointInside(CGPoint kPoint, CGRect kRect)
{
	return (kPoint.x >= kRect.origin.x && kPoint.y >= kRect.origin.y
		&& kPoint.x <= kRect.size.width + kRect.origin.x
		&& kPoint.y <= kRect.size.height + kRect.origin.y);
}

const char* GetSMImgPath( const char* name )
{
	if (!name)
	{
		return "";
	}

	std::string str = "Res00/";
	str += name;

	return NDPath::GetImgPath(str.c_str()).c_str();
}

NS_NDENGINE_END