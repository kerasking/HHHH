#include "NDUtil.h"

NS_NDENGINE_BGN

bool IsPointInside(CGPoint kPoint, CGRect kRect)
{
	return (kPoint.x >= kRect.origin.x && kPoint.y >= kRect.origin.y
		&& kPoint.x <= kRect.size.width + kRect.origin.x
		&& kPoint.y <= kRect.size.height + kRect.origin.y);
}

NS_NDENGINE_END