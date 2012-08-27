//
//  JavaMethod.m
//  cocotest
//
//  Created by xiezhenghai on 10-11-24.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#include "JavaMethod.h"
#include "Utility.h"

int FileOp::readByte(FILE* f)
{
	if (!f)
	{
		NDAsssert(0);
		return 0;
	}

	size_t size = sizeof(unsigned char);
	unsigned char ucData = 0;
	size_t read = fread(&ucData, 1, size, f);
	if (size != read)
	{
		NDAsssert(0);
		return 0;
	}
	return ucData;
}

int FileOp::readShort(FILE* f)
{
	if (!f)
	{
		NDAsssert(0);
		return 0;
	}

	size_t size = sizeof(unsigned short);
	unsigned short usData = 0;
	unsigned char shortBuf[2] = {0x00};
	size_t read = fread(&shortBuf, 1, size, f);
	if (size != read)
	{
		NDAsssert(0);
		return 0;
	}
	usData = ((unsigned short)shortBuf[0] << 8) + shortBuf[1];
	return usData;
}

int FileOp::readInt(FILE* f)
{
	if (!f)
	{
		NDAsssert(0);
		return 0;
	}

	size_t size = sizeof(unsigned int);
	unsigned int unData = 0;
	unsigned char intBuf[4] = {0x00};
	size_t read = fread(&intBuf, 1, size, f);
	if (size != read)
	{
		NDAsssert(0);
		return 0;
	}
	unData = ((unsigned int)intBuf[0] << 24) +
			((unsigned int)intBuf[1] << 16) +
			((unsigned int)intBuf[2] << 8) +
			((unsigned int)intBuf[3]);
	return unData;
}

std::string FileOp::readUTF8String(FILE* f)
{
	if (!f)
	{
		NDAsssert(0);
		return "";
	}

	unsigned char ucHight	= this->readByte(f);
	unsigned char ucLow		= this->readByte(f);
	
	size_t strlen = (unsigned int)(ucHight << 8) + ucLow;
	if (strlen == 0)
	{
		return "";
	}

	unsigned char pszTemp[4096] = {0};
	size_t read = fread(&pszTemp, 1, strlen, f);
	if (read != strlen)
	{
		NDAsssert(0);
		return "";
	}

	return (char*)&pszTemp;
}

std::string FileOp::readUTF8StringNoExcept(FILE* f)
{
	if (!f)
	{
		return "";
	}

	unsigned char ucHight	= this->readByte(f);
	unsigned char ucLow		= this->readByte(f);

	size_t strlen = (unsigned int)(ucHight << 8) + ucLow;
	if (strlen == 0)
	{
		return "";
	}

	unsigned char tmp[4096] = {0};
	size_t read = fread(&tmp, 1, strlen, f);
	if (read != strlen)
	{
		return "";
	}

	return (char*)&tmp;
}
