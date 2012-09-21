// ConverToMK.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include "ConverToMK.h"
#include <iostream>

using namespace std;

int main(int argc, char** argv)
{
	options_description kOptions("Tool Options");
	CConverToMK* pkMK = CConverToMK::initWithIniFile("ConvertToMKConfig.xml");

	kOptions.add_options()("help","这是帮助文档")("XX","XXXX");
	variables_map kVM;
	store(parse_command_line(argc,argv,kOptions),kVM);

	if (kVM.count("help"))
	{
		CConverToMK::StringVector kHelpStringSet;

		kHelpStringSet = pkMK->GetHelpComment();

		for (unsigned int uiIndex = 0;uiIndex < kHelpStringSet.size();uiIndex++)
		{
			cout << kHelpStringSet[uiIndex] << endl;
		}

		cout << "以下为参数功能" << endl;
		cout << kOptions << endl;
		return 0;
	}

	pkMK->WriteToMKFile();

	getchar();

	return 0;
}