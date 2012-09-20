// ConverToMK.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include "ConverToMK.h"

int main(int argc, char** argv)
{
	CConverToMK* pkMK = CConverToMK::initWithIniFile("ConverToMKConfig.ini");

	return 0;
}