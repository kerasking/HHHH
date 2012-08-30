/**
 *
 */

#ifndef IMAGENUMBER_H
#define IMAGENUMBER_H

#include <cocos2d.h>
#include "./platform.h"

using namespace cocos2d;

class ImageNumber
{
public:

	ImageNumber();
	virtual ~ImageNumber();

	void SetTitleRedNumber(unsigned int number, unsigned int interval = 0);
	void SetTitleRedTwoNumber(unsigned int number1, unsigned int number2,
			unsigned int interval = 0);

	void SetBigRedNumber(int number, bool bWithSign = false);
	void SetBigRedTwoNumber(int number1, int number2);

	void SetBigGreenNumber(int number, bool bWithSign = false);
	void SetSmallWhiteNumber(int number, bool bWithSign = false);
	void SetSmallRedNumber(int number, bool bWithSign = false);
	void SetSmallRedTwoNumber(uint num1, uint num2);
	void SetSmallGoldNumber(int num);

	void Initialization();
	cocos2d::CCSize GetNumberSize();

protected:
private:
};

#endif
