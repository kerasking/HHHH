/*
*
*/

#ifndef NDUTIL_H
#define NDUTIL_H

#include "define.h"
#include "CCGeometry.h"
#include "NDObject.h"
#include "BaseType.h"

NS_NDENGINE_BGN

bool IsPointInside(cocos2d::CCPoint kPoint, cocos2d::CCRect kRect);

class NDUtil:public NDObject
{
	DECLARE_CLASS(NDUtil)

	STRING_VEC ErgodicFolderForSpceialFileExtName(const char* pszPath,
		const char* pszExtFilename);

public:

	NDUtil();
	virtual ~NDUtil();

protected:
private:
};

//const char* GetSMImgPath(const char* name);


NS_NDENGINE_END

#endif